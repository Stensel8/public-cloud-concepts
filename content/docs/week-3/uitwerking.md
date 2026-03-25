---
title: "Uitwerking"
weight: 2
---

[![CI Week 3 - Blue-Green Deploy](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml)
[![Week 3 - Switch Blue-Green Slot](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml)

In week 3 heb ik een Blue-Green deployment opgezet voor de applicatie uit week 1 en 2, met Google Artifact Registry als container registry in plaats van Docker Hub. Daarnaast heb ik een CI/CD pipeline ingericht met GitHub Actions.

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

### Switchen tussen slots

De `switch-slot` workflow is een handmatige workflow (`workflow_dispatch`) die via GitHub Actions gestart wordt. Bij het starten kies ik `blue` of `green`, waarna de Service selector wordt aangepast met:

```bash
kubectl patch service public-cloud-concepts \
  -p '{"spec":{"selector":{"slot":"<blue|green>"}}}'
```

De pipeline gebruikt `kubectl apply` zodat de Service ook aangemaakt wordt als die nog niet bestaat. Na de switch verifieert de pipeline de actieve slot en toont de draaiende pods.

---

## Stap 1: Kubernetes Cluster aanmaken

Als basis gebruik ik de Week 2-omgeving: een GKE cluster, opnieuw opgezet als `week3-cluster`. Standaard cluster, 2 nodes, `e2-medium` (2 vCPU, 4 GB RAM), `europe-west4-a`.

{{< tabs >}}
{{< tab name="Linux" >}}
```bash
gcloud container clusters get-credentials week3-cluster \
  --region europe-west4-a \
  --project project-5b8c5498-4fe2-42b9-bc3
```
{{< /tab >}}
{{< tab name="Windows (PowerShell)" >}}
```powershell
gcloud container clusters get-credentials week3-cluster `
  --region europe-west4-a `
  --project project-5b8c5498-4fe2-42b9-bc3
```
{{< /tab >}}
{{< /tabs >}}

![gcloud connect cluster commando](/docs/week-3/media/gcloud-connect-cluster.avif)

![GKE cluster nodes actief](/docs/week-3/media/gke-cluster-nodes.avif)

---

## Stap 2: Service Account aanmaken

Een Service Account voor GitHub Actions om met GCP te communiceren:

![Het formulier voor het aanmaken van een service account](/docs/week-3/media/service-account-form.avif)

![Service account aanmaken](/docs/week-3/media/service-account-create.avif)

Naam: **Github Pipeline Account**. Rollen:
- Artifact Registry Reader
- Artifact Registry Writer
- Kubernetes Engine Developer

![Rollen toegewezen aan het service account](/docs/week-3/media/service-account-permissions.avif)

![Service account principals overzicht](/docs/week-3/media/service-account-principals.avif)

---

## Stap 3: JSON Key aanmaken

Bij het aanmaken van de key verschijnt een foutmelding:

![Foutmelding: service account key creation is disabled](/docs/week-3/media/service-account-key-disabled.avif)

Een Organization Policy (`iam.disableServiceAccountKeyCreation`) blokkeert dit.

![Organization Policy overzicht](/docs/week-3/media/org-policy-overview.avif)

![Organization Policy geblokkeerd](/docs/week-3/media/org-policy-blocked.avif)

Opgelost via Cloud Shell:

```bash
gcloud organizations list
```

![Lijst van organizations](/docs/week-3/media/org-list.avif)

```bash
gcloud organizations add-iam-policy-binding 774668784967 \
  --member="user:stentijhuis861@gmail.com" \
  --role="roles/orgpolicy.policyAdmin"
```

![IAM policy binding toevoegen](/docs/week-3/media/org-policy-add-binding.avif)

```bash
gcloud resource-manager org-policies disable-enforce iam.disableServiceAccountKeyCreation \
  --project=project-5b8c5498-4fe2-42b9-bc3
```

![Policy succesvol uitgeschakeld op projectniveau](/docs/week-3/media/org-policy-disable-enforce.avif)

![JSON key downloaden](/docs/week-3/media/json-key-download.avif)

![JSON key opgeslagen](/docs/week-3/media/json-key-saved.avif)

![Service account keys overzicht](/docs/week-3/media/service-account-keys.avif)

---

## Stap 4: GitHub Secrets instellen

De JSON key en projectgegevens als repository secrets via **Settings → Secrets and variables → Actions**:

![GitHub Secrets gedeeltelijk ingesteld](/docs/week-3/media/github-secrets-partial.avif)

![GitHub Secrets volledig ingesteld (GCP_PROJECT_ID, GCP_SA_KEY, GKE_CLUSTER, GKE_ZONE)](/docs/week-3/media/github-secrets-complete.avif)

---

## Stap 5: Artifact Registry

Artifact Registry repository aangemaakt: `public-cloud-concepts`, Docker-formaat, `europe-west4`. Container Scanning API ingeschakeld voor kwetsbaarheidsscans.

![Artifact Registry aanmaken](/docs/week-3/media/artifact-registry-create.avif)

![Lege Artifact Registry na aanmaken](/docs/week-3/media/artifact-registry-empty.avif)

![Container Scanning API ingeschakeld](/docs/week-3/media/container-scanning-api.avif)

![Artifact Registry met het gepushte green image](/docs/week-3/media/artifact-registry-result.avif)

---

## IAM-configuratie

Er zijn twee identiteiten betrokken:

**GitHub Pipeline Account** - wordt door GitHub Actions gebruikt om images te pushen naar Artifact Registry en kubectl-opdrachten te sturen naar GKE.

**Compute Engine default service account** - wordt door de GKE-nodes gebruikt om images te pullen bij het starten van pods. Zonder `Artifact Registry Reader` op dit account krijg je een `ImagePullBackOff` fout, ook als het pipeline account wel de juiste rechten heeft.

![IAM-rechten van het GitHub pipeline service account](/docs/week-3/media/iam-pipeline-account.avif)

![IAM-rechten van het Compute Engine default service account](/docs/week-3/media/iam-gke-node-account.avif)

---

## Resultaat

![GitHub Actions workflow: Build, push & deploy geslaagd](/docs/week-3/media/github-actions-run.avif)

![GitHub Actions workflow volledig groen](/docs/week-3/media/github-actions-green-build.avif)

![Website draaiend in het cluster](/docs/week-3/media/website-draaiend.avif)

![GKE observability overzicht](/docs/week-3/media/gke-observability.avif)

### Beide deployments parallel testen

Beide deployments draaien tegelijkertijd. De Service bepaalt via de `selector` welke slot verkeer ontvangt. Switchen kan op twee manieren: via de commandline of via een GitHub Actions workflow.

#### Optie 1: Commandline (kubectl)

`kubectl patch` past direct de `selector` in de Service aan. Kubernetes stuurt verkeer meteen door naar de nieuwe pods, zonder herstart of downtime.

```bash
# Naar green switchen
kubectl patch service public-cloud-concepts \
  -p '{"spec":{"selector":{"slot":"green"}}}'

# Terug naar blue
kubectl patch service public-cloud-concepts \
  -p '{"spec":{"selector":{"slot":"blue"}}}'
```

Controleer daarna welke slot actief is:

```bash
kubectl get service public-cloud-concepts \
  -o jsonpath='Actieve slot: {.spec.selector.slot}{"\n"}'
```

{{< callout type="info" >}}
`kubectl patch` is de aanbevolen manier voor blue-green switching in Kubernetes. Het is atomisch: de selector-update is één API-call en Kubernetes zorgt dat verkeer direct naar de nieuwe pods gaat. De pipeline gebruikt `kubectl apply` (idempotent: maakt de Service ook aan als die nog niet bestaat), maar voor handmatig switchen is `patch` sneller en directer.
{{< /callout >}}

#### Optie 2: GitHub Actions workflow (GUI)

Voor wie niet via de commandline wil switchen, is er de `switch-slot` workflow: een handmatige workflow (`workflow_dispatch`) die je vanuit de GitHub Actions UI kunt starten. Je kiest `blue` of `green`, en de pipeline doet de rest.

![Blue-Green slot switch via GitHub Actions workflow UI](/docs/week-3/media/blue-green-switch-workflow.avif)

De workflow toont na de switch de actieve slot en de draaiende pods:

```
Actieve slot: blue
NAME                                READY   STATUS    RESTARTS   AGE
deployment-blue-78c48bc59-m7xqm     1/1     Running   0          7m48s
deployment-green-7fbf59cf77-q2nxj   1/1     Running   0          7m32s
```

Je hebt dus zowel een commandline-optie als een kleine GUI; beide leiden tot hetzelfde resultaat.

![De website met actieve blue slot - blauwe balk bovenaan](/docs/week-3/media/website-slot-blue.avif)

![De website met actieve green slot - groene balk bovenaan](/docs/week-3/media/website-slot-green.avif)

![Service handmatig aangemaakt na switch](/docs/week-3/media/service-handmatig-aangemaakt.avif)

![Overzicht van de draaiende pods met slot-labels](/docs/week-3/media/gke-pods-overzicht.avif)

---

## Cluster verbinden en status controleren

### Verbinden met het cluster

Kubeconfig instellen voor kubectl-toegang:

{{< tabs >}}
{{< tab name="Linux" >}}
```bash
gcloud container clusters get-credentials week3-cluster \
  --region europe-west4-a \
  --project <GCP_PROJECT_ID>
```
{{< /tab >}}
{{< tab name="Windows (PowerShell)" >}}
```powershell
gcloud container clusters get-credentials week3-cluster `
  --region europe-west4-a `
  --project <GCP_PROJECT_ID>
```
{{< /tab >}}
{{< /tabs >}}

### Extern IP-adres ophalen

Het externe IP ophalen via de LoadBalancer Service:

```bash
kubectl get service public-cloud-concepts
```

Uitvoer:

```
NAME                    TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)        AGE
public-cloud-concepts   LoadBalancer   10.X.X.X       <EXTERNAL-IP>    80:XXXXX/TCP   Xm
```

Het `EXTERNAL-IP`-veld is het publieke IP-adres waarop de applicatie bereikbaar is via poort 80. Dit adres wordt toegewezen door de Google Cloud load balancer.

### Actieve slot controleren

Welke slot momenteel verkeer ontvangt:

```bash
kubectl get service public-cloud-concepts \
  -o jsonpath='{.spec.selector.slot}'
```

Dit geeft `blue` of `green` terug.

### Overzicht van draaiende deployments

Alle deployments en hun status:

```bash
kubectl get deployments
```

```
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
deployment-blue     1/1     1            1           Xm
deployment-green    1/1     1            1           Xm
```

Pods inclusief hun slot-label:

```bash
kubectl get pods -l app=public-cloud-concepts --show-labels
```

Dit is ook zichtbaar in de Google Cloud Console. In de Cloud Shell terminal zijn de `kubectl patch`-opdrachten en het IP-adres te zien:

![GKE cluster details en kubectl-commando's in Cloud Shell](/docs/week-3/media/gke-cloudshell-kubectl.avif)

---

## Argo CD en Flux CD

Voor de opdracht heb ik onderzocht hoe Argo CD en Flux CD zich verhouden tot GitHub Actions.

**Argo CD** biedt een visuele webinterface en synchroniseert actief vanuit Git naar het cluster.
**Flux CD** werkt zonder UI en draait volledig als Kubernetes-controllers - meer geschikt voor volledig geautomatiseerde omgevingen.

| | GitHub Actions | Argo CD / Flux CD |
|---|---|---|
| Model | Push: pipeline stuurt actief naar het cluster | Pull: tool haalt gewenste staat op uit Git |
| Trigger | Event in GitHub (push, PR) | Continu polling van Git-repository |
| Cluster-toegang | Runner heeft directe toegang nodig | Tool draait in het cluster zelf |
| Drift detectie | Geen - pipeline runt alleen bij events | Automatisch - herstelt afwijkingen zonder trigger |
| Geschikt voor | CI (bouwen, testen, pushen) | CD (deployen, synchroniseren, bewaken) |

In productie zou ik GitHub Actions en Argo CD/Flux CD combineren: Actions bouwt en pusht het image, Argo CD of Flux CD deployt het naar het cluster.
