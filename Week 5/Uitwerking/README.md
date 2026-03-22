# Week 5 - Monitoring & Observability

Voor de opdracht van week 5 heb ik een GKE cluster opgezet met Prometheus, Loki en Grafana. Voor log collection is in Poging 1 Promtail gebruikt en in Poging 2 Grafana Alloy.

Er zijn twee pogingen gedocumenteerd:
- **Poging 1**: het script zoals aangeleverd vanuit school, inclusief de geconstateerde problemen
- **Poging 2**: een verbeterde, gemoderniseerde versie met actuele Helm charts

---

## Stap 1: Kubernetes cluster aanmaken

GKE **Standard** cluster met 2 nodes per zone in `europe-west4`, afgestemd op de studentquota.

> **Waarom Standard en niet Autopilot?**
> GKE biedt twee cluster-modi: **Autopilot** en **Standard**.
>
> Autopilot beheert nodes volledig automatisch en legt beperkingen op aan workloads: DaemonSets worden beperkt uitgevoerd, privileged containers zijn standaard geblokkeerd en resource requests zijn verplicht voor elke pod. Dit conflicteert direct met de monitoring stack in deze opdracht:
>
> - **Alloy** draait als DaemonSet met toegang tot `/var/log/pods` op de host — Autopilot beperkt dit soort host-toegang
> - **Prometheus node-exporter** heeft privileged toegang nodig tot host-metrics
> - **ingress-nginx** vereist een specifieke poortconfiguratie die Autopilot niet altijd toestaat
>
> De opdracht en docent schrijven dan ook expliciet een Standard cluster voor. Standard geeft volledige controle over node-configuratie, DaemonSets en privileged workloads — wat noodzakelijk is voor een monitoring stack die op node-niveau moet kunnen meekijken.

GKE Standard cluster met 2 nodes per zone, afgestemd op de studentquota:

```bash
gcloud container clusters create week5-cluster \
  --region=europe-west4 \
  --project=project-5b8c5498-4fe2-42b9-bc3 \
  --machine-type=e2-small \
  --num-nodes=2 \
  --disk-size=50 \
  --disk-type=pd-balanced \
  --release-channel=regular \
  --cluster-version=1.35.1-gke.1396001
```

<details>
<summary>PowerShell (Windows)</summary>

```powershell
gcloud container clusters create "week5-cluster" `
  --region "europe-west4" `
  --project "project-5b8c5498-4fe2-42b9-bc3" `
  --machine-type "e2-small" `
  --num-nodes "2" `
  --disk-size "50" `
  --disk-type "pd-balanced" `
  --release-channel "regular" `
  --cluster-version "1.35.1-gke.1396001"
```

