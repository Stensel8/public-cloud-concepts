---
title: "Uitwerking"
weight: 2
---

Week 6 gaat over het opsplitsen van een monolithische applicatie naar microservices op GKE, en het toevoegen van een API Gateway als toegangslaag.

---

## 6.1 Microservices op GKE

Het lab [Migrating a Monolithic Website to Microservices on Google Kubernetes Engine](https://www.cloudskillsboost.google/focuses/11953) is succesvol afgerond met een score van 100%.

![Google Cloud Skills Boost: lab Migrating a Monolithic Website to Microservices afgerond met Assessment 100%, Passed](/docs/week-6/media/uitwerking/lab-voltooid.avif)

Het lab begint met een webshop die als één grote container draait. In drie stappen wordt die opgesplitst in losse services op Kubernetes. Eerst gaat de orders-module eruit als eigen Deployment, daarna de products-module, en tot slot de frontend. Aan het einde bestaat de monoliet niet meer en schalen de drie services volledig onafhankelijk van elkaar. Ze vinden elkaar intern via de cluster-DNS.

---

### API Gateway toevoegen

Zonder een API Gateway heeft elke microservice zijn eigen extern IP-adres via een LoadBalancer Service. Dat werkt, maar het is niet handig: clients moeten weten waar elke service zit, authenticatie moet je per service inregelen, en TLS is ook per service apart.

Een API Gateway lost dat op door als enkel ingangspunt te fungeren. Alle requests komen binnen op de gateway, die ze doorstuurt naar de juiste service. De services zelf worden dan ClusterIP in plaats van LoadBalancer, zodat ze niet meer direct van buiten bereikbaar zijn.

Via [Secure traffic to a service with Google Cloud Console](https://cloud.google.com/api-gateway/docs/secure-traffic-console) werkt het als volgt. Je maakt een OpenAPI-definitie die de routes beschrijft en aangeeft naar welke backend elk pad doorgestuurd wordt. Dat bestand upload je als API config, en daarna maak je de gateway aan die die config gebruikt.

```bash
gcloud api-gateway api-configs create week6-config \
  --api=week6-api \
  --openapi-spec=openapi.yaml \
  --project=<project-id>

gcloud api-gateway gateways create week6-gateway \
  --api=week6-api \
  --api-config=week6-config \
  --location=europe-west4 \
  --project=<project-id>
```

Authenticatie zet je in met een `securityDefinitions` blok in de OpenAPI-definitie. Als iemand dan een request stuurt zonder geldige API Key, krijg die direct een 403 terug van de gateway, nog voordat het de services bereikt.

Het grote voordeel is dat je nu één plek hebt voor alles wat met toegang te maken heeft. Nieuwe service erbij? Voeg een route toe in de OpenAPI-definitie en deploy een nieuwe config. De clients merken niets, want de gateway-URL blijft hetzelfde.
