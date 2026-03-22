---
title: "Bestanden"
weight: 3
---

Kubernetes-configuratiebestanden voor de Blue-Green deployment van Week 3. De broncode staat op [GitHub](https://github.com/Stensel8/public-cloud-concepts/tree/main/Week%203/Bestanden).

<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week3.yml/badge.svg" alt="CI Week 3 - Blue-Green Deploy" style="display:inline;vertical-align:middle;" /></a>
<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/switch-slot.yml/badge.svg" alt="Switch Blue-Green Slot" style="display:inline;vertical-align:middle;" /></a>

---

## deployment-blue.yml

De Blue slot draait op de `main` branch. Het image-tag `${IMAGE_TAG}` wordt door de GitHub Actions pipeline ingevuld bij elke push.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-blue
  labels:
    app: public-cloud-concepts
    slot: blue
spec:
  replicas: 1
  selector:
    matchLabels:
      app: public-cloud-concepts
      slot: blue
  template:
    metadata:
      labels:
        app: public-cloud-concepts
        slot: blue
    spec:
      containers:
        - name: app
          image: ${IMAGE_TAG}
          imagePullPolicy: Always
          ports:
            - containerPort: 80
```

---

## deployment-green.yml

De Green slot draait op de `development` branch. Identieke structuur als Blue, maar met `slot: green`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-green
  labels:
    app: public-cloud-concepts
    slot: green
spec:
  replicas: 1
  selector:
    matchLabels:
      app: public-cloud-concepts
      slot: green
  template:
    metadata:
      labels:
        app: public-cloud-concepts
        slot: green
    spec:
      containers:
        - name: app
          image: ${IMAGE_TAG}
          imagePullPolicy: Always
          ports:
            - containerPort: 80
```

---

## service.yml

De Service verwijst standaard naar de Blue slot. Om te switchen naar Green: verander `slot: blue` naar `slot: green` in de selector, of gebruik de `switch-slot` GitHub Actions workflow.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: public-cloud-concepts
spec:
  type: LoadBalancer
  selector:
    app: public-cloud-concepts
    slot: blue
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

{{< callout type="info" >}}
Switchen gaat zonder downtime. Kubernetes past de selector aan en stuurt verkeer direct naar de andere slot. Beide deployments blijven tegelijk draaien.
{{< /callout >}}
