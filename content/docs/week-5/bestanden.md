---
title: "Bestanden"
weight: 3
---

Alle configuratiebestanden voor de monitoring stack van Week 5.

De **originele bestanden van de docent** staan in [`Week 5/Opdracht/Bestanden/`](https://github.com/Stensel8/public-cloud-concepts/tree/main/Week%205/Opdracht/Bestanden) — inclusief de deprecated charts (Promtail, loki-distributed).

De **verbeterde bestanden** staan in [`Week 5/Uitwerking/Bestanden/`](https://github.com/Stensel8/public-cloud-concepts/tree/main/Week%205/Uitwerking/Bestanden) — actuele charts zonder deprecated warnings.

---

## setup-loki-prometheus-grafana.sh

Het installatiescript dat de volledige stack in vijf stappen opzet.

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Helm repositories toevoegen en updaten..."
helm repo add grafana              https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo "[2/5] ingress-nginx controller installeren..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/cloud/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "[3/5] Loki installeren..."
helm upgrade --install \
  --namespace loki --create-namespace \
  --values loki-values.yaml \
  loki grafana/loki

echo "[4/5] Alloy installeren..."
helm upgrade --install \
  --namespace alloy --create-namespace \
  --values alloy-values.yaml \
  alloy grafana/alloy

echo "[5/5] Prometheus + Grafana installeren..."
helm upgrade --install \
  --namespace prometheus --create-namespace \
  --values prometheus-values.yaml \
  prometheus prometheus-community/kube-prometheus-stack
```

---

## loki-values.yaml

```yaml
deploymentMode: SingleBinary

loki:
  auth_enabled: false
  commonConfig:
    replication_factor: 1
  storage:
    type: filesystem
  schemaConfig:
    configs:
      - from: "2024-04-01"
        store: tsdb
        object_store: filesystem
        schema: v13
        index:
          prefix: loki_index_
          period: 24h
  pattern_ingester:
    enabled: true
  limits_config:
    allow_structured_metadata: true
    volume_enabled: true
    retention_period: 336h
  ruler:
    enable_api: true

singleBinary:
  replicas: 1
  persistence:
    storageClass: standard-rwo
    size: 5Gi

# Alle gedistribueerde componenten uitschakelen (vereist voor SingleBinary)
read:
  replicas: 0
write:
  replicas: 0
backend:
  replicas: 0
# ... (overige gedistribueerde componenten ook op 0)

minio:
  enabled: false
```

---

## alloy-values.yaml

Alloy vervangt Promtail en gebruikt de Alloy flow language om logs van Kubernetes pods te verzamelen en door te sturen naar Loki.

```yaml
alloy:
  configMap:
    content: |
      discovery.kubernetes "pod" {
        role = "pod"
      }

      discovery.relabel "pod_logs" {
        targets = discovery.kubernetes.pod.targets
        rule {
          source_labels = ["__meta_kubernetes_namespace"]
          target_label  = "namespace"
        }
        rule {
          source_labels = ["__meta_kubernetes_pod_name"]
          target_label  = "pod"
        }
        rule {
          source_labels = ["__meta_kubernetes_pod_container_name"]
          target_label  = "container"
        }
        rule {
          source_labels = ["__meta_kubernetes_pod_node_name"]
          target_label  = "node"
        }
      }

      loki.source.kubernetes "logs" {
        targets    = discovery.relabel.pod_logs.output
        forward_to = [loki.write.loki.receiver]
      }

      loki.write "loki" {
        endpoint {
          url = "http://loki-gateway.loki.svc.cluster.local/loki/api/v1/push"
        }
      }

serviceAccount:
  create: true
  name: alloy-sa

rbac:
  create: true
```

---

## prometheus-values.yaml

Grafana is gebundeld in de `kube-prometheus-stack` - geen aparte `grafana/grafana` release nodig.

```yaml
alertmanager:
  enabled: false

grafana:
  enabled: true
  adminUser: sten
  adminPassword: <wachtwoord>

  ingress:
    enabled: true
    ingressClassName: nginx
    hosts:
      - grafana.stijhuis.nl

  persistence:
    type: pvc
    enabled: true
    storageClass: "standard-rwo"
    size: 1Gi

  additionalDataSources:
    - name: loki
      type: loki
      url: http://loki-gateway.loki.svc.cluster.local

prometheus:
  enabled: true
  prometheusSpec:
    scrapeInterval: 10s
    evaluationInterval: 30s
    retention: 4d
    replicas: 1
```
