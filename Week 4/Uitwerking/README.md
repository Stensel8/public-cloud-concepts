# Mijn Uitwerking - Week 4

## 4.1 Helm

Voor het installeren van Helm volg ik de officiële documentatie: <https://helm.sh/docs/intro/install/>

### 1. Mijn situatie (Dualboot)

Ik ben een dualboot-gebruiker en werk dus met meerdere besturingssystemen door elkaar.
Op dit moment doe ik mijn development werk het liefst op Linux, omdat dat voor mij het prettigst werkt.

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

### 4. Cluster aanmaken

Voordat ik met Helm aan de slag kan, maak ik een Autopilot GKE-cluster aan via de Google Cloud Console.

![Autopilot cluster week4-cluster aanmaken in de Google Cloud Console](week4-cluster-aanmaken.avif)

In Google Cloud ziet het opgezette cluster er als volgt uit:

![Overzicht van het actieve week4-cluster in de Google Cloud Console](week4-cluster-overzicht.avif)

Als het cluster eenmaal is opgezet, verbind ik ermee en haal ik de credentials op via de CLI:

![Cluster credentials ophalen via gcloud get-credentials voor week4-cluster](week4-cluster-credentials.avif)

---

## 4.2 Cloud Identity & IAM

> Uitwerking volgt na het bestuderen van het lesmateriaal en het uitvoeren van de opdrachten.

---

## 4.3 Case Study: EHR Healthcare

> Uitwerking volgt na het lezen van de casestudy.
