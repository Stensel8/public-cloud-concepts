# install loki
helm repo add loki https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install --namespace loki --create-namespace --values loki-values.yaml loki loki/loki-distributed
# install promtail
helm repo add promtail https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install --namespace promtail --create-namespace --values promtail-values.yaml promtail promtail/promtail
#install prometheus
helm repo add prometheus https://prometheus-community.github.io/helm-charts
helm repo update
#install grafana
helm upgrade --install --namespace prometheus --create-namespace --values prometheus-values.yaml prometheus prometheus/kube-prometheus-stack
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade  --install --namespace grafana --create-namespace --values grafana-values.yaml grafana grafana/grafana
# install ingress-nginx controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/cloud/deploy.yaml