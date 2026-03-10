# Mijn Uitwerking - Week 4

## 4.1 Helm

Helm is de pakketbeheerder voor Kubernetes. In plaats van handmatig losse `deployment.yaml`- en `service.yaml`-bestanden toe te passen, bundelt Helm alles in een **chart**: één installeerbaar pakket met alle benodigde Kubernetes-resources.

Er zijn drie kernconcepten in Helm:

1. Een **chart** is een bundel met alle informatie die nodig is om een instantie van een Kubernetes-applicatie te maken.
2. De **config** (bijv. `values.yaml`) bevat configuratie die samengevoegd kan worden met een chart om een release-object te maken.
3. Een **release** is een draaiende instantie van een chart, gecombineerd met een specifieke configuratie.

Voor het installeren van Helm volg ik de officiële documentatie: <https://helm.sh/docs/intro/install/>

---

### 1. Mijn situatie (Dualboot)

Ik ben een dualboot-gebruiker en werk dus met meerdere besturingssystemen door elkaar.
Op dit moment doe ik mijn development werk het liefst op Linux, omdat dat voor mij het prettigst werkt.

---

### 2. Installatie

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

---

### 3. Cluster aanmaken

Voordat ik met Helm aan de slag kan, maak ik een Autopilot GKE-cluster aan via de Google Cloud Console.

![Autopilot cluster week4-cluster aanmaken in de Google Cloud Console](week4-cluster-aanmaken.avif)

In Google Cloud ziet het opgezette cluster er als volgt uit:

![Overzicht van het actieve week4-cluster in de Google Cloud Console](week4-cluster-overzicht.avif)

Als het cluster eenmaal is opgezet, verbind ik ermee en haal ik de credentials op via de CLI:

![Cluster credentials ophalen via gcloud get-credentials voor week4-cluster](week4-cluster-credentials.avif)

---

### 4. Helm chart aanmaken

Ik maak een Helm chart aan met de `helm create`-opdracht:

```bash
helm create public-cloud-concepts
```

![Uitvoer van helm create public-cloud-concepts in de terminal](week4-helm-create.avif)

---

### 5. Structuur van de chart

Wanneer je `helm create` gebruikt om een chart te maken, wordt er een standaard structuur aangemaakt. Deze structuur bevat verschillende bestanden en mappen die elk een specifieke rol spelen:

- **`charts/`**: Bedoeld voor het opslaan van afhankelijkheden (dependencies) van de chart. Standaard is deze map leeg.
- **`templates/`**: Bevat Kubernetes-gerelateerde YAML-bestanden die de daadwerkelijke resources definiëren, zoals Deployments, Services en ConfigMaps. Deze bestanden bevatten variabelen die worden ingevuld met waarden uit `values.yaml`.
- **`Chart.yaml`**: Bevat de metadata van de chart, zoals de naam, versie en beschrijving.
- **`values.yaml`**: Bevat de standaard configuratiewaarden die door de gebruiker aangepast kunnen worden. Dit is de centrale plek voor configuratie, want aanpassen direct in de templates is complexer.

Standaard ziet `values.yaml` er zo uit:

![Inhoud van values.yaml na helm create](week4-helm-values.avif)

De standaardwaarden zijn: `replicaCount: 1`, image `nginx`, `service.type: ClusterIP` en Ingress uitgeschakeld.

---

## 4.2 Cloud Identity & IAM

> Uitwerking volgt na het bestuderen van het lesmateriaal en het uitvoeren van de opdrachten.

---

## 4.3 Case Study: EHR Healthcare

> Uitwerking volgt na het lezen van de casestudy.
