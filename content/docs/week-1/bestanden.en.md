---
title: "Files"
weight: 3
---

All scripts and configuration files used for Week 1. The source code is on [GitHub](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-1/bestanden).

[![CI Week 1](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week1.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week1.yml)

---

## Scripts

| File | Description |
|------|-------------|
| [configure_master.sh](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/configure_master.sh) | Sets up the Kubernetes **master node** on Ubuntu 25.10. Goes through ten steps: system updates, kernel modules, installing and configuring containerd (including `SystemdCgroup = true` via a Python patch), Kubernetes v1.35 packages, disabling swap, `kubeadm init`, and installing Flannel CNI. |
| [configure_worker.sh](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/configure_worker.sh) | Sets up a **worker node**. Runs the same steps 1-8 as the master script, but skips `kubeadm init`. After this script, run the `kubeadm join ...` command from the master. |
| [AUTOSTART-configure_classic_sudo.sh](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/AUTOSTART-configure_classic_sudo.sh) | GCP startup script that installs classic `sudo` on every boot to replace `sudo-rs`. Ubuntu 25.10 ships with `sudo-rs` (version 0.2.8) by default, which has a session bug causing `sudo reboot` to fail. |
| [Installmastertemplate.sh](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/Installmastertemplate.sh) | Template script for master node installation. |
| [installnode.sh](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/installnode.sh) | Installation script for a generic node. |

## Application

| File | Description |
|------|-------------|
| [Dockerfile](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/Dockerfile) | Builds the static site based on `nginx:1-alpine-slim`. The Alpine variant was chosen deliberately: ~5 MB vs ~180 MB for Debian, reduced risk of vulnerabilities, and faster pull times. |
| [nginx-default.conf](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/nginx-default.conf) | Nginx configuration for the static site. |
| [deployment.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/deployment.yml) | Kubernetes Deployment with 2 replicas of the container (`stensel8/public-cloud-concepts:latest`). |
| [service.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/service.yml) | Kubernetes LoadBalancer Service on port 80. |
| [index.html](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/index.html) | Source code of the static site. |
