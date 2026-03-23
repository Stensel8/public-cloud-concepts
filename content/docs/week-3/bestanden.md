---
title: "Bestanden"
weight: 3
---

Kubernetes-configuratiebestanden voor de Blue-Green deployment van Week 3. De broncode staat op [GitHub](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-3/bestanden).

[![CI Week 3 - Blue-Green Deploy](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml)
[![Week 3 - Switch Blue-Green Slot](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml)

---

| Bestand | Beschrijving |
|---------|-------------|
| [deployment-blue.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-3/bestanden/deployment-blue.yml) | Blue slot en draait op de `main` branch. Het `${IMAGE_TAG}` wordt door de GitHub Actions pipeline ingevuld bij elke push. |
| [deployment-green.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-3/bestanden/deployment-green.yml) | Green slot en draait op de `development` branch. Identieke structuur als Blue, maar met `slot: green`. |
| [service.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-3/bestanden/service.yml) | LoadBalancer Service die standaard naar de Blue slot wijst. Switchen gaat zonder downtime door de `selector` aan te passen; beide deployments blijven tegelijk draaien. |

{{< callout type="info" >}}
Switchen gaat zonder downtime. Kubernetes past de selector aan en stuurt verkeer direct naar de andere slot. Beide deployments blijven tegelijk draaien.
{{< /callout >}}
