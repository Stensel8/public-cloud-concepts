---
title: "Solution"
weight: 2
---

## 4.1 Helm

Helm is the package manager for Kubernetes. Instead of manually applying individual YAML files, Helm bundles everything into a **chart**.

There are three core concepts:

1. A **chart** is a bundle with all the information needed to install a Kubernetes application.
2. The **config** (`values.yaml`) contains configuration that can be merged with a chart.
3. A **release** is a running instance of a chart combined with specific configuration.

Installation via the [official Helm docs](https://helm.sh/docs/intro/install/).

---

### a) Default chart

**Creating the cluster:**

An Autopilot GKE cluster was created: `week4-cluster`.

![Creating Autopilot cluster week4-cluster in the Google Cloud Console](/docs/week-4/media/cluster-aanmaken.avif)

![Overview of the active week4-cluster](/docs/week-4/media/cluster-overzicht.avif)

{{< tabs >}}
{{< tab name="Linux" >}}
```bash
gcloud container clusters get-credentials week4-cluster --region=europe-west4
```
{{< /tab >}}
{{< tab name="Windows (PowerShell)" >}}
```powershell
gcloud container clusters get-credentials week4-cluster --region=europe-west4
```
{{< /tab >}}
{{< /tabs >}}

![Connecting to the cluster via gcloud](/docs/week-4/media/cluster-credentials.avif)

**Creating a Helm chart:**

```bash
helm create public-cloud-concepts
```

![Output of helm create public-cloud-concepts](/docs/week-4/media/helm-create.avif)

**Chart structure:**

- **`charts/`** - dependencies (empty by default)
- **`templates/`** - Kubernetes YAML files with variables from `values.yaml`
- **`Chart.yaml`** - metadata (name, version, description)
- **`values.yaml`** - default configuration values

Default values: `replicaCount: 1`, image `nginx`, `service.type: ClusterIP`, Ingress disabled.

![Viewing the contents of values.yaml](/docs/week-4/media/helm-values.avif)

**Installing as v1:**

```bash
helm install public-cloud-concepts-v1 public-cloud-concepts
```

![Output of helm install with STATUS deployed and REVISION 1](/docs/week-4/media/helm-install-v1.avif)

![helm ls, kubectl get pods and kubectl get services for v1](/docs/week-4/media/helm-status-v1.avif)

**Updating to v2:**

Two values changed in `values.yaml`:

```diff
-replicaCount: 1
+replicaCount: 2

 ingress:
-  enabled: false
+  enabled: true
```

![Diff of values.yaml - v1 to v2 changes](/docs/week-4/media/helm-values-v2-diff.avif)

```bash
helm upgrade public-cloud-concepts-v1 public-cloud-concepts
```

![Output of helm upgrade with STATUS deployed and REVISION 2](/docs/week-4/media/helm-upgrade-v2.avif)

![Both pods Running after upgrade to v2](/docs/week-4/media/helm-status-v2.avif)

```bash
helm history public-cloud-concepts-v1
# REVISION 1: superseded
# REVISION 2: deployed
```

![helm history shows revisions 1 (superseded) and 2 (deployed)](/docs/week-4/media/helm-history.avif)

**Rollback:**

```bash
helm rollback public-cloud-concepts-v1 1
```

**Uninstall:**

```bash
helm uninstall public-cloud-concepts-v1
```

![helm uninstall output](/docs/week-4/media/helm-uninstall.avif)

---

### b) Own application

The `static-site` chart uses the Docker image from Week 1 and 2. In `values.yaml` the default nginx image was replaced:

```diff
 image:
-  repository: nginx
+  repository: stensel8/public-cloud-concepts
+  tag: "latest"
```

```bash
helm install static-site-v1 ./static-site
```

![helm install static-site output](/docs/week-4/media/helm-install-static-site.avif)

```bash
kubectl port-forward svc/static-site-v1 8080:80
```

![kubectl port-forward tunnels local port 8080 to the pod in GKE](/docs/week-4/media/port-forward.avif)

![The static-site application running on localhost:8080](/docs/week-4/media/static-site-browser.avif)

---

### c) WordPress via Bitnami

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

The default `helm install bitnami/wordpress` does not work directly on GKE Autopilot. Three issues:

| Issue | Cause | Solution |
|---|---|---|
| WP-CLI rejects `user@example.com` | WordPress considers this an invalid email address | Pass `--set wordpressEmail` |
| Ephemeral storage limit 50Mi | GKE Autopilot sets a default 50Mi limit - WordPress writes more temporary files | Set storage requests and limits explicitly higher |
| LoadBalancer service missing | Bug in Bitnami WordPress chart v29.2.0 | Extract the Service manually from the Helm manifest and apply it |

```bash
helm install my-wordpress bitnami/wordpress \
    --set wordpressUsername=admin \
    --set wordpressPassword=MijnWachtwoord123 \
    --set wordpressEmail=admin@example.com \
    --set wordpressBlogName="Mijn Blog" \
    --set resources.requests.ephemeral-storage=1Gi \
    --set resources.limits.ephemeral-storage=2Gi \
    --set resources.requests.memory=256Mi \
    --set resources.requests.cpu=100m \
    --set mariadb.primary.resources.requests.ephemeral-storage=1Gi \
    --set mariadb.primary.resources.limits.ephemeral-storage=2Gi \
    --set mariadb.primary.resources.requests.memory=256Mi \
    --set mariadb.primary.resources.requests.cpu=100m
```

Service was missing after installation, created manually:

```bash
helm get manifest my-wordpress | awk '/Source: wordpress\/templates\/svc.yaml/,/^---/' | kubectl apply -f -
```

![kubectl get svc shows my-wordpress as LoadBalancer with external IP](/docs/week-4/media/wordpress-svc.avif)

![WordPress login page reachable at external GKE IP](/docs/week-4/media/wordpress-login.avif)

![WordPress blog "Mijn Blog" running publicly](/docs/week-4/media/wordpress-blog.avif)

**Cleanup:**

```bash
helm uninstall my-wordpress
kubectl delete pvc --selector app.kubernetes.io/instance=my-wordpress
gcloud container clusters delete week4-cluster --region=europe-west4
```

---

## 4.2 IAM & Case Study: EHR Healthcare

EHR Healthcare is a company with on-premise infrastructure that wants to migrate to the cloud. They are interested in security and IAM. For each requested concept I explained what it is and why I would recommend it for this company.

---

### 1. Single Sign-On (SSO)

SSO means you log in once and then have access to multiple applications without having to authenticate again each time. In Azure this goes via Microsoft Entra ID. Via Azure AD Application Proxy or SAML integration this also works for on-premise applications.

For EHR I would definitely use this. Fewer separate passwords means less phishing risk, and employees do not need to maintain a separate account for each application.

---

### 2. Conditional Access

Conditional Access is policy that determines under which circumstances access is granted, such as only from managed devices or requiring MFA when logging in from an unknown country.

For EHR this is essential. They work with sensitive patient data, so access should not depend purely on a password. Location, device and risk level should also be factored in.

---

### 3. RBAC (Role-Based Access Control)

With RBAC you assign permissions based on roles rather than individual users. In Azure this works at subscription level, resource group level, or resource level.

For a controlled migration this is essential. By defining roles in advance (e.g. "Database administrator", "Application administrator") management stays clear and permissions automatically follow personnel changes.

---

### 4. Identity Protection

Microsoft Entra Identity Protection automatically detects risky login attempts, such as sign-ins from anonymous IP addresses, impossible travel (logging in from Amsterdam and Tokyo within an hour), or leaked passwords.

Most attacks start with compromised credentials. Identity Protection detects this and can automatically enforce MFA or block accounts. For EHR I would definitely use this.

---

### 5. Multi-Factor Authentication (MFA)

MFA is a second verification step in addition to the password, such as an authenticator app, SMS, or hardware token.

For EHR I would make this mandatory for all employees. MFA blocks the vast majority of account attacks, even if a password has been leaked. For healthcare this is simply a baseline measure.

---

### 6. Managed Identities and Service Principals

Managed Identities are Azure-managed identities for applications and services. No password needed; Azure handles the credentials automatically. Service Principals are the manual variant where you manage credentials yourself.

For cloud-native applications, Managed Identity is the better choice. No stored passwords in configuration files, automatic rotation, and direct integration with Azure RBAC. Service Principals are only used when an application runs outside Azure and needs to access Azure resources.
