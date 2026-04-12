---
title: "Bestanden"
weight: 3
---

Alle scripts en configuratiebestanden die gebruikt zijn voor Week 1. De broncode staat op [GitHub](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-1/bestanden).

[![CI Week 1](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week1.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week1.yml)

---

## Scripts

| Bestand | Beschrijving |
|---------|-------------|
| [configure_master.sh](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/configure_master.sh) | Richt de Kubernetes **masternode** in op Ubuntu 25.10. Doorloopt tien stappen: systeemupdates, kernelmodules, containerd installeren en configureren (inclusief `SystemdCgroup = true` via een Python patch), Kubernetes v1.35-pakketten, swap uitschakelen, `kubeadm init` en Flannel CNI installeren. |
| [configure_worker.sh](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/configure_worker.sh) | Richt een **workernode** in. Voert dezelfde stappen 1-8 uit als het master-script, maar geen `kubeadm init`. Na dit script voer je het `kubeadm join ...`-commando van de master uit. |
| [AUTOSTART-configure_classic_sudo.sh](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/AUTOSTART-configure_classic_sudo.sh) | GCP startup-script dat bij elke opstart klassieke `sudo` installeert ter vervanging van `sudo-rs`. Ubuntu 25.10 wordt standaard geleverd met `sudo-rs` (versie 0.2.8), dat een sessiebug heeft waardoor `sudo reboot` mislukt. |
| [Installmastertemplate.sh](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/Installmastertemplate.sh) | Template-script voor masternode installatie. |
| [installnode.sh](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/installnode.sh) | Installatiescript voor een generieke node. |

## Applicatie

| Bestand | Beschrijving |
|---------|-------------|
| [Dockerfile](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/Dockerfile) | Bouwt de statische site op basis van `nginx:1-alpine-slim`. De Alpine-variant is bewust gekozen: ~5 MB versus ~180 MB voor Debian, minder kans op kwetsbaarheden en snellere pull-tijden. |
| [nginx-default.conf](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/nginx-default.conf) | Nginx-configuratie voor de statische site. |
| [deployment.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/deployment.yml) | Kubernetes Deployment met 2 replicas van de container (`stensel8/public-cloud-concepts:latest`). |
| [service.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/service.yml) | Kubernetes LoadBalancer Service op poort 80. |
| [index.html](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/index.html) | Broncode van de statische site. |
