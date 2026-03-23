---
title: "Files"
weight: 3
---

All Kubernetes configuration files used for Week 2. The source code is on [GitHub](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-2/bestanden).

[![CI Week 2](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week2.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week2.yml)

---

## bison/

The Bison application simulates a school website, accessible via `bison.mysaxion.nl`.

| File | Description |
|------|-------------|
| [deployment.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/bison/deployment.yml) | Kubernetes Deployment with 2 replicas, image tag `bison`. |
| [service.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/bison/service.yml) | ClusterIP Service on port 80. |
| [dockerfile](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/bison/dockerfile) | Dockerfile for the Bison container. |
| [index.html](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/bison/index.html) | Source code of the Bison page. |

## brightspace/

The Brightspace application, accessible via `brightspace.mysaxion.nl`. Identical structure to Bison, with image tag `brightspace`.

| File | Description |
|------|-------------|
| [deployment.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/brightspace/deployment.yml) | Kubernetes Deployment with 2 replicas, image tag `brightspace`. |
| [service.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/brightspace/service.yml) | ClusterIP Service on port 80. |
| [dockerfile](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/brightspace/dockerfile) | Dockerfile for the Brightspace container. |
| [index.html](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/brightspace/index.html) | Source code of the Brightspace page. |

## ingress.yml

| File | Description |
|------|-------------|
| [ingress.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/ingress.yml) | Kubernetes Ingress that routes incoming traffic to the correct service based on the `Host` HTTP header. Both applications are accessible via a single external IP address. |
