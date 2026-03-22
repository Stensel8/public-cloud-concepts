# public-cloud-concepts Helm Chart

Standaard Helm chart gegenereerd met `helm create public-cloud-concepts`. Het image is de standaard `nginx` en is niet aangepast.

De chart met mijn eigen applicatie staat in [`../static-site/`](../static-site/).

## Structuur

```
public-cloud-concepts/
├── Chart.yaml
├── values.yaml
├── .helmignore
└── templates/
    ├── _helpers.tpl
    ├── deployment.yaml
    ├── service.yaml
    ├── serviceaccount.yaml
    ├── ingress.yaml
    ├── hpa.yaml
    ├── httproute.yaml
    ├── NOTES.txt
    └── tests/
        └── test-connection.yaml
```

## Gebruik

```bash
# Installeren
helm install mychart-v1 ./public-cloud-concepts

# Upgraden
helm upgrade mychart-v1 ./public-cloud-concepts

# Verwijderen
helm uninstall mychart-v1
```
