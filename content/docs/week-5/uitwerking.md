---
title: "Uitwerking"
weight: 2
---

GKE **Standard** cluster opgezet met een moderne monitoring stack: Loki (SingleBinary), Grafana Alloy en Prometheus via `kube-prometheus-stack`.

{{< callout type="warning" >}}
**Afwijkingen t.o.v. het aangeleverde schoolmateriaal**

Het script vanuit school bevatte een aantal foutjes en verouderde onderdelen. Bij het uitvoeren kreeg ik deprecation warnings in mijn terminal, dus ik heb gekeken of ik dat zelf kon oplossen. Dat lukte.

| Schoolscript | Mijn versie | Reden |
|---|---|---|
| `grafana/loki-distributed` | `grafana/loki` (SingleBinary) | `loki-distributed` chart is deprecated; functionaliteit zit nu in de hoofdchart |
| `grafana/promtail` | `grafana/alloy` | `promtail` is deprecated |
| losse `grafana/grafana` release | gebundeld in `kube-prometheus-stack` | standalone chart is deprecated |
| `storageClass: managed-csi` | `standard-rwo` | Azure-specifiek, werkt niet op GKE |

Het originele script staat in [`static/docs/week-5/bestanden/opdracht/`](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-5/bestanden/opdracht), mijn versie in [`static/docs/week-5/bestanden/uitwerking/`](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-5/bestanden/uitwerking).
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

Autopilot beperkt DaemonSets, blokkeert standaard containers met extra rechten en vereist resource requests voor elke pod. Dat botst met de monitoring stack:

- **Alloy** draait als DaemonSet met toegang tot `/var/log/pods` op de host
- **Prometheus node-exporter** heeft toegang met extra rechten nodig tot host-metrics
- **ingress-nginx** vereist poortconfiguratie die Autopilot niet altijd toestaat

Met Standard heb je gewoon volledige controle over node-configuratie, DaemonSets en workloads met extra rechten.
{{< /callout >}}

