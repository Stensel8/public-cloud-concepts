---
title: "Uitwerking"
weight: 2
---

[![CI Week 1](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week1.yml/badge.svg)](https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week1.yml)

## 1.1 Google Cloud & GKE - Voltooide Badges

Voltooide badges via [Google Skills](https://www.skills.google/public_profiles/d92d9d25-7174-4f3a-8f70-fab880429afe):

{{< cards >}}
  {{< card link="https://www.skills.google/public_profiles/d92d9d25-7174-4f3a-8f70-fab880429afe" title="Google Cloud Fundamentals: Core Infrastructure" image="https://cdn.qwiklabs.com/V%2FuXlPOWQoaDTrhNB3K%2Ba2p2wGiQZT7%2BODtWIPHmON4%3D" >}}
  {{< card link="https://www.skills.google/public_profiles/d92d9d25-7174-4f3a-8f70-fab880429afe" title="Essential Google Cloud Infrastructure: Core Services" image="https://cdn.qwiklabs.com/sgKmjMjD%2BpyCGA4VRZkhXxeonasfqbo8j85m8b5gC%2Bg%3D" >}}
  {{< card link="https://www.skills.google/public_profiles/d92d9d25-7174-4f3a-8f70-fab880429afe" title="Getting Started with Google Kubernetes Engine" image="https://cdn.qwiklabs.com/HPtjPjHuWp197QQiSmfshQL2uNxmxDCHjWps43o10Cg%3D" >}}
{{< /cards >}}

---

## 1.2 Kubernetes

### Opdracht 1 - Cluster Installatie

{{< callout type="info" >}}
De opdracht specificeert Ubuntu 24.04 LTS minimal. Ik heb **Ubuntu 25.10 LTS minimal** gebruikt.

Ubuntu 25.10 komt standaard met `sudo-rs` (een Rust-herimplementatie van sudo) versie 0.2.8. Deze versie heeft een bekende sessiebug - `sudo reboot` mislukt met een onverwachte fout. Opgelost via een GCP-opstartscript dat klassieke `sudo` installeert bij elke opstart.
{{< /callout >}}

![sudo-rs versie op een nieuwe Ubuntu 25.10](/docs/week-1/media/sudo-rs-version.avif)

![sudo-rs bug: reboot mislukt](/docs/week-1/media/sudo-rs-bug.avif)

![GCP opstartscript vervangt sudo-rs](/docs/week-1/media/sudo-rs-startup-script.avif)

**Gebruikte instanties:**

| Node | Naam | Zone | Type | OS |
|------|------|------|------|----|
| Master | master-amsterdam | europe-west4-a (Nederland) | e2-medium | Ubuntu 25.10 LTS minimal |
| Worker 1 | worker-brussels | europe-west1-b (België) | e2-medium | Ubuntu 25.10 LTS minimal |
| Worker 2 | worker-london | europe-west2-b (Verenigd Koninkrijk) | e2-medium | Ubuntu 25.10 LTS minimal |

![VM-instanties in Google Cloud](/docs/week-1/media/vm-instances-gcp.avif)

![OS en opslagconfiguratie](/docs/week-1/media/vm-os-storage-config.avif)

Het cluster is geïnstalleerd met twee shell-scripts: `configure_master.sh` voor de masternode en `configure_worker.sh` voor de workernodes. Deze scripts automatiseren kernelmoduleconfiguratie, containerd installeren, Kubernetes-pakketinstallatie (v1.35) en clusterinitialisatie.

![configure_master.sh uitvoeren op master-amsterdam](/docs/week-1/media/configure-master-run.avif)

![configure_worker.sh uitvoeren op worker-brussels](/docs/week-1/media/configure-worker-run.avif)

![Workers toegevoegd - alle nodes Ready](/docs/week-1/media/cluster-nodes-joined.avif)

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

![kubectl get pods -n kube-system](/docs/week-1/media/kubectl-get-pods-kube-system.avif)

![kubectl get pods -n kube-flannel](/docs/week-1/media/kubectl-get-pods-kube-flannel.avif)

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

**Dockerfile:** ([bekijk op GitHub](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/Dockerfile))

Een Dockerfile is een tekstbestand met instructies die Docker stap voor stap uitvoert om een image te bouwen. Elke instructie maakt een laag aan in het image. Docker kan lagen cachen: als een instructie niet veranderd is, gebruikt Docker de gecachede laag en hoeft hij die stap niet opnieuw uit te voeren. Dat maakt builds sneller.

De Dockerfile voor deze applicatie werkt als volgt:

```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
```

**`FROM nginx:alpine`**
Dit is de basis van het image. `nginx:alpine` is de officiele nginx-webserver op Alpine Linux. Alpine is een minimalistische Linux-distributie van ongeveer 5 MB, tegenover ~180 MB voor de Debian-variant. Kleiner betekent minder aanvalsvlak: er staan minder paketten op het systeem die kwetsbaarheden kunnen bevatten. Voor een webserver die alleen statische bestanden serveert is Alpine meer dan genoeg.

**`COPY . /usr/share/nginx/html`**
Kopieer alle bestanden uit de huidige map (dus `index.html` en eventuele andere assets) naar de nginx-documentroot. Dit is de map waar nginx standaard naar kijkt als er een request binnenkomt. Zo hoeft nginx niet geconfigureerd te worden en draait de statische site meteen.

nginx start automatisch op de voorgrond als de container opstart, want dat is ingebouwd in het `nginx:alpine` image. Daardoor blijft de container actief zolang nginx draait.

**GitHub Actions workflow:**

De workflow ([ci_week1.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/.github/workflows/ci_week1.yml)) bouwt en pusht het image als `stensel8/public-cloud-concepts:latest` bij elke push naar `main`.

**deployment.yaml:** ([bekijk op GitHub](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/deployment.yml))

**2b - Pod-IPs:**

```
NAME                               IP           NODE
first-deployment-5ffbd9444c-5hkzs  10.244.2.2   worker-london
first-deployment-5ffbd9444c-s4xdb  10.244.1.2   worker-brussels
```

![kubectl apply uitvoer - pods in Pending status](/docs/week-1/media/deployment-apply-pods-pending.avif)

![Beide pods Running](/docs/week-1/media/deployment-pods-running.avif)

![curl en kubectl exec uitvoer](/docs/week-1/media/curl-pod-and-exec.avif)

De respons bevestigt dat de nginx-container draait en de statische site serveert via het interne Flannel-IP. Externe toegang vereist een Kubernetes Service (Week 2).
