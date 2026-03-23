---
title: "Week 1: Containerisation & Kubernetes"
linkTitle: "Week 1"
weight: 1
---

In week 1 I started working with Google Cloud Platform and Kubernetes. I set up a cluster using kubeadm on separate Ubuntu instances, with a master node in the Netherlands and worker nodes in Brussels and London.

I then containerised the application using Docker and set up a GitHub Actions pipeline that automatically builds and pushes the image on every push to `main`.

<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week1.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week1.yml/badge.svg" alt="CI Week 1" style="display:inline;vertical-align:middle;" /></a>
