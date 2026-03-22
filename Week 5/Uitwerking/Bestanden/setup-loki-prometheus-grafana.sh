#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Week 5 - Monitoring stack setup (Poging 2 - gemoderniseerde versie)
# Installeert: ingress-nginx · Loki · Alloy · Prometheus + Grafana (gebundeld)
# =============================================================================

echo ""
echo "=================================================="
echo " Week 5 - Monitoring stack installatie"
echo " Loki · Alloy · Prometheus · Grafana · ingress-nginx"
echo "=================================================="
echo ""
sleep 2

# ------------------------------------------------------------------------------
echo "[1/5] Helm repositories toevoegen en updaten..."
# ------------------------------------------------------------------------------
helm repo add grafana              https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
echo ""
sleep 1

# ------------------------------------------------------------------------------
echo "[2/5] ingress-nginx controller installeren..."
# ------------------------------------------------------------------------------
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/cloud/deploy.yaml
echo ""
echo "      Wachten tot ingress-nginx admission webhook gereed is..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
echo ""
sleep 1

# ------------------------------------------------------------------------------
echo "[3/5] Loki installeren..."
# ------------------------------------------------------------------------------
helm upgrade --install \
  --namespace loki \
  --create-namespace \
  --values loki-values.yaml \
  loki grafana/loki
echo ""
sleep 1

# ------------------------------------------------------------------------------
echo "[4/5] Alloy installeren..."
# ------------------------------------------------------------------------------
helm upgrade --install \
  --namespace alloy \
  --create-namespace \
  --values alloy-values.yaml \
  alloy grafana/alloy
echo ""
sleep 1

# ------------------------------------------------------------------------------
echo "[5/5] Prometheus + Grafana installeren..."
# ------------------------------------------------------------------------------
helm upgrade --install \
  --namespace prometheus \
  --create-namespace \
  --values prometheus-values.yaml \
  prometheus prometheus-community/kube-prometheus-stack
echo ""

# ------------------------------------------------------------------------------
echo "=================================================="
echo " Installatie voltooid."
echo " Controleer de pods met:"
echo "   kubectl get pods -A"
echo "=================================================="
echo ""
