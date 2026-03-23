---
title: "Week 5: Monitoring & Observability"
linkTitle: "Week 5"
weight: 5
---

In week 5 heb ik een volledige monitoring stack opgezet in Kubernetes. Ik gebruik Prometheus voor metrics, Loki voor log-aggregatie, Grafana Alloy als log-collector (opvolger van Promtail) en Grafana als visualisatietool.

De stack draait op een GKE Standard cluster. Grafana is bereikbaar via `grafana.stijhuis.nl` dankzij een Ingress en een DNS A-record bij Bunny DNS.

Verder heb ik SIEM, SOAR en de TerramEarth-casestudy rondom monitoring en observability uitgewerkt.
