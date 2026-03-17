# Week 5 - Monitoring & Observability

Voor de opdracht van week 5 heb ik een GKE cluster opgezet met Prometheus, Loki, Promtail en Grafana.

---

## Stap 1 — Kubernetes cluster aanmaken

Standaard GKE cluster met 2 nodes in `europe-west4`:

```bash
gcloud container clusters create week5-cluster \
  --region=europe-west4 \        # Regio dichtstbij Nederland
  --project=project-5b8c5498-4fe2-42b9-bc3 \
  --machine-type=e2-small \      # 2 vCPU, 2GB RAM — één tier onder e2-medium
  --num-nodes=2 \                # 2 nodes per zone (regio heeft 3 zones = 6 nodes totaal)
  --disk-size=32 \               # 32GB per node — standaard is 100GB, te veel voor studentquota
  --disk-type=pd-standard        # HDD in plaats van SSD — valt buiten de SSD-quota
```

> **Waarom niet de standaard instellingen?**
> Een standaard `gcloud container clusters create` zonder extra vlaggen pakt automatisch:
> - **100GB SSD (`pd-balanced`) per node** — in een regio met 3 zones en 2 nodes per zone zijn dat 6 nodes × 100GB = **600GB SSD**. Het studentproject heeft een SSD-quota van 250GB, waardoor de aanmaak mislukt.
> - **`e2-medium` als machine type** — groter dan nodig voor deze opdracht.
>
> Door `--disk-size=32`, `--disk-type=pd-standard` en `--machine-type=e2-small` mee te geven blijft het cluster ruim binnen de studentquota.

![Cluster aanmaken via gcloud CLI](stap1-cluster-aanmaken.avif)

Na het uitvoeren van het commando is het cluster zichtbaar in de Google Cloud Console. Het cluster wordt aangemaakt in de Standard-modus (niet Autopilot):

![GKE cluster wordt aangemaakt in de GCP Console](stap1-cluster-provisioning.avif)

---

## Stap 2 — Script en values.yaml bestuderen

Het script `setup-loki-prometheus-grafana` installeert vier componenten via Helm:

| Component   | Namespace    | Chart                              |
|-------------|-------------|-------------------------------------|
| Loki        | `loki`       | `grafana/loki-distributed`         |
| Promtail    | `promtail`   | `grafana/promtail`                 |
| Prometheus  | `prometheus` | `prometheus-community/kube-prometheus-stack` |
| Grafana     | `grafana`    | `grafana/grafana`                  |

Relevante instellingen uit de values-bestanden:

- **Grafana** gebruikersnaam: `saxion`, wachtwoord: `DLLrE5xxKyInitgYX23ppyfP`
- **Grafana** draait op poort `80` (intern), bereikbaar via `grafana.project.intern`
- **Loki** querier URL (voor Grafana datasource): `http://loki-loki-distributed-querier.loki:3100`
- **Prometheus** URL (voor Grafana datasource): `http://prometheus-kube-prometheus-prometheus.prometheus:9090`

---

## Stap 3 — Verbinding maken en script uitvoeren

Verbinding maken met het cluster:

```bash
gcloud container clusters get-credentials week5-cluster \
  --region=europe-west4 \
  --project=project-5b8c5498-4fe2-42b9-bc3
```

Script uitvoeren vanuit de `Bestanden`-map:

```bash
cd "Week 5/Bestanden"
bash setup-loki-prometheus-grafana
```

---

## Stap 4 — Ingress-controller controleren

Op de laatste regel van het script wordt de NGINX ingress-controller geïnstalleerd. Controleren of de pod actief is:

```bash
kubectl get pods --namespace ingress-nginx
```

![kubectl get pods --namespace ingress-nginx toont de ingress-nginx-controller als Running](images/image-001.png)

---

## Stap 5 — Ingress aanmaken voor Grafana

De ingress is al geconfigureerd via `grafana-values.yaml` en wordt automatisch aangemaakt door de Helm-installatie. Het volledige `grafana-ingress.yaml` ziet er als volgt uit:

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

---

## Stap 6 — IP-adres van de Ingress opzoeken en hosts-bestand aanpassen

Het externe IP-adres opzoeken:

```bash
kubectl get ingress -n grafana
```

Het IP-adres toevoegen aan het hosts-bestand op de pc. Op Linux/macOS: `/etc/hosts`, op Windows: `C:\Windows\System32\drivers\etc\hosts`:

```
<EXTERNAL-IP>  grafana.project.intern
```

---

## Stap 7 — Grafana openen in de browser

Grafana is bereikbaar via: `http://grafana.project.intern`

Inloggen met:
- **Gebruikersnaam:** `saxion`
- **Wachtwoord:** `DLLrE5xxKyInitgYX23ppyfP`

---

## Stap 8 & 9 — Databronnen controleren

Na het inloggen zijn de twee databronnen zichtbaar onder **Connections → Data sources**:

- **Loki** — `http://loki-loki-distributed-querier.loki:3100`
- **Prometheus** — `http://prometheus-kube-prometheus-prometheus.prometheus:9090`

![Grafana Data sources: Loki en Prometheus verbonden](images/image-002.png)

Door een databron te selecteren, naar beneden te scrollen en op **Test** te klikken, is te controleren of de verbinding werkt.

![Test van Prometheus datasource geslaagd](images/image-003.png)

---

## Stap 10 — Eigen applicatie deployen en dashboards instellen

De applicatie uit week 1 en 2 deployen in het cluster:

```bash
kubectl apply -f <deployment.yaml>
```

### Dashboards

<!-- Vul aan na instellen van dashboards -->

---

## Stap 11 — Architectuurdiagram

<!-- Voeg architectuurdiagram toe -->

---

## Stap 12 — Andere monitoring-tools voor Kubernetes

<!-- Vul in -->
