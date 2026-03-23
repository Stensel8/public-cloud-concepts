---
title: "Week 2: Kubernetes Services & Ingress"
linkTitle: "Week 2"
weight: 2
---

In week 2 I expanded the week 1 setup with services and ingress. A pod has a temporary IP address that changes on restart. For external access and load balancing a stable endpoint is needed.

I worked through all three service types (ClusterIP, NodePort, LoadBalancer) on both the kubeadm cluster and on GKE, and set up Ingress so multiple applications are reachable via a single external IP.

[![CI Week 2](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week2.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week2.yml)