PowerShell gebruikt de backtick (`` ` ``) als regelvervolg in plaats van `\`.

</details>

| Vlag | Waarde | Toelichting |
|------|--------|-------------|
| `--region` | `europe-west4` | Regio dichtstbij Nederland |
| `--machine-type` | `e2-small` | 2 vCPU, 2GB RAM |
| `--num-nodes` | `2` | 2 nodes per zone (regio heeft 3 zones = 6 nodes totaal) |
| `--disk-size` | `50` | 50GB SSD per node: 6 × 50 = 300GB, past binnen het SSD-quota van 500GB |
| `--disk-type` | `pd-balanced` | SSD (balanced), betere I/O voor Prometheus TSDB writes |
| `--release-channel` | `regular` | Stabiele GKE-versies met automatische upgrades; aanbevolen voor de meeste workloads ([GKE release channels](https://docs.cloud.google.com/kubernetes-engine/docs/concepts/release-channels)) |
| `--cluster-version` | `1.35.1-gke.1396001` | Pinned initiële versie voor reproduceerbaarheid; de release channel beheert daarna automatische upgrades |

> **Studentquota — werkelijke limieten (gemeten):**
>
> | Resource | Quota | Gebruik vóór dit cluster |
> |---|---|---|
> | Persistent Disk SSD (GB) | **500 GB** | 2 GB |
> | Persistent Disk Standard (GB) | **4,096 GB** | 64 GB |
>
> De standaard GKE-instellingen (`pd-balanced`, 100GB per node) zouden 6 × 100GB = **600GB SSD** vereisen, wat boven het SSD-quota van 500GB uitkomt. Door `--disk-size=50` te gebruiken met `pd-balanced` past alles ruim: 6 × 50GB = 300GB SSD.

> **Waarom `e2-small` met de monitoring stack?**
> De monitoring stack (Loki, Alloy, Prometheus, Grafana) is RAM-intensief. Prometheus kan per replica 400–600MB gebruiken. Om te voorkomen dat dit de e2-small-nodes (2GB RAM) overbelast, is in `prometheus-values.yaml` gekozen voor **1 Prometheus-replica** in plaats van 2. Met 6 nodes in totaal is één replica ruim voldoende voor een demo-omgeving.

![Cluster aanmaken via gcloud CLI](media/stap1-cluster-aanmaken.avif)

Na het uitvoeren van het commando is het cluster zichtbaar in de Google Cloud Console. Het cluster wordt aangemaakt in de **Standard**-modus (niet Autopilot — zie toelichting hierboven):

![GKE cluster wordt aangemaakt in de GCP Console](media/stap1-cluster-provisioning.avif)

Na ongeveer 6 minuten is het cluster gereed met status `RUNNING` en 6 nodes (2 per zone):

![Cluster succesvol aangemaakt met status RUNNING](media/stap1-cluster-gereed.avif)

---

## Stap 2: Verbinding maken met het cluster

```bash
gcloud container clusters get-credentials week5-cluster \
  --region=europe-west4 \
  --project=project-5b8c5498-4fe2-42b9-bc3
```

Na het uitvoeren wordt de kubeconfig automatisch bijgewerkt. Met `kubectl get nodes` zijn alle 6 nodes zichtbaar met status `Ready`:

![get-credentials en kubectl get nodes tonen 6 Ready nodes](media/stap3-cluster-verbinding.avif)

---

## Poging 1: Schoolscript (as-is)

### Script en values.yaml bestuderen

Het script `setup-loki-prometheus-grafana` installeert vier componenten via Helm:

| Component  | Namespace    | Chart                                        |
|------------|--------------|----------------------------------------------|
| Loki       | `loki`       | `grafana/loki-distributed`                   |
| Promtail   | `promtail`   | `grafana/promtail`                           |
| Prometheus | `prometheus` | `prometheus-community/kube-prometheus-stack` |
| Grafana    | `grafana`    | `grafana/grafana`                            |

Relevante instellingen uit de values-bestanden:

- **Grafana** gebruikersnaam: `saxion`, wachtwoord: `DLLrE5xxKyInitgYX23ppyfP`
- **Grafana** intern bereikbaar via `grafana.grafana.svc.cluster.local`, extern via `grafana.project.intern`
- **Loki** querier URL (voor Grafana datasource): `http://loki-loki-distributed-querier.loki:3100`
- **Prometheus** URL (voor Grafana datasource): `http://prometheus-kube-prometheus-prometheus.prometheus:9090`

### Script uitvoeren

```bash
cd "Week 5/Opdracht/Bestanden"
bash setup-loki-prometheus-grafana
```

[▶ Bekijk screencast van de installatie](media/stap3-script-uitvoeren.avif)

<details>
<summary>Volledige output van het script</summary>

```
"loki" has been added to your repositories
...Successfully got an update from the "loki" chart repository
Release "loki" does not exist. Installing it now.
level=WARN msg="this chart is deprecated"
NAME: loki
LAST DEPLOYED: Tue Mar 17 22:29:12 2026
NAMESPACE: loki
STATUS: deployed
REVISION: 1

Installed components:
* gateway
* ingester
* distributor
* querier
* query-frontend
* compactor

Release "promtail" does not exist. Installing it now.
level=WARN msg="this chart is deprecated"
NAME: promtail
LAST DEPLOYED: Tue Mar 17 22:29:23 2026
NAMESPACE: promtail
STATUS: deployed
REVISION: 1

Release "prometheus" does not exist. Installing it now.
NAME: prometheus
LAST DEPLOYED: Tue Mar 17 22:29:41 2026
NAMESPACE: prometheus
STATUS: deployed
REVISION: 1

Release "grafana" does not exist. Installing it now.
level=WARN msg="this chart is deprecated"
NAME: grafana
LAST DEPLOYED: Tue Mar 17 22:30:19 2026
NAMESPACE: grafana
STATUS: deployed
REVISION: 1

namespace/ingress-nginx created
...
deployment.apps/ingress-nginx-controller created
ingressclass.networking.k8s.io/nginx created
```

</details>

### Geconstateerde problemen

Bij het uitvoeren van het schoolscript zijn de volgende waarschuwingen en problemen geconstateerd:

| Component | Probleem |
|-----------|----------|
| `loki-distributed` | Chart is **deprecated**, Grafana raadt `loki` (SingleBinary/SimpleScalable) aan |
| `promtail` | Chart is **deprecated**, vervangen door **Grafana Alloy** |
| `grafana/grafana` | Chart geeft **deprecated** waarschuwing |
| `storageClass: managed-csi` | Azure-specifieke storage class die niet bestaat op GKE, aangepast naar `standard-rwo` |

Deze problemen zijn opgelost in Poging 2.

### Ingress-controller controleren

```bash
kubectl get pods --namespace ingress-nginx
```

De ingress-controller draait. Tegelijk is het externe IP-adres van de Grafana ingress op te zoeken:

```bash
kubectl get ingress -n grafana
```

![ingress-nginx Running en Grafana ingress met extern IP 34.141.226.132](media/stap4-ingress-status.avif)

Het externe IP-adres is `34.141.226.132`.

### Ingress aanmaken voor Grafana

De ingress wordt automatisch aangemaakt via de Helm-installatie (`grafana-values.yaml`). De volledige configuratie:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: grafana
  annotations:
    kubernetes.io/ingress.class: ingress-nginx
spec:
  ingressClassName: nginx
  rules:
    - host: grafana.project.intern
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: grafana
                port:
                  number: 80
```

### IP-adres opzoeken en DNS instellen

Het externe IP is `34.141.226.132` (zichtbaar in de ingress-output hierboven).

De opdracht schrijft voor om het hosts-bestand handmatig aan te passen. Dat is een lokale, niet-schaalbare oplossing die per apparaat herhaald moet worden. In plaats daarvan heb ik een A-record aangemaakt bij Bunny DNS voor `grafana.stijhuis.nl`:

![A-record aanmaken in Bunny DNS voor grafana.stijhuis.nl](media/stap5-dns-record-aanmaken.avif)

![DNS-overzicht stijhuis.nl met grafana A-record actief](media/stap5-dns-overzicht.avif)

> **Waarom geen hosts-bestand?**
> Het handmatig aanpassen van het hosts-bestand is een noodoplossing voor lokale ontwikkeling. Het werkt alleen op het apparaat waar de aanpassing is gedaan, is niet schaalbaar, en vereist beheerdersrechten. Een DNS-record is de correcte productie-aanpak: het werkt direct op alle apparaten wereldwijd, zonder lokale configuratie.

De `grafana-values.yaml` is aangepast zodat de ingress-hostname overeenkomt met het DNS-record:

![grafana-values.yaml met grafana.stijhuis.nl als hostname](media/stap5-grafana-values-aangepast.avif)

Daarna de Helm-release updaten zodat de nieuwe hostname actief wordt:

```bash
cd "Week 5/Opdracht/Bestanden"
helm upgrade --namespace grafana --values grafana-values.yaml grafana grafana/grafana
```

### Grafana openen en databronnen controleren

Na de DNS-aanpassing was Grafana nog niet bereikbaar, want de ingress verwees nog naar de oude hostname `grafana.project.intern`. De `grafana-values.yaml` was al lokaal aangepast maar nog niet naar het cluster gepusht:

![grafana.stijhuis.nl geeft 404 omdat de Helm upgrade nog niet uitgevoerd was](media/stap6-grafana-404.avif)

Na het uitvoeren van de Helm upgrade was Grafana direct bereikbaar via `http://grafana.stijhuis.nl`:

![Grafana loginpagina bereikbaar via grafana.stijhuis.nl](media/stap6-grafana-login.avif)

Inloggen met gebruikersnaam `saxion`.

---

## Poging 2: Gemoderniseerde opzet

Bij Poging 1 gaf Helm drie `level=WARN msg="this chart is deprecated"` waarschuwingen. In Poging 2 zijn alle deprecated charts vervangen door hun actuele opvolgers en is de bijbehorende configuratie aangepast. Tijdens het uitvoeren van Poging 2 bleek ook dat de nieuwe `grafana/loki` chart een verplichte `schemaConfig` vereist die in Poging 1 niet nodig was — dit is gedocumenteerd onder [loki-values.yaml](#loki-valuesyaml-1).

### Bronnen

| Onderwerp | Bron |
|---|---|
| Helm installatie | [helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/) |
| Loki monolithic (SingleBinary) installatie | [grafana.com/docs/enterprise-logs/latest/setup/install/helm/install-monolithic/](https://grafana.com/docs/enterprise-logs/latest/setup/install/helm/install-monolithic/) |
| Loki schema configuratie | [grafana.com/docs/loki/latest/operations/storage/schema/](https://grafana.com/docs/loki/latest/operations/storage/schema/) |
| Alloy Kubernetes pod logs (aanbevolen aanpak met k8s-monitoring) | [grafana.com/docs/alloy/latest/monitor/monitor-kubernetes-logs/](https://grafana.com/docs/alloy/latest/monitor/monitor-kubernetes-logs/) |
| Alloy configureren op Kubernetes (standalone chart) | [grafana.com/docs/alloy/latest/configure/kubernetes/](https://grafana.com/docs/alloy/latest/configure/kubernetes/) |
| Alloy voorbeeldscenario's | [github.com/grafana/alloy-scenarios](https://github.com/grafana/alloy-scenarios) |

### Overzicht wijzigingen

| | Poging 1 | Poging 2 | Reden |
|---|---|---|---|
| Loki chart | `grafana/loki-distributed` | `grafana/loki` (SingleBinary) | `loki-distributed` is deprecated |
| Log collector | `grafana/promtail` | `grafana/alloy` | `promtail` is deprecated |
| Grafana | losse `grafana/grafana` release | gebundeld in `kube-prometheus-stack` | `grafana/grafana` standalone chart is deprecated |
| Loki datasource URL | `loki-loki-distributed-querier.loki:3100` | `loki-gateway.loki.svc.cluster.local` | Nieuwe chart gebruikt nginx gateway |
| Config-formaat log collector | YAML (`config.clients`) | Alloy flow language | Alloy gebruikt eigen River/Alloy syntax |
| Prometheus | `prometheus-community/kube-prometheus-stack` | `prometheus-community/kube-prometheus-stack` | Ongewijzigd |

### Gewijzigde bestanden

De bestanden voor Poging 2 staan in [`Bestanden/`](Bestanden/).

#### `setup-loki-prometheus-grafana.sh`

Drie wijzigingen ten opzichte van het schoolscript:

- `loki/loki-distributed` → `grafana/loki` (SingleBinary)
- `grafana/promtail` → `grafana/alloy` (in namespace `alloy`)
- Losse `grafana/grafana` release vervalt — Grafana is nu gebundeld in de `kube-prometheus-stack`
- **ingress-nginx staat nu als eerste stap**, vóór Prometheus/Grafana — de Grafana ingress triggert anders de admission webhook van ingress-nginx voordat die beschikbaar is

#### `loki-values.yaml`

De `loki-distributed` chart werkte met meerdere losse componenten (ingester, distributor, querier, query-frontend, compactor, gateway). De nieuwe `grafana/loki` chart ondersteunt een **SingleBinary**-modus waarbij alles in één pod draait — geschikt voor een demo-omgeving.

Bij het uitvoeren van de eerste versie van Poging 2 gaf Helm de volgende foutmelding:

```
Error: execution error at (loki/templates/validate.yaml:40:4): You must provide a
schema_config for Loki, one is not provided as this will be individual for every Loki
cluster. See https://grafana.com/docs/loki/latest/operations/storage/schema/ for schema
information.
```

De nieuwe `grafana/loki` chart vereist een expliciete `schemaConfig`, terwijl `loki-distributed` dit automatisch invulde. Op basis van de [officiële Loki schema docs](https://grafana.com/docs/loki/latest/operations/storage/schema/) en de [monolithic installatie docs](https://grafana.com/docs/loki/latest/setup/install/helm/install-monolithic/) is de volgende configuratie toegevoegd:

```yaml
schemaConfig:
  configs:
    - from: "2024-04-01"
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: loki_index_
        period: 24h
```

Overige wijzigingen ten opzichte van de `loki-distributed` config, op basis van de [officiële monolithic install docs](https://grafana.com/docs/enterprise-logs/latest/setup/install/helm/install-monolithic/):

- `deploymentMode: SingleBinary` toegevoegd
- `singleBinary.replicas: 1` met resource requests
- `singleBinary.persistence.storageClass: standard-rwo` (GKE-compatibel, in plaats van `managed-csi` dat Azure-specifiek is)
- `pattern_ingester.enabled: true`, `limits_config.allow_structured_metadata: true` en `ruler.enable_api: true` (vereist door nieuwe chart versie)
- Alle gedistribueerde componenten expliciet op `replicas: 0` (vereist door de chart om conflicten te voorkomen)
- `minio.enabled: false` (niet nodig bij filesystem storage — MinIO is alleen vereist bij S3-gebaseerde opslag voor HA-setups)

#### `promtail-values.yaml` → `alloy-values.yaml`

Promtail werd geconfigureerd via YAML met een `config.clients[].url`. Alloy gebruikt een eigen declaratieve taal (Alloy flow language).

> **Twee geldige aanpakken:** De officiële Grafana tutorial voor Kubernetes log monitoring ([monitor-kubernetes-logs](https://grafana.com/docs/alloy/latest/monitor/monitor-kubernetes-logs/)) gebruikt de `grafana/k8s-monitoring` chart — een kant-en-klare bundel die Alloy intern inzet. Voor meer controle en transparantie is het ook volledig ondersteund om de standalone `grafana/alloy` chart te gebruiken met een zelf geschreven config, zoals beschreven in de [configure/kubernetes docs](https://grafana.com/docs/alloy/latest/configure/kubernetes/). Gezien de leerdoelstelling — begrijpen wat er onder de motorkap gebeurt — is gekozen voor de standalone aanpak.

Op basis van de [officiële Alloy docs](https://grafana.com/docs/alloy/latest/configure/kubernetes/) (Method 1: embed in `values.yaml`) doet de nieuwe config hetzelfde als Promtail:

1. Kubernetes pods ontdekken (`discovery.kubernetes`)
2. Labels toevoegen op basis van pod-metadata (`discovery.relabel`)
3. Logs lezen van de pods (`loki.source.kubernetes`)
4. Logs doorsturen naar Loki (`loki.write`)

#### `grafana-values.yaml` en `alloy-values.yaml` — Loki gateway URL

De nieuwe `grafana/loki` chart zet standaard een **nginx gateway** voor de Loki pod. Dit bleek pas bij het daadwerkelijk uitvoeren van het script: de Helm-installatie output meldde expliciet:

```
Loki has been configured with a gateway (nginx) to support reads and writes from a single component.

You can send logs from inside the cluster using the cluster DNS:
http://loki-gateway.loki.svc.cluster.local/loki/api/v1/push

If Grafana operates within the cluster, you'll set up a new Loki datasource by utilizing the following URL:
http://loki-gateway.loki.svc.cluster.local/
```

Alle drie de Loki-URL's zijn hierop aangepast:

```
# Poging 1 (loki-distributed, directe querier)
url: http://loki-loki-distributed-querier.loki:3100

# Poging 2 — eerste poging (directe pod, incorrect)
url: http://loki.loki.svc.cluster.local:3100

# Poging 2 — gecorrigeerd (via nginx gateway)
url: http://loki-gateway.loki.svc.cluster.local        ← Grafana datasource
url: http://loki-gateway.loki.svc.cluster.local/loki/api/v1/push  ← Alloy push
```

### Script uitvoeren

```bash
cd "Week 5/Uitwerking/Bestanden"
bash setup-loki-prometheus-grafana.sh
```

![Cluster aanmaken met verbeterd commando (pd-balanced, release-channel, cluster-version)](media/poging2-stap1-cluster-aanmaken.avif)

![GKE console toont week5-cluster: Standard modus, 6 nodes, versie 1.35.1-gke.1396001, Regular release channel](media/poging2-stap1-cluster-details.avif)

### IP-adres ophalen en DNS instellen

Na de installatie is het externe IP van de Grafana ingress op te halen via:

```bash
kubectl get ingress -n prometheus
```

![kubectl get ingress toont IP 34.90.109.80 voor grafana.stijhuis.nl](media/poging2-stap4-ingress-ip.avif)

Het externe IP (`34.90.109.80`) wordt vervolgens als A-record ingesteld bij Bunny DNS voor `grafana.stijhuis.nl`, zoals ook gedaan in Poging 1.

---

## Stap 10: Dashboards instellen

### Dashboard template

Als basis voor de Kubernetes monitoring heb ik het community dashboard [k8s-custom-metrics (ID 20960)](https://grafana.com/grafana/dashboards/20960-k8s-custom-metrics/) gebruikt, versie 3. Dit dashboard geeft een modern overzicht van cluster- en node-resources via Prometheus metrics:

![Grafana dashboard template k8s-custom-metrics als basis voor eigen dashboard](media/stap10-dashboard-template.avif)

Het dashboard is geïmporteerd via **Dashboards > Import** met ID `20960`. Als datasource is Prometheus geselecteerd:

![Dashboard importeren in Grafana met Prometheus als datasource](media/stap10-dashboard-import.avif)

Na het importeren toont het dashboard de cluster- en node-resources op basis van de standaard Prometheus metrics. Cluster CPU en RAM zijn zichtbaar, maar node-level metrics en pod-data tonen deels nog "No data" omdat er nog geen eigen applicatie draait:

![Kubernetes application insights dashboard actief met cluster CPU 70% en RAM 63%](media/stap10-dashboard-resultaat.avif)

> Dit is een basale opzet met standaard metrics op clusterniveau. In Poging 2 wordt een eigen applicatie gemonitord en worden de dashboards verder uitgebreid.

---

## Stap 11: Architectuurdiagram

<!-- Voeg architectuurdiagram toe -->

---

## Stap 12: Andere monitoring-tools voor Kubernetes

<!-- Vul in -->
