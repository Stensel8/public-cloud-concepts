---
title: "Week 3: CI/CD & Blue-Green Deployments"
linkTitle: "Week 3"
weight: 3
---

In week 3 heb ik de deployment-pipeline volledig geautomatiseerd. Ik gebruik Google Artifact Registry als container registry in plaats van Docker Hub, en heb een Blue-Green deployment ingericht.

Bij Blue-Green draaien twee versies tegelijk in Kubernetes. De service stuurt al het verkeer naar één versie. Switchen gaat zonder downtime door simpelweg de selector in de service aan te passen. Elke push naar `main` of `development` triggert automatisch een nieuw image en een bijgewerkte deployment via GitHub Actions.

[![CI Week 3 - Blue-Green Deploy](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml)
[![Week 3 - Switch Blue-Green Slot](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml)
