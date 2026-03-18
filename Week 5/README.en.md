[Nederlands](README.md) | English

> [!NOTE]
> This repository is primarily maintained in **Dutch**. This English version may not always be fully up to date.

# Week 5 - Monitoring & Observability

## Topics

This week we set up a **monitoring environment** for Kubernetes using **Prometheus**, **Loki**, **Promtail** and **Grafana**. We also explore **SIEM** and **SOAR** in the context of the ITIL and DevOps frameworks, and apply this to the TerramEarth case study.

---

## Learning Goals

- Set up processes for proactive management of (hybrid) cloud environments
- Analyse observability in the cloud (including Microsoft 365 Defender, Microsoft Sentinel)
- Configure monitoring in Kubernetes with Prometheus, Loki and Grafana
- Get to know SIEM: running queries, visualising and monitoring data
- Give advice on how to improve security for SaaS solutions

---

## Assignments & Solutions

| Folder | Description |
|---|---|
| [Opdracht/](Opdracht/) | Assignments for week 5 |
| [Uitwerking/](Uitwerking/) | My solutions for week 5 |

---

## Course Files

| File | Description |
|---|---|
| [setup-loki-prometheus-grafana.sh](Bestanden/setup-loki-prometheus-grafana.sh) | Installation script for the monitoring stack |
| [grafana-values.yaml](Bestanden/grafana-values.yaml) | Helm values for Grafana |
| [loki-values.yaml](Bestanden/loki-values.yaml) | Helm values for Loki |
| [prometheus-values.yaml](Bestanden/prometheus-values.yaml) | Helm values for Prometheus |
| [promtail-values.yaml](Bestanden/promtail-values.yaml) | Helm values for Promtail |
