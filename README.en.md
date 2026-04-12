[Nederlands](README.md) | English

[![Switch Blue-Green Slot](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml)
[![Deploy Hugo site to Pages](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/hugo.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/hugo.yml)
[![PR Checks](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/pr-checks.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/pr-checks.yml)
[![Dependabot Updates](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/dependabot/dependabot-updates)
[![Copilot code review](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/copilot-pull-request-reviewer/copilot-pull-request-reviewer/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/copilot-pull-request-reviewer/copilot-pull-request-reviewer)

> [!NOTE]
> This repository is primarily maintained in **Dutch**. The original documentation is in `README.md`; this file (`README.en.md`) is an English translation and may not always be fully up to date.

---

# Public Cloud Concepts

This repository is maintained by [Sten Tijhuis](https://github.com/Stensel8) and covers the individual module of the Cloud Engineering specialisation.

**Documentation:** [public-cloud-concepts.stensel.nl](https://public-cloud-concepts.stensel.nl)

[![GitHub](https://img.shields.io/badge/GitHub-Stensel8%2Fpublic--cloud--concepts-181717?logo=github&logoColor=white)](https://github.com/Stensel8/public-cloud-concepts)
[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-stensel8%2Fpublic--cloud--concepts-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/stensel8/public-cloud-concepts)
[![Artifact Registry](https://img.shields.io/badge/Artifact%20Registry-europe--west4-4285F4?logo=google-cloud&logoColor=white)](https://console.cloud.google.com/artifacts/docker/project-5b8c5498-4fe2-42b9-bc3/europe-west4/public-cloud-concepts)

## Modules

| Module |
|--------|
| Public Cloud Concepts |

> [**Architecting the Cloud**](https://github.com/Stensel8/cloud-engineering/tree/main/architecting-the-cloud) and [**Cloud Automation Concepts**](https://github.com/Stensel8/cloud-engineering/tree/main/cloud-automation-concepts) are shared modules done in collaboration with [Wout Achterhuis](https://github.com/Hintenhaus04) and live in their own repository: [cloud-engineering](https://github.com/Stensel8/cloud-engineering).

## Course Overview

| Week | Topic | Files |
|------|-------|-------|
| 1 | Introduction & Deployments | [Week 1/Bestanden](static/docs/week-1/bestanden/) |
| 2 | Ingress, Services & Apps | [Week 2/Bestanden](static/docs/week-2/bestanden/) |
| 3 | Blue-Green Deployments & Artifact Registry | [Week 3/Bestanden](static/docs/week-3/bestanden/) |
| 4 | Helm & Identity and Access Management | [Week 4/Bestanden](static/docs/week-4/bestanden/) |
| 5 | Monitoring & Observability | [Week 5/Bestanden](static/docs/week-5/bestanden/) |
| 6 | Microservices | [Week 6](content/docs/week-6/) |
| 7 | Serverless & API Gateway | [Week 7](content/docs/week-7/) |

<details>
<summary>Installing Google Cloud SDK</summary>

The assignments in this repository use the [Google Cloud CLI (`gcloud`)](https://cloud.google.com/sdk/docs/install). Install it once using the instructions below.

<details>
<summary>Linux (including CachyOS / Arch-based)</summary>

```bash
curl https://sdk.cloud.google.com | bash
```

Follow the wizard. Choose your shell config file (e.g. `~/.config/fish/config.fish` for Fish or `~/.bashrc` for Bash) and restart your terminal or run:

```bash
source ~/.bashrc   # or source ~/.config/fish/config.fish for Fish
```

Verify the installation:

```bash
gcloud version
```

Then log in with your Google account:

```bash
gcloud auth login
```

</details>

<details>
<summary>Windows</summary>

Via [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/):

```powershell
winget install -e --id Google.CloudSDK
```

Restart PowerShell or the command prompt after installation so that `gcloud` is available.

</details>

</details>

<details>
<summary>Installing the GKE Auth Plugin</summary>

To use `kubectl` with GKE clusters, `gke-gcloud-auth-plugin` is required:

```bash
gcloud components install gke-gcloud-auth-plugin
gke-gcloud-auth-plugin --version
```

</details>

<details>
<summary>Images (AVIF)</summary>

All images in this repository use the [AVIF](https://en.wikipedia.org/wiki/AVIF) format: open, royalty-free, and more efficient than PNG or JPEG at equivalent quality.

Batch-convert PNG/JPG screenshots to AVIF (converts and removes originals):

```bash
find . -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | while read -r f; do avifenc -q 80 -s 6 "$f" "${f%.*}.avif" && rm "$f"; done
```

Install `avifenc` first via `sudo pacman -S libavif` (Arch/CachyOS) or `sudo apt install libavif-bin` (Debian/Ubuntu).

</details>

