# Week 3 - Blue-Green Deployment & Artifact Registry

[![CI Week 3 - Blue-Green Deploy](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml)
[![Switch Blue-Green Slot](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml)

Voor week 3 is het de bedoeling dat ik een Blue-Green deployment opzet voor de eerder gecreëerde applicatie, maar dan met Google Artifact Registry als container registry in plaats van Docker Hub.

Daarnaast richt ik een CI/CD pipeline in met GitHub Actions die automatisch een nieuw image bouwt en uitrolt bij elke codeverandering.

---

## Blue-Green strategie

> [!NOTE]
> Bij een **Blue-Green deployment** draaien twee versies van de applicatie tegelijk in Kubernetes. Een Kubernetes Service stuurt al het verkeer naar één versie (de actieve slot). Overschakelen gaat zonder downtime door simpelweg de `selector` in de Service aan te passen.

| Slot | Branch | Docker image tag | Status |
|------|--------|-----------------|--------|
| Blue | `main` | `blue` | Productie - ontvangt live verkeer |
| Green | `development` | `green` | Test - draait parallel, ontvangt geen verkeer |

### Hoe de pipeline werkt

Elke branch heeft zijn eigen deployment:
- **Push naar `main`** → CI workflow bouwt automatisch het `:blue` image en deployed naar `deployment-blue`
- **Push naar `development`** → CI workflow bouwt automatisch het `:green` image en deployed naar `deployment-green`

**Beide deployments draaien tegelijkertijd** in het cluster. De code op de `development` branch kan verschillen van `main` - ze hoeven niet gesynchroniseerd te worden. Dit maakt het mogelijk om:
1. Nieuwe functionaliteiten te ontwikkelen op `development`
2. Deze te deployen naar de green slot (die draait maar geen verkeer ontvangt)
3. Te testen of alles werkt
4. Te switchen naar green met de `switch-slot` workflow
5. Later (optioneel) de changes te mergen naar `main`

De Kubernetes Service bepaalt welke deployment verkeer ontvangt via de `selector`. De `switch-slot.yml` workflow past alleen deze selector aan - er worden geen nieuwe builds gemaakt bij het switchen.

---

## Stap 1: Kubernetes Cluster aanmaken

Eerst ruim ik de werkzaamheden van Week 1 op (de handmatig opgezette deployments op de virtuele machines). Als basis gebruik ik de omgeving van Week 2: een Google Kubernetes Engine cluster, wat beter geschikt is voor een Blue-Green deployment.

De week 2 omgeving draait nog, maar ik bouw hem opnieuw op als `week3-cluster` - dat is netter en overzichtelijker.

Net zoals bij Week 2 kies ik voor een **standaard cluster**. Dit geeft volledige controle over de configuratie en is goedkoop te houden voor deze opdracht.

**Instellingen:**
- **2 nodes** - het minimum dat nodig is voor een Blue-Green deployment
- **Machinetype e2-medium** (2 vCPU's, 4 GB RAM) - voldoende voor de applicatie en nog betaalbaar

Het aanmaken van het cluster duurde ongeveer 5 minuten.

---

## Stap 2: Service Account aanmaken

Terwijl het cluster aangemaakt wordt, begin ik alvast met het opzetten van een Service Account waarmee GitHub Actions met GCP kan communiceren. Ik volg hiervoor deze handleiding:
[Setup CI/CD using GitHub Actions to deploy to GKE](https://medium.com/@gravish316/setup-ci-cd-using-github-actions-to-deploy-to-google-kubernetes-engine-ef465a482fd)

![Het formulier voor het aanmaken van een service account](service-account-form.avif)

Ik vul de naam in als **Github Pipeline Account**.

![Service account aangemaakt met naam en beschrijving](service-account-create.avif)

Het service account krijgt de volgende rollen:
- Artifact Registry Reader
- Artifact Registry Writer
- Kubernetes Engine Developer

![Rollen toegewezen aan het service account](service-account-permissions.avif)

![Principals with access - stap 3 van het aanmaken](service-account-principals.avif)

---

## Stap 3: JSON Key aanmaken

Om de GitHub Actions workflow te kunnen authenticeren, maak ik een JSON key aan via **IAM → Service Accounts → Keys → Add Key → JSON**.

![Keys-tabblad van het Github Pipeline Account](service-account-keys.avif)

Bij het aanmaken van de key krijg ik de volgende foutmelding:

![Foutmelding: service account key creation is disabled](service-account-key-disabled.avif)

Een Organization Policy (`iam.disableServiceAccountKeyCreation`) blokkeert het aanmaken van keys.

![Organization Policies overzicht met de geblokkeerde policy](org-policy-overview.avif)

In de GUI kan ik de policy niet aanpassen - daarvoor ontbreken de benodigde rechten.

![Bewerkoptie geblokkeerd in de GUI](org-policy-blocked.avif)

### Oplossing via Cloud Shell

Via de CLI los ik dit in twee stappen op. Eerst zoek ik het organization ID op:

```bash
gcloud organizations list
```

![Organization ID opvragen via gcloud](org-list.avif)

Daarna geef ik mezelf de benodigde rechten:

```bash
gcloud organizations add-iam-policy-binding 774668784967 \
  --member="user:stentijhuis861@gmail.com" \
  --role="roles/orgpolicy.policyAdmin"
```

![IAM policy binding toegevoegd aan de organisatie](org-policy-add-binding.avif)

Vervolgens zet ik de policy op projectniveau uit:

```bash
gcloud resource-manager org-policies disable-enforce iam.disableServiceAccountKeyCreation \
  --project=project-5b8c5498-4fe2-42b9-bc3
```

![Policy succesvol uitgeschakeld op projectniveau](org-policy-disable-enforce.avif)

De policy is nu uitgeschakeld (`booleanPolicy: {}`), waarna ik de key wel kan aanmaken.

![Bestandsdialoog voor het opslaan van de JSON key](json-key-download.avif)

![Bevestiging: private key opgeslagen op de computer](json-key-saved.avif)

---

## Stap 4: GitHub Secrets instellen

De JSON key en overige projectgegevens voeg ik toe als repository secrets in GitHub via **Settings → Secrets and variables → Actions**.

![GitHub Secrets gedeeltelijk ingesteld (DOCKER_PAT en DOCKER_USERNAME)](github-secrets-partial.avif)

De volgende secrets zijn aangemaakt:

![GitHub Secrets volledig ingesteld (GCP_PROJECT_ID, GCP_SA_KEY, GKE_CLUSTER, GKE_ZONE)](github-secrets-complete.avif)

---

## Stap 5: Artifact Registry & cluster verbinden

Daarna maak ik verbinding met het cluster via de gcloud CLI:

```bash
gcloud container clusters get-credentials week3-cluster --region europe-west4-a --project project-5b8c5498-4fe2-42b9-bc3
```

![Cluster credentials ophalen via gcloud in Cloud Shell](gcloud-connect-cluster.avif)

Daarna ga ik naar de Artifact Registry om een repository aan te maken voor de container images. Ik kies dezelfde naam als mijn Docker Hub en GitHub repositories: `public-cloud-concepts`.

![Artifact Registry nog leeg - geen repositories aangemaakt](artifact-registry-empty.avif)

![Formulier voor het aanmaken van een Artifact Registry repository](artifact-registry-create.avif)

De instellingen heb ik grotendeels op de standaardwaarden gelaten: Docker-formaat, region `europe-west4`.

Tot slot schakel ik de **Container Scanning API** in. Dit deed ik in Week 1 en 2 ook al met Docker Scout - het geeft een mooi overzicht van kwetsbaarheden in de images.

![Container Scanning API activeren in Google Cloud](container-scanning-api.avif)

---

## Resultaat

Na het uitvoeren van de Blue-Green deployment via GitHub Actions ziet de workflow er zo uit:

![GitHub Actions workflow: Build, push & deploy geslaagd](github-actions-run.avif)

In de Artifact Registry staat nu het gebuilde image met tag `green` - 25,2 MB groot.

![Artifact Registry met het gepushte green image](artifact-registry-result.avif)

## IAM-configuratie

Er zijn twee afzonderlijke identiteiten betrokken bij de deployment:

**GitHub Pipeline Account** (`github-pipeline-account@...`)
Wordt gebruikt door GitHub Actions tijdens de CI/CD-run. Dit account pusht images naar Artifact Registry en stuurt kubectl-opdrachten naar GKE. Zodra de pipeline klaar is, speelt dit account geen rol meer.

Rollen: Artifact Registry Reader, Artifact Registry Writer, Kubernetes Engine Developer

![IAM-rechten van het GitHub pipeline service account](iam-pipeline-account.avif)

**Compute Engine default service account** (`[PROJECT_NUMBER]-compute@...`)
Wordt intern door de GKE-nodes gebruikt om container images te pullen op het moment dat een pod gestart wordt. Dit is een volledig apart account - de GitHub Actions credentials worden hier *niet* voor gebruikt. Zonder `Artifact Registry Reader` op dit account krijg je een `ImagePullBackOff` fout, ook al heeft het pipeline account wel de juiste rechten.

![IAM-rechten van het Compute Engine default service account dat door GKE-nodes wordt gebruikt](iam-gke-node-account.avif)



---

## Verificatie

Na het deployen controleer ik of het cluster, de pods en de website correct draaien.

### Beide deployments parallel testen

Omdat beide deployments tegelijkertijd draaien, kunnen we de green versie testen zonder het publieke verkeer te switchen. Dit kan op twee manieren:

**Optie 1: Port-forward naar een specifieke pod**
```bash
# Vind de green pod
kubectl get pods -l slot=green

# Port-forward naar de green pod
kubectl port-forward deployment/deployment-green 8080:80

# Test via localhost:8080
```

**Optie 2: Tijdelijk de service wijzigen**
```bash
# Switch naar green
kubectl patch service public-cloud-concepts -p '{"spec":{"selector":{"slot":"green"}}}'

# Test de website via het externe IP

# Switch terug naar blue
kubectl patch service public-cloud-concepts -p '{"spec":{"selector":{"slot":"blue"}}}'
```

Dit toont aan dat beide versies parallel draaien en dat green een andere codebase kan hebben dan blue zonder naar main te hoeven mergen.

### Cluster en pods

De twee nodes van het cluster zijn actief in `europe-west4-a`:

![De twee nodes van het week3-cluster in de GCP Console](gke-cluster-nodes.avif)

Via de GKE Console is ook observability beschikbaar - hier zijn de actieve workloads en pods zichtbaar:

![Observability vanuit de GKE Console met actieve pods en deployments](gke-observability.avif)

De Kubernetes Service is eenmalig handmatig aangemaakt via Cloud Shell met `kubectl apply`, omdat de pipeline de service nog niet automatisch toepaste. Dit is later gecorrigeerd in de workflow:

![Kubernetes Service aangemaakt via kubectl apply in Cloud Shell](service-handmatig-aangemaakt.avif)

De website is bereikbaar via het externe IP van de LoadBalancer Service op poort 80. De gekleurde balk bovenaan geeft aan welke slot actief is - dit wordt ingevoegd op build-tijd via een Docker ARG:

![De website met actieve blue slot - blauwe balk bovenaan](website-slot-blue.avif)

Na het uitvoeren van de switch-slot workflow naar green verschijnt de groene balk:

![De website met actieve green slot - groene balk bovenaan](website-slot-green.avif)

De pods draaien correct en zijn voorzien van de juiste labels (`slot=blue` of `slot=green`):

![Overzicht van de draaiende pods in het cluster met slot-labels](gke-pods-overzicht.avif)

---

## Argo CD en Flux CD

De opdracht vraagt om te onderzoeken wat Argo CD en Flux CD zijn en hoe ze zich verhouden tot GitHub Actions.

### Wat zijn het?

**Argo CD** en **Flux CD** zijn GitOps-tools. Bij GitOps is de Git-repository de enige bron van waarheid voor de gewenste staat van het cluster. De tool vergelijkt voortdurend wat er in Git staat met wat er in het cluster draait, en corrigeert automatisch als er een afwijking is.

**Argo CD** biedt een visuele webinterface waarmee je de status van alle deployments in een oogopslag ziet. Het synchroniseert actief vanuit Git naar het cluster en geeft een melding als de werkelijke staat afwijkt van de gewenste staat.

**Flux CD** werkt zonder UI en draait volledig als een set Kubernetes-controllers. Het is meer CLI-gericht en past beter in een volledig geautomatiseerde omgeving zonder handmatige ingrepen.

### Verschil met GitHub Actions

| | GitHub Actions | Argo CD / Flux CD |
|---|---|---|
| Model | Push: pipeline stuurt actief naar het cluster | Pull: tool haalt zelf de gewenste staat op uit Git |
| Trigger | Event in GitHub (push, PR) | Continu polling van Git-repository |
| Kluster-toegang | Runner heeft directe toegang nodig (kubeconfig/SA key) | Tool draait in het cluster zelf, geen externe toegang nodig |
| Drift detectie | Geen - pipeline runt alleen bij events | Automatisch - herstelt afwijkingen zonder handmatige trigger |
| Geschikt voor | CI (bouwen, testen, pushen) | CD (deployen, synchroniseren, bewaken) |

### Conclusie

GitHub Actions is primair een CI-tool die ook CD kan doen, maar dan op een "push"-manier. Argo CD en Flux CD zijn pure CD-tools die beter schalen voor complexe omgevingen met veel teams of clusters, omdat de credentials voor het cluster nooit buiten het cluster hoeven te bestaan en afwijkingen automatisch worden hersteld.

In productie-omgevingen worden GitHub Actions en Argo CD/Flux CD vaak gecombineerd: Actions bouwt en pusht het image, Argo CD of Flux CD pakt het op en deployt het naar het cluster.
