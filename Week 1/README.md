🇳🇱 Nederlands | [🇬🇧 English](README.en.md)

---

| [Overzicht](../README.md) | [Week 2 - Kubernetes Networking & CI/CD →](../Week%202/README.md) |
|:---|---:|

---

# Week 1 - Introductie tot Google Cloud & Kubernetes

## Onderwerpen

Deze week maak je kennis met het **Google Cloud Platform** en **Kubernetes**. We leren de basisconcepten van GCP, zetten een Kubernetes-cluster op met `kubeadm` en draaien een gecontaineriseerde applicatie via een CI/CD-pipeline.

---

## Leerdoelen

- [ ] Basisconcepten van Google Cloud Platform begrijpen
- [ ] Google Kubernetes Engine (GKE) opzetten en gebruiken
- [ ] Een Kubernetes-cluster installeren met `kubeadm` (1 master + 2 workers)
- [ ] Een gecontaineriseerde applicatie bouwen en uitrollen via Docker + GitHub Actions
- [ ] Kubernetes-resources begrijpen: Pods, Deployments, ReplicaSets

---

## Leermaterialen

### Google Cloud

| Resource | Link |
|---|---|
| A Tour of Google Cloud Hands-on Labs (GSP282) | [cloudskillsboost.google](https://www.cloudskillsboost.google/focuses/2794?parent=catalog) |
| Google Cloud Fundamentals - Core Infrastructure | [cloudskillsboost.google](https://www.cloudskillsboost.google/course_templates/60) |
| Essential Google Cloud Infrastructure - Core Services | [cloudskillsboost.google](https://www.cloudskillsboost.google/course_templates/49) |
| Google Compute Engine documentatie | [cloud.google.com](https://cloud.google.com/compute?hl=en) |

### Kubernetes

| Resource | Link |
|---|---|
| Getting Started with Google Kubernetes Engine | [cloudskillsboost.google](https://www.cloudskillsboost.google/paths/11/course_templates/2) |
| Google Kubernetes Engine documentatie | [cloud.google.com](https://cloud.google.com/kubernetes-engine/docs/concepts/kubernetes-engine-overview) |
| Kubernetes documentatie | [kubernetes.io](https://kubernetes.io/docs/home/) |
| Kubernetes cluster op Ubuntu (stap-voor-stap handleiding) | [hbayraktar.medium.com](https://hbayraktar.medium.com/how-to-install-kubernetes-cluster-on-ubuntu-22-04-step-by-step-guide-7dbf7e8f5f99) |

---

## Bestanden in Deze Map

| Bestand / Map | Beschrijving |
|---|---|
| [Assignments week 1.md](Assignments%20week%201.md) | Opdrachten voor week 1 |
| [My Solution week 1.md](My%20Solution%20week%201.md) | Mijn uitwerkingen voor week 1 |
| [Dockerfile](Dockerfile) | Docker image definitie voor de Week 1 applicatie |
| [deployment.yml](deployment.yml) | Kubernetes Deployment manifest |
| [service.yml](service.yml) | Kubernetes Service manifest |
| [index.html](index.html) | Statische HTML-pagina geserveerd door de container |
| [configure_master.sh](configure_master.sh) | Script voor het opzetten van de Kubernetes masternode |
| [configure_worker.sh](configure_worker.sh) | Script voor het opzetten van een Kubernetes workernode |
| [Installmastertemplate](Installmastertemplate) | Scriptsjabloon (origineel van cursus) voor de masternode |
| [installnode](installnode) | Script (origineel van cursus) voor de workernodes |

---

| [🏠 Overzicht](../README.md) | [Week 2 - Kubernetes Networking \& CI/CD →](../Week%202/README.md) |
|:---|---:|
