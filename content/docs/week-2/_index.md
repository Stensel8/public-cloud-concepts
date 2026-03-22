---
title: "Week 2 — Kubernetes Services & Ingress"
linkTitle: "Week 2"
weight: 2
---

In week 2 breiden we de Week 1-setup uit met Kubernetes Services en Ingress. Een pod heeft een tijdelijk IP-adres dat verandert zodra de pod herstart. Services lossen dit op door een stabiel virtueel IP te bieden.

We testen de drie service-typen (ClusterIP, NodePort, LoadBalancer) op zowel het zelfgebouwde kubeadm-cluster als op GKE. Tot slot zetten we een Ingress op waarmee meerdere applicaties via één extern IP-adres bereikbaar zijn.

<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week2.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week2.yml/badge.svg" alt="CI Week 2" style="display:inline;vertical-align:middle;" /></a>
