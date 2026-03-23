---
title: "Uitwerking"
weight: 2
---

<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week2.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week2.yml/badge.svg" alt="CI Week 2" style="display:inline;vertical-align:middle;" /></a>

## CI/CD - Docker Hub Tags

De GitHub Actions workflow bouwt twee images en pusht ze naar `stensel8/public-cloud-concepts`:

| Image | Tag | Pull commando |
|-------|-----|---------------|
| Bison app | `bison` | `docker pull stensel8/public-cloud-concepts:bison` |
| Brightspace app | `brightspace` | `docker pull stensel8/public-cloud-concepts:brightspace` |

![DockerHub tags: latest, brightspace, bison](../media/ci-dockerhub-tags.avif)

---

## 2.2 Kubernetes

### Opdracht 2.2a - Deployment draait

De Week 1 deployment (`first-deployment`) draait op het kubeadm-cluster met beide pods actief in twee regio's:

![Deployment running - alle nodes Ready, pods Running met IPs](../media/2-2a-deployment-running.avif)

```
NAME               STATUS   ROLES           AGE   VERSION
master-amsterdam   Ready    control-plane   9d    v1.35.1
worker-brussels    Ready    <none>          9d    v1.35.1
worker-london      Ready    <none>          9d    v1.35.1

NAME                                READY   STATUS    IP           NODE
first-deployment-5ffbd9444c-5hkzs   1/1     Running   10.244.2.3   worker-london
first-deployment-5ffbd9444c-s4xdb   1/1     Running   10.244.1.3   worker-brussels
```

---

### Opdracht 2.2b - Pod verwijderen en opnieuw aanmaken

Een pod werd verwijderd terwijl de Deployment actief bleef. Kubernetes maakte automatisch een vervangende pod aan met een **ander IP-adres**, wat aantoont dat pod-IPs tijdelijk zijn.

![Pod verwijderd - nieuwe pod aangemaakt met ander IP](../media/2-2b-pod-delete-new-ip.avif)

```
# Voor verwijdering:
first-deployment-5ffbd9444c-5hkzs   IP: 10.244.2.3   worker-london

# Na verwijdering - nieuwe pod:
first-deployment-5ffbd9444c-pdrw0   IP: 10.244.2.4   worker-london
```

Dit is precies waarom een Service nodig is: pods zijn wegwerpbaar en hun IPs veranderen.

---

### Opdracht 2.2c - ClusterIP Service

**[service.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-1/bestanden/service.yml)** - Een Service koppelt via `selector` aan pods met het label `app: my-container`. De eerste versie was `ClusterIP`: alleen bereikbaar binnen het cluster, geen extern IP:

```diff
+apiVersion: v1
+kind: Service
+metadata:
+  name: first-service
+spec:
+  type: ClusterIP        # stabiel virtueel IP, alleen intern
+  selector:
+    app: my-container    # koppelt aan pods met dit label
+  ports:
+    - port: 80
+      targetPort: 80
```

![ClusterIP service aangemaakt met stabiel virtueel IP](../media/2-2c-clusterip-service.avif)

```
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
first-service   ClusterIP   10.110.23.98    <none>        80/TCP    0s
```

Het ClusterIP is alleen bereikbaar vanuit het cluster. Verkeer wordt load-balanced over alle pods met selector `app: my-container`.

---

### Opdracht 2.2d - ClusterIP bereikbaar vanaf elke node

Alle drie nodes gaven de HTML-respons terug via `curl 10.110.23.98`.

![curl via ClusterIP vanaf master](../media/2-2d-curl-from-master.avif)

![curl via ClusterIP vanaf worker-brussels](../media/2-2d-curl-from-worker-brussels.avif)

![curl via ClusterIP vanaf worker-london](../media/2-2d-curl-from-worker-london.avif)

---

### Opdracht 2.2e - NodePort Service

Voor externe toegang is het type gewijzigd naar `NodePort` en een vaste poort toegevoegd:

```diff
 spec:
-  type: ClusterIP
+  type: NodePort
   ports:
     - port: 80
       targetPort: 80
+      nodePort: 32490   # vaste poort op alle nodes (bereik: 30000–32767)
```

![NodePort service - poort 80:32490/TCP](../media/2-2e-nodeport-service.avif)

```
NAME            TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
first-service   NodePort   10.110.23.98    <none>        80:32490/TCP   8m39s
```

**Interne nodes opzoeken:**

![Interne IP-adressen van de nodes](../media/2-2e-nodes-internal-ips.avif)

**Testen via intern node-IP:**

![curl via intern node-IP en NodePort werkt](../media/2-2e-nodeport-curl-internal.avif)

**Externe toegang via NodePort + firewallregel:**

GCP blokkeert inkomend verkeer standaard. Een firewallregel is aangemaakt voor TCP poort `32490`:

![Firewallregel aanmaken in GCP console](../media/2-2e-firewall-rule-created.avif)

Eerst getest zonder firewallregel - geblokkeerd:

![Browser geblokkeerd zonder firewallregel](../media/2-2e-browser-blocked-no-firewall.avif)

Na het aanmaken van de firewallregel werkt de site:

![Website bereikbaar via extern IP en NodePort](../media/2-2e-browser-working-after-firewall.avif)

{{< callout type="info" >}}
`kubectl port-forward` is een developer-tool voor lokaal testen, geen externe toegangsoplossing. De tunnel is alleen bereikbaar op de machine waar het commando draait en stopt bij `Ctrl+C`.

![kubectl port-forward actief](../media/2-2e-port-forward-running.avif)

![curl via localhost:8080 werkt via port-forward](../media/2-2e-port-forward-curl-localhost.avif)
{{< /callout >}}

