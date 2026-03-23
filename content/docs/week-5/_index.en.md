---
title: "Week 5: Monitoring & Observability"
linkTitle: "Week 5"
weight: 5
---

In week 5 I set up a complete monitoring stack in Kubernetes. I use Prometheus for metrics, Loki for log aggregation, Grafana Alloy as the log collector (successor to Promtail), and Grafana as the visualisation tool.

The stack runs on a GKE Standard cluster. Grafana is accessible via `grafana.stijhuis.nl` thanks to an Ingress and a DNS A-record at Bunny DNS.

I also worked through SIEM, SOAR, and the TerramEarth case study on monitoring and observability.
