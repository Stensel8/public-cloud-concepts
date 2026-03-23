---
title: "Assignment"
weight: 1
---

The company TerramEarth (see the case description) wants to use monitoring and observability to gain better control over their IT processes. Setting up processes for proactive management of (hybrid) cloud environments is much more than installing a tool. The ITIL framework and DevOps provide best practices to align with IT processes in a changing business environment.

---

## 5.1 Monitoring with Prometheus, Loki, Promtail, and Grafana

### Installation

1. Create a Kubernetes cluster in Google Cloud. Use the **Standard** option instead of the automated Autopilot cluster; the Autopilot cluster does not work for this assignment.

2. Study the script `setup-loki-prometheus-grafana` and the accompanying `values.yaml` files. Determine which usernames and passwords are used (or adjust them), and which ports are used.

3. Connect to the cluster and run the script `setup-loki-prometheus-grafana`. Make sure the accompanying `values.yaml` files are available.

4. The last line of the script installs the ingress controller. Verify with the following command that this pod is active. Wait if necessary until the pod has the status `Running`:

   ```bash
   kubectl get pods --namespace ingress-nginx
   ```

   ![kubectl get pods --namespace ingress-nginx shows the ingress-nginx-controller as Running](/docs/week-5/media/opdracht/image-001.avif)

5. Create an Ingress for the Grafana service (port 443) in the `grafana` namespace. The beginning of the `grafana-ingress.yaml` file looks as follows:

   ![Beginning of grafana-ingress.yaml with apiVersion, kind, metadata and host grafana.project.intern](/docs/week-5/media/opdracht/image-002.avif)

6. Look up the IP address of the Ingress. Update the `hosts` file on your PC so that the name `grafana.project.intern` points to the corresponding IP address.

7. Open the Grafana application in your browser via `https://grafana.project.intern`. After logging in, check the two data sources: **Loki** and **Prometheus**.

   Select a data source, scroll down, and click **Test** to verify the connection works.

   ![Grafana Data sources: Loki and Prometheus connected](/docs/week-5/media/opdracht/image-003.avif)

### Setting up monitoring

8. Run your own application from week 1 and 2 in the Kubernetes cluster.

9. Determine what you want to monitor (from logs or metrics). Go to Dashboards and create or import the appropriate dashboards for the desired monitoring. Explain which dashboards are valuable to you.

10. Create an **architecture diagram** showing the relationship between the installed components: Prometheus, Loki, Promtail, and Grafana. Make clear what the role of each component is.

11. Are there other tools commonly used for monitoring a Kubernetes cluster?

---

## 5.2 SIEM and SOAR

12. Review the sources from the course materials and describe the concepts **SIEM** and **SOAR**. Relate these to the ITIL and DevOps frameworks and the TerramEarth case study. Use the sources in your answer (paraphrase or cite).

---

## 5.3 Case Study: TerramEarth

13. Study the TerramEarth case. Analyse which products (at least 2) they can deploy for Monitoring and/or Observability.

    For each of the following processes, provide concrete examples (at least 2) of what you would measure and how you would structure this at **tactical** and **operational** level:

    - **Problem Management**
    - **Monitoring & Event Management**