{{< tabs >}}
{{< tab name="Linux" >}}
```bash
gcloud container clusters create week5-cluster \
  --region=europe-west4 \
  --node-locations=europe-west4-a,europe-west4-b \
  --project=project-5b8c5498-4fe2-42b9-bc3 \
  --machine-type=e2-medium \
  --num-nodes=2 \
  --disk-size=50 \
  --disk-type=pd-balanced \
  --release-channel=regular
```
{{< /tab >}}
{{< tab name="Windows (PowerShell)" >}}
```powershell
gcloud container clusters create "week5-cluster" `
  --region "europe-west4" `
  --node-locations "europe-west4-a,europe-west4-b" `
  --project "project-5b8c5498-4fe2-42b9-bc3" `
  --machine-type "e2-medium" `
  --num-nodes "2" `
  --disk-size "50" `
  --disk-type "pd-balanced" `
  --release-channel "regular"
```
PowerShell gebruikt de backtick (`` ` ``) als regelvervolg in plaats van `\`.
{{< /tab >}}
{{< /tabs >}}

| Vlag | Waarde | Toelichting |
|------|--------|-------------|
| `--region` | `europe-west4` | Regio dichtstbij Nederland |
| `--node-locations` | `europe-west4-a,europe-west4-b` | Alleen zones a en b; zone-c had continu `GCE_STOCKOUT` fouten |
| `--machine-type` | `e2-medium` | 2 vCPU, 4GB RAM, voldoende voor SingleBinary Loki + Prometheus + Grafana |
| `--num-nodes` | `2` | 2 nodes per zone × 2 zones = 4 nodes totaal |
| `--disk-size` | `50` | 4 × 50GB = 200GB SSD, ruim binnen het quota van 500GB |
| `--disk-type` | `pd-balanced` | SSD (balanced), betere I/O voor Prometheus TSDB writes |
| `--release-channel` | `regular` | Stabiele GKE-versies met automatische upgrades |

{{< callout type="warning" >}}
**Studentquota (disk):** De standaard GKE-instellingen (100GB per node) zouden 4 × 100GB = **400GB SSD** vereisen. Met `--disk-size=50` komt het uit op 4 × 50GB = 200GB SSD, ruim binnen het quota van 500GB.

**Studentquota (RAM):** e2-medium (4GB RAM per node) verdubbelt het RAM t.o.v. e2-small. GCP telt RAM niet als separate quota; de begrenzing zit in VM instances en CPUs, beide ruim binnen de studentlimieten.
{{< /callout >}}

{{< callout type="error" >}}
**Dit cluster heeft me bijna twee weken gekost.**

Ik bleef een `GCE_STOCKOUT` fout krijgen in zone `europe-west4-c` - de zone had simpelweg geen capaciteit beschikbaar. Mijn quota's zagen er prima uit, dus ik had geen idee waar het aan lag. Ik heb er samen met een paar klasgenoten naar gekeken, maar niemand kon het direct verklaren.

De oplossing was om zone-c uit te sluiten met `--node-locations=europe-west4-a,europe-west4-b`. Zones a en b hadden geen problemen, zone-c bleef hangen. Voor een monitoring stack zijn twee zones meer dan genoeg.

![Quota overzicht - ruim binnen de limieten](/docs/week-5/media/quota-overzicht.avif)

![GCE_STOCKOUT fout zichtbaar in de GKE console](/docs/week-5/media/gce-stockout-console.avif)

![GCE_STOCKOUT fout in de terminal tijdens cluster aanmaken](/docs/week-5/media/gce-stockout-terminal.avif)

![Instance groups: zone-c blijft hangen op Updating terwijl a en b gewoon draaien](/docs/week-5/media/instance-groups.avif)
{{< /callout >}}

{{< callout type="info" >}}
**Stap 1 t/m 3 voer je uit vanuit [Google Cloud Shell](https://shell.cloud.google.com).** `helm`, `kubectl` en `gcloud` zijn daar standaard beschikbaar, je hoeft niets lokaal te installeren.
{{< /callout >}}

Na het installeren van de auth plugin in Cloud Shell:

```bash
gcloud components install gke-gcloud-auth-plugin
```

{{< video src="/docs/week-5/media/Cluster-create-week5.webm" >}}

![Cluster aanmaken via gcloud CLI](/docs/week-5/media/cluster-aanmaken.avif)

![Clusterdetails tijdens aanmaken in de GCP Console](/docs/week-5/media/cluster-aanmaken-details.avif)

![GKE cluster wordt aangemaakt in de GCP Console](/docs/week-5/media/cluster-provisioning.avif)

![Cluster succesvol aangemaakt met status RUNNING](/docs/week-5/media/cluster-gereed.avif)

![GKE console: Standard modus, 6 nodes, versie 1.35.1-gke.1396001, Regular release channel](/docs/week-5/media/cluster-details.avif)

---

## Stap 2: Verbinding maken met het cluster

Verbinden in **Google Cloud Shell**:

```bash
gcloud container clusters get-credentials week5-cluster \
  --region=europe-west4 \
  --project=project-5b8c5498-4fe2-42b9-bc3
```

![get-credentials en kubectl get nodes tonen 6 Ready nodes](/docs/week-5/media/cluster-verbinding.avif)

---

## Stap 3: Stack deployen

De repository klonen in Cloud Shell (of updaten als die al bestaat):

```bash
# Eerste keer
git clone https://github.com/Stensel8/public-cloud-concepts.git
cd public-cloud-concepts

# Al eerder gecloned
cd public-cloud-concepts && git pull
```

Daarna het script uitvoeren:

```bash
cd static/docs/week-5/bestanden/uitwerking
bash setup-loki-prometheus-grafana.sh
```

{{< video src="/docs/week-5/media/Grafana-create-week5.webm" >}}

![Uitvoer van setup-loki-prometheus-grafana.sh in Cloud Shell](/docs/week-5/media/stack-installatie-uitvoer.avif)

Het script installeert de stack in vijf stappen: Helm repos toevoegen, ingress-nginx (met `kubectl wait`), Loki, Alloy, Prometheus + Grafana.

**Waarom ingress-nginx als eerste?**
De `kube-prometheus-stack` maakt bij installatie direct een Grafana Ingress-object aan. De ingress-nginx controller valideert dat object via een webhook; als ingress-nginx nog niet draait, mislukt de Helm-installatie met een webhook-fout. Door ingress-nginx eerst te installeren en te wachten tot de controller `Ready` is, voorkom ik dat.

### `loki-values.yaml`

De `grafana/loki` chart vereist een expliciete `schemaConfig`, anders geeft Helm een harde fout:

```
Error: You must provide a schema_config for Loki.
```

#### Deployment mode kiezen

De `grafana/loki` chart ondersteunt drie deployment modes. De keuze hangt af van de clustergrootte:

| Mode | Pods | Wanneer gebruiken | Memcached caches |
|---|---|---|---|
| **SingleBinary** | 1 | Dev, labs, één gebruiker | Zinloos (alles intern) |
| **SimpleScalable** | 3 (read / write / backend) | Middelgrote teams, staging | Zinvol |
| **Distributed** | 7+ (elk component apart) | Grote productie, hoge load | Essentieel |

**Distributed is niet altijd beter.** Het principe is dat read- en write-paden onafhankelijk schalen, maar als je toch op 1 replica per component zit voeg je alleen maar netwerkhops en geheugenoverhead toe. Op een cluster van 4× e2-medium nodes is Distributed ronduit verspilling.

**SimpleScalable** klinkt als de logische middenweg, maar vereist een object storage backend (GCS, S3 of MinIO). Filesystem storage is de eenvoudigste optie in een leeromgeving, maar wordt niet ondersteund in SimpleScalable mode. Dat levert de volgende fout bij `helm install`:

```
Error: Cannot run scalable targets (backend, read, write) or distributed targets without an object storage backend.
```

SimpleScalable is een goede keuze als object storage al beschikbaar is (zoals een GCS bucket), maar dat opzetten voegt behoorlijk wat overhead toe voor een labopdracht.

**SingleBinary** is daarmee de juiste keuze: één pod, filesystem storage, geen object storage nodig. De memcached caches (`chunks-cache`, `results-cache`) zijn in deze mode zinloos en worden uitgeschakeld. Alles draait in-process, dus caching via een externe service voegt alleen overhead toe.

{{< callout type="info" >}}
**Verband met de opdracht:** De docent gebruikte de `grafana/loki-distributed` chart, die inmiddels deprecated is. Dat betekent niet dat *distributed Loki* deprecated is; de functionaliteit zit nu in de hoofdchart (`grafana/loki`). Voor een leeromgeving met filesystem storage is SingleBinary de correcte keuze.
{{< /callout >}}

Het volledige bestand staat op [GitHub](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/uitwerking/loki-values.yaml). Overige keuzes:

- `storageClass: standard-rwo`: GKE-compatibel; het schoolscript gebruikte `managed-csi`, wat Azure-specifiek is
- `minio.enabled: false`: filesystem storage is voldoende voor deze setup
- `retention_period: 336h` (14 dagen) + compactor met `retention_enabled: true`: logs worden daadwerkelijk verwijderd na 14 dagen

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

> **Twee geldige aanpakken:** De officiële Grafana tutorial gebruikt de `grafana/k8s-monitoring` chart (kant-en-klare bundel). Voor meer inzicht in wat er onder de motorkap gebeurt heb ik gekozen voor de standalone `grafana/alloy` chart.

### `prometheus-values.yaml`

Grafana is ingebouwd in `kube-prometheus-stack` (`grafana.enabled: true`), dus is er geen aparte `grafana/grafana` chart nodig. Prometheus staat op 1 replica, de monitoring stack is RAM-intensief en meerdere replica's zijn voor deze setup niet nodig.

---

## Stap 4: IP-adres ophalen

```bash
kubectl get ingress -n prometheus
```

![kubectl get ingress toont het externe IP-adres voor grafana.stijhuis.nl](/docs/week-5/media/ingress-ip.avif)

![Ingress status met adres en hostnaam](/docs/week-5/media/ingress-status.avif)

---

## Stap 5: DNS instellen

Het externe IP is als A-record ingesteld bij Bunny DNS voor `grafana.stijhuis.nl`, in plaats van het `hosts`-bestand handmatig aan te passen. Een DNS-record werkt direct op alle apparaten wereldwijd, zonder lokale configuratie.

![Grafana values aangepast met de hostnaam](/docs/week-5/media/grafana-values-aangepast.avif)

![DNS record aanmaken in Bunny DNS](/docs/week-5/media/dns-record-aanmaken.avif)

![Overzicht DNS records in Bunny DNS](/docs/week-5/media/dns-overzicht.avif)

---

## Stap 6: Grafana openen

Via `https://grafana.stijhuis.nl` in de browser:

![Grafana 404 bij eerste bezoek, DNS nog niet gepropageerd](/docs/week-5/media/grafana-404.avif)

![Grafana login pagina bereikbaar](/docs/week-5/media/grafana-login.avif)

Na het inloggen zijn de twee databronnen actief: **Loki** en **Prometheus**. Via **Connections > Data sources** heb ik beide bronnen getest.

---

## Stap 7: Dashboards instellen

Als basis voor Kubernetes monitoring is het community dashboard [k8s-custom-metrics (ID 20960)](https://grafana.com/grafana/dashboards/20960-k8s-custom-metrics/) gebruikt (versie 3).

Dashboard geïmporteerd via **Dashboards > Import** met ID `20960`, Prometheus als datasource:

![Dashboard template selecteren bij importeren](/docs/week-5/media/dashboard-template.avif)

![Dashboard importeren in Grafana met Prometheus als datasource](/docs/week-5/media/dashboard-import.avif)

![Kubernetes application insights dashboard actief, cluster CPU 70%, RAM 63%](/docs/week-5/media/dashboard-resultaat.avif)

{{< video src="/docs/week-5/media/monitoring-demo-week5.webm" >}}

---

## Stap 8: Week 1 en 2 applicatie deployen

De week 1 applicatie (`stensel8/public-cloud-concepts:latest`) is een statische website geserveerd via nginx. Week 2 gebruikt hetzelfde Docker image, een aparte deployment is daarvoor niet nodig. Het installatiescript deployt de app automatisch als stap 6. Omdat ingress-nginx al actief is, gebruikt de app een ClusterIP service met een Ingress.

```bash
kubectl get pods -n mywebsite
kubectl get ingress -n mywebsite
```

Stel een DNS A-record in voor `mywebsite.stijhuis.nl` naar hetzelfde Ingress IP-adres als Grafana.

{{< callout type="info" >}}
**Wat valt er te monitoren aan een static site?**

Op het eerste gezicht weinig, maar de monitoring stack pikt automatisch het volgende op:

- **Loki + Alloy** leest de nginx access logs uit → HTTP statuscodes, request rate, 404's
- **kube-state-metrics** (onderdeel van kube-prometheus-stack) → pod availability, restarts, CPU/memory

In Grafana zijn deze logs en metrics direct zichtbaar via de Loki- en Prometheus-databronnen. Dat is precies wat de opdracht aantoont: niet de complexiteit van de app, maar het functioneren van de monitoring stack.
{{< /callout >}}

---

## Stap 9: Architectuurdiagram

De monitoring stack bestaat uit vier lagen: **log-verzameling** (Alloy), **log-opslag** (Loki), **metrics** (Prometheus + exporters) en **visualisatie** (Grafana). Ingress-nginx verzorgt de externe toegang.

![Architectuurdiagram](/docs/week-5/media/mermaid-diagram-week-5.avif)

| Component | Namespace | Rol |
|-----------|-----------|-----|
| **ingress-nginx** | `ingress-nginx` | Externe toegang; exposeert Grafana via HTTP Ingress |
| **Grafana Alloy** | `alloy` | DaemonSet; leest pod-logs via `loki.source.kubernetes` en stuurt ze naar Loki |
| **Loki Gateway** | `loki` | nginx reverse proxy voor de Loki API |
| **Loki SingleBinary** | `loki` | Log-aggregatie; slaat logs op als chunks op filesystem |
| **node-exporter** | `prometheus` | DaemonSet; exporteert host-level metrics (CPU, RAM, disk, netwerk) |
| **kube-state-metrics** | `prometheus` | Exporteert Kubernetes object-status (pods, deployments, replicas) |
| **Prometheus** | `prometheus` | Scrapet metrics van node-exporter en kube-state-metrics; slaat op als TSDB |
| **Grafana** | `prometheus` | Visualiseert metrics (PromQL) en logs (LogQL) via datasources |

---

## Stap 10: Andere monitoring-tools voor Kubernetes

De stack die ik gebruik (Loki, Alloy, Prometheus, Grafana) is open-source en zelf te hosten. Er zijn ook commerciële alternatieven die meer out-of-the-box bieden.

### Datadog

Datadog is een cloud-native observability platform. Je installeert een DaemonSet (de Datadog Agent) in je cluster, en daarna verzamelt het automatisch metrics, logs en traces. Geen losse Helm charts voor Prometheus, Loki en Grafana; alles zit in één platform.

Voordeel: snelle setup, sterke integraties, goede APM (Application Performance Monitoring) voor distributed tracing. Nadeel: kostbaar op schaal en je bent volledig afhankelijk van Datadog als vendor.

### New Relic

Vergelijkbaar met Datadog. New Relic heeft ook een Kubernetes-integratie die automatisch cluster-health bijhoudt. Het heeft een genereuze gratis laag (100 GB/maand), wat het aantrekkelijk maakt voor kleinere omgevingen.

### Dynatrace

Dynatrace gaat een stap verder met AI-gedreven root cause analysis. In plaats van alleen dashboards te tonen, probeert het automatisch te bepalen wat de oorzaak is van een probleem. Nuttig in grote, complexe omgevingen waar handmatig door dashboards scrollen niet schaalbaar is.

### Vergelijking met mijn stack

| | Mijn stack | Datadog / New Relic / Dynatrace |
|---|---|---|
| Kosten | Gratis (open-source) | Betaald (op basis van hosts of data) |
| Setup | Meer configuratie nodig | Snelle installatie |
| Vendor lock-in | Geen | Hoog |
| Flexibiliteit | Volledig aanpasbaar | Beperkt tot platform-mogelijkheden |
| APM / tracing | Zelf opzetten (Tempo) | Ingebouwd |

Voor een leeromgeving is de open-source stack de betere keuze: je begrijpt wat er onder de motorkap gebeurt. In een professionele omgeving met een groot cluster zou ik Datadog of Dynatrace overwegen vanwege de lage beheerslast.

---

## Stap 11: SIEM en SOAR

### Wat is SIEM?

SIEM staat voor Security Information and Event Management. Een SIEM verzamelt logs en events uit allerlei bronnen (servers, netwerkapparaten, applicaties) en correleert die om verdacht gedrag te detecteren. Bekende voorbeelden zijn Microsoft Sentinel, Splunk en IBM QRadar.

Het gaat niet alleen om opslaan van logs, maar om het vinden van patronen: meerdere mislukte inlogpogingen van hetzelfde IP, een account dat midden in de nacht data downloadt, of een nieuwe admin die opeens toegang heeft tot productie.

### Wat is SOAR?

SOAR staat voor Security Orchestration, Automation and Response. Waar een SIEM detecteert, regelt een SOAR de reactie. Als een SIEM een alert genereert, kan een SOAR automatisch een playbook uitvoeren: het account blokkeren, een ticket aanmaken, de beheerder notificeren.

In combinatie werkt het zo: SIEM detecteert een incident, SOAR reageert er geautomatiseerd op.

### Koppeling aan ITIL

ITIL beschrijft processen voor IT-dienstverlening. Twee processen zijn hier direct relevant:

**Incident Management** gaat over het zo snel mogelijk herstellen van een dienst. Een SIEM signaleert het incident; een SOAR-playbook onderneemt automatisch actie en maakt een ticket aan. Dat verkort de Mean Time to Detect (MTTD) en Mean Time to Respond (MTTR) direct.

**Problem Management** gaat een stap verder: wat is de onderliggende oorzaak? Uit SIEM-data kun je patronen halen die wijzen op een structureel probleem, zoals een applicatie die structureel te veel rechten vraagt of een endpoint dat regelmatig het doelwit is van brute-force.

### Koppeling aan DevOps

In DevOps wil je security integreren in de hele pipeline (DevSecOps). Een SIEM/SOAR past daar goed in:

- Alerts uit de SIEM kunnen automatisch een pipeline blokkeren als er verdachte activiteit is gedetecteerd.
- SOAR-playbooks kunnen geautomatiseerd reageren zonder dat een beheerder handmatig hoeft in te grijpen, wat past bij de DevOps-filosofie van automatisering.

---

## Stap 12: TerramEarth casestudy

TerramEarth maakt zware machines voor de mijnbouw en landbouw. Ze hebben 2 miljoen voertuigen in gebruik die sensortdata verzamelen: kritieke data gaat real-time, de rest wordt dagelijks geupload. Dat is per voertuig 200-500 MB per dag. Ze draaien op Google Cloud, maar hebben ook legacy-systemen on-premise.

Een expliciete uitdaging uit hun executive statement: "improve and standardize tools necessary for application and network monitoring and troubleshooting." Dat is precies het speelveld van de twee producten hieronder.

### Product 1: Google Cloud Monitoring (Operations Suite)

Google Cloud Monitoring verzamelt metrics, logs en traces van alle Google Cloud-resources. Omdat TerramEarth al op Google Cloud draait, is integratie minimaal: Cloud Monitoring is out-of-the-box beschikbaar.

**Problem Management:**

*Tactisch niveau:* Cloud Monitoring kan trends analyseren over langere periodes. Als voertuigsensoren van een bepaald model structureel hogere CPU-load rapporteren op de verwerkingspipeline, is dat een signaal voor een structureel probleem in de dataverwerkingscode. Een dashboard met historische trends maakt dit zichtbaar voor het management.

*Operationeel niveau:* Een beheerder ziet in real-time dat de ingest-pipeline vertraging oploopt. Via Cloud Monitoring Alerts krijgt hij een notificatie als de latency boven een drempelwaarde komt. Hij kan direct de oorzaak opsporen via de bijbehorende logs in Cloud Logging.

**Monitoring and Event Management:**

*Tactisch niveau:* SLO (Service Level Objectives) instellen voor de datapipeline. TerramEarth kan afspreken dat 99,9% van de real-time vehicledata binnen 5 seconden verwerkt moet zijn. Cloud Monitoring bewaakt deze SLO continu en rapporteert de error budget naar het management.

*Operationeel niveau:* Automatische alerts bij afwijkingen. Als een zone opeens geen data meer ontvangt van voertuigen in een bepaalde regio, triggert een alert direct. Dat kan wijzen op een netwerkaanleg of een softwarefout in de on-board firmware.

---

### Product 2: Grafana + Prometheus (zelf te hosten of via Grafana Cloud)

Dit is dezelfde stack als ik in Week 5 gebruik. Voor TerramEarth is dit interessant omdat ze naast hun Google Cloud omgeving ook on-premise legacy-systemen hebben. Grafana kan datasources van beide omgevingen combineren in één dashboard.

---

## Stap 13: Terraform als tooling-aanbeveling

Terraform is een Infrastructure as Code (IaC) tool van HashiCorp. In plaats van handmatig resources aanmaken in een console of via losse scripts, beschrijf je de gewenste infrastructuur in `.tf`-bestanden. Terraform vergelijkt die beschrijving met de huidige staat en voert alleen de benodigde wijzigingen door.

### Hoe werkt het?

Je schrijft resources in de HashiCorp Configuration Language (HCL). Terraform heeft providers voor bijna alle cloudplatformen. Voor Google Cloud gebruik je de `google`-provider, voor AWS de `aws`-provider.

Een voorbeeld voor het aanmaken van een GKE-cluster met Terraform zou er zo uitzien:

```hcl
resource "google_container_cluster" "week5" {
  name     = "week5-cluster"
  location = "europe-west4"

  initial_node_count = 2

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 50
  }
}
```

In plaats van dit handmatig in de console in te klikken of een `gcloud`-commando te onthouden, staat de configuratie nu in een bestand dat je kunt committen in Git.

De drie basiscommando's zijn:

| Commando | Wat het doet |
|---|---|
| `terraform init` | Downloadt de benodigde providers |
| `terraform plan` | Laat zien wat er aangemaakt, gewijzigd of verwijderd wordt |
| `terraform apply` | Voert de wijzigingen door |

### Waarom voor TerramEarth?

TerramEarth heeft een hybride omgeving: Google Cloud voor de datapipeline en on-premise systemen voor legacy. Met Terraform kunnen ze beide omgevingen beschrijven in dezelfde tooling. De infrastructuur staat dan in Git, waardoor je een volledig overzicht hebt van wat er draait, wie wat heeft aangepast en wanneer.

Een concreet voordeel voor TerramEarth: ze willen hun monitoring en observability standardiseren. Met Terraform kun je de hele monitoring stack (GKE-cluster, Loki, Prometheus, Grafana) beschrijven als code. Als er een nieuw project opgestart wordt, kun je dezelfde setup in een paar minuten reproduceren in een andere regio zonder handmatige stappen.

### Terraform tegenover handmatige scripts

| | Handmatige scripts (`gcloud`, `kubectl`) | Terraform |
|---|---|---|
| Staat bijhouden | Nee, script weet niet wat er al bestaat | Ja, Terraform houdt een state-bestand bij |
| Idempotent | Nee, script kan dingen dubbel aanmaken | Ja, `terraform apply` verandert alleen wat nodig is |
| Versiebeheer | Script in Git, maar geen koppelingen naar resources | Staat + code beide in Git |
| Samenwerken | Iedereen moet weten welk script al gedraaid is | State is gedeeld, iedereen ziet de actuele staat |
| Hybride cloud | Losse scripts per platform | Één workflow voor meerdere providers |

Voor een bedrijf als TerramEarth, dat standaardisatie wil in hun tooling, is Terraform een logische keuze: één manier van werken voor alle cloudresources, in Git, herhaalbaar en controleerbaar.

**Problem Management:**

*Tactisch niveau:* Grafana heeft annotaties: je kunt events (zoals software-releases of firmware-updates) markeren op grafieken. Als een nieuwe firmware-versie samenvalt met een stijging in foutmeldingen, is de correlatie direct zichtbaar. Dat helpt bij het identificeren van de root cause.

*Operationeel niveau:* Via Prometheus-alerting kunnen beheerders automatisch gewaarschuwd worden als een specifiek voertuigtype buiten normale bandbreedtegrenzen valt. Dat kan wijzen op een defect sensor of een netwerkprobleem in het veld.

**Monitoring and Event Management:**

*Tactisch niveau:* Omdat TerramEarth zowel Google Cloud als on-premise heeft, is een gecentraliseerd Grafana-dashboard waardevol. Prometheus scrapt metrics van beide omgevingen, Grafana visualiseert alles in één plek. Het management heeft zo een compleet beeld van de infrastructuurstatus.

*Operationeel niveau:* Grafana Alerting kan bij een alert automatisch een webhook sturen naar een ticketsysteem (zoals PagerDuty of Jira). Dat is vergelijkbaar met SOAR: detectie en de eerste stap van response zijn geautomatiseerd.
