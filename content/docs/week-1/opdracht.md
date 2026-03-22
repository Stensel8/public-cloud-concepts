---
title: "Opdracht"
weight: 1
---

## 1.1 Google Cloud & Google Kubernetes Engine (GKE)

Deze week maak je kennis met het Google Cloud Platform. Je leert de basisconcepten van Google Cloud en de belangrijkste Google-services.

Als je al basiskennis hebt van Public Cloud Concepts, kun je de eerste twee basiscursussen overslaan.

- Voltooi de cursus Essential Google Cloud Infrastructure: Core Infrastructure: <https://www.cloudskillsboost.google/course_templates/60>
- Voltooi de cursus Essential Google Cloud Infrastructure: Core Services: <https://www.cloudskillsboost.google/course_templates/49>

Nu je de basiskennis van Google Cloud hebt, duiken we in Google Kubernetes Engine (GKE).

- Voltooi de cursus Getting Started with Google Kubernetes Engine, inclusief labs (12 credits): <https://www.cloudskillsboost.google/paths/11/course_templates/2>

Voeg de Proof of Completion (Course Badge) toe aan je portfolio.

![](../media/opdracht/image-001.avif)

## 1.2 Kubernetes Uitdaging

Om de eerste weekopdracht te voltooien, gaan we de kennis van Kubernetes toepassen en verdiepen.

We hebben daarvoor een Kubernetes-cluster nodig. Dat kan op veel manieren. Bijvoorbeeld via cloudservices of eenvoudige installaties zoals minikube. Daarmee gebeurt er echter veel onder de motorkap en krijgen we niet de beste basis om te leren hoe het werkt.

Daarom installeren we een volledig cluster op Ubuntu minimal 24.04 LTS-instances (1 masternode en 2 workernodes) met kubeadm.

Je mag hiervoor uiteraard allerlei bronnen gebruiken, zoals ChatGPT of handleidingen op internet. Bestudeer ook de relevante onderdelen uit het e-book Production Kubernetes (zie Brightspace).

1. Maak drie Ubuntu 24.04 LTS minimal-instances aan in Google (kies type e2-standard-2 als node) en kies Ubuntu 24.04 LTS minimal als besturingssysteem. Om te zien dat een virtueel netwerk in Google meerdere regio's direct verbindt, kun je de master in Nederland plaatsen, een node in Brussel en een node in Londen.

![](../media/opdracht/image-002.avif)

Installeer een Kubernetes master en 2 Kubernetes workernodes.

Een goede handleiding is: <https://hbayraktar.medium.com/how-to-install-kubernetes-cluster-on-ubuntu-22-04-step-by-step-guide-7dbf7e8f5f99>

Gebruik Flannel als CNI, anders werkt de communicatie tussen pods op verschillende nodes mogelijk niet.

In Brightspace zijn de bash-scripts `installmastertemplate` en `installnode` beschikbaar.

`Installmastertemplate` moet nog worden aangepast (uncomment de juiste regels zoals aangegeven bovenaan het bestand) en daarna op de master uitgevoerd worden. `installnode` moet op de workernodes worden uitgevoerd.

Daarna moeten de nodes aan het cluster worden toegevoegd met het commando dat zichtbaar is op de master na het uitvoeren van het script:

```bash
sudo kubeadm join ....
```

Als dat niet zichtbaar is, voer dan op de master het volgende uit:

```bash
kubeadm token create --print-join-command
```

Leg uit wat het commando `kubeadm init` doet (en waarom dat alleen op de master hoeft te worden gedaan) en leg uit wat het volgende commando doet (de CNI moet worden geïnstalleerd op de master nadat de nodes zijn toegevoegd). Welke andere netwerk-CNIs zijn er?

