---
title: "Files"
weight: 3
---

Kubernetes configuration files for the Blue-Green deployment of Week 3. The source code is on [GitHub](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-3/bestanden).

[![CI Week 3 - Blue-Green Deploy](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml)
[![Week 3 - Switch Blue-Green Slot](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml)

---

| File | Description |
|------|-------------|
| [deployment-blue.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-3/bestanden/deployment-blue.yml) | Blue slot running on the `main` branch. The `${IMAGE_TAG}` is filled in by the GitHub Actions pipeline on every push. |
| [deployment-green.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-3/bestanden/deployment-green.yml) | Green slot running on the `development` branch. Identical structure to Blue, but with `slot: green`. |
| [service.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-3/bestanden/service.yml) | LoadBalancer Service that points to the Blue slot by default. Switching is done without downtime by updating the `selector`; both deployments keep running simultaneously. |

{{< callout type="info" >}}
Switching is done without downtime. Kubernetes updates the selector and immediately routes traffic to the other slot. Both deployments keep running at the same time.
{{< /callout >}}