---

### Opdracht 2.2f - LoadBalancer op het kubeadm-cluster

![LoadBalancer service aangemaakt - EXTERNAL-IP pending](../media/2-2f-loadbalancer-service-created.avif)

![LoadBalancer blijft in pending-status zonder cloud controller](../media/2-2f-loadbalancer-pending.avif)

```
NAME            TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
first-service   LoadBalancer   10.110.23.98   <pending>     80:32490/TCP   26m
```

**Waarom blijft het pending?**

Een `LoadBalancer` service vraagt de **cloud controller manager** om een externe load balancer te provisionen. Op een zelfbeheerd kubeadm-cluster is er geen cloud controller manager aanwezig - er is geen component dat namens Kubernetes een GCP load balancer kan aanvragen. Het externe IP wordt nooit toegewezen.

| Aanpak | Hoe | Wanneer |
|---|---|---|
| **Juiste manier** | GKE: cloud controller manager regelt automatisch een Load Balancer | Productie |
| **NodePort + firewallregel** | Open handmatig een GCP-firewallregel voor de NodePort-poort | Workaround op kubeadm |
| **Ingress controller** | nginx Ingress Controller routeert meerdere services via één extern IP | Meerdere apps (opdracht 2.2h) |

---

### Opdracht 2.2g - LoadBalancer op GKE

Een GKE-cluster `week2-cluster` aangemaakt: `e2-medium`, 2 nodes, `europe-west4-a`, Regular release channel.

![GKE cluster basis instellingen](../media/2-2g-gke-cluster-create-basics.avif)

![GKE node pool configuratie](../media/2-2g-gke-cluster-node-pool-details.avif)

![GKE node machine type e2-medium](../media/2-2g-gke-cluster-node-machine-type.avif)

![GKE week2-cluster provisioning op 33%](../media/2-2g-gke-cluster-provisioning.avif)

{{< tabs >}}
{{< tab name="Linux" >}}
```bash
gcloud container clusters get-credentials week2-cluster --zone europe-west4-a
```
{{< /tab >}}
{{< tab name="Windows (PowerShell)" >}}
```powershell
gcloud container clusters get-credentials week2-cluster --zone europe-west4-a
```
{{< /tab >}}
{{< /tabs >}}

![GKE cluster verbonden - twee nodes Ready](../media/2-2g-gke-kubectl-connected.avif)

Na deployen van de deployment en service:

![LoadBalancer op GKE - extern IP toegewezen na ~44 seconden](../media/2-2g-gke-loadbalancer-external-ip.avif)

```
NAME            TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)        AGE
first-service   LoadBalancer   34.118.232.196   34.12.127.52    80:31275/TCP   44s
```

Na ~44 seconden had GKE een Google Cloud Load Balancer geprovisioneert en het externe IP `34.12.127.52` toegewezen. Dit is het kernverschil met het kubeadm-cluster.

![Website bereikbaar via GKE LoadBalancer extern IP](../media/2-2g-gke-browser-working.avif)

---

### Opdracht 2.2h - Ingress: meerdere services via één load balancer

Twee apps beschikbaar via één Ingress, elk op een eigen hostnaam:

| Hostnaam | Backend service |
|---|---|
| `bison.mysaxion.nl` | `bison-service` (poort 80) |
| `brightspace.mysaxion.nl` | `brightspace-service` (poort 80) |

**nginx Ingress Controller installeren:**

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/cloud/deploy.yaml
```

![nginx Ingress Controller - extern IP 34.91.190.135 toegewezen](../media/2-2h-nginx-ingress-controller-external-ip.avif)

**Manifesten deployen:**

Toegepaste bestanden (zie [GitHub](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-2/bestanden)):

| Bestand | Beschrijving |
|---|---|
| [bison/deployment.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/bison/deployment.yml) | 2 replicas, image-tag `bison` |
| [bison/service.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/bison/service.yml) | ClusterIP op poort 80 |
| [brightspace/deployment.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/brightspace/deployment.yml) | 2 replicas, image-tag `brightspace` |
| [brightspace/service.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/brightspace/service.yml) | ClusterIP op poort 80 |
| [ingress.yml](https://github.com/Stensel8/public-cloud-concepts/blob/main/static/docs/week-2/bestanden/ingress.yml) | Ingress op basis van `Host` HTTP-header |

![nginx Ingress Controller geïnstalleerd - pods Running](../media/2-2h-nginx-ingress-controller-installed.avif)

![Deployments, services en Ingress toegepast](../media/2-2h-deployments-services-ingress-applied.avif)

```
NAME             CLASS   HOSTS                                        ADDRESS          PORTS   AGE
ingress-saxion   nginx   bison.mysaxion.nl,brightspace.mysaxion.nl   34.91.190.135    80      25s
```

![Ingress met saxion adres en hostnamen](../media/2-2h-ingress-saxion-address.avif)

**Hosts-bestand bijgewerkt:**

![Hosts-bestand met bison.mysaxion.nl en brightspace.mysaxion.nl](../media/2-2h-hosts-file-updated.avif)

![bison.mysaxion.nl - Bison-applicatie bereikbaar via Ingress](../media/2-2h-browser-bison.avif)

![brightspace.mysaxion.nl - Brightspace-applicatie bereikbaar via Ingress](../media/2-2h-browser-brightspace.avif)

**Waarom Ingress?**

Zonder Ingress heeft elke applicatie een aparte `LoadBalancer` service nodig (eigen IP, eigen kosten). Met Ingress stuurt één load balancer op basis van de `Host` HTTP-header verkeer naar de juiste service.
