---
title: "Uitwerking"
weight: 2
---

<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml/badge.svg" alt="CI Week 3 - Blue-Green Deploy" style="display:inline;vertical-align:middle;" /></a>
<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml/badge.svg" alt="Switch Blue-Green Slot" style="display:inline;vertical-align:middle;" /></a>

Voor week 3 is een Blue-Green deployment opgezet voor de eerder gecreëerde applicatie, met Google Artifact Registry als container registry in plaats van Docker Hub. Daarnaast is een CI/CD pipeline ingericht met GitHub Actions.

---

## Blue-Green strategie

{{< callout type="info" >}}
Bij een **Blue-Green deployment** draaien twee versies van de applicatie tegelijk in Kubernetes. Een Kubernetes Service stuurt al het verkeer naar één versie (de actieve slot). Overschakelen gaat zonder downtime door simpelweg de `selector` in de Service aan te passen.
{{< /callout >}}

| Slot | Branch | Docker image tag | Status |
|------|--------|-----------------|--------|
| Blue | `main` | `blue` | Productie - ontvangt live verkeer |
| Green | `development` | `green` | Test - draait parallel, ontvangt geen verkeer |

### Hoe de pipeline werkt

- **Push naar `main`** → CI workflow bouwt het `:blue` image en deployed naar `deployment-blue`
- **Push naar `development`** → CI workflow bouwt het `:green` image en deployed naar `deployment-green`

**Beide deployments draaien tegelijkertijd.** Dit maakt het mogelijk om nieuwe functionaliteiten te ontwikkelen op `development`, te testen in de green slot, en daarna te switchen via de `switch-slot` workflow.

---

## Stap 1: Kubernetes Cluster aanmaken

Als basis dient de Week 2-omgeving: een GKE cluster, opnieuw opgezet als `week3-cluster`. Standaard cluster, 2 nodes, `e2-medium` (2 vCPU, 4 GB RAM), `europe-west4-a`.

```bash
gcloud container clusters get-credentials week3-cluster --region europe-west4-a \
  --project project-5b8c5498-4fe2-42b9-bc3
```

![gcloud connect cluster commando](../media/gcloud-connect-cluster.avif)

![GKE cluster nodes actief](../media/gke-cluster-nodes.avif)

---

## Stap 2: Service Account aanmaken

Een Service Account voor GitHub Actions om met GCP te communiceren:

![Het formulier voor het aanmaken van een service account](../media/service-account-form.avif)

![Service account aanmaken](../media/service-account-create.avif)

Naam: **Github Pipeline Account**. Rollen:
- Artifact Registry Reader
- Artifact Registry Writer
- Kubernetes Engine Developer

![Rollen toegewezen aan het service account](../media/service-account-permissions.avif)

![Service account principals overzicht](../media/service-account-principals.avif)

---

## Stap 3: JSON Key aanmaken

Bij het aanmaken van de key verschijnt een foutmelding:

![Foutmelding: service account key creation is disabled](../media/service-account-key-disabled.avif)

Een Organization Policy (`iam.disableServiceAccountKeyCreation`) blokkeert dit.

![Organization Policy overzicht](../media/org-policy-overview.avif)

![Organization Policy geblokkeerd](../media/org-policy-blocked.avif)

Opgelost via Cloud Shell:

```bash
gcloud organizations list
```

![Lijst van organizations](../media/org-list.avif)

```bash
gcloud organizations add-iam-policy-binding 774668784967 \
  --member="user:stentijhuis861@gmail.com" \
  --role="roles/orgpolicy.policyAdmin"
```

![IAM policy binding toevoegen](../media/org-policy-add-binding.avif)

```bash
gcloud resource-manager org-policies disable-enforce iam.disableServiceAccountKeyCreation \
  --project=project-5b8c5498-4fe2-42b9-bc3
```

![Policy succesvol uitgeschakeld op projectniveau](../media/org-policy-disable-enforce.avif)

