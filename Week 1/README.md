Nederlands | [English](README.en.md)

---

| [Overzicht](../README.md) | [Week 2 - Kubernetes Networking & CI/CD](../Week%202/README.md) |
|:---|---:|

---

# Week 1 - Introductie tot Google Cloud & Kubernetes

## Onderwerpen

Deze week maak je kennis met het **Google Cloud Platform** en **Kubernetes**. We leren de basisconcepten van GCP, zetten een Kubernetes-cluster op met `kubeadm` en draaien een gecontaineriseerde applicatie via een CI/CD-pipeline.

---

## Leerdoelen

- Basisconcepten van Google Cloud Platform begrijpen
- Google Kubernetes Engine (GKE) opzetten en gebruiken
- Een Kubernetes-cluster installeren met `kubeadm` (1 master + 2 workers)
- Een gecontaineriseerde applicatie bouwen en uitrollen via Docker + GitHub Actions
- Kubernetes-resources begrijpen: Pods, Deployments, ReplicaSets

---


## Opdrachten & Uitwerkingen

| Bestand | Beschrijving |
|---|---|
| [Assignments week 1.md](Assignments%20week%201.md) | Opdrachten voor week 1 |
| [My Solution week 1.md](My%20Solution%20week%201.md) | Mijn uitwerkingen voor week 1 |

## Gebruikte Bestanden Deze Week

| Bestand | Beschrijving |
|---|---|
| [Dockerfile](Dockerfile) | Docker image definitie voor de Week 1 applicatie |
| [deployment.yml](deployment.yml) | Kubernetes Deployment manifest |
| [service.yml](service.yml) | Kubernetes Service manifest |
| [index.html](index.html) | Statische HTML-pagina geserveerd door de container |
| [configure_master.sh](configure_master.sh) | Script voor het opzetten van de Kubernetes masternode |
| [configure_worker.sh](configure_worker.sh) | Script voor het opzetten van een Kubernetes workernode |
| [Installmastertemplate](Installmastertemplate) | Scriptsjabloon (origineel van cursus) voor de masternode |
| [installnode](installnode) | Script (origineel van cursus) voor de workernodes |

---

| [Overzicht](../README.md) | [Week 2 - Kubernetes Networking \& CI/CD](../Week%202/README.md) |
|:---|---:|
