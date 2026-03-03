🇳🇱 Nederlands | [🇬🇧 English](README.en.md)

---

# Week 1 - Introductie tot Google Cloud & Kubernetes

---

# Opdrachten

## 1.1 Google Cloud & Google Kubernetes Engine (GKE)

Deze week maak je kennis met het Google Cloud Platform. We leren de basisconcepten van Google Cloud en de belangrijkste Google-services.

Als je al een basiskennis hebt van Public Cloud Concepts, kun je de eerste twee basiscursussen overslaan.

- Voltooi de cursus **Essential Google Cloud Infrastructure: Core Infrastructure**
  https://www.cloudskillsboost.google/course_templates/60

- Voltooi de cursus **Essential Google Cloud Infrastructure: Core Services**
  https://www.cloudskillsboost.google/course_templates/49

Nu je een basiskennis hebt van Google Cloud, gaan we aan de slag met Google Kubernetes Engine (GKE).

- Voltooi de cursus **Getting Started with Google Kubernetes Engine**, incl. labs (12 credits):
  https://www.cloudskillsboost.google/paths/11/course_templates/2

Voeg de Proof of Completion (Course Badge) badges toe aan je portfolio.

---

## 1.2 Kubernetes Uitdaging

Om de eerste weekopdracht af te ronden, willen we de opgedane Kubernetes-kennis toepassen en verder verdiepen.

Daarvoor hebben we een Kubernetes-cluster nodig. We gaan een volledig cluster installeren op **Ubuntu minimal 24.04 LTS**-instanties (1 masternode en 2 workernodes) met `kubeadm`.

Bestudeer ook de relevante hoofdstukken uit het e-book *Production Kubernetes* (zie Brightspace).

### Opdracht 1 - Het Kubernetes Cluster Installeren

**Vereisten (per node):**

- Een Ubuntu 24.04 LTS minimal systeem
- Beheerderstoegang (root of sudo)
- Actieve internetverbinding
- Minimaal 4 GB RAM
- Minimaal 2 CPU-kernen (of 2 vCPUs)
- 20 GB vrije schijfruimte op `/var` (of meer)

1. Maak drie Ubuntu 24.04 LTS minimal-instanties aan in Google Cloud (type `e2-standard-2`). Plaats ze in verschillende regio's om te zien hoe Google's netwerk meerdere regio's direct verbindt:
   - de **master** in Nederland
   - een **node** in Brussel
   - een **node** in Londen

   Installeer een Kubernetes master en 2 Kubernetes workernodes.
   Handige handleiding: https://hbayraktar.medium.com/how-to-install-kubernetes-cluster-on-ubuntu-22-04-step-by-step-guide-7dbf7e8f5f99

   > **Gebruik de Flannel CNI**, anders werkt de communicatie tussen pods op verschillende nodes mogelijk niet.

   De bash-scripts `Installmastertemplate` en `installnode` zijn beschikbaar (zie bestanden in deze map). Pas `Installmastertemplate` aan (verwijder commentaar van de juiste regels bovenaan het bestand) en voer het uit op de master. `installnode` voer je uit op de workernodes.

   Voeg daarna de nodes toe aan het cluster met het commando dat na het script zichtbaar is op de master: `sudo kubeadm join....`
   Niet zichtbaar? Voer dan op de master uit: `kubeadm token create --print-join-command`

   Leg uit wat `kubeadm init` doet (en waarom dit alleen op de master hoeft) en leg uit wat het volgende commando doet (installeer de CNI op de master nadat de nodes zijn toegevoegd):
   ```
   kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
   ```
   Welke andere netwerk-CNIs bestaan er?

   **a)** Als alles goed is, heb je een werkend cluster. Controleer dat eerst op de master met:
   ```
   kubectl get nodes
   kubectl get pods -n kube-system
   ```
   Verklaar deze pods aan de hand van het diagram uit het boek *Production Kubernetes*.

