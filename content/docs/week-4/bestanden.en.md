---
title: "Files"
weight: 3
---

The Helm charts created for Week 4. The source code is on [GitHub](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-4/bestanden).

---

## public-cloud-concepts (default chart)

The default chart created with `helm create public-cloud-concepts`. Used as a base to study the structure of a Helm chart.

| File | Description |
|------|-------------|
| [Chart.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-4/bestanden/public-cloud-concepts/Chart.yaml) | Metadata: name, version, description. |
| [values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-4/bestanden/public-cloud-concepts/values.yaml) | Default configuration values (replicaCount, image, service, ingress). |
| [templates/](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-4/bestanden/public-cloud-concepts/templates) | Deployment, Service, Ingress, HPA, ServiceAccount, NOTES.txt and test files. |

## static-site (own application)

A copy of the default chart, modified to run the application from Week 1 and 2 (`stensel8/public-cloud-concepts:latest`).

| File | Description |
|------|-------------|
| [Chart.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-4/bestanden/static-site/Chart.yaml) | Metadata of the static-site chart. |
| [values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-4/bestanden/static-site/values.yaml) | Customised values: repository `stensel8/public-cloud-concepts`, tag `latest`. |
| [templates/](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-4/bestanden/static-site/templates) | Same structure as the default chart. |
