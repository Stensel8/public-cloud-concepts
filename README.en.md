[Nederlands](README.md) | English

---

# Spring 2026 - Public Cloud Concepts

> **Work in progress** - Individual repository for the HBO specialisation *Cloud Engineering* (Spring 2026, Q3/Q4).

This repository is maintained by [Stensel8](https://github.com/Stensel8) and covers the individual module of the Cloud Engineering specialisation.

[![GitHub](https://img.shields.io/badge/GitHub-Stensel8%2Fpublic--cloud--concepts-181717?logo=github&logoColor=white)](https://github.com/Stensel8/public-cloud-concepts)
[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-stensel8%2Fpublic--cloud--concepts-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/stensel8/public-cloud-concepts)
[![Artifact Registry](https://img.shields.io/badge/Artifact%20Registry-europe--west4-4285F4?logo=google-cloud&logoColor=white)](https://console.cloud.google.com/artifacts/docker/project-5b8c5498-4fe2-42b9-bc3/europe-west4/public-cloud-concepts)

## Modules

| Module | EC | Quarter |
|--------|-----|---------|
| Public Cloud Concepts | 5 EC | Q3 |

> [**Architecting the Cloud**](https://github.com/Stensel8/spring2026-cloud-engineering/tree/main/architecting-the-cloud) and [**Cloud Automation Concepts**](https://github.com/Stensel8/spring2026-cloud-engineering/tree/main/cloud-automation-concepts) (5 EC, Q3) are shared modules done in collaboration with [Wout Achterhuis](https://github.com/Hintenhaus04) and live in their own repository: [Spring 2026 - Cloud Engineering](https://github.com/Stensel8/spring2026-cloud-engineering).

## Course Structure

| Week | Topic | Folder |
|------|-------|--------|
| 1 | Introduction & Deployments | [Week 1](Week%201/) |
| 2 | Ingress, Services & Apps | [Week 2](Week%202/) |

## Image assets

All images in this repository use the [AVIF](https://en.wikipedia.org/wiki/AVIF) format: open, royalty-free, and more efficient than PNG or JPEG at equivalent quality.

Batch-convert PNG/JPG screenshots to AVIF (converts and removes originals):

```bash
find . -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | while read -r f; do avifenc -q 80 -s 6 "$f" "${f%.*}.avif" && rm "$f"; done
```

Install `avifenc` first via `sudo pacman -S libavif` (Arch/CachyOS) or `sudo apt install libavif-bin` (Debian/Ubuntu).

## Disclaimer

This is a work in progress for educational purposes. Code, configurations, and documentation may change significantly as the course progresses.

---

*Last updated: March 2026*
