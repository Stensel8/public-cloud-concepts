# Mijn Uitwerking - Week 4

## 1. Helm

Helm is de pakketbeheerder voor Kubernetes. In plaats van handmatig losse `deployment.yaml`- en `service.yaml`-bestanden toe te passen, bundelt Helm alles in een **chart**: één installeerbaar pakket met alle benodigde Kubernetes-resources.

Er zijn drie kernconcepten in Helm:

1. Een **chart** is een bundel met alle informatie die nodig is om een instantie van een Kubernetes-applicatie te maken.
2. De **config** (bijv. `values.yaml`) bevat configuratie die samengevoegd kan worden met een chart om een release-object te maken.
3. Een **release** is een draaiende instantie van een chart, gecombineerd met een specifieke configuratie.

Voor het installeren van Helm volg ik de officiële documentatie: <https://helm.sh/docs/intro/install/>

---

### a) Standaard chart

#### Mijn situatie (Dualboot)

Ik ben een dualboot-gebruiker en werk dus met meerdere besturingssystemen door elkaar.
Op dit moment doe ik mijn development werk het liefst op Linux, omdat dat voor mij het prettigst werkt.

#### Installatie

<details>
<summary>Linux (Arch / CachyOS)</summary>

Omdat ik momenteel Arch (CachyOS) draai, gebruik ik de Helm package uit CachyOS:

<https://packages.cachyos.org/package/cachyos-extra-v4/x86_64_v4/helm>

```bash
sudo pacman -S helm
```

</details>

<details>
<summary>Windows</summary>

Via Winget:

<https://winstall.app/apps/Helm.Helm>

```powershell
winget install -e --id Helm.Helm
```

</details>

Voor andere systemen en alle officiële installatiemethoden, zie: <https://helm.sh/docs/intro/install/>

#### Cluster aanmaken

Voordat ik met Helm aan de slag kan, maak ik een Autopilot GKE-cluster aan via de Google Cloud Console.

![Autopilot cluster week4-cluster aanmaken in de Google Cloud Console](week4-cluster-aanmaken.avif)

In Google Cloud ziet het opgezette cluster er als volgt uit:

![Overzicht van het actieve week4-cluster in de Google Cloud Console](week4-cluster-overzicht.avif)

Als het cluster eenmaal is opgezet, verbind ik ermee en haal ik de credentials op via de CLI:

![Cluster credentials ophalen via gcloud get-credentials voor week4-cluster](week4-cluster-credentials.avif)

#### Helm chart aanmaken

Ik maak een Helm chart aan met de `helm create`-opdracht:

```bash
helm create public-cloud-concepts
```

![Uitvoer van helm create public-cloud-concepts in de terminal](week4-helm-create.avif)

#### Structuur van de chart

Wanneer je `helm create` gebruikt om een chart te maken, wordt er een standaard structuur aangemaakt. Deze structuur bevat verschillende bestanden en mappen die elk een specifieke rol spelen:

- **`charts/`**: Bedoeld voor het opslaan van afhankelijkheden (dependencies) van de chart. Standaard is deze map leeg.
- **`templates/`**: Bevat Kubernetes-gerelateerde YAML-bestanden die de daadwerkelijke resources definiëren, zoals Deployments, Services en ConfigMaps. Deze bestanden bevatten variabelen die worden ingevuld met waarden uit `values.yaml`.
- **`Chart.yaml`**: Bevat de metadata van de chart, zoals de naam, versie en beschrijving.
- **`values.yaml`**: Bevat de standaard configuratiewaarden die door de gebruiker aangepast kunnen worden. Dit is de centrale plek voor configuratie, want aanpassen direct in de templates is complexer.

Standaard ziet `values.yaml` er zo uit:

![Inhoud van values.yaml na helm create](week4-helm-values.avif)

De standaardwaarden zijn: `replicaCount: 1`, image `nginx`, `service.type: ClusterIP` en Ingress uitgeschakeld.

#### Installeren als v1

Met de standaardwaarden installeer ik de chart als de eerste release:

