# Week 1 — Introduction to Google Cloud & Kubernetes

## Completion Badges

Behaalde badges via [Google Cloud Skills Boost](https://www.skills.google/public_profiles/d92d9d25-7174-4f3a-8f70-fab880429afe):

[![Google Cloud Fundamentals: Core Infrastructure](https://cdn.qwiklabs.com/V%2FuXlPOWQoaDTrhNB3K%2Ba2p2wGiQZT7%2BODtWIPHmON4%3D)](https://www.skills.google/public_profiles/d92d9d25-7174-4f3a-8f70-fab880429afe)
[![Essential Google Cloud Infrastructure: Core Services](https://cdn.qwiklabs.com/sgKmjMjD%2BpyCGA4VRZkhXxeonasfqbo8j85m8b5gC%2Bg%3D)](https://www.skills.google/public_profiles/d92d9d25-7174-4f3a-8f70-fab880429afe)
[![Getting Started with Google Kubernetes Engine](https://cdn.qwiklabs.com/HPtjPjHuWp197QQiSmfshQL2uNxmxDCHjWps43o10Cg%3D)](https://www.skills.google/public_profiles/d92d9d25-7174-4f3a-8f70-fab880429afe)

---

## Topics

This week you will be introduced to the **Google Cloud Platform**. Firstly, you will learn the basic concepts of Google Cloud and the most important Google services. Secondly, you will learn how **Kubernetes** works and apply your knowledge by creating a Kubernetes Cluster on three Ubuntu Nodes.

---

## Learning Goals

- [ ] Granting members IAM roles within a project
- [ ] Enabling APIs within projects
- [ ] Creating a VPC with subnets (e.g., custom-mode VPC, shared VPC)
- [ ] Adding a subnet to an existing VPC
- [ ] Launching a Compute Engine instance with custom network configuration
  - Internal-only IP address
  - Google private access
  - Static external and private IP address
  - Network tags
- [ ] Creating a Kubernetes cluster on 3 Ubuntu nodes
- [ ] Setting up a pipeline in GitHub to create a new Docker image and upload it to Docker Hub

---

## Learning Materials

### Google Cloud

| Resource | Link |
|---|---|
| A Tour of Google Cloud Hands-on Labs (GSP282) | [cloudskillsboost.google](https://www.cloudskillsboost.google/focuses/2794?parent=catalog) |
| Google Cloud Fundamentals — Core Infrastructure | [cloudskillsboost.google](https://www.cloudskillsboost.google/course_templates/60) |
| Essential Google Cloud Infrastructure — Core Services | [cloudskillsboost.google](https://www.cloudskillsboost.google/course_templates/49) |
| Google Compute Engine documentation | [cloud.google.com](https://cloud.google.com/compute?hl=en) |

### Kubernetes

| Resource | Link |
|---|---|
| Getting Started with Google Kubernetes Engine | [cloudskillsboost.google](https://www.cloudskillsboost.google/paths/11/course_templates/2) |
| Google Kubernetes Engine documentation | [cloud.google.com](https://cloud.google.com/kubernetes-engine/docs/concepts/kubernetes-engine-overview) |
| Kubernetes documentation | [kubernetes.io](https://kubernetes.io/docs/home/) |

---

## Course Documents

| Document | Omschrijving |
|---|---|
| [Slides week 1](Les%201%20Introductie%20Google%20en%20Kubernetes.pdf) | Introductie Google Cloud & Kubernetes |
| [Assignments week 1 v2](Assignments%20week%201%20v2.pdf) | Opdrachten voor week 1 |

---

## Files in This Directory

| File | Description |
|---|---|
| [Dockerfile](Dockerfile) | Docker image definition for the week 1 application |
| [deployment.yml](deployment.yml) | Kubernetes Deployment manifest |
| [service.yml](service.yml) | Kubernetes Service manifest |
| [index.html](index.html) | Application HTML page |
| [deploymenttemplate.yaml](deploymenttemplate.yaml) | Template for Kubernetes deployments |
| [Installmastertemplate](Installmastertemplate) | Script template for setting up the Kubernetes master node |
| [installnode](installnode) | Script for setting up a Kubernetes worker node |
