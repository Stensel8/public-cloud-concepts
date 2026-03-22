---
title: "Bestanden"
weight: 3
---

Alle Kubernetes-configuratiebestanden die gebruikt zijn voor Week 2. De broncode staat op [GitHub](https://github.com/Stensel8/public-cloud-concepts/tree/main/Week%202/Bestanden).

<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week2.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week2.yml/badge.svg" alt="CI Week 2" style="display:inline;vertical-align:middle;" /></a>

---

## bison/

De Bison-applicatie simuleert een schoolwebsite, bereikbaar via `bison.mysaxion.nl`.

**deployment.yml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bison-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: bison
  template:
    metadata:
      labels:
        app: bison
    spec:
      containers:
      - name: bison
        image: stensel8/public-cloud-concepts:bison
        ports:
        - containerPort: 80
```

**service.yml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: bison-service
spec:
  type: ClusterIP
  selector:
    app: bison
  ports:
    - port: 80
      targetPort: 80
```

---

## brightspace/

De Brightspace-applicatie, bereikbaar via `brightspace.mysaxion.nl`. Identieke structuur aan Bison, met tag `brightspace`.

---

## ingress.yml

De Ingress stuurt binnenkomend verkeer op basis van de `Host` HTTP-header naar de juiste service. Zo zijn beide applicaties via één extern IP-adres bereikbaar.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-saxion
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: "bison.mysaxion.nl"
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: bison-service
            port:
              number: 80
  - host: "brightspace.mysaxion.nl"
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: brightspace-service
            port:
              number: 80
```
