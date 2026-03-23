Nederlands | [English](README.en.md)

[![Switch Blue-Green Slot](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml)
[![Deploy Hugo site to Pages](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/hugo.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/hugo.yml)
[![PR Checks](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/pr-checks.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/pr-checks.yml)
[![Dependabot Updates](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/dependabot/dependabot-updates)
[![Copilot code review](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/copilot-pull-request-reviewer/copilot-pull-request-reviewer/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/copilot-pull-request-reviewer/copilot-pull-request-reviewer)

> [!NOTE]
> Deze repository wordt primair in het **Nederlands** bijgehouden. Er is een (niet altijd volledige of actuele) Engelse vertaling beschikbaar in `README.en.md`, maar deze versie heeft geen prioriteit.

---

# Public Cloud Concepts

Deze repository wordt bijgehouden door [Sten Tijhuis](https://github.com/Stensel8) en bevat de individuele module van de Cloud Engineering-specialisatie.

**Documentatie:** [public-cloud-concepts.stensel.nl](https://public-cloud-concepts.stensel.nl)

[![GitHub](https://img.shields.io/badge/GitHub-Stensel8%2Fpublic--cloud--concepts-181717?logo=github&logoColor=white)](https://github.com/Stensel8/public-cloud-concepts)
[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-stensel8%2Fpublic--cloud--concepts-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/stensel8/public-cloud-concepts)
[![Artifact Registry](https://img.shields.io/badge/Artifact%20Registry-europe--west4-4285F4?logo=google-cloud&logoColor=white)](https://console.cloud.google.com/artifacts/docker/project-5b8c5498-4fe2-42b9-bc3/europe-west4/public-cloud-concepts)

## Modules

| Module | EC | Kwartaal |
|--------|-----|----------|
| Public Cloud Concepts | 5 EC | Q3 |

> [**Architecting the Cloud**](https://github.com/Stensel8/cloud-engineering/tree/main/architecting-the-cloud) en [**Cloud Automation Concepts**](https://github.com/Stensel8/cloud-engineering/tree/main/cloud-automation-concepts) (5 EC, Q3) zijn gedeelde modules die samen met [Wout Achterhuis](https://github.com/Hintenhaus04) worden gedaan en staan in een aparte repository: [cloud-engineering](https://github.com/Stensel8/cloud-engineering).

## Week-overzicht

| Week | Onderwerp | Bestanden |
|------|-----------|-----------|
| 1 | Introductie & Deployments | [Week 1/Bestanden](static/docs/week-1/bestanden/) |
| 2 | Ingress, Services & Apps | [Week 2/Bestanden](static/docs/week-2/bestanden/) |
| 3 | Blue-Green Deployments & Artifact Registry | [Week 3/Bestanden](static/docs/week-3/bestanden/) |
| 4 | Helm & Identity and Access Management | [Week 4/Bestanden](static/docs/week-4/bestanden/) |
| 5 | Monitoring & Observability | [Week 5/Bestanden](static/docs/week-5/bestanden/) |
| 6 | Microservices | Week 6/Bestanden (binnenkort beschikbaar) |
| 7 | Serverless & API Gateway | Week 7/Bestanden (binnenkort beschikbaar) |

## Google Cloud SDK installeren

De opdrachten in deze repository maken gebruik van de [Google Cloud CLI (`gcloud`)](https://cloud.google.com/sdk/docs/install). Installeer deze eenmalig via onderstaande instructies.

<details>
<summary>Linux (inclusief CachyOS / Arch-gebaseerd)</summary>

```bash
curl https://sdk.cloud.google.com | bash
```

Volg daarna de wizard. Kies je shell-configuratiebestand (bijv. `~/.config/fish/config.fish` voor Fish of `~/.bashrc` voor Bash) en herstart je terminal of voer het volgende uit:

```bash
source ~/.bashrc   # of source ~/.config/fish/config.fish voor Fish
```

Verifieer de installatie:

```bash
gcloud version
```

Verwachte uitvoer (versienummers kunnen afwijken):

```
Google Cloud SDK 559.0.0
bq 2.1.28
core 2026.02.27
gsutil 5.35
```

Log daarna in met je Google-account:

```bash
gcloud auth login
```

Er wordt automatisch een browsertabblad geopend. Na het inloggen zie je een bevestiging in de terminal:

```
You are now logged in as [jouw-emailadres].
Your current project is [jouw-project-id].  You can change this setting by running:
  $ gcloud config set project PROJECT_ID
```

</details>

<details>
<summary>Windows</summary>

Via [winget](https://learn.microsoft.com/nl-nl/windows/package-manager/winget/):

```powershell
winget install -e --id Google.CloudSDK
```

> Meer informatie: [winstall.app/apps/Google.CloudSDK](https://winstall.app/apps/Google.CloudSDK)

Herstart PowerShell of de opdrachtprompt na de installatie, zodat `gcloud` beschikbaar is.

</details>

## GKE Auth Plugin installeren

Om `kubectl` te gebruiken met GKE-clusters is `gke-gcloud-auth-plugin` vereist:

```bash
gcloud components install gke-gcloud-auth-plugin
gke-gcloud-auth-plugin --version
```

---

## Afbeeldingen

Alle afbeeldingen in deze repository gebruiken het [AVIF](https://en.wikipedia.org/wiki/AVIF)-formaat: open, royalty-free en compacter dan PNG of JPEG bij gelijke kwaliteit.

Batch-converteer PNG/JPG screenshots naar AVIF (converteert en verwijdert originelen):

```bash
find . -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | while read -r f; do avifenc -q 80 -s 6 "$f" "${f%.*}.avif" && rm "$f"; done
```

Installeer `avifenc` eerst via `sudo pacman -S libavif` (Arch/CachyOS) of `sudo apt install libavif-bin` (Debian/Ubuntu).