```bash
helm install public-cloud-concepts-v1 public-cloud-concepts
```

![Uitvoer van helm install public-cloud-concepts-v1 met STATUS deployed en REVISION 1](week4-helm-install-v1.avif)

Daarna verifieer ik of de release actief is en de pod en service correct draaien:

```bash
helm ls
kubectl get pods
kubectl get services
```

![Overzicht van helm ls, kubectl get pods en kubectl get services voor v1](week4-helm-status-v1.avif)

#### Aanpassen naar v2

Voor v2 pas ik twee waarden aan in `values.yaml`:

- `replicaCount`: van `1` naar `2`
- `ingress.enabled`: van `false` naar `true`

![Git diff van values.yaml met replicaCount 1 naar 2 en ingress.enabled false naar true](week4-helm-values-v2-diff.avif)

Daarna upgrade ik de release naar v2:

```bash
helm upgrade public-cloud-concepts-v1 public-cloud-concepts
```

![Uitvoer van helm upgrade met STATUS deployed en REVISION 2](week4-helm-upgrade-v2.avif)

Verificatie: beide pods draaien nu:

```bash
kubectl get pods
kubectl get services
```

![Beide pods Running na upgrade naar v2 met replicaCount 2](week4-helm-status-v2.avif)

Met `helm history` is de volledige revisiegeschiedenis zichtbaar: REVISION 1 (superseded) en REVISION 2 (deployed):

```bash
helm history public-cloud-concepts-v1
```

![helm history toont REVISION 1 superseded en REVISION 2 deployed](week4-helm-history.avif)

#### Verwijderen

Om een release te verwijderen gebruik je `helm uninstall`:

```bash
helm uninstall public-cloud-concepts-v1
```

Na het verwijderen is de release niet meer zichtbaar in `helm ls` en geeft `helm history` een foutmelding dat de release niet meer bestaat.

![helm uninstall bevestigt dat de release is verwijderd en helm ls toont een lege lijst](week4-helm-uninstall.avif)

#### Rollback

Met `helm rollback` zet je een release terug naar een eerdere revisie. Je geeft de naam van de release en het revisienummer mee:

```bash
helm rollback public-cloud-concepts-v1 1
```

Dit zet de release terug naar REVISION 1. De revisiegeschiedenis is op te vragen via `helm history`.

---

### b) Eigen applicatie

De `static-site` chart is een kopie van de `public-cloud-concepts` chart. In `values.yaml` is het image aangepast naar het Docker image uit Week 1 en 2:

```yaml
image:
  repository: stensel8/public-cloud-concepts
  tag: "latest"
```

```bash
helm install static-site-v1 ./static-site
```

![Uitvoer van helm install static-site-v1 met STATUS deployed en REVISION 1](week4-helm-install-static-site.avif)

#### App bekijken

Omdat de service type `ClusterIP` is (alleen intern bereikbaar), gebruik je `kubectl port-forward` om de app lokaal te openen:

```bash
kubectl port-forward svc/static-site-v1 8080:80
```

![kubectl port-forward tunnelt lokaal poort 8080 naar de pod in GKE](week4-port-forward.avif)

Daarna open je <http://localhost:8080> in de browser en is de applicatie zichtbaar:

![De static-site applicatie draait op localhost:8080 na port-forward](week4-static-site-browser.avif)

---

### c) WordPress via Bitnami

WordPress installeren via de externe Bitnami Helm repo. Geen lokale chartmap nodig.

