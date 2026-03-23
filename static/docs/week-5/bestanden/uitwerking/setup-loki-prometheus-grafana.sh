#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Week 5 - Monitoring stack setup
# Installeert: ingress-nginx · Loki · Alloy · Prometheus + Grafana · mywebsite
# =============================================================================

echo ""
echo "=================================================="
echo " Week 5 - Monitoring stack installatie"
echo " Loki · Alloy · Prometheus · Grafana · ingress-nginx · mywebsite"
echo "=================================================="
echo ""

# ------------------------------------------------------------------------------
echo "[0/6] Prerequisites controleren..."
# ------------------------------------------------------------------------------
PREREQ_OK=true

for tool in kubectl helm gcloud; do
  if ! command -v "${tool}" &>/dev/null; then
    echo "FOUT: '${tool}' is niet geïnstalleerd of niet gevonden in PATH."
    PREREQ_OK=false
  fi
done

# Controleer of gcloud een actief account heeft (alleen als gcloud aanwezig is)
if command -v gcloud &>/dev/null; then
  if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | grep -q .; then
    echo "FOUT: Geen actief gcloud account gevonden."
    echo "      Voer eerst uit: gcloud auth login"
    PREREQ_OK=false
  fi
fi

# Controleer of kubectl verbinding kan maken met het cluster
if command -v kubectl &>/dev/null; then
  if ! kubectl cluster-info &>/dev/null; then
    echo "FOUT: kubectl kan het cluster niet bereiken."
    echo "      Voer eerst uit: gcloud container clusters get-credentials <cluster> --region <region>"
    PREREQ_OK=false
  fi
else
  echo "FOUT: 'kubectl' ontbreekt, kan clusterinformatie niet ophalen."
  PREREQ_OK=false
fi

# Controleer of de benodigde values-bestanden aanwezig zijn
for f in loki-values.yaml alloy-values.yaml prometheus-values.yaml mywebsite.yaml; do
  if [ ! -f "${f}" ]; then
    echo "FOUT: Bestand '${f}' niet gevonden. Voer dit script uit vanuit de juiste map."
    PREREQ_OK=false
  fi
done

if [ "${PREREQ_OK}" = false ]; then
  echo ""
  echo "Los bovenstaande problemen op en probeer opnieuw."
  exit 1
fi

echo "      Alle prerequisites OK."
echo ""

# ------------------------------------------------------------------------------
echo "[1/6] Helm repositories toevoegen en updaten..."
# ------------------------------------------------------------------------------
helm repo add grafana              https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
echo ""

# ------------------------------------------------------------------------------
echo "[2/6] ingress-nginx controller installeren..."
# ------------------------------------------------------------------------------
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/cloud/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
echo ""

# ------------------------------------------------------------------------------
echo "[3/6] Loki installeren..."
# ------------------------------------------------------------------------------
helm upgrade --install \
  --namespace loki \
  --create-namespace \
  --values loki-values.yaml \
  loki grafana/loki
kubectl rollout status statefulset/loki --namespace loki --timeout=300s
echo ""

# ------------------------------------------------------------------------------
echo "[4/6] Alloy installeren..."
# ------------------------------------------------------------------------------
helm upgrade --install \
  --namespace alloy \
  --create-namespace \
  --values alloy-values.yaml \
  alloy grafana/alloy
kubectl rollout status daemonset/alloy --namespace alloy --timeout=300s
echo ""

# ------------------------------------------------------------------------------
echo "[5/6] Prometheus + Grafana installeren..."
# ------------------------------------------------------------------------------
helm upgrade --install \
  --namespace prometheus \
  --create-namespace \
  --values prometheus-values.yaml \
  prometheus prometheus-community/kube-prometheus-stack
kubectl rollout status deployment/prometheus-kube-prometheus-operator \
  --namespace prometheus --timeout=300s
kubectl rollout status deployment/prometheus-grafana \
  --namespace prometheus --timeout=600s
echo ""

# ------------------------------------------------------------------------------
echo "[6/6] Week 1 applicatie deployen..."
# ------------------------------------------------------------------------------
kubectl apply -f mywebsite.yaml
kubectl rollout status deployment/mywebsite --namespace mywebsite --timeout=120s
echo ""

# ------------------------------------------------------------------------------
echo "      Wachten tot Grafana Ingress een extern IP-adres krijgt..."
GRAFANA_IP=""
for i in $(seq 1 18); do
  GRAFANA_IP=$(kubectl -n prometheus get ingress prometheus-grafana \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
  [ -n "${GRAFANA_IP}" ] && break
  GRAFANA_IP=$(kubectl -n prometheus get ingress prometheus-grafana \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)
  [ -n "${GRAFANA_IP}" ] && break
  sleep 10
done

echo ""
echo "=================================================="
echo " Installatie voltooid."
echo ""
if [ -n "${GRAFANA_IP}" ]; then
  echo " Grafana Ingress IP: ${GRAFANA_IP}"
  echo ""
  echo " Stel een DNS A-record in:"
  echo "   grafana.stijhuis.nl  →  ${GRAFANA_IP}"
  echo "   mywebsite.stijhuis.nl  →  ${GRAFANA_IP}"
  echo ""
  echo " Of voeg tijdelijk toe aan /etc/hosts:"
  echo "   ${GRAFANA_IP}  grafana.stijhuis.nl"
  echo "   ${GRAFANA_IP}  mywebsite.stijhuis.nl"
else
  echo " Kon het Ingress IP-adres nog niet ophalen."
  echo " Controleer later met:"
  echo "   kubectl get ingress -n prometheus"
fi
echo ""
echo " Controleer alle pods met:"
echo "   kubectl get pods -A"
echo "=================================================="
echo ""
