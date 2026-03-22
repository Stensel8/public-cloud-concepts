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

![Autopilot cluster week4-cluster aanmaken in de Google Cloud Console](../media/week4-cluster-aanmaken.avif)

![Overzicht van het actieve week4-cluster](../media/week4-cluster-overzicht.avif)

```bash
gcloud container clusters get-credentials week4-cluster --region=europe-west4
```

![Verbinding maken met het cluster via gcloud](../media/week4-cluster-credentials.avif)

**Helm chart aanmaken:**

```bash
helm create public-cloud-concepts
```

![Uitvoer van helm create public-cloud-concepts](../media/week4-helm-create.avif)

**Chartstructuur:**

- **`charts/`** - afhankelijkheden (standaard leeg)
- **`templates/`** - Kubernetes YAML-bestanden met variabelen uit `values.yaml`
- **`Chart.yaml`** - metadata (naam, versie, beschrijving)
- **`values.yaml`** - standaard configuratiewaarden

Standaardwaarden: `replicaCount: 1`, image `nginx`, `service.type: ClusterIP`, Ingress uitgeschakeld.

![Inhoud van values.yaml bekijken](../media/week4-helm-values.avif)

**Installeren als v1:**

```bash
helm install public-cloud-concepts-v1 public-cloud-concepts
```

![Uitvoer van helm install met STATUS deployed en REVISION 1](../media/week4-helm-install-v1.avif)

![helm ls, kubectl get pods en kubectl get services voor v1](../media/week4-helm-status-v1.avif)

**Aanpassen naar v2:**

Twee waarden aangepast in `values.yaml`:
- `replicaCount`: `1` naar `2`
- `ingress.enabled`: `false` naar `true`

![Diff van values.yaml - v1 naar v2 wijzigingen](../media/week4-helm-values-v2-diff.avif)

```bash
helm upgrade public-cloud-concepts-v1 public-cloud-concepts
```

![Uitvoer van helm upgrade met STATUS deployed en REVISION 2](../media/week4-helm-upgrade-v2.avif)

![Beide pods Running na upgrade naar v2](../media/week4-helm-status-v2.avif)

```bash
helm history public-cloud-concepts-v1
# REVISION 1: superseded
# REVISION 2: deployed
```

![helm history toont revisions 1 (superseded) en 2 (deployed)](../media/week4-helm-history.avif)

**Rollback:**

```bash
helm rollback public-cloud-concepts-v1 1
```

**Verwijderen:**

```bash
helm uninstall public-cloud-concepts-v1
```

![helm uninstall uitvoer](../media/week4-helm-uninstall.avif)

---

### b) Eigen applicatie

De `static-site` chart gebruikt het Docker-image uit Week 1 en 2:

```yaml
image:
  repository: stensel8/public-cloud-concepts
  tag: "latest"
```

```bash
helm install static-site-v1 ./static-site
```

![helm install static-site uitvoer](../media/week4-helm-install-static-site.avif)

```bash
kubectl port-forward svc/static-site-v1 8080:80
```

![kubectl port-forward tunnelt lokaal poort 8080 naar de pod in GKE](../media/week4-port-forward.avif)

![De static-site applicatie draait op localhost:8080](../media/week4-static-site-browser.avif)

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

![kubectl get svc toont my-wordpress als LoadBalancer met extern IP](../media/week4-wordpress-svc.avif)

![WordPress login pagina bereikbaar op extern GKE IP](../media/week4-wordpress-login.avif)

![WordPress blog "Mijn Blog" draait publiek](../media/week4-wordpress-blog.avif)

**Opruimen:**

```bash
helm uninstall my-wordpress
kubectl delete pvc --selector app.kubernetes.io/instance=my-wordpress
gcloud container clusters delete week4-cluster --region=europe-west4
```

---

## 4.2 IAM & Casestudy: EHR Healthcare

EHR Healthcare is een bedrijf met een on-premise infrastructuur dat wil migreren naar de cloud. Ze zijn met name geïnteresseerd in beveiliging en IAM. In de cloud biedt IAM meer functionaliteit dan een on-premise Active Directory.

Hieronder worden de gevraagde Azure IAM-concepten uitgelegd met een advies voor EHR Healthcare.

---

### 1. Single Sign-On (SSO)

**Wat is het?**
Met SSO log je één keer in en heb je daarna toegang tot meerdere applicaties - zonder elke keer opnieuw in te loggen. In Azure wordt dit gerealiseerd via Microsoft Entra ID (voorheen Azure AD).

**On-premise?** Ja. Via Azure AD Application Proxy of SAML-integratie zijn ook on-premise applicaties te koppelen aan SSO.

**Advies voor EHR Healthcare:** Zeker inzetten. Minder wachtwoorden betekent minder risico op phishing. Medewerkers hoeven niet voor elke applicatie een apart account te onthouden.

---

### 2. Conditional Access

**Wat is het?**
Beleid dat bepaalt onder welke omstandigheden toegang wordt verleend. Bijvoorbeeld: alleen toegang vanaf beheerde apparaten, of MFA vereisen als iemand inlogt vanuit een onbekend land.

**Advies voor EHR Healthcare:** Absoluut inzetten. EHR werkt met gevoelige patiëntgegevens. Conditional Access zorgt dat toegang niet alleen afhankelijk is van een wachtwoord, maar ook van locatie, apparaat en risiconiveau.

---

### 3. RBAC (Role-Based Access Control)

**Wat is het?**
Rechten worden toegewezen op basis van rollen, niet op individuele gebruikers. In Azure kun je rollen toewijzen op abonnementsniveau, resource group-niveau of resource-niveau.

**Advies voor EHR Healthcare:** Essentieel voor een gecontroleerde migratie. Door rollen vooraf te definiëren (bijv. "Database-beheerder", "Applicatiebeheerder") blijft het beheer overzichtelijk en worden de rechten automatisch mee-gemigreerd bij personeelswisselingen.

---

### 4. Identity Protection

**Wat is het?**
Microsoft Entra Identity Protection detecteert riskante inlogpogingen automatisch. Denk aan aanmeldingen vanuit anonieme IP-adressen, unmogelijke reizen (inloggen vanuit Amsterdam en Tokyo binnen een uur), of gelekte wachtwoorden.

**Advies voor EHR Healthcare:** Inzetten. De meeste aanvallen beginnen met gecompromitteerde inloggegevens. Identity Protection detecteert dit en kan automatisch MFA afdwingen of accounts blokkeren.

---

### 5. Multi-Factor Authentication (MFA)

**Wat is het?**
Een tweede verificatiestap naast het wachtwoord, zoals een authenticator-app, sms of hardware token.

**Advies voor EHR Healthcare:** Verplicht inzetten voor alle medewerkers. Zeker voor healthcare-omgevingen is dit een basismaatregel. MFA blokkeert het overgrote deel van account-aanvallen, ook als een wachtwoord uitgelekt is.

---

### 6. Managed Identities en Service Principals

**Wat is het?**
Managed Identities zijn Azure-beheerde identiteiten voor applicaties en services - geen wachtwoord nodig, Azure regelt de credentials automatisch. Service Principals zijn de handmatige variant waarbij je zelf credentials beheert.

**Advies voor EHR Healthcare:** Managed Identities zijn de voorkeur voor cloud-native applicaties. Geen opgeslagen wachtwoorden in configuratiebestanden, automatische rotatie en directe integratie met Azure RBAC. Service Principals zijn alleen nodig voor applicaties die buiten Azure draaien en Azure-resources moeten benaderen.
