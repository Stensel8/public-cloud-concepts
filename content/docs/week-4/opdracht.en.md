---
title: "Assignment"
weight: 1
---

The week 4 assignment consists of two parts: studying the package manager **Helm** and studying **IAM**.

---

## 4.1 Helm

Helm is the package manager for Kubernetes. Instead of manually applying individual `deployment.yaml` and `service.yaml` files, Helm bundles everything into a **chart**: a single installable package.

There are three key concepts in Helm:

1. The **chart** is a bundle containing all information needed to create an instance of a Kubernetes application.
2. The **config** (e.g. `values.yaml`) contains configuration information that can be merged with a chart to create a release object.
3. A **release** is a running instance of a chart combined with a specific configuration.

### a) Default chart

1. Create an Autopilot GKE cluster in Google Cloud and connect to it via the Cloud Console or via the Google CLI on your PC.

   > Helm is already installed in the Cloud Console. If you use the Google CLI on your PC, first download the `helm` binary and place it in a directory.

2. Create a Helm chart yourself (e.g. `MyChart`) and study its contents:

   ```bash
   helm create mychart
   ```

3. Describe the contents of the Helm chart and explain the different components.

4. Install the Helm chart on the Kubernetes cluster:

   ```bash
   helm install mychart-v1 mychart
   ```

5. Check the `values.yaml` file and verify that `replicaCount` is set to `1` and that no Ingress has been created.

6. Update `values.yaml` so that an Ingress is created and set `replicaCount` to `2`.

7. Install the chart as version v2 and verify that everything works as expected:

   ```bash
   helm upgrade mychart-v1 mychart
   ```

   Verify with:

   ```bash
   helm ls
   kubectl get pods
   kubectl get services
   kubectl get deployments
   ```

8. Show how to remove a release:

   ```bash
   helm uninstall mychart-v1
   ```

### b) Your own application

Copy the Helm chart you created in part a) and modify the copy so that the application from week 1 and 2 (your own Docker image) can be installed via the chart.

### c) WordPress via Artifact Hub

Install WordPress via a Helm chart from the Bitnami repository. Show that the application is running correctly.

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-wordpress bitnami/wordpress
```

Afterwards, remove all installations and delete the cluster.

---

## 4.2 IAM & Case Study: EHR Healthcare

EHR Healthcare (see the case description) is a company with on-premise infrastructure that wants to migrate to the cloud. They are particularly interested in security and IAM. In the cloud, IAM offers more functionality than an on-premise Active Directory.

Explain the following concepts as used in Azure, and advise EHR Healthcare whether they should use each concept. Justify your answer.

1. **Single Sign-On (SSO):** Can this also be configured for on-premise applications?
2. **Conditional Access**
3. **RBAC** (Role-Based Access Control)
4. **Identity Protection**
5. **Multi-Factor Authentication (MFA)**
6. **Managed Identities and Service Principals**
