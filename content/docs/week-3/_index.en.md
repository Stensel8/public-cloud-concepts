---
title: "Week 3: CI/CD & Blue-Green Deployments"
linkTitle: "Week 3"
weight: 3
---

In week 3 I fully automated the deployment pipeline. I use Google Artifact Registry as the container registry instead of Docker Hub, and set up a Blue-Green deployment.

With Blue-Green, two versions run simultaneously in Kubernetes. The service routes all traffic to one version. Switching happens without downtime by simply updating the selector in the service. Every push to `main` or `development` automatically triggers a new image build and updated deployment via GitHub Actions.

[![CI Week 3 - Blue-Green Deploy](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml) [![Week 3 - Switch Blue-Green Slot](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml)
