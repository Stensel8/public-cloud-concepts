Nederlands | [English](README.en.md)

> [!NOTE]
> Deze repository wordt primair in het **Nederlands** bijgehouden. Een Engelse vertaling is mogelijk in de toekomst beschikbaar, maar dit is geen garantie.

---

# Voorjaar 2026 - Public Cloud Concepts


Deze repository wordt bijgehouden door [Sten Tijhuis](https://github.com/Stensel8) en bevat de individuele module van de Cloud Engineering-specialisatie.

[![GitHub](https://img.shields.io/badge/GitHub-Stensel8%2Fpublic--cloud--concepts-181717?logo=github&logoColor=white)](https://github.com/Stensel8/public-cloud-concepts)
[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-stensel8%2Fpublic--cloud--concepts-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/stensel8/public-cloud-concepts)
[![Artifact Registry](https://img.shields.io/badge/Artifact%20Registry-europe--west4-4285F4?logo=google-cloud&logoColor=white)](https://console.cloud.google.com/artifacts/docker/project-5b8c5498-4fe2-42b9-bc3/europe-west4/public-cloud-concepts)

## Modules

| Module | EC | Kwartaal |
|--------|-----|----------|
| Public Cloud Concepts | 5 EC | Q3 |

> [**Architecting the Cloud**](https://github.com/Stensel8/spring2026-cloud-engineering/tree/main/architecting-the-cloud) en [**Cloud Automation Concepts**](https://github.com/Stensel8/spring2026-cloud-engineering/tree/main/cloud-automation-concepts) (5 EC, Q3) zijn gedeelde modules die samen met [Wout Achterhuis](https://github.com/Hintenhaus04) worden gedaan en staan in een aparte repository: [Voorjaar 2026 - Cloud Engineering](https://github.com/Stensel8/spring2026-cloud-engineering).

## Week-overzicht

| Week | Onderwerp | Map |
|------|-----------|-----|
| 1 | Introductie & Deployments | [Week 1](Week%201/) |
| 2 | Ingress, Services & Apps | [Week 2](Week%202/) |
| 3 | Blue-Green Deployments & Artifact Registry | [Week 3](Week%203/) |

## Afbeeldingen

Alle afbeeldingen in deze repository gebruiken het [AVIF](https://en.wikipedia.org/wiki/AVIF)-formaat: open, royalty-free en compacter dan PNG of JPEG bij gelijke kwaliteit.

Batch-converteer PNG/JPG screenshots naar AVIF (converteert en verwijdert originelen):

```bash
for f in *.png *.jpg *.jpeg; do [ -f "$f" ] && avifenc -q 80 -s 6 "$f" "${f%.*}.avif" && rm "$f"; done
```

Installeer `avifenc` eerst via `sudo pacman -S libavif` (Arch/CachyOS) of `sudo apt install libavif-bin` (Debian/Ubuntu).

## Disclaimer

Dit is een lopend project voor educatieve doeleinden. Code, configuraties en documentatie kunnen gedurende de cursus nog veranderen.

---

*Laatst bijgewerkt: maart 2026*
