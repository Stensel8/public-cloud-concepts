---
title: "Bestanden"
weight: 3
---

Alle Kubernetes-configuratiebestanden die gebruikt zijn voor Week 2. De broncode staat op [GitHub](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-2/bestanden).

<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week2.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week2.yml/badge.svg" alt="CI Week 2" style="display:inline;vertical-align:middle;" /></a>

---

## bison/

De Bison-applicatie simuleert een schoolwebsite, bereikbaar via `bison.mysaxion.nl`.

| Bestand | Beschrijving |
|---------|-------------|
| [deployment.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/bison/deployment.yml) | Kubernetes Deployment met 2 replicas, image-tag `bison`. |
| [service.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/bison/service.yml) | ClusterIP Service op poort 80. |
| [dockerfile](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/bison/dockerfile) | Dockerfile voor de Bison-container. |
| [index.html](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/bison/index.html) | Broncode van de Bison-pagina. |

## brightspace/

De Brightspace-applicatie, bereikbaar via `brightspace.mysaxion.nl`. Identieke structuur aan Bison, met image-tag `brightspace`.

| Bestand | Beschrijving |
|---------|-------------|
| [deployment.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/brightspace/deployment.yml) | Kubernetes Deployment met 2 replicas, image-tag `brightspace`. |
| [service.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/brightspace/service.yml) | ClusterIP Service op poort 80. |
| [dockerfile](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/brightspace/dockerfile) | Dockerfile voor de Brightspace-container. |
| [index.html](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/brightspace/index.html) | Broncode van de Brightspace-pagina. |

## ingress.yml

| Bestand | Beschrijving |
|---------|-------------|
| [ingress.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/ingress.yml) | Kubernetes Ingress die binnenkomend verkeer op basis van de `Host` HTTP-header naar de juiste service stuurt. Beide applicaties zijn zo via één extern IP-adres bereikbaar. |