![JSON key downloaden](../media/json-key-download.avif)

![JSON key opgeslagen](../media/json-key-saved.avif)

![Service account keys overzicht](../media/service-account-keys.avif)

---

## Stap 4: GitHub Secrets instellen

De JSON key en projectgegevens als repository secrets via **Settings → Secrets and variables → Actions**:

![GitHub Secrets volledig ingesteld (GCP_PROJECT_ID, GCP_SA_KEY, GKE_CLUSTER, GKE_ZONE)](../media/github-secrets-complete.avif)

---

## Stap 5: Artifact Registry

Artifact Registry repository aangemaakt: `public-cloud-concepts`, Docker-formaat, `europe-west4`. Container Scanning API ingeschakeld voor kwetsbaarheidsscans.

![Artifact Registry aanmaken](../media/artifact-registry-create.avif)

![Lege Artifact Registry na aanmaken](../media/artifact-registry-empty.avif)

![Container Scanning API ingeschakeld](../media/container-scanning-api.avif)

![Artifact Registry met het gepushte green image](../media/artifact-registry-result.avif)

---

## IAM-configuratie

Er zijn twee identiteiten betrokken:

**GitHub Pipeline Account** - wordt door GitHub Actions gebruikt om images te pushen naar Artifact Registry en kubectl-opdrachten te sturen naar GKE.

**Compute Engine default service account** - wordt door de GKE-nodes gebruikt om images te pullen bij het starten van pods. Zonder `Artifact Registry Reader` op dit account krijg je een `ImagePullBackOff` fout, ook als het pipeline account wel de juiste rechten heeft.

![IAM-rechten van het GitHub pipeline service account](../media/iam-pipeline-account.avif)

![IAM-rechten van het Compute Engine default service account](../media/iam-gke-node-account.avif)

---

## Resultaat

![GitHub Actions workflow: Build, push & deploy geslaagd](../media/github-actions-run.avif)

![Website draaiend in het cluster](../media/website-draaiend.avif)

![GKE observability overzicht](../media/gke-observability.avif)

### Beide deployments parallel testen

```bash
# Port-forward naar de green pod
kubectl get pods -l slot=green
kubectl port-forward deployment/deployment-green 8080:80

# Of: tijdelijk verkeer switchen
kubectl patch service public-cloud-concepts -p '{"spec":{"selector":{"slot":"green"}}}'
```

![De website met actieve blue slot - blauwe balk bovenaan](../media/website-slot-blue.avif)

![De website met actieve green slot - groene balk bovenaan](../media/website-slot-green.avif)

![Service handmatig aangemaakt na switch](../media/service-handmatig-aangemaakt.avif)

![Overzicht van de draaiende pods met slot-labels](../media/gke-pods-overzicht.avif)

---

## Argo CD en Flux CD

De opdracht vraagt om te onderzoeken hoe Argo CD en Flux CD zich verhouden tot GitHub Actions.

**Argo CD** biedt een visuele webinterface en synchroniseert actief vanuit Git naar het cluster.
**Flux CD** werkt zonder UI en draait volledig als Kubernetes-controllers - meer geschikt voor volledig geautomatiseerde omgevingen.

| | GitHub Actions | Argo CD / Flux CD |
|---|---|---|
| Model | Push: pipeline stuurt actief naar het cluster | Pull: tool haalt gewenste staat op uit Git |
| Trigger | Event in GitHub (push, PR) | Continu polling van Git-repository |
| Cluster-toegang | Runner heeft directe toegang nodig | Tool draait in het cluster zelf |
| Drift detectie | Geen - pipeline runt alleen bij events | Automatisch - herstelt afwijkingen zonder trigger |
| Geschikt voor | CI (bouwen, testen, pushen) | CD (deployen, synchroniseren, bewaken) |

In productie worden GitHub Actions en Argo CD/Flux CD vaak gecombineerd: Actions bouwt en pusht het image, Argo CD of Flux CD deployt het naar het cluster.
