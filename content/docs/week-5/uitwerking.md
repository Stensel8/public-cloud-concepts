---
title: "Uitwerking"
weight: 2
---

GKE **Standard** cluster opgezet met een moderne monitoring stack: Loki (SingleBinary), Grafana Alloy en Prometheus via `kube-prometheus-stack`.

{{< callout type="warning" >}}
**Afwijkingen t.o.v. het aangeleverde schoolmateriaal**

Het originele script van de docent gebruikt drie deprecated Helm charts. Deze zijn vervangen:

| Schoolscript | Verbeterd | Reden |
|---|---|---|
| `grafana/loki-distributed` | `grafana/loki` (SingleBinary) | `loki-distributed` is deprecated |
| `grafana/promtail` | `grafana/alloy` | `promtail` is deprecated |
| losse `grafana/grafana` release | gebundeld in `kube-prometheus-stack` | standalone chart is deprecated |
| `storageClass: managed-csi` | `standard-rwo` | Azure-specifiek, werkt niet op GKE |

De originele bestanden staan in [`Week 5/Opdracht/Bestanden/`](https://github.com/Stensel8/public-cloud-concepts/tree/main/Week%205/Opdracht/Bestanden). De verbeterde versie staat in [`Week 5/Uitwerking/Bestanden/`](https://github.com/Stensel8/public-cloud-concepts/tree/main/Week%205/Uitwerking/Bestanden).
{{< /callout >}}

**Gebruikte charts:**

| Component | Namespace | Chart |
|-----------|-----------|-------|
| Loki | `loki` | `grafana/loki` (SingleBinary) |
| Log collector | `alloy` | `grafana/alloy` |
| Prometheus + Grafana | `prometheus` | `prometheus-community/kube-prometheus-stack` |
| Ingress | `ingress-nginx` | `ingress-nginx/ingress-nginx` |

**Bronnen:**

| Onderwerp | Bron |
|---|---|
| Loki monolithic (SingleBinary) | [grafana.com/docs/…/install-monolithic/](https://grafana.com/docs/enterprise-logs/latest/setup/install/helm/install-monolithic/) |
| Loki schema configuratie | [grafana.com/docs/loki/latest/operations/storage/schema/](https://grafana.com/docs/loki/latest/operations/storage/schema/) |
| Alloy configureren op Kubernetes | [grafana.com/docs/alloy/latest/configure/kubernetes/](https://grafana.com/docs/alloy/latest/configure/kubernetes/) |
| Alloy voorbeeldscenario's | [github.com/grafana/alloy-scenarios](https://github.com/grafana/alloy-scenarios) |

---

## Stap 1: Kubernetes cluster aanmaken

{{< callout type="info" >}}
**Waarom Standard en niet Autopilot?**

Autopilot beperkt DaemonSets, blokkeert privileged containers standaard en vereist resource requests voor elke pod. Dit conflicteert direct met de monitoring stack:

- **Alloy** draait als DaemonSet met toegang tot `/var/log/pods` op de host
- **Prometheus node-exporter** heeft privileged toegang nodig tot host-metrics
- **ingress-nginx** vereist poortconfiguratie die Autopilot niet altijd toestaat

Standard geeft volledige controle over node-configuratie, DaemonSets en privileged workloads.
{{< /callout >}}

{{< tabs items="Linux / macOS,Windows (PowerShell)" >}}
{{< tab >}}
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
{{< /tab >}}
{{< tab >}}
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
{{< /tab >}}
{{< /tabs >}}

| Vlag | Waarde | Toelichting |
|------|--------|-------------|
| `--region` | `europe-west4` | Regio dichtstbij Nederland |
| `--machine-type` | `e2-small` | 2 vCPU, 2GB RAM |
| `--num-nodes` | `2` | 2 nodes per zone × 3 zones = 6 nodes totaal |
| `--disk-size` | `50` | 6 × 50GB = 300GB SSD, past binnen het quota van 500GB |
| `--disk-type` | `pd-balanced` | SSD (balanced), betere I/O voor Prometheus TSDB writes |
| `--release-channel` | `regular` | Stabiele GKE-versies met automatische upgrades |
| `--cluster-version` | `1.35.1-gke.1396001` | Gepinde initiële versie voor reproduceerbaarheid |

{{< callout type="warning" >}}
**Studentquota:** De standaard GKE-instellingen (`pd-balanced`, 100GB per node) zouden 6 × 100GB = **600GB SSD** vereisen, wat boven het quota van 500GB uitkomt. Met `--disk-size=50` past alles: 6 × 50GB = 300GB SSD.
{{< /callout >}}

Na het installeren van de auth plugin:

```bash
gcloud components install gke-gcloud-auth-plugin
```

<video controls width="100%" style="max-width:800px">
  <source src="../media/Cluster-create-week5.webm" type="video/webm">
</video>

![Cluster aanmaken via gcloud CLI](../media/stap1-cluster-aanmaken.avif)

![GKE cluster wordt aangemaakt in de GCP Console](../media/stap1-cluster-provisioning.avif)

![Cluster succesvol aangemaakt met status RUNNING](../media/stap1-cluster-gereed.avif)

![GKE console: Standard modus, 6 nodes, versie 1.35.1-gke.1396001, Regular release channel](../media/stap1-cluster-details.avif)

---

## Stap 2: Verbinding maken met het cluster

```bash
gcloud container clusters get-credentials week5-cluster \
  --region=europe-west4 \
  --project=project-5b8c5498-4fe2-42b9-bc3
```

![get-credentials en kubectl get nodes tonen 6 Ready nodes](../media/stap3-cluster-verbinding.avif)

---

## Stap 3: Stack deployen

```bash
cd "Week 5/Uitwerking/Bestanden"
bash setup-loki-prometheus-grafana.sh
```

<video controls width="100%" style="max-width:800px">
  <source src="../media/Grafana-create-week5.webm" type="video/webm">
</video>

![Script uitvoeren: Helm repos toevoegen en stack installeren](../media/stap3-script-uitvoeren.avif)

Het script installeert de stack in vijf stappen: Helm repos toevoegen, ingress-nginx (met `kubectl wait`), Loki, Alloy, Prometheus + Grafana.

**Waarom ingress-nginx als eerste?**
De `kube-prometheus-stack` maakt bij installatie direct een Grafana Ingress-object aan. De admission webhook van ingress-nginx valideert dat object — als ingress-nginx nog niet draait, mislukt de Helm-installatie met een webhook-fout. Door ingress-nginx eerst te installeren en te wachten tot de controller `Ready` is, wordt dit voorkomen.

### `loki-values.yaml`

De `grafana/loki` chart vereist een expliciete `schemaConfig` — zonder dit geeft Helm een harde fout:

```
Error: You must provide a schema_config for Loki.
```

Op basis van de [officiële Loki schema docs](https://grafana.com/docs/loki/latest/operations/storage/schema/):

```yaml
deploymentMode: SingleBinary
loki:
  auth_enabled: false
  commonConfig:
    replication_factor: 1
  storage:
    type: filesystem
  schemaConfig:
    configs:
      - from: "2024-04-01"
        store: tsdb
        object_store: filesystem
        schema: v13
        index:
          prefix: loki_index_
          period: 24h
  pattern_ingester:
    enabled: true
  limits_config:
    allow_structured_metadata: true
    volume_enabled: true
    retention_period: 336h
  ruler:
    enable_api: true
singleBinary:
  replicas: 1
  persistence:
    storageClass: standard-rwo
    size: 5Gi
minio:
  enabled: false
```

- `storageClass: standard-rwo` — GKE-compatibel (schoolscript gebruikte `managed-csi`, wat Azure-specifiek is)
- Alle gedistribueerde componenten expliciet op `replicas: 0` — vereist door de chart
- `minio.enabled: false` — niet nodig bij filesystem storage

### `alloy-values.yaml`

Alloy vervangt Promtail en gebruikt de Alloy flow language. De config doet hetzelfde als Promtail, maar declaratief:

1. Kubernetes pods ontdekken (`discovery.kubernetes`)
2. Labels toevoegen op basis van pod-metadata (`discovery.relabel`)
3. Logs lezen van de pods (`loki.source.kubernetes`)
4. Logs doorsturen naar Loki (`loki.write`)

De `grafana/loki` chart zet standaard een nginx gateway voor de Loki pod. Alle Loki-URLs gaan via die gateway:

```
# Alloy naar Loki (push)
http://loki-gateway.loki.svc.cluster.local/loki/api/v1/push

# Grafana datasource
http://loki-gateway.loki.svc.cluster.local
```

> **Twee geldige aanpakken:** De officiële Grafana tutorial gebruikt de `grafana/k8s-monitoring` chart (kant-en-klare bundel). Voor meer inzicht in wat er onder de motorkap gebeurt is gekozen voor de standalone `grafana/alloy` chart.

### `prometheus-values.yaml`

Grafana is ingebouwd in `kube-prometheus-stack` (`grafana.enabled: true`). Dit elimineert de behoefte aan een losse `grafana/grafana` release. Prometheus is ingesteld op 1 replica — de monitoring stack is RAM-intensief en de `e2-small` nodes (2GB) zouden anders te zwaar belast worden.

---

## Stap 4: IP-adres ophalen

```bash
kubectl get ingress -n prometheus
```

![kubectl get ingress toont het externe IP-adres voor grafana.stijhuis.nl](../media/stap4-ingress-ip.avif)

![Ingress status met adres en hostnaam](../media/stap4-ingress-status.avif)

---

## Stap 5: DNS instellen

Het externe IP is als A-record ingesteld bij Bunny DNS voor `grafana.stijhuis.nl` — in plaats van het `hosts`-bestand handmatig aan te passen. Een DNS-record werkt direct op alle apparaten wereldwijd, zonder lokale configuratie.

![Grafana values aangepast met de hostnaam](../media/stap5-grafana-values-aangepast.avif)

![DNS record aanmaken in Bunny DNS](../media/stap5-dns-record-aanmaken.avif)

![Overzicht DNS records in Bunny DNS](../media/stap5-dns-overzicht.avif)

---

## Stap 6: Grafana openen

Via `https://grafana.stijhuis.nl` in de browser:

![Grafana 404 bij eerste bezoek — DNS nog niet gepropageerd](../media/stap6-grafana-404.avif)

![Grafana login pagina bereikbaar](../media/stap6-grafana-login.avif)

Na het inloggen zijn de twee databronnen actief: **Loki** en **Prometheus**. Via **Connections > Data sources** en dan **Test** op elke bron is de verbinding te controleren.

---

## Stap 7: Dashboards instellen

Als basis voor Kubernetes monitoring is het community dashboard [k8s-custom-metrics (ID 20960)](https://grafana.com/grafana/dashboards/20960-k8s-custom-metrics/) gebruikt (versie 3).

Dashboard geïmporteerd via **Dashboards > Import** met ID `20960`, Prometheus als datasource:

![Dashboard template selecteren bij importeren](../media/stap10-dashboard-template.avif)

![Dashboard importeren in Grafana met Prometheus als datasource](../media/stap10-dashboard-import.avif)

![Kubernetes application insights dashboard actief — cluster CPU 70%, RAM 63%](../media/stap10-dashboard-resultaat.avif)

---

## Stap 8: Architectuurdiagram

<!-- Voeg architectuurdiagram toe -->

---

## Stap 9: Andere monitoring-tools voor Kubernetes

<!-- Vul in -->
