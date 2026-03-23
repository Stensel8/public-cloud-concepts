---
title: "Opdracht"
weight: 1
---

Het bedrijf TerramEarth (zie de casebeschrijving) wil monitoring en observability inzetten om beter grip te krijgen op hun IT-processen. Het instellen van processen voor proactief beheer van (hybride) cloudomgevingen is veel meer dan het installeren van een tool. Het ITIL-framework en DevOps bieden best practices om aan te sluiten op IT-processen in een veranderende bedrijfsomgeving.

---

## 5.1 Monitoring met Prometheus, Loki, Promtail en Grafana

### Installatie

1. Maak een Kubernetes-cluster aan in Google Cloud. Gebruik de **Standard**-optie in plaats van het geautomatiseerde Autopilot-cluster; het Autopilot-cluster werkt niet voor deze opdracht.

2. Bestudeer het script `setup-loki-prometheus-grafana` en de bijbehorende `values.yaml`-bestanden. Stel vast welke gebruikersnamen en wachtwoorden worden gebruikt (of pas ze aan), en welke poorten er worden gebruikt.

3. Maak verbinding met het cluster en voer het script `setup-loki-prometheus-grafana` uit. Zorg dat de bijbehorende `values.yaml`-bestanden beschikbaar zijn.

4. Op de laatste regel van het script wordt de ingress-controller geïnstalleerd. Controleer met het volgende commando of deze pod actief is. Wacht indien nodig tot de pod de status `Running` heeft:

   ```bash
   kubectl get pods --namespace ingress-nginx
   ```

   ![kubectl get pods --namespace ingress-nginx toont de ingress-nginx-controller als Running](/docs/week-5/media/opdracht/image-001.avif)

5. Maak een Ingress aan voor de Grafana-service (poort 443) in de `grafana`-namespace. Het begin van het `grafana-ingress.yaml`-bestand ziet er als volgt uit:

   ![Begin van grafana-ingress.yaml met apiVersion, kind, metadata en host grafana.project.intern](/docs/week-5/media/opdracht/image-002.avif)

6. Zoek het IP-adres van de Ingress op. Pas het `hosts`-bestand op je pc aan zodat de naam `grafana.project.intern` verwijst naar het bijbehorende IP-adres.

7. Open vanuit de browser de Grafana-applicatie via `https://grafana.project.intern`. Controleer na het inloggen de twee databronnen: **Loki** en **Prometheus**.

   Selecteer een databron, scroll naar beneden en klik op **Test** om te controleren of de verbinding werkt.

   ![Grafana Data sources: Loki en Prometheus verbonden](/docs/week-5/media/opdracht/image-003.avif)

### Monitoring instellen

8. Draai je eigen applicatie uit week 1 en 2 in het Kubernetes-cluster.

9. Bepaal wat je wil monitoren (vanuit logs of metrics). Ga naar Dashboards en maak of importeer de juiste dashboards voor de gewenste monitoring. Leg uit welke dashboards waardevol zijn voor jou.

10. Maak een **architectuurdiagram** dat de relatie tussen de geïnstalleerde componenten weergeeft: Prometheus, Loki, Promtail en Grafana. Maak duidelijk wat de rol van elk onderdeel is.

11. Zijn er andere tools die vaak worden gebruikt voor het monitoren van een Kubernetes-cluster?

---

## 5.2 SIEM en SOAR

12. Bekijk de bronnen uit het lesmateriaal en beschrijf de concepten **SIEM** en **SOAR**. Relateer deze aan de ITIL- en DevOps-frameworks en de casestudy van TerramEarth. Gebruik de bronnen in je antwoord (parafraseer of citeer).

---

## 5.3 Casestudy: TerramEarth

13. Bestudeer de TerramEarth-casus. Analyseer welke producten (minimaal 2) zij kunnen inzetten voor Monitoring en/of Observability.

    Geef voor elk van de volgende processen concrete voorbeelden (minimaal 2) van wat je zou meten en hoe je dit op **tactisch** en **operationeel** niveau zou inrichten:

    - **Probleembeheer** (Problem Management)
    - **Monitoring & Eventbeheer** (Monitoring & Event Management)
