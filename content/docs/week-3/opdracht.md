---
title: "Opdracht"
weight: 1
---

<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml/badge.svg" alt="CI Week 3 - Blue-Green Deploy" style="display:inline;vertical-align:middle;" /></a>
<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml/badge.svg" alt="Week 3 - Switch Blue-Green Slot" style="display:inline;vertical-align:middle;" /></a>

## 3.1 Blue-Green Deployment & Artifact Registry

In deze opdracht maken we een Blue-Green deployment voor een applicatie. Blue is de productieversie van de applicatie, Green is een nieuwe (test-)versie.

De applicatie is dezelfde als in week 1 en 2. De Blue-versie staat in de main-branch van de GitHub-repository, de Green-versie in een andere branch, bijvoorbeeld de test-branch.

Om de Docker-images op te slaan, gebruiken we nu de Google Artifact Registry - een alternatief voor Docker Hub.

Er wordt een pipeline aangemaakt zodat wanneer de code verandert, het Docker-image wordt gebouwd en het image gestart wordt in een pod op het Kubernetes-cluster in Google.

![Schema van de Blue-Green deployment met Artifact Registry en CI/CD-pipeline](/docs/week-3/media/opdracht/image-001.avif)

Voer de volgende stappen uit:

- Maak een Kubernetes-cluster aan met Google GKE.
- Maak een GitHub-repository aan met twee branches (`main` en bijvoorbeeld `test`). De `main`-branch bevat de productieversie van de applicatie; de `test`-branch de testversie. De applicatie is dezelfde als in week 1 en 2 (de testversie heeft enkele wijzigingen in het `index.html`-bestand).
- Maak een Google Artifact Registry aan om de Docker-images met de applicatie op te slaan (als alternatief voor DockerHub).
- Maak een CI/CD-pipeline aan voor elke branch en gebruik omgevingsvariabelen voor region, cluster, etc. Gebruik <https://medium.com/@gravish316/setup-ci-cd-using-github-actions-to-deploy-to-google-kubernetes-engine-ef465a482fd> voor het opzetten van de pipeline. Pas de gegeven pipeline aan zodat die werkt in jouw omgeving.
- Maak deployments en de service aan voor een Blue-Green deployment.
- Deploy en test de productie- en testversie van de applicatie naar het Kubernetes-cluster via de pipeline.
- Schakel van blue naar green en terug door de service aan te passen. Controleer of de switch correct werkt.

## 3.2 Andere CI/CD-tools

Andere tools naast GitHub Actions zijn Argo CD en Flux CD. Onderzoek wat deze tools zijn en wat het verschil is met GitHub Actions.
