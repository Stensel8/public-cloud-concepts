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

| Module | EC | Quarter |
|--------|-----|---------|
| Public Cloud Concepts | 5 EC | Q3 |

> [**Architecting the Cloud**](https://github.com/Stensel8/cloud-engineering/tree/main/architecting-the-cloud) and [**Cloud Automation Concepts**](https://github.com/Stensel8/cloud-engineering/tree/main/cloud-automation-concepts) (5 EC, Q3) are shared modules done in collaboration with [Wout Achterhuis](https://github.com/Hintenhaus04) and live in their own repository: [cloud-engineering](https://github.com/Stensel8/cloud-engineering).

## Course Overview

| Week | Topic | Folder |
|------|-------|--------|
| 1 | Introduction & Deployments | [Week 1](Week%201/) |
| 2 | Ingress, Services & Apps | [Week 2](Week%202/) |
| 3 | Blue-Green Deployments & Artifact Registry | [Week 3](Week%203/) |
| 4 | Helm & Identity and Access Management | [Week 4](Week%204/) |
| 5 | Monitoring & Observability | [Week 5](Week%205/) |

## Installing Google Cloud SDK

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

Expected output (version numbers may differ):

```
Google Cloud SDK 559.0.0
bq 2.1.28
core 2026.02.27
gsutil 5.35
```

Then log in with your Google account:

```bash
gcloud auth login
```

A browser tab will open automatically. After logging in you will see a confirmation in the terminal:

```
You are now logged in as [your-email-address].
Your current project is [your-project-id].  You can change this setting by running:
  $ gcloud config set project PROJECT_ID
```

</details>

<details>
<summary>Windows</summary>

Via [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/):

```powershell
winget install -e --id Google.CloudSDK
```

> More info: [winstall.app/apps/Google.CloudSDK](https://winstall.app/apps/Google.CloudSDK)

Restart PowerShell or the command prompt after installation so that `gcloud` is available.

</details>

## Installing the GKE Auth Plugin

To use `kubectl` with Google Kubernetes Engine (GKE) clusters, the `gke-gcloud-auth-plugin` is required. Without it, `gcloud container clusters create` will show the following error:

```
CRITICAL: ACTION REQUIRED: gke-gcloud-auth-plugin, which is needed for continued use of kubectl,
was not found or is not executable.
```

Install the plugin once via:

```bash
gcloud components install gke-gcloud-auth-plugin
```

Then verify the installation:

```bash
gke-gcloud-auth-plugin --version
```

---

## Images

All images in this repository use the [AVIF](https://en.wikipedia.org/wiki/AVIF) format: open, royalty-free, and more efficient than PNG or JPEG at equivalent quality.

Batch-convert PNG/JPG screenshots to AVIF (converts and removes originals):

```bash
find . -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | while read -r f; do avifenc -q 80 -s 6 "$f" "${f%.*}.avif" && rm "$f"; done
```

Install `avifenc` first via `sudo pacman -S libavif` (Arch/CachyOS) or `sudo apt install libavif-bin` (Debian/Ubuntu).

