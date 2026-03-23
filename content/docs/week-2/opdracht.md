---
title: "Opdracht"
weight: 1
---

<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week2.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week2.yml/badge.svg" alt="CI Week 2" style="display:inline;vertical-align:middle;" /></a>

## 2.1 Google Kubernetes Engine (GKE) en DORA

Deze week verdiep je je kennis van GKE en analyseer je DORA.

- Voltooi Kubernetes Engine: Qwik Start (GSP100, 1 credit) via [Google Skills](https://www.cloudskillsboost.google/focuses/878?parent=catalog) en lever bewijs aan door verbinding te maken met de container via `kubectl exec` en de laatste 15 regels van het webserver-logbestand te tonen.
- Voltooi het lab "Managing Deployments Using Kubernetes Engine" (5 credits) van de cursus "Set Up and Configure a Cloud Environment in Google Cloud" via [Google Skills](https://www.cloudskillsboost.google/paths/11/course_templates/625).
  Lever bewijs via screenshots.
- Analyseer hoe alle technische DORA-capabilities kunnen leiden tot betere Organizational Performance (processen) en Well-being (mensen).

## 2.2 Kubernetes

In week 1 is een pod gestart met daarin een container (webserver). De pod is echter alleen bereikbaar via het IP van de pod. Dit is kwetsbaar, omdat als de pod uitvalt (of verwijderd wordt) er een nieuwe wordt aangemaakt (mits de deployment actief is) met een ander IP-adres.

1. Zorg dat de deployment van vorige week actief is en draait. Controleer welke pods actief zijn en wat hun IP-adres is.
2. Verwijder een pod (`kubectl delete pod`) terwijl de deployment actief blijft. Controleer dat er een nieuwe wordt aangemaakt. Controleer ook of het IP is veranderd.
3. Om de pods via een vast IP te kunnen bereiken, testen we de verschillende opties.

   Maak een bestand `service.yaml` aan dat een service aanmaakt voor de eerder gemaakte pods. Kies eerst `ClusterIP` als type.

   Maak de service aan en vraag daarna het IP-adres op via `kubectl get service`.

4. Het moet nu mogelijk zijn om de webserver in de pods te bereiken vanaf elke node in het cluster (inclusief de master) via het ClusterIP. Test dit op elke node via:

   ```bash
   curl <clusterip>
   ```

5. Pas nu de service aan naar `NodePort`. Er wordt nu op elke node (inclusief de master) een poort geopend waardoor de pods bereikbaar zijn.

   Test dit eerst met het commando `curl <intern-ip-node>:<open-poort>`. Dit zou op elke node moeten werken. Test dan ook via het externe IP van de nodes. Dat werkt nog niet, want de firewall blokkeert het.

   Pas de firewall aan voor VPC-Network. Open de betreffende poort voor alle instances op het netwerk. Test nu opnieuw of het werkt.

   Test vanuit je pc in een browser of je de applicatie kunt bereiken. Dit zou moeten werken.

6. Pas nu de service aan naar type `LoadBalancer`. Controleer de service met `kubectl get service`. Je ziet nu dat de service nog geen extern IP heeft (pending). Leg uit waarom.

7. Om de load balancer-functionaliteit te kunnen zien, schakelen we over naar Google Cloud en gebruiken we de GKE-service. Maak daar een Kubernetes-cluster aan en zorg dat dezelfde deployment en service worden aangemaakt als op de Google-instances (de container met de webserver moet draaien). Pas de service aan naar type `LoadBalancer` en controleer of er nu een extern IP-adres wordt aangemaakt. Test of de service via internet bereikbaar is in een browser op je pc.

   ![GKE LoadBalancer service: extern IP-adres aangemaakt, applicatie bereikbaar via browser](/docs/week-2/media/opdracht/image-001.avif)

8. Er is nu een load balancer voor een applicatie zodat die via internet bereikbaar is. Als er meerdere applicaties zijn, zou dat betekenen dat er meerdere load balancers nodig zijn (1 per service). We willen nu meerdere services ontsluiten via 1 zogenaamde Ingress.

   Maak eerst twee containers aan zoals de huidige. Eén simuleert de website Bison, de ander de website Brightspace (toon bijvoorbeeld alleen een welkomstbericht). Zorg dat er voor elk van deze twee een deployment en service zijn zodat ze bereikbaar zijn. Het service-type is bijvoorbeeld `NodePort` of `ClusterIP`. Maak nu een Ingress aan zodat de "bison"-website bereikbaar is via `bison.mysaxion.nl` en de "brightspace"-website via `brightspace.mysaxion.nl`.

   Maak ook een hosts-bestand aan waarin je beide namen resolved naar het IP-adres van de ingress-controller.

   Bekijk ook de load balancer die automatisch wordt aangemaakt en de Ingress in Google's portal (zie bijv. de monitoring).
