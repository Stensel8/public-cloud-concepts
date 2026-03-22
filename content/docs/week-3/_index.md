---
title: "Week 3: CI/CD & Blue-Green Deployments"
linkTitle: "Week 3"
weight: 3
---

In week 3 automatiseren we de deployment-pipeline volledig. We gebruiken Google Artifact Registry als container registry (als alternatief voor Docker Hub) en richten een Blue-Green deployment in.

Bij een Blue-Green deployment draaien twee versies van de applicatie tegelijk. De Service stuurt al het verkeer naar één versie; overschakelen gaat zonder downtime door simpelweg de selector in de Service te wijzigen. De GitHub Actions pipeline zorgt ervoor dat elke push naar `main` of `development` automatisch leidt tot een nieuw image en een bijgewerkte deployment.

<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml/badge.svg" alt="CI Week 3 - Blue-Green Deploy" style="display:inline;vertical-align:middle;" /></a>
<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml/badge.svg" alt="Switch Blue-Green Slot" style="display:inline;vertical-align:middle;" /></a>
