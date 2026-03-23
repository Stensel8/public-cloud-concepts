---
title: "Files"
weight: 3
---

All configuration files for the monitoring stack of Week 5. The source code is on [GitHub](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-5/bestanden).

---

## Assignment (school material)

Original files from the teacher, including deprecated charts (Promtail, loki-distributed).

| File | Description |
|------|-------------|
| [setup-loki-prometheus-grafana.sh](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/opdracht/setup-loki-prometheus-grafana.sh) | Installs the monitoring stack via Helm: Loki (loki-distributed), Promtail, and a standalone Grafana. |
| [loki-values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/opdracht/loki-values.yaml) | Helm values for `grafana/loki-distributed` (deprecated). |
| [prometheus-values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/opdracht/prometheus-values.yaml) | Helm values for `prometheus-community/kube-prometheus-stack`. |
| [grafana-values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/opdracht/grafana-values.yaml) | Helm values for the standalone `grafana/grafana` chart (deprecated, now bundled in kube-prometheus-stack). |
| [promtail-values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/opdracht/promtail-values.yaml) | Helm values for `grafana/promtail` (deprecated, replaced by Alloy). |

## Solution

Improved files using up-to-date charts without deprecated warnings.

| File | Description |
|------|-------------|
| [setup-loki-prometheus-grafana.sh](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/uitwerking/setup-loki-prometheus-grafana.sh) | Installs the stack in five steps: ingress-nginx, Loki (SimpleScalable), Alloy, Prometheus + Grafana (bundled). |
| [loki-values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/uitwerking/loki-values.yaml) | Helm values for `grafana/loki` in SimpleScalable mode, with `schema_config` and 14-day retention. |
| [prometheus-values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/uitwerking/prometheus-values.yaml) | Helm values for `prometheus-community/kube-prometheus-stack`, including Grafana and Ingress configuration. |
| [grafana-values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/uitwerking/grafana-values.yaml) | Grafana-specific settings (hostname, TLS, datasources). |
| [alloy-values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/uitwerking/alloy-values.yaml) | Helm values for `grafana/alloy`: pod discovery, label relabelling, and log push to the Loki gateway. |
| [mywebsite.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/uitwerking/mywebsite.yaml) | Kubernetes Deployment, Service, and Ingress for the static website from Week 1 and 2. |
