# Week 3 - Blue-Green Deployment & Artifact Registry

Voor week 3 is het de bedoeling dat ik een Blue-Green deployment opzet voor de eerder gecreëerde applicatie, maar dan met Google Artifact Registry als container registry in plaats van Docker Hub.

Daarnaast richt ik een CI/CD pipeline in met GitHub Actions die automatisch een nieuw image bouwt en uitrolt bij elke codeverandering.

---

## Blue-Green strategie

> [!NOTE]
> Bij een **Blue-Green deployment** draaien twee versies van de applicatie tegelijk in Kubernetes. Een Kubernetes Service stuurt al het verkeer naar één versie (de actieve slot). Overschakelen gaat zonder downtime door simpelweg de `selector` in de Service aan te passen.

| Slot | Branch | Docker image tag | Status |
|------|--------|-----------------|--------|
| 🔵 Blue | `main` | `blue` | Productie - ontvangt live verkeer |
| 🟢 Green | `development` | `green` | Test - draait parallel, ontvangt geen verkeer |

De branchnamen hoeven niet `blue` en `green` te heten - de kleur wordt bepaald door het label `slot: blue` of `slot: green` in de Kubernetes Deployment, en door welke selector de Service gebruikt.

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


