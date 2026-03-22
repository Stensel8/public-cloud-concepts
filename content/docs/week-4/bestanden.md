---
title: "Bestanden"
weight: 3
---

De Helm charts die aangemaakt zijn voor Week 4. De broncode staat op [GitHub](https://github.com/Stensel8/public-cloud-concepts/tree/main/Week%204/Uitwerking).

---

## public-cloud-concepts (standaard chart)

De standaard chart aangemaakt met `helm create public-cloud-concepts`. Gebruikt als basis om de structuur van een Helm chart te bestuderen.

**Chart.yaml**

```yaml
apiVersion: v2
name: public-cloud-concepts
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "1.16.0"
```

**Chartstructuur:**

```
public-cloud-concepts/
├── Chart.yaml          # Metadata: naam, versie, beschrijving
├── values.yaml         # Standaard configuratiewaarden
├── .helmignore         # Bestanden uitgesloten van packaging
└── templates/
    ├── _helpers.tpl    # Herbruikbare template-functies
    ├── deployment.yaml # Kubernetes Deployment
    ├── service.yaml    # Kubernetes Service
    ├── ingress.yaml    # Kubernetes Ingress (optioneel)
    ├── hpa.yaml        # Horizontal Pod Autoscaler (optioneel)
    ├── serviceaccount.yaml
    ├── NOTES.txt       # Instructies die na installatie worden getoond
    └── tests/
        └── test-connection.yaml
```

**Kernwaarden in values.yaml (v2 - na upgrade):**

```yaml
replicaCount: 2

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: ""

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  className: ""
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
```

---

## static-site (eigen applicatie)

Kopie van de standaard chart, aangepast om de applicatie uit Week 1 en 2 te draaien.

**Aanpassing in values.yaml:**

```yaml
image:
  repository: stensel8/public-cloud-concepts
  tag: "latest"
```

Installeren en testen:

```bash
helm install static-site-v1 ./static-site
kubectl port-forward svc/static-site-v1 8080:80
```
