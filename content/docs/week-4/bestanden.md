---
title: "Bestanden"
weight: 3
---

De Helm charts die aangemaakt zijn voor Week 4. De broncode staat op [GitHub](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-4/bestanden).

---

## public-cloud-concepts (standaard chart)

De standaard chart aangemaakt met `helm create public-cloud-concepts`. Gebruikt als basis om de structuur van een Helm chart te bestuderen.

| Bestand | Beschrijving |
|---------|-------------|
| [Chart.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-4/bestanden/public-cloud-concepts/Chart.yaml) | Metadata: naam, versie, beschrijving. |
| [values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-4/bestanden/public-cloud-concepts/values.yaml) | Standaard configuratiewaarden (replicaCount, image, service, ingress). |
| [templates/](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-4/bestanden/public-cloud-concepts/templates) | Deployment, Service, Ingress, HPA, ServiceAccount, NOTES.txt en testbestanden. |

## static-site (eigen applicatie)

Kopie van de standaard chart, aangepast om de applicatie uit Week 1 en 2 te draaien (`stensel8/public-cloud-concepts:latest`).

| Bestand | Beschrijving |
|---------|-------------|
| [Chart.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-4/bestanden/static-site/Chart.yaml) | Metadata van de static-site chart. |
| [values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-4/bestanden/static-site/values.yaml) | Aangepaste waarden: repository `stensel8/public-cloud-concepts`, tag `latest`. |
| [templates/](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-4/bestanden/static-site/templates) | Zelfde structuur als de standaard chart. |
