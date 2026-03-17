# Week 5 - Monitoring & Observability

Voor de opdracht van week 5 heb ik een GKE cluster opgezet met Prometheus, Loki, Promtail en Grafana.

Er zijn twee pogingen gedocumenteerd:
- **Poging 1** — het script zoals aangeleverd vanuit school, inclusief de geconstateerde problemen
- **Poging 2** — een verbeterde, gemoderniseerde versie met actuele Helm charts

---

## Stap 1 — Kubernetes cluster aanmaken

Standaard GKE cluster met 2 nodes in `europe-west4`:

```bash
gcloud container clusters create week5-cluster \
  --region=europe-west4 \
  --project=project-5b8c5498-4fe2-42b9-bc3 \
  --machine-type=e2-small \
  --num-nodes=2 \
  --disk-size=32 \
  --disk-type=pd-standard
```

| Vlag | Waarde | Toelichting |
|------|--------|-------------|
| `--region` | `europe-west4` | Regio dichtstbij Nederland |
| `--machine-type` | `e2-small` | 2 vCPU, 2GB RAM — één tier onder e2-medium |
| `--num-nodes` | `2` | 2 nodes per zone (regio heeft 3 zones = 6 nodes totaal) |
| `--disk-size` | `32` | 32GB per node — standaard is 100GB, te veel voor studentquota |
| `--disk-type` | `pd-standard` | HDD in plaats van SSD — valt buiten de SSD-quota |

> **Waarom niet de standaard instellingen?**
> Een standaard `gcloud container clusters create` zonder extra vlaggen pakt automatisch:
> - **100GB SSD (`pd-balanced`) per node** — in een regio met 3 zones en 2 nodes per zone zijn dat 6 nodes × 100GB = **600GB SSD**. Het studentproject heeft een SSD-quota van 250GB, waardoor de aanmaak mislukt.
> - **`e2-medium` als machine type** — groter dan nodig voor deze opdracht.
>
> Door `--disk-size=32`, `--disk-type=pd-standard` en `--machine-type=e2-small` mee te geven blijft het cluster ruim binnen de studentquota.

![Cluster aanmaken via gcloud CLI](stap1-cluster-aanmaken.avif)

Na het uitvoeren van het commando is het cluster zichtbaar in de Google Cloud Console. Het cluster wordt aangemaakt in de Standard-modus (niet Autopilot):

![GKE cluster wordt aangemaakt in de GCP Console](stap1-cluster-provisioning.avif)

Na ongeveer 6 minuten is het cluster gereed met status `RUNNING` en 6 nodes (2 per zone):

![Cluster succesvol aangemaakt met status RUNNING](stap1-cluster-gereed.avif)

---

## Stap 2 — Verbinding maken met het cluster

```bash
gcloud container clusters get-credentials week5-cluster \
  --region=europe-west4 \
  --project=project-5b8c5498-4fe2-42b9-bc3
```

Na het uitvoeren wordt de kubeconfig automatisch bijgewerkt. Met `kubectl get nodes` zijn alle 6 nodes zichtbaar met status `Ready`:

![get-credentials en kubectl get nodes tonen 6 Ready nodes](stap3-cluster-verbinding.avif)

---

## Poging 1 — Schoolscript (as-is)

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
cd "Week 5/Bestanden"
bash setup-loki-prometheus-grafana.sh
```

[▶ Bekijk screencast van de installatie](stap3-script-uitvoeren.mp4)

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
| `loki-distributed` | Chart is **deprecated** — Grafana raadt `loki` (SingleBinary/SimpleScalable) aan |
| `promtail` | Chart is **deprecated** — vervangen door **Grafana Alloy** |
| `grafana/grafana` | Chart geeft **deprecated** waarschuwing |
| `storageClass: managed-csi` | Azure-specifieke storage class, bestaat niet op GKE — aangepast naar `standard-rwo` |

Deze problemen zijn opgelost in Poging 2.

### Ingress-controller controleren

```bash
kubectl get pods --namespace ingress-nginx
```

De ingress-controller draait. Tegelijk is het externe IP-adres van de Grafana ingress op te zoeken:

```bash
kubectl get ingress -n grafana
```

![ingress-nginx Running en Grafana ingress met extern IP 34.141.226.132](stap4-ingress-status.avif)

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

De opdracht schrijft voor om het hosts-bestand handmatig aan te passen. Dat is een lokale, niet-schaalbare oplossing die per apparaat herhaald moet worden. In plaats daarvan is een A-record aangemaakt bij Bunny DNS voor `grafana.stijhuis.nl`:

![A-record aanmaken in Bunny DNS voor grafana.stijhuis.nl](stap5-dns-record-aanmaken.avif)

![DNS-overzicht stijhuis.nl met grafana A-record actief](stap5-dns-overzicht.avif)

> **Waarom geen hosts-bestand?**
> Het handmatig aanpassen van het hosts-bestand is een noodoplossing voor lokale ontwikkeling. Het werkt alleen op het apparaat waar de aanpassing is gedaan, is niet schaalbaar, en vereist beheerdersrechten. Een DNS-record is de correcte productie-aanpak: het werkt direct op alle apparaten wereldwijd, zonder lokale configuratie.

De `grafana-values.yaml` is aangepast zodat de ingress-hostname overeenkomt met het DNS-record:

![grafana-values.yaml met grafana.stijhuis.nl als hostname](stap5-grafana-values-aangepast.avif)

Daarna de Helm-release updaten zodat de nieuwe hostname actief wordt:

```bash
cd "Week 5/Bestanden"
helm upgrade --namespace grafana --values grafana-values.yaml grafana grafana/grafana
```

### Grafana openen en databronnen controleren

Na de DNS-aanpassing was Grafana initieel nog niet bereikbaar — de ingress verwees nog naar de oude hostname `grafana.project.intern`. De `grafana-values.yaml` was al lokaal aangepast maar nog niet naar het cluster gepusht:

![grafana.stijhuis.nl geeft 404 omdat de Helm upgrade nog niet uitgevoerd was](stap6-grafana-404.avif)

Na het uitvoeren van de Helm upgrade met de bijgewerkte values was Grafana direct bereikbaar via `http://grafana.stijhuis.nl`:

![Grafana loginpagina bereikbaar via grafana.stijhuis.nl](stap6-grafana-login.avif)

Inloggen met gebruikersnaam `saxion`.

---

## Poging 2 — Gemoderniseerde opzet

<!-- Wordt uitgewerkt -->

---

## Stap 10 — Eigen applicatie deployen en dashboards instellen

<!-- Wordt uitgewerkt -->

---

## Stap 11 — Architectuurdiagram

<!-- Voeg architectuurdiagram toe -->

---

## Stap 12 — Andere monitoring-tools voor Kubernetes

<!-- Vul in -->
