# install loki (SingleBinary - vervangt deprecated loki-distributed)
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install --namespace loki --create-namespace --values loki-values.yaml loki grafana/loki
# install alloy (vervangt deprecated promtail)
helm upgrade --install --namespace alloy --create-namespace --values alloy-values.yaml alloy grafana/alloy
# install prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install --namespace prometheus --create-namespace --values prometheus-values.yaml prometheus prometheus-community/kube-prometheus-stack
# install grafana
helm upgrade --install --namespace grafana --create-namespace --values grafana-values.yaml grafana grafana/grafana
# install ingress-nginx controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/cloud/deploy.yaml