### Opdracht 2 - Een Gecontaineriseerde Applicatie Draaien

Nu willen we een gecontaineriseerde applicatie draaien in dit cluster. Een `Dockerfile` en `index.html` zijn beschikbaar (zie bestanden in deze map).

Bestudeer de Dockerfile en leg uit hoe de applicatie is gebouwd en wat het doet.

We gebruiken GitHub om automatisch een image te bouwen wanneer de code (`index.html`) wordt aangepast. Dat image wordt opgeslagen in DockerHub, waarna we het kunnen uitvoeren in het Google Kubernetes-cluster.

2. Maak een repository aan in GitHub (bijv. `container`). Zorg dat git op je pc staat, clone de repository en voeg de `Dockerfile` en `index.html` toe.

   Maak ook een repository aan in DockerHub voor het docker image.

   Maak een GitHub workflow die automatisch een nieuw image bouwt en uploadt als de Dockerfile wordt aangepast. Begin met de `blank.yml` workflow van https://github.com/actions/starter-workflows/tree/main/ci

   Pas de workflow zo aan dat de laatste stappen er zo uitzien:

   ```yaml
   steps:
     - uses: actions/checkout@v4

     - name: Login to Docker Hub
       uses: docker/login-action@v2
       with:
         username: ${{ secrets.DOCKER_USERNAME }}
         password: ${{ secrets.DOCKER_PASSWORD }}

     - name: Build and push Docker image
       run: |
         docker build -t <dockerhub-accountnaam>/<repository>:latest .
         docker push <dockerhub-accountnaam>/<repository>:latest
   ```

   Stel de secrets in via GitHub (Settings -> Secrets and Variables -> Actions -> Repository Secrets) en pas het Docker-account en de repository aan.

   Commit de bestanden en push naar GitHub. De workflow start dan automatisch en bouwt een Docker image in de DockerHub-repository.

   Maak nu een `Deployment.yaml` voor het nieuwe image (bijv. met 2 replica's). Het begin van dit bestand ziet er zo uit:

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: myfirst-deployment
   spec:
     replicas: 1  # Aantal instanties (pods) om uit te voeren
     selector:
       matchLabels:
         app: my-container
   # alles onder template is de definitie van de pod die wordt aangemaakt
     template:
       metadata:
         labels:
           app: my-container
       spec:
         containers:
         - name: web-app
           image:
   ```

   **a)** Bestudeer de structuur van dit bestand en verklaar de verschillende onderdelen. Vul het image in en voeg de poort toe (poort 80). Maak twee pods aan met `kubectl apply -f`.

   **b)** Controleer of de pods draaien en bekijk de IP-adressen. Voer `curl <ip-pod>` uit vanaf een node waarop een pod draait. Laat de uitvoer zien.

   **c)** Log ook in op de pod vanuit de master met `kubectl exec` en controleer of de map `/usr/share/nginx/html/` bestaat. Gebruik `cat` om de inhoud van `index.html` te bekijken.

---

# Leermaterialen

### Google Cloud

| Resource | Link |
|---|---|
| A Tour of Google Cloud Hands-on Labs (GSP282) | [cloudskillsboost.google](https://www.cloudskillsboost.google/focuses/2794?parent=catalog) |
| Google Cloud Fundamentals - Core Infrastructure | [cloudskillsboost.google](https://www.cloudskillsboost.google/course_templates/60) |
| Essential Google Cloud Infrastructure - Core Services | [cloudskillsboost.google](https://www.cloudskillsboost.google/course_templates/49) |
| Google Compute Engine documentatie | [cloud.google.com](https://cloud.google.com/compute?hl=en) |

### Kubernetes

| Resource | Link |
|---|---|
| Getting Started with Google Kubernetes Engine | [cloudskillsboost.google](https://www.cloudskillsboost.google/paths/11/course_templates/2) |
| Google Kubernetes Engine documentatie | [cloud.google.com](https://cloud.google.com/kubernetes-engine/docs/concepts/kubernetes-engine-overview) |
| Kubernetes documentatie | [kubernetes.io](https://kubernetes.io/docs/home/) |
| Kubernetes cluster op Ubuntu (stap-voor-stap handleiding) | [hbayraktar.medium.com](https://hbayraktar.medium.com/how-to-install-kubernetes-cluster-on-ubuntu-22-04-step-by-step-guide-7dbf7e8f5f99) |

---

# Bestanden in Deze Map

| Bestand | Beschrijving |
|---|---|
| [Dockerfile](Dockerfile) | Docker image definitie voor de Week 1 applicatie |
| [deployment.yml](deployment.yml) | Kubernetes Deployment manifest |
| [service.yml](service.yml) | Kubernetes Service manifest |
| [index.html](index.html) | Statische HTML-pagina geserveerd door de container |
| [Installmastertemplate](Installmastertemplate) | Scriptsjabloon voor het opzetten van de Kubernetes masternode |
| [installnode](installnode) | Script voor het opzetten van een Kubernetes workernode |

---

---

# Mijn Werk

## 1.1 Google Cloud & GKE - Voltooide Badges

Voltooide badges via [Google Cloud Skills Boost](https://www.skills.google/public_profiles/d92d9d25-7174-4f3a-8f70-fab880429afe):

[![Google Cloud Fundamentals: Core Infrastructure](https://cdn.qwiklabs.com/V%2FuXlPOWQoaDTrhNB3K%2Ba2p2wGiQZT7%2BODtWIPHmON4%3D)](https://www.skills.google/public_profiles/d92d9d25-7174-4f3a-8f70-fab880429afe)
[![Essential Google Cloud Infrastructure: Core Services](https://cdn.qwiklabs.com/sgKmjMjD%2BpyCGA4VRZkhXxeonasfqbo8j85m8b5gC%2Bg%3D)](https://www.skills.google/public_profiles/d92d9d25-7174-4f3a-8f70-fab880429afe)
[![Getting Started with Google Kubernetes Engine](https://cdn.qwiklabs.com/HPtjPjHuWp197QQiSmfshQL2uNxmxDCHjWps43o10Cg%3D)](https://www.skills.google/public_profiles/d92d9d25-7174-4f3a-8f70-fab880429afe)

---

## 1.2 Kubernetes Uitdaging

### Opdracht 1 - Cluster Installatie

> **Opmerking:** De opdracht specificeert Ubuntu 24.04 LTS minimal. Ik heb **Ubuntu 25.10 LTS minimal** gebruikt.
>
> Ubuntu 25.10 komt standaard met `sudo-rs` (een Rust-herimplementatie van sudo) versie 0.2.8, zoals hieronder te zien is:
>
> ![sudo-rs versie op een nieuwe Ubuntu 25.10](screenshots/sudo-rs-version.png)
>
> Deze versie heeft een bekende sessiebug. `sudo reboot` mislukt bijvoorbeeld met een onverwachte fout in plaats van te herstarten:
>
> ![sudo-rs bug: reboot mislukt](screenshots/sudo-rs-bug.png)
>
> Opgelost via een GCP-opstartscript ([AUTOSTART-configure_classic_sudo.sh](AUTOSTART-configure_classic_sudo.sh)) dat klassieke `sudo` installeert bij elke opstart ter vervanging van `sudo-rs`:
>
> ![GCP opstartscript vervangt sudo-rs](screenshots/sudo-rs-startup-script.png)

**Gebruikte instanties:**

| Node | Naam | Zone | Type | OS |
|------|------|------|------|----|
| Master | master-amsterdam | europe-west4-a (Nederland) | e2-medium | Ubuntu 25.10 LTS minimal |
| Worker 1 | worker-brussels | europe-west1-b (Belgie) | e2-medium | Ubuntu 25.10 LTS minimal |
| Worker 2 | worker-london | europe-west2-b (Verenigd Koninkrijk) | e2-medium | Ubuntu 25.10 LTS minimal |

![VM-instanties in Google Cloud](screenshots/vm-instances-gcp.png)

![OS en opslagconfiguratie](screenshots/vm-os-storage-config.png)

Het cluster heb ik geinstalleerd met twee eigen shell-scripts: [`configure_master.sh`](configure_master.sh) voor de masternode en [`configure_worker.sh`](configure_worker.sh) voor de workernodes. Deze scripts automatiseren alle stappen: kernelmoduleconfiguratie, containerd installeren, Kubernetes-pakketinstallatie (v1.35) en clusterinitialisatie.

![configure_master.sh uitvoeren op master-amsterdam](screenshots/configure-master-run.png)

![configure_worker.sh uitvoeren op worker-brussels](screenshots/configure-worker-run.png)

Nadat beide workers klaar waren, heb ik ze via het `kubeadm join`-commando van de master aan het cluster toegevoegd. De screenshot hieronder toont de volledige Flannel-installatie, de twee workers die toetreden en de uiteindelijke `kubectl get nodes` waaruit blijkt dat alle drie nodes `Ready` zijn:

![Workers toegevoegd - alle nodes Ready](screenshots/cluster-nodes-joined.png)

**Uitleg van `kubeadm init`:**

`kubeadm init` zet het Kubernetes-besturingsvlak op op de masternode. Het genereert alle TLS-certificaten (voor de API-server, etcd en kubelet), schrijft kubeconfig-bestanden, maakt de statische Pod-manifesten aan voor de kerncomponenten (kube-apiserver, kube-controller-manager, kube-scheduler, etcd) en genereert een bootstrap-token waarmee workernodes het cluster kunnen binnenkomen. Het wordt alleen op de master uitgevoerd omdat de master de enige node is die het besturingsvlak draait. Workernodes draaien geen API-server of etcd, die voeren alleen workloads uit via kubelet.

**Uitleg van `kubectl apply -f kube-flannel.yml`:**

Dit commando installeert Flannel als de Container Network Interface (CNI) plugin. Kubernetes regelt zelf geen pod-naar-pod networking, dat wordt gedelegeerd aan een CNI-plugin. Flannel maakt een overlay-netwerk (standaard VXLAN) dat elk pod een uniek IP-adres geeft, zodat pods op verschillende nodes direct met elkaar kunnen communiceren, zelfs over regio's heen. Het `apply -f`-commando leest het Flannel-manifest en maakt alle benodigde resources aan: een DaemonSet (zodat Flannel op elke node draait), een ConfigMap met de netwerkconfiguratie (CIDR `10.244.0.0/16`) en de benodigde RBAC-regels. De CIDR moet overeenkomen met de `--pod-network-cidr` die je aan `kubeadm init` hebt meegegeven.

**Andere netwerk-CNIs:**

| CNI | Beschrijving |
|-----|-------------|
| **Flannel** | Eenvoudig L3 overlay-netwerk via VXLAN. Makkelijk op te zetten, geen netwerkbeleidsondersteuning. |
| **Calico** | Veelzijdige CNI met BGP-routing en volledige NetworkPolicy-ondersteuning. Veel gebruikt in productie. |
| **Cilium** | eBPF-gebaseerde CNI met geavanceerde observeerbaarheid en beveiliging. |
| **Weave Net** | Mesh overlay-netwerk, eenvoudige installatie, ondersteunt NetworkPolicy. |
| **Canal** | Combineert Flannel (networking) met Calico (netwerkbeleid). |

**1a - Uitvoer van `kubectl get nodes`:**

```
NAME               STATUS   ROLES           AGE    VERSION
worker-brussels    Ready    <none>          14m    v1.35.1
worker-london      Ready    <none>          7m     v1.35.1
master-amsterdam   Ready    control-plane   17m    v1.35.1
```

**Uitvoer van `kubectl get pods -n kube-system`:**

![kubectl get pods -n kube-system](screenshots/kubectl-get-pods-kube-system.png)

```
NAME                                          READY   STATUS    RESTARTS   AGE
coredns-7d764666f9-fxf8b                      1/1     Running   0          17m
coredns-7d764666f9-hk9mj                      1/1     Running   0          17m
etcd-master-amsterdam                         1/1     Running   0          17m
kube-apiserver-master-amsterdam               1/1     Running   0          17m
kube-controller-manager-master-amsterdam      1/1     Running   0          17m
kube-proxy-gkbv7                              1/1     Running   0          17m
kube-proxy-jpjhp                              1/1     Running   0          14m
kube-proxy-xfg9q                              1/1     Running   0          7m23s
kube-scheduler-master-amsterdam               1/1     Running   0          17m
```

> **Opmerking:** De `kube-flannel`-pods staan hier niet bij omdat Flannel zijn eigen `kube-flannel`-namespace aanmaakt. Geverifieerd met `kubectl get pods -n kube-flannel`:

![kubectl get pods -n kube-flannel](screenshots/kubectl-get-pods-kube-flannel.png)

```
NAME                    READY   STATUS    RESTARTS   AGE
kube-flannel-ds-jmm49   1/1     Running   0          19m
kube-flannel-ds-w2b5x   1/1     Running   0          26m
kube-flannel-ds-z8zdb   1/1     Running   0          29m
```

Er draait één `kube-flannel-ds`-pod op elke node (master + 2 workers) als een DaemonSet. Elke pod configureert het VXLAN overlay-netwerk op zijn node, zodat pods op verschillende nodes en regio's elkaar kunnen bereiken.

**Verklaring van de kube-system pods:**

De `kube-system`-namespace bevat de kerncomponenten van Kubernetes:

| Pod | Rol |
|-----|-----|
| `kube-apiserver` | Het front-end van het besturingsvlak. Alle kubectl-commando's, node-registraties en interne componenten lopen via deze REST API. Draait alleen op de master. |
| `kube-controller-manager` | Voert alle controller-loops uit: zorgt dat het juiste aantal pod-replica's draait, beheert node-levenscycli, handelt certificaatrotatie af, enz. Alleen op master. |
| `kube-scheduler` | Bewaakt niet-ingeplande pods en wijst ze toe aan een geschikte node op basis van beschikbare resources, taints en affinity-regels. Alleen op master. |
| `etcd` | Gedistribueerde sleutel-waardeopslag met de volledige clusterstatus. Alle API-server lees- en schrijfacties gaan via etcd. Alleen op master. |
| `kube-proxy` | Draait op elke node. Beheert iptables/nftables-regels zodat Service-IPs verkeer correct naar pods routeren. Een pod per node, dus drie in totaal voor master + 2 workers. |
| `coredns` | Cluster-interne DNS. Pods lossen servicenamen op (bijv. `my-service.default.svc.cluster.local`) via CoreDNS. Twee replica's voor redundantie. |

---

### Opdracht 2 - Gecontaineriseerde Applicatie

**Uitleg Dockerfile:**

```dockerfile
FROM nginx:alpine
COPY static-site/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**`FROM nginx:alpine`**: Het image is gebouwd op basis van het officiele `nginx:alpine` base image. De `alpine`-variant is bewust gekozen boven `nginx:latest` (Debian-gebaseerd): Alpine Linux is veel kleiner (~5 MB vs ~180 MB), heeft veel minder voorgeinstalleerde software en heeft daarmee een kleiner aanvalsoppervlak met minder CVEs. Voor een simpele statische webserver is het volledige Debian-image gewoon onnodige overhead.

**`COPY static-site/ /usr/share/nginx/html/`**: Dit kopieert de volledige `static-site/`-map (met `index.html` en eventuele assets) naar de nginx-documentroot. Wanneer een browser een verzoek stuurt, serveert nginx dit bestand als HTTP-respons. Zo wordt de eigen website in het image geladen en vervangt het de standaard placeholder van nginx.

**`EXPOSE 80`**: Geeft aan dat de container luistert op poort 80 (standaard HTTP). Dit is een conventie voor Docker en Kubernetes om te weten welke poort de applicatie gebruikt, en is nodig voor het routeren van verkeer. Zonder dit kunnen browsers geen verbinding maken via de standaard HTTP-poort. Bij een niet-standaard poort (bijv. 8000) moeten clients dit expliciet aangeven, bijv. `stentijhuis.nl:8000`.

**`CMD ["nginx", "-g", "daemon off;"]`**: Dit is het opstartcommando van de container. Het start nginx op de voorgrond (`daemon off` voorkomt dat nginx naar de achtergrond forkt). Containers draaien rond een enkel voorgrondproces: als dat stopt, stopt de container. Nginx op de voorgrond houden zorgt dat de container actief blijft zolang nginx draait.

**GitHub Actions workflow:**

De workflow staat in [`.github/workflows/ci_week1.yml`](../.github/workflows/ci_week1.yml) en draait automatisch bij elke push of pull request naar `main`. Er zijn twee jobs:

```yaml
name: CI Week 1

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  lint:
    name: Dockerfile lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - name: Install hadolint
        run: |
          wget -qO /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
          chmod +x /usr/local/bin/hadolint
      - name: Lint Dockerfile
        run: hadolint "Week 1/Dockerfile"

  build:
    name: Build & scan
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v6

      - name: Build Docker image
        run: docker build -t stensel8/public-cloud-concepts:latest "./Week 1/"

      - name: Scan image with Trivy
        uses: aquasecurity/trivy-action@0.34.1
        with:
          image-ref: stensel8/public-cloud-concepts:latest
          format: table
          exit-code: "1"
          severity: CRITICAL

      - name: Login to Docker Hub
        if: github.ref == 'refs/heads/main' && github.event_name != 'pull_request'
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PAT }}

      - name: Push to Docker Hub
        if: github.ref == 'refs/heads/main' && github.event_name != 'pull_request'
        run: docker push stensel8/public-cloud-concepts:latest
```

**Job 1 (`lint`):** Installeert [Hadolint](https://github.com/hadolint/hadolint) via `wget` (de `hadolint/hadolint-action` werd vervangen omdat die geen mapnamen met spaties aankon) en checkt de Dockerfile statisch op best-practice schendingen (bijv. ontbrekende `--no-install-recommends`, verkeerde `COPY`-volgorde). De build-job start pas als de lint slaagt.

**Job 2 (`build`)** draait na `lint`:

- Bouwt het Docker image van `Week 1/Dockerfile`
- Scant het image met [Trivy](https://github.com/aquasecurity/trivy) en breekt de pipeline af bij **CRITICAL** CVEs
- Logt in bij DockerHub met repository-secrets (`DOCKER_USERNAME` en `DOCKER_PAT`), alleen bij pushes naar `main` (niet bij PRs)
- Pusht het image als `stensel8/public-cloud-concepts:latest` naar DockerHub, ook alleen bij directe pushes naar `main`

De secrets stel je in via **Settings -> Secrets and Variables -> Actions -> Repository Secrets** in de GitHub-repository.

**2a - Uitleg van de deployment.yaml structuur:**

Het voltooide `deployment.yml` dat ik voor deze opdracht heb gebruikt:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: first-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-container
  template:
    metadata:
      labels:
        app: my-container
    spec:
      containers:
      - name: my-container
        image: stensel8/public-cloud-concepts:latest
        ports:
        - containerPort: 80
```

**`apiVersion: apps/v1`**: Geeft aan welke Kubernetes API-groep en versie gebruikt wordt. `apps/v1` is de stabiele API voor workload-resources zoals Deployments, ReplicaSets en StatefulSets.

**`kind: Deployment`**: Bepaalt het type resource. Een Deployment beheert een ReplicaSet, die ervoor zorgt dat het gewenste aantal pod-replica's altijd draait. Als een pod crasht of wordt verwijderd, maakt de Deployment-controller automatisch een nieuwe aan.

**`metadata.name: first-deployment`**: Een unieke naam voor deze Deployment binnen de namespace, waarmee je het kunt identificeren en beheren via `kubectl`.

**`spec.replicas: 2`**: Vertelt Kubernetes om altijd precies 2 actieve pods van deze applicatie te onderhouden.

**`spec.selector.matchLabels`**: Vertelt de Deployment welke pods bij hem horen. Hij selecteert pods met het label `app: my-container`. Dit label moet overeenkomen met de labels in het pod-sjabloon hieronder.

**`spec.template`**: Het pod-sjabloon. Alles onder deze sleutel bepaalt hoe elke nieuwe pod eruitziet.

- **`metadata.labels: app: my-container`**: Het label dat op elke pod wordt gezet. Moet overeenkomen met `spec.selector.matchLabels` zodat de Deployment zijn pods kan bijhouden.
- **`spec.containers[0].name: my-container`**: De naam van de container in de pod.
- **`spec.containers[0].image: stensel8/public-cloud-concepts:latest`**: Het Docker image dat van DockerHub gepullt en uitgevoerd wordt. Dit is het image dat door de GitHub Actions workflow gebouwd en gepusht is.
- **`spec.containers[0].ports[0].containerPort: 80`**: Geeft aan dat de container op poort 80 (HTTP) luistert. Dit is informatief voor Kubernetes en nodig zodat Services verkeer naar de juiste poort kunnen sturen.

De deployment heb ik toegepast met:

```bash
kubectl apply -f deployment.yml
```

**2b - Pod-IPs en `curl`-uitvoer:**

Na het toepassen van de deployment kwamen beide pods op `Running` in twee verschillende regio's, wat aantoont dat Flannel pod-verkeer correct routeert over GCP-regio's heen:

![Beide pods Running](screenshots/deployment-pods-running.png)

```text
NAME                               READY   STATUS    RESTARTS   AGE   IP           NODE              NOMINATED NODE   READINESS GATES
first-deployment-5ffbd9444c-5hkzs  1/1     Running   0          88s   10.244.2.2   worker-london     <none>           <none>
first-deployment-5ffbd9444c-s4xdb  1/1     Running   0          88s   10.244.1.2   worker-brussels   <none>           <none>
```

`curl` uitgevoerd van de masternode naar de pod op `worker-london` (`10.244.2.2`):

![curl en kubectl exec uitvoer](screenshots/curl-pod-and-exec.png)

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta content="width=device-width, initial-scale=1.0" name="viewport">
  <title>Sten Tijhuis - Public Cloud Concepts</title>
  <!-- Bootstrap CSS, Google Fonts, iconen ... (afgekapt) -->
```

De respons bevestigt dat de nginx-container draait en de statische site serveert via het interne Flannel-IP. Dit IP is alleen bereikbaar vanuit het cluster, niet via een browser van buitenaf. Externe toegang vereist een Kubernetes Service (behandeld in Week 2).

**2c - Uitvoer van `kubectl exec -it <pod> -- cat /usr/share/nginx/html/index.html`:**

Inloggen op de pod via `kubectl exec` en het bestand direct uitlezen bevestigt dat de `index.html` correct door de Dockerfile in de nginx-documentroot is geplaatst:

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta content="width=device-width, initial-scale=1.0" name="viewport">
  <title>Sten Tijhuis - Public Cloud Concepts</title>
  <!-- Bootstrap CSS, Google Fonts, iconen ... (afgekapt) -->
```
