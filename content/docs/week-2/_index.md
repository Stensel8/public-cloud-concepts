---
title: "Week 2: Kubernetes Services & Ingress"
linkTitle: "Week 2"
weight: 2
---

In week 2 heb ik de week 1 setup gebruikt en uitgebreid met services en ingress. Een pod heeft een tijdelijk IP-adres wat niet vaststaat en verandert bij een herstart. Voor externe toegang en loadbalancing wil je een stabiel endpoint, want je gaat niet steeds die configs met de hand bijwerken.

Ik heb de drie service-typen uitgewerkt (ClusterIP, NodePort, LoadBalancer) op zowel het kubeadm-cluster als op GKE. Verder heb ik Ingress opgezet zodat meerdere applicaties via één extern IP beschikbaar zijn.

<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week2.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week2.yml/badge.svg" alt="CI Week 2" style="display:inline;vertical-align:middle;" /></a>
