Nederlands | [English](README.en.md)

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

| Map | Beschrijving |
|---|---|
| [Opdracht/](Opdracht/) | Opdrachten voor week 1 |
| [Uitwerking/](Uitwerking/) | Mijn uitwerkingen voor week 1 |

## Gebruikte Bestanden Deze Week

| Bestand | Beschrijving |
|---|---|
| [Dockerfile](Bestanden/Dockerfile) | Docker image definitie voor de Week 1 applicatie |
| [deployment.yml](Bestanden/deployment.yml) | Kubernetes Deployment manifest |
| [service.yml](Bestanden/service.yml) | Kubernetes Service manifest |
| [index.html](Bestanden/index.html) | Statische HTML-pagina geserveerd door de container |
| [configure_master.sh](Bestanden/configure_master.sh) | Script voor het opzetten van de Kubernetes masternode |
| [configure_worker.sh](Bestanden/configure_worker.sh) | Script voor het opzetten van een Kubernetes workernode |
| [Installmastertemplate](Bestanden/Installmastertemplate) | Scriptsjabloon (origineel van cursus) voor de masternode |
| [installnode](Bestanden/installnode) | Script (origineel van cursus) voor de workernodes |
