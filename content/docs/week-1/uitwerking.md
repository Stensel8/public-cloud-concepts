---
title: "Uitwerking"
weight: 2
---

<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week1.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week1.yml/badge.svg" alt="CI Week 1" style="display:inline;vertical-align:middle;" /></a>

## 1.1 Google Cloud & GKE - Voltooide Badges

Voltooide badges via [Google Cloud Skills Boost](https://www.skills.google/public_profiles/d92d9d25-7174-4f3a-8f70-fab880429afe):

<a href="https://www.skills.google/public_profiles/d92d9d25-7174-4f3a-8f70-fab880429afe"><img src="https://cdn.qwiklabs.com/V%2FuXlPOWQoaDTrhNB3K%2Ba2p2wGiQZT7%2BODtWIPHmON4%3D" alt="Google Cloud Fundamentals: Core Infrastructure" width="120"></a>
<a href="https://www.skills.google/public_profiles/d92d9d25-7174-4f3a-8f70-fab880429afe"><img src="https://cdn.qwiklabs.com/sgKmjMjD%2BpyCGA4VRZkhXxeonasfqbo8j85m8b5gC%2Bg%3D" alt="Essential Google Cloud Infrastructure: Core Services" width="120"></a>
<a href="https://www.skills.google/public_profiles/d92d9d25-7174-4f3a-8f70-fab880429afe"><img src="https://cdn.qwiklabs.com/HPtjPjHuWp197QQiSmfshQL2uNxmxDCHjWps43o10Cg%3D" alt="Getting Started with Google Kubernetes Engine" width="120"></a>

---

## 1.2 Kubernetes Uitdaging

### Opdracht 1 - Cluster Installatie

{{< callout type="info" >}}
De opdracht specificeert Ubuntu 24.04 LTS minimal. Ik heb **Ubuntu 25.10 LTS minimal** gebruikt.

Ubuntu 25.10 komt standaard met `sudo-rs` (een Rust-herimplementatie van sudo) versie 0.2.8. Deze versie heeft een bekende sessiebug - `sudo reboot` mislukt met een onverwachte fout. Opgelost via een GCP-opstartscript dat klassieke `sudo` installeert bij elke opstart.
{{< /callout >}}

![sudo-rs versie op een nieuwe Ubuntu 25.10](../media/sudo-rs-version.avif)

![sudo-rs bug: reboot mislukt](../media/sudo-rs-bug.avif)

![GCP opstartscript vervangt sudo-rs](../media/sudo-rs-startup-script.avif)

**Gebruikte instanties:**

| Node | Naam | Zone | Type | OS |
|------|------|------|------|----|
| Master | master-amsterdam | europe-west4-a (Nederland) | e2-medium | Ubuntu 25.10 LTS minimal |
| Worker 1 | worker-brussels | europe-west1-b (België) | e2-medium | Ubuntu 25.10 LTS minimal |
| Worker 2 | worker-london | europe-west2-b (Verenigd Koninkrijk) | e2-medium | Ubuntu 25.10 LTS minimal |

![VM-instanties in Google Cloud](../media/vm-instances-gcp.avif)

![OS en opslagconfiguratie](../media/vm-os-storage-config.avif)

Het cluster is geïnstalleerd met twee shell-scripts: `configure_master.sh` voor de masternode en `configure_worker.sh` voor de workernodes. Deze scripts automatiseren kernelmoduleconfiguratie, containerd installeren, Kubernetes-pakketinstallatie (v1.35) en clusterinitialisatie.

![configure_master.sh uitvoeren op master-amsterdam](../media/configure-master-run.avif)

![configure_worker.sh uitvoeren op worker-brussels](../media/configure-worker-run.avif)

![Workers toegevoegd - alle nodes Ready](../media/cluster-nodes-joined.avif)

**Uitleg van `kubeadm init`:**

`kubeadm init` zet het Kubernetes-besturingsvlak op de masternode. Het genereert TLS-certificaten, schrijft kubeconfig-bestanden, maakt statische Pod-manifesten aan voor kerncomponenten (kube-apiserver, kube-controller-manager, kube-scheduler, etcd) en genereert een bootstrap-token voor workernodes.

**Uitleg van `kubectl apply -f kube-flannel.yml`:**

Installeert Flannel als CNI-plugin. Flannel maakt een VXLAN overlay-netwerk dat elke pod een uniek IP geeft, zodat pods op verschillende nodes direct communiceren. De CIDR `10.244.0.0/16` moet overeenkomen met de `--pod-network-cidr` van `kubeadm init`.

**Andere netwerk-CNIs:**

| CNI | Beschrijving |
|-----|-------------|
| **Flannel** | Eenvoudig L3 overlay-netwerk via VXLAN. Geen netwerkbeleidsondersteuning. |
| **Calico** | BGP-routing met volledige NetworkPolicy-ondersteuning. Veel gebruikt in productie. |
| **Cilium** | eBPF-gebaseerde CNI met geavanceerde observeerbaarheid en beveiliging. |
| **Weave Net** | Mesh overlay-netwerk, eenvoudige installatie, ondersteunt NetworkPolicy. |
| **Canal** | Combineert Flannel (networking) met Calico (netwerkbeleid). |

**1a - `kubectl get nodes`:**

```
NAME               STATUS   ROLES           AGE    VERSION
worker-brussels    Ready    <none>          14m    v1.35.1
worker-london      Ready    <none>          7m     v1.35.1
master-amsterdam   Ready    control-plane   17m    v1.35.1
```

![kubectl get pods -n kube-system](../media/kubectl-get-pods-kube-system.avif)

![kubectl get pods -n kube-flannel](../media/kubectl-get-pods-kube-flannel.avif)

**Verklaring van de kube-system pods:**

| Pod | Rol |
|-----|-----|
| `kube-apiserver` | Front-end van het besturingsvlak. Alle kubectl-commando's en interne componenten lopen via deze REST API. Alleen op de master. |
| `kube-controller-manager` | Voert alle controller-loops uit: juiste aantal pod-replica's, node-levenscycli, certificaatrotatie. Alleen op master. |
| `kube-scheduler` | Bewaakt niet-ingeplande pods en wijst ze toe aan een geschikte node. Alleen op master. |
| `etcd` | Gedistribueerde sleutel-waardeopslag met de volledige clusterstatus. Alleen op master. |
| `kube-proxy` | Beheert iptables/nftables-regels zodat Service-IPs correct naar pods routeren. Eén pod per node. |
| `coredns` | Cluster-interne DNS. Twee replica's voor redundantie. |

---

### Opdracht 2 - Gecontaineriseerde Applicatie

**Dockerfile:**

```dockerfile
FROM nginx:alpine
COPY static-site/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

- **`FROM nginx:alpine`**: Alpine-variant bewust gekozen: ~5 MB vs ~180 MB Debian, kleiner aanvalsoppervlak.
- **`COPY static-site/`**: Kopieert de website naar de nginx-documentroot.
- **`EXPOSE 80`**: Geeft aan dat de container luistert op poort 80.
- **`CMD ["nginx", "-g", "daemon off;"]`**: Start nginx op de voorgrond zodat de container actief blijft.

**GitHub Actions workflow:**

De workflow ([ci_week1.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/.github/workflows/ci_week1.yml)) bouwt en pusht het image als `stensel8/public-cloud-concepts:latest` bij elke push naar `main`.

**deployment.yaml:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: first-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-container
  template:
    metadata:
      labels:
        app: my-container
    spec:
      containers:
      - name: my-container
        image: stensel8/public-cloud-concepts:latest
        ports:
        - containerPort: 80
```

**2b - Pod-IPs:**

```
NAME                               IP           NODE
first-deployment-5ffbd9444c-5hkzs  10.244.2.2   worker-london
first-deployment-5ffbd9444c-s4xdb  10.244.1.2   worker-brussels
```

![kubectl apply uitvoer - pods in Pending status](../media/deployment-apply-pods-pending.avif)

![Beide pods Running](../media/deployment-pods-running.avif)

![curl en kubectl exec uitvoer](../media/curl-pod-and-exec.avif)

De respons bevestigt dat de nginx-container draait en de statische site serveert via het interne Flannel-IP. Externe toegang vereist een Kubernetes Service (Week 2).
