---
title: "Opdracht"
weight: 1
---

De opdracht voor week 4 bestaat uit twee onderdelen: het bestuderen van de packagemanager **Helm** en het bestuderen van **IAM**.

---

## 4.1 Helm

Helm is de package manager voor Kubernetes. In plaats van handmatig losse `deployment.yaml`- en `service.yaml`-bestanden toe te passen, bundelt Helm alles in een **chart**: één installeerbaar pakket.

Er zijn drie belangrijke concepten in Helm:

1. De **chart** is een bundel met alle informatie die nodig is om een instantie van een Kubernetes-applicatie te maken.
2. De **config** (bijv. `values.yaml`) bevat configuratie-informatie die samengevoegd kan worden met een chart om een release-object te maken.
3. Een **release** is een draaiende instantie van een chart, gecombineerd met een specifieke configuratie.

### a) Standaard chart

1. Maak een Autopilot GKE-cluster aan in Google Cloud en verbind ermee via de Cloud Console of via de Google CLI op je pc.

   > In de Cloud Console is Helm al geïnstalleerd. Als je de Google CLI op je pc gebruikt, download dan eerst het `helm`-binaire bestand en plaats het in een directory.

2. Maak zelf een Helm chart aan (bijv. `MyChart`) en bestudeer de inhoud:

   ```bash
   helm create mychart
   ```

3. Beschrijf de inhoud van de Helm chart en leg de verschillende onderdelen uit.

4. Installeer de Helm chart op het Kubernetes-cluster:

   ```bash
   helm install mychart-v1 mychart
   ```

5. Controleer het `values.yaml`-bestand en stel vast dat `replicaCount` op `1` staat en dat er geen Ingress is aangemaakt.

6. Pas `values.yaml` aan zodat een Ingress wordt aangemaakt en stel `replicaCount` in op `2`.

7. Installeer de chart als versie v2 en controleer of alles werkt zoals verwacht:

   ```bash
   helm upgrade mychart-v1 mychart
   ```

   Controleer met:

   ```bash
   helm ls
   kubectl get pods
   kubectl get services
   kubectl get deployments
   ```

8. Laat zien hoe je een versie verwijdert:

   ```bash
   helm uninstall mychart-v1
   ```

### b) Eigen applicatie

Kopieer de Helm chart die je in deel a) hebt aangemaakt en pas de kopie aan zodat de applicatie uit week 1 en 2 (jouw eigen Docker-image) via de chart geïnstalleerd kan worden.

### c) WordPress via Artifact Hub

Installeer WordPress via een Helm chart uit de Bitnami-repository. Laat zien dat de applicatie correct draait.

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-wordpress bitnami/wordpress
```

Verwijder daarna alle installaties en verwijder het cluster.

---

## 4.2 IAM & Case Study: EHR Healthcare

EHR Healthcare (zie de casebeschrijving) is een bedrijf met een on-premise infrastructuur dat wil migreren naar de cloud. Ze zijn met name geïnteresseerd in beveiliging en IAM. In de cloud biedt IAM meer functionaliteit dan een on-premise Active Directory.

Leg de volgende concepten uit zoals ze worden gebruikt in Azure, en geef EHR Healthcare een advies of ze elk concept zouden moeten gebruiken. Motiveer je antwoord.

1. **Single Sign-On (SSO):** Kan dit ook geconfigureerd worden voor on-premise applicaties?
2. **Conditional Access**
3. **RBAC** (Role-Based Access Control)
4. **Identity Protection**
5. **Multi-Factor Authentication (MFA)**
6. **Managed Identities en Service Principals**