#### Repo toevoegen

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm repo list
helm search repo bitnami/wordpress
```

#### Installeren

De standaard `helm install bitnami/wordpress` werkt niet direct op GKE Autopilot. Er zijn drie problemen en hun oplossingen:

**Probleem 1: WP-CLI weigert `user@example.com`**
Het standaard e-mailadres in de Bitnami chart is `user@example.com`. WordPress WP-CLI beschouwt dit als ongeldig en stopt de setup met exit code 1. Oplossing: altijd `--set wordpressEmail` meegeven.

**Probleem 2: Ephemeral storage limiet van 50Mi**
GKE Autopilot zet standaard een ephemeral storage limiet van 50Mi per container. WordPress schrijft tijdens de setup meer dan 50Mi aan tijdelijke bestanden, waarna de pod door Autopilot wordt geevict. Oplossing: storage requests en limits expliciet hoger instellen.

**Probleem 3: LoadBalancer service niet aangemaakt**
De Bitnami WordPress chart versie 29.2.0 had een bug waarbij de `my-wordpress` service niet werd aangemaakt. Oplossing: service handmatig uit de Helm manifest halen en toepassen.

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

#### Extern IP ophalen

```bash
kubectl get svc my-wordpress
```

![kubectl get svc toont my-wordpress als LoadBalancer met extern IP 34.13.227.107](week4-wordpress-svc.avif)

WordPress is bereikbaar op het externe IP dat GKE toekent.

![WordPress login pagina bereikbaar op extern GKE IP](week4-wordpress-login.avif)

![WordPress blog "Mijn Blog" draait publiek op het externe IP](week4-wordpress-blog.avif)

#### Verwijderen

Na afloop worden de installatie en de bijbehorende opslag verwijderd:

```bash
helm uninstall my-wordpress
kubectl delete pvc --selector app.kubernetes.io/instance=my-wordpress
```

Daarna wordt het GKE-cluster verwijderd:

```bash
gcloud container clusters delete week4-cluster --region=europe-west4
```

---

## 2. IAM - EHR Healthcare

EHR Healthcare is een bedrijf met een on-premise infrastructuur dat wil migreren naar de cloud. Ze zijn met name geïnteresseerd in beveiliging en IAM.

Voor EHR Healthcare ben ik van mening dat alle genoemde onderdelen voor hen van toepassing zijn.

- **Single Sign-On (SSO)** is een must voor een bedrijf als EHR Healthcare. Zodra een medewerker inlogt, moet er toegang zijn tot alle benodigde applicaties zonder dat er opnieuw ingelogd hoeft te worden. Dit verhoogt de productiviteit en vermindert de kans op zwakke wachtwoorden. SSO is ook te configureren voor on-premise applicaties via Azure AD Application Proxy.

- **Conditional Access** is ook belangrijk voor EHR Healthcare, omdat het bedrijf te maken heeft met gevoelige data zoals patientgegevens. Met Conditional Access kunnen ze ervoor zorgen dat alleen geautoriseerde gebruikers toegang hebben tot bepaalde applicaties. Dit verbetert de scheiding en lagen van beveiliging.

- **RBAC** (Role-Based Access Control) is belangrijk. Dit lijkt qua functionaliteit een beetje op Conditional Access, maar is meer bedoeld voor eenvoudige en overzichtelijke toewijzing van rollen en permissies. Het toewijzen van rollen aan individuele gebruikers brengt namelijk extra risico's met zich mee.

- **Identity Protection** is relevant omdat het bedrijf te maken heeft met gevoelige persoonsgegevens. Identity Protection is een verzamelnaam voor verschillende maatregelen die gericht zijn op het beschermen van gebruikersaccounts tegen misbruik. Denk hierbij aan detectie van verdachte inlogpogingen en het automatisch blokkeren van accounts bij verdachte activiteiten.

- **Multi Factor Authentication (MFA)** dwingt tweestapsverificatie af onder bepaalde omstandigheden. Dit is een extra beveiligingslaag die ervoor zorgt dat zelfs als een wachtwoord wordt gelekt, men nog steeds geen toegang heeft en dus geen misbruik kan maken van een gebruikersaccount.

- **Managed Identities en Service Principals** zijn relevant en sluiten aan bij het idee van RBAC. Het is een principle of least privilege, waarbij je ervoor zorgt dat applicaties en services alleen de toegang krijgen die ze nodig hebben en niet meer. Dit vermindert het risico op misbruik van credentials en maakt het beheer van toegangsrechten eenvoudiger. Dit wordt vooral gebruikt om externe applicaties toegang te geven zonder een gebruikersaccount te gebruiken.
