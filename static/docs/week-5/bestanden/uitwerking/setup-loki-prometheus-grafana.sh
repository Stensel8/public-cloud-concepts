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

wait_for_pods() {
  local namespace="$1"
  local selector="$2"
  local appear_timeout="$3"
  local ready_timeout="$4"
  local waited=0

  echo "      Wachten tot pods bestaan voor selector: ${selector}"
  while true; do
    if kubectl -n "${namespace}" get pods -l "${selector}" --no-headers 2>/dev/null | grep -q .; then
      break
    fi

    if [ "${waited}" -ge "${appear_timeout}" ]; then
      echo "FOUT: Geen pods gevonden in namespace '${namespace}' met selector '${selector}' na ${appear_timeout}s."
      kubectl -n "${namespace}" get pods -o wide || true
      exit 1
    fi

    sleep 5
    waited=$((waited + 5))
  done

  kubectl wait --namespace "${namespace}" \
    --for=condition=ready pod \
    --selector="${selector}" \
    --timeout="${ready_timeout}"
}

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

echo "      Wachten tot Loki pods Ready zijn..."
wait_for_pods "loki" "app.kubernetes.io/instance=loki" 180 300s
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

echo "      Wachten tot Alloy pods Ready zijn..."
wait_for_pods "alloy" "app.kubernetes.io/instance=alloy" 180 300s
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

echo "      Wachten tot Prometheus Operator en Grafana uitgerold zijn..."
kubectl rollout status deployment/prometheus-kube-prometheus-operator \
  --namespace prometheus \
  --timeout=600s
kubectl rollout status deployment/prometheus-grafana \
  --namespace prometheus \
  --timeout=900s

echo "      Wachten tot Prometheus StatefulSet klaar is..."
kubectl rollout status statefulset/prometheus-prometheus-kube-prometheus \
  --namespace prometheus \
  --timeout=900s

echo "      Controle op Grafana service endpoints..."
GRAFANA_ENDPOINTS="$(kubectl -n prometheus get endpoints prometheus-grafana -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null || true)"
if [[ -z "${GRAFANA_ENDPOINTS}" ]]; then
  echo "FOUT: Grafana service heeft nog geen ready endpoints."
  echo "Diagnose:"
  kubectl -n prometheus get svc prometheus-grafana || true
  kubectl -n prometheus get endpoints prometheus-grafana -o yaml || true
  kubectl -n prometheus get pods -o wide
  kubectl -n prometheus describe pod -l app.kubernetes.io/name=grafana || true
  exit 1
fi
echo ""

# ------------------------------------------------------------------------------
echo "=================================================="
echo " Installatie voltooid."
echo " Controleer de pods met:"
echo "   kubectl get pods -A"
echo "=================================================="
echo ""
