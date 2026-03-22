---
title: "Week 5: Monitoring & Observability"
linkTitle: "Week 5"
weight: 5
---

In week 5 zetten we een volledige monitoring stack op in Kubernetes. We gebruiken Prometheus voor metrics, Loki voor log-aggregatie, Grafana Alloy als log-collector (opvolger van Promtail) en Grafana als visualisatietool.

De stack draait op een GKE Standard cluster. Grafana is bereikbaar via een publieke domeinnaam (`grafana.stijhuis.nl`) dankzij een Ingress en een DNS A-record bij Bunny DNS.

Naast de technische installatie behandelen we ook SIEM, SOAR en de TerramEarth-casestudy rondom monitoring en observability.
