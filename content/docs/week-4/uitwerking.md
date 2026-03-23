---
title: "Uitwerking"
weight: 2
---

## 4.1 Helm

Helm is de pakketbeheerder voor Kubernetes. In plaats van handmatig losse YAML-bestanden toe te passen, bundelt Helm alles in een **chart**.

Er zijn drie kernconcepten:

1. Een **chart** is een bundel met alle informatie die nodig is om een Kubernetes-applicatie te installeren.
2. De **config** (`values.yaml`) bevat configuratie die samengevoegd kan worden met een chart.
3. Een **release** is een draaiende instantie van een chart gecombineerd met specifieke configuratie.

Installatie via de [officiële Helm docs](https://helm.sh/docs/intro/install/).

---

### a) Standaard chart

**Cluster aanmaken:**

Een Autopilot GKE-cluster aangemaakt: `week4-cluster`.

![Autopilot cluster week4-cluster aanmaken in de Google Cloud Console](/docs/week-4/media/cluster-aanmaken.avif)

![Overzicht van het actieve week4-cluster](/docs/week-4/media/cluster-overzicht.avif)

{{< tabs >}}
{{< tab name="Linux" >}}
```bash
gcloud container clusters get-credentials week4-cluster --region=europe-west4
```
{{< /tab >}}
{{< tab name="Windows (PowerShell)" >}}
```powershell
gcloud container clusters get-credentials week4-cluster --region=europe-west4
```
{{< /tab >}}
{{< /tabs >}}

![Verbinding maken met het cluster via gcloud](/docs/week-4/media/cluster-credentials.avif)

**Helm chart aanmaken:**

```bash
helm create public-cloud-concepts
```

![Uitvoer van helm create public-cloud-concepts](/docs/week-4/media/helm-create.avif)

**Chartstructuur:**

- **`charts/`** - afhankelijkheden (standaard leeg)
- **`templates/`** - Kubernetes YAML-bestanden met variabelen uit `values.yaml`
- **`Chart.yaml`** - metadata (naam, versie, beschrijving)
- **`values.yaml`** - standaard configuratiewaarden

Standaardwaarden: `replicaCount: 1`, image `nginx`, `service.type: ClusterIP`, Ingress uitgeschakeld.

![Inhoud van values.yaml bekijken](/docs/week-4/media/helm-values.avif)

**Installeren als v1:**

```bash
helm install public-cloud-concepts-v1 public-cloud-concepts
```

![Uitvoer van helm install met STATUS deployed en REVISION 1](/docs/week-4/media/helm-install-v1.avif)

![helm ls, kubectl get pods en kubectl get services voor v1](/docs/week-4/media/helm-status-v1.avif)

**Aanpassen naar v2:**

Twee waarden aangepast in `values.yaml`:

```diff
-replicaCount: 1
+replicaCount: 2

 ingress:
-  enabled: false
+  enabled: true
```

![Diff van values.yaml - v1 naar v2 wijzigingen](/docs/week-4/media/helm-values-v2-diff.avif)

```bash
helm upgrade public-cloud-concepts-v1 public-cloud-concepts
```

![Uitvoer van helm upgrade met STATUS deployed en REVISION 2](/docs/week-4/media/helm-upgrade-v2.avif)

![Beide pods Running na upgrade naar v2](/docs/week-4/media/helm-status-v2.avif)

```bash
helm history public-cloud-concepts-v1
# REVISION 1: superseded
# REVISION 2: deployed
```

![helm history toont revisions 1 (superseded) en 2 (deployed)](/docs/week-4/media/helm-history.avif)

**Rollback:**

```bash
helm rollback public-cloud-concepts-v1 1
```

**Verwijderen:**

```bash
helm uninstall public-cloud-concepts-v1
```

![helm uninstall uitvoer](/docs/week-4/media/helm-uninstall.avif)

---

### b) Eigen applicatie

De `static-site` chart gebruikt het Docker-image uit Week 1 en 2. In `values.yaml` is het standaard nginx-image vervangen:

```diff
 image:
-  repository: nginx
+  repository: stensel8/public-cloud-concepts
+  tag: "latest"
```

```bash
helm install static-site-v1 ./static-site
```

![helm install static-site uitvoer](/docs/week-4/media/helm-install-static-site.avif)

```bash
kubectl port-forward svc/static-site-v1 8080:80
```

![kubectl port-forward tunnelt lokaal poort 8080 naar de pod in GKE](/docs/week-4/media/port-forward.avif)

![De static-site applicatie draait op localhost:8080](/docs/week-4/media/static-site-browser.avif)

---

### c) WordPress via Bitnami

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

De standaard `helm install bitnami/wordpress` werkt niet direct op GKE Autopilot. Drie problemen:

| Probleem | Oorzaak | Oplossing |
|---|---|---|
| WP-CLI weigert `user@example.com` | WordPress beschouwt dit als ongeldig e-mailadres | `--set wordpressEmail` meegeven |
| Ephemeral storage limiet 50Mi | GKE Autopilot zet standaard 50Mi limiet - WordPress schrijft meer tijdelijke bestanden | Storage requests en limits expliciet hoger instellen |
| LoadBalancer service ontbreekt | Bug in Bitnami WordPress chart v29.2.0 | Service handmatig uit de Helm manifest halen en toepassen |

```bash
helm install my-wordpress bitnami/wordpress \
    --set wordpressUsername=admin \
    --set wordpressPassword=MijnWachtwoord123 \
    --set wordpressEmail=admin@example.com \
    --set wordpressBlogName="Mijn Blog" \
    --set resources.requests.ephemeral-storage=1Gi \
    --set resources.limits.ephemeral-storage=2Gi \
    --set resources.requests.memory=256Mi \
    --set resources.requests.cpu=100m \
    --set mariadb.primary.resources.requests.ephemeral-storage=1Gi \
    --set mariadb.primary.resources.limits.ephemeral-storage=2Gi \
    --set mariadb.primary.resources.requests.memory=256Mi \
    --set mariadb.primary.resources.requests.cpu=100m
```

Service ontbrak na installatie, handmatig aangemaakt:

```bash
helm get manifest my-wordpress | awk '/Source: wordpress\/templates\/svc.yaml/,/^---/' | kubectl apply -f -
```

![kubectl get svc toont my-wordpress als LoadBalancer met extern IP](/docs/week-4/media/wordpress-svc.avif)

![WordPress login pagina bereikbaar op extern GKE IP](/docs/week-4/media/wordpress-login.avif)

![WordPress blog "Mijn Blog" draait publiek](/docs/week-4/media/wordpress-blog.avif)

**Opruimen:**

```bash
helm uninstall my-wordpress
kubectl delete pvc --selector app.kubernetes.io/instance=my-wordpress
gcloud container clusters delete week4-cluster --region=europe-west4
```

---

## 4.2 IAM & Casestudy: EHR Healthcare

EHR Healthcare is een bedrijf met een on-premise infrastructuur dat wil migreren naar de cloud. Ze zijn geïnteresseerd in beveiliging en IAM. Per gevraagd concept heb ik uitgelegd wat het is en waarom ik het zou aanbevelen voor dit bedrijf.

---

### 1. Single Sign-On (SSO)

SSO betekent dat je één keer inlogt en daarna toegang hebt tot meerdere applicaties zonder elke keer opnieuw te authenticeren. In Azure gaat dit via Microsoft Entra ID. Via Azure AD Application Proxy of SAML-integratie werkt dit ook voor on-premise applicaties.

Voor EHR zou ik dit zeker inzetten. Minder losse wachtwoorden betekent minder phishing-risico, en medewerkers hoeven niet voor elke applicatie een apart account bij te houden.

---

### 2. Conditional Access

Conditional Access is beleid dat bepaalt onder welke omstandigheden toegang wordt verleend, zoals alleen vanaf beheerde apparaten of MFA vereisen bij inloggen vanuit een onbekend land.

Voor EHR is dit essentieel. Ze werken met gevoelige patiëntgegevens, dus toegang mag niet puur afhangen van een wachtwoord. Locatie, apparaat en risiconiveau moeten ook meewegen.

---

### 3. RBAC (Role-Based Access Control)

Met RBAC wijs je rechten toe op basis van rollen in plaats van individuele gebruikers. In Azure werkt dit op abonnementsniveau, resource group-niveau of resource-niveau.

Voor een gecontroleerde migratie is dit essentieel. Door rollen vooraf te definiëren (bijv. "Database-beheerder", "Applicatiebeheerder") blijft het beheer overzichtelijk en gaan rechten automatisch mee bij personeelswisselingen.

---

### 4. Identity Protection

Microsoft Entra Identity Protection detecteert riskante inlogpogingen automatisch, zoals aanmeldingen vanuit anonieme IP-adressen, onmogelijke reizen (inloggen vanuit Amsterdam en Tokyo binnen een uur), of gelekte wachtwoorden.

De meeste aanvallen beginnen met gecompromitteerde inloggegevens. Identity Protection detecteert dit en kan automatisch MFA afdwingen of accounts blokkeren. Voor EHR zou ik dit zeker inzetten.

---

### 5. Multi-Factor Authentication (MFA)

MFA is een tweede verificatiestap naast het wachtwoord, zoals een authenticator-app, sms of hardware token.

Voor EHR zou ik dit verplicht stellen voor alle medewerkers. MFA blokkeert het overgrote deel van account-aanvallen, ook als een wachtwoord uitgelekt is. Voor healthcare is dit gewoon een basismaatregel.

---

### 6. Managed Identities en Service Principals

Managed Identities zijn Azure-beheerde identiteiten voor applicaties en services. Geen wachtwoord nodig; Azure regelt de credentials automatisch. Service Principals zijn de handmatige variant waarbij je zelf credentials beheert.

Voor cloud-native applicaties is Managed Identity de betere keuze. Geen opgeslagen wachtwoorden in configuratiebestanden, automatische rotatie en directe integratie met Azure RBAC. Service Principals gebruik je alleen als een applicatie buiten Azure draait en Azure-resources moet benaderen.
