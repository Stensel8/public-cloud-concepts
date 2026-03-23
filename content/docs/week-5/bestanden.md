---
title: "Bestanden"
weight: 3
---

Alle configuratiebestanden voor de monitoring stack van Week 5. De broncode staat op [GitHub](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-5/bestanden).

---

## Opdracht (schoolmateriaal)

Originele bestanden van de docent, inclusief deprecated charts (Promtail, loki-distributed).

| Bestand | Beschrijving |
|---------|-------------|
| [setup-loki-prometheus-grafana.sh](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/opdracht/setup-loki-prometheus-grafana.sh) | Installeert de monitoring stack via Helm: Loki (loki-distributed), Promtail en een losse Grafana. |
| [loki-values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/opdracht/loki-values.yaml) | Helm values voor `grafana/loki-distributed` (deprecated). |
| [prometheus-values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/opdracht/prometheus-values.yaml) | Helm values voor `prometheus-community/kube-prometheus-stack`. |
| [grafana-values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/opdracht/grafana-values.yaml) | Helm values voor de losse `grafana/grafana` chart (deprecated, nu gebundeld in kube-prometheus-stack). |
| [promtail-values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/opdracht/promtail-values.yaml) | Helm values voor `grafana/promtail` (deprecated, vervangen door Alloy). |

## Uitwerking

Verbeterde bestanden met actuele charts en zonder deprecated warnings.

| Bestand | Beschrijving |
|---------|-------------|
| [setup-loki-prometheus-grafana.sh](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/uitwerking/setup-loki-prometheus-grafana.sh) | Installeert de stack in vijf stappen: ingress-nginx, Loki (SimpleScalable), Alloy, Prometheus + Grafana (gebundeld). |
| [loki-values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/uitwerking/loki-values.yaml) | Helm values voor `grafana/loki` in SimpleScalable-modus, met `schema_config` en retentie van 14 dagen. |
| [prometheus-values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/uitwerking/prometheus-values.yaml) | Helm values voor `prometheus-community/kube-prometheus-stack`, inclusief Grafana en Ingress-configuratie. |
| [grafana-values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/uitwerking/grafana-values.yaml) | Grafana-specifieke instellingen (hostnaam, TLS, datasources). |
| [alloy-values.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/uitwerking/alloy-values.yaml) | Helm values voor `grafana/alloy`: pod discovery, label-relabeling en log push naar Loki gateway. |
| [mywebsite.yaml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-5/bestanden/uitwerking/mywebsite.yaml) | Kubernetes Deployment, Service en Ingress voor de static website uit Week 1 en 2. |
