---
title: "Week 1: Containerisatie & Kubernetes"
linkTitle: "Week 1"
weight: 1
---

In week 1 ben ik begonnen met Google Cloud Platform en Kubernetes. Ik heb een cluster opgezet met kubeadm op losse Ubuntu-instances, met een masternode in Nederland en workernodes in Brussel en Londen.

Daarna heb ik de applicatie gecontaineriseerd met Docker en een GitHub Actions pipeline ingericht die het image automatisch bouwt en pusht bij elke push naar `main`.

<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week1.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week1.yml/badge.svg" alt="CI Week 1" style="display:inline;vertical-align:middle;" /></a>