```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

**a)** Als alles goed is geïnstalleerd, heb je een goed werkend cluster.

Controleer dit op de master met:

```bash
kubectl get nodes
```

![](../media/opdracht/image-003.avif)

Gebruik het volgende commando om te controleren welke pods draaien in de namespace `kube-system`. Het ziet er ongeveer zo uit:

```bash
kubectl get pods -n kube-system
```

![](../media/opdracht/image-004.avif)

Leg deze pods uit aan de hand van de onderstaande figuur uit het boek "Production Kubernetes":

![](../media/opdracht/image-005.avif)

2. We willen nu een gecontaineriseerde applicatie in dit cluster draaien.

Op Brightspace zijn een Dockerfile en een `index.html`-bestand voor de applicatie beschikbaar.

Bestudeer de Dockerfile en leg uit hoe de applicatie is gebouwd en wat hij doet.

We gebruiken GitHub om automatisch een image te maken als de code (`index.html`) wordt gewijzigd. Het image wordt dan opgeslagen in DockerHub.

Daarna kunnen we het image draaien in het Google Kubernetes-cluster. Dit is schematisch weergegeven hieronder:

![](../media/opdracht/image-006.avif)

Maak een repository aan in GitHub (bijv. "container"). Zorg dat git is geïnstalleerd op je pc en clone de GitHub-repository naar je eigen pc. Plaats de Dockerfile en het `index.html`-bestand daar.

Maak ook een repository aan in DockerHub waar het docker-image na een build wordt geplaatst. Maak een workflow aan in GitHub die een nieuw image bouwt als de Dockerfile wordt gewijzigd en dit uploadt naar de nieuwe DockerHub-repository.

Begin met het blank workflow-template: <https://github.com/actions/starter-workflows/tree/main/ci>

Pas deze workflow aan zodat de laatste stappen er als volgt uitzien:

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
      docker build -t <dockerhubaccountnaam>/<repository>:latest .
      docker push <dockerhubaccountnaam>/<repository>:latest
```

Zorg dat de secrets zijn ingesteld in GitHub (via **Settings > Secrets and Variables > Actions > Repository Secrets**) en dat het Docker-account en de repository zijn ingevuld.

Commit de bestanden `Dockerfile` en `index.html` op je pc en push naar GitHub. De workflow zou nu moeten starten zodat een docker-image wordt aangemaakt in de DockerHub-repository.

We willen dit image (een webapplicatie) nu draaien in een pod in Kubernetes.

Maak een `deployment.yaml`-bestand aan voor het nieuw gemaakte image (bijv. 2 replica's). Het eerste deel van dit bestand ziet er als volgt uit:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myfirst-deployment
spec:
  replicas: 1  # Aantal instances (pods) dat moet draaien
  selector:
    matchLabels:
      app: my-container
  # Alles onder template is de definitie van de pod die aangemaakt wordt.
  template:
    metadata:
      labels:
        app: my-container
    spec:
      containers:
      - name: web-app
        image:
```

**a)** Bestudeer de structuur van dit bestand en leg de verschillende onderdelen uit.

Vul het deployment-bestand aan door het image in te vullen en de poort toe te voegen (poort 80). Maak twee pods aan via het deployment-bestand met het commando `kubectl apply -f`.

**b)** Controleer of de pods draaien en zoek het IP-adres op van de nieuw aangemaakte pods.

Benader de webserver in de pod door het volgende commando uit te voeren vanuit een node waar een pod op draait:

```bash
curl <ip-pod>
```

Laat zien wat de uitvoer is.

**c)** Log ook in op de pod vanaf de master met het commando `kubectl exec` en controleer of de directory `/usr/share/nginx/html/` bestaat. Gebruik `cat` om de inhoud van het bestand `index.html` te bekijken.

We hebben nu een draaiend cluster met een eenvoudige applicatie. De container voor de applicatie wordt aangemaakt via een workflow zodat elke keer als de code wordt gewijzigd, de container opnieuw wordt aangemaakt op DockerHub. De container wordt nog niet automatisch uitgerold.
