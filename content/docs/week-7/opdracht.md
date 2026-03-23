---
title: "Opdracht"
weight: 1
---

De opdracht voor week 7 richt zich op een Proof of Concept op basis van een Cloud reference architectuur, specifiek het deel over serverless en event-driven architecturen.

**Leerdoelen:**

- Serverless concepten analyseren (Google Cloud Functions / AWS Lambda / Azure Functions)
- API Gateways gebruiken
- Werken met OpenAPI-definities
- Event-driven architecturen verkennen (Pub-Sub)

---

## 7.1 REST API via API Gateway

1. Lees de bronnen over serverless computing en API Gateway ter voorbereiding.

   Ga naar het AWS Learner Lab en maak een API Gateway aan via het REST API-voorbeeld: [Creating a REST API by importing an example](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-api-from-example.html).

   - POST een favoriete huisdier, haal het gegenereerde ID op en voer een GET-request uit op dat huisdier via Postman.
   - Als dit niet werkt, laat dan zien wat er gebeurt en probeer het te verklaren.
   - Beschrijf de relatie tussen een **method** en een **integration**.

   Voeg screenshots toe aan je portfolio.

2. Maak een REST API met een Lambda-functie als backend via het lab: [Build an API Gateway REST API with Lambda integration](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-api-as-simple-proxy-for-lambda.html).

---

## 7.2 Event-driven architecturen

3. Lees de bronnen over event-driven architecturen en het Pub-Sub patroon ter voorbereiding.

   - Leg uit hoe serverless computing past binnen het concept van event-driven architecturen.
   - Hoe zou je de Petstore-applicatie kunnen hosten met een event-driven architectuur, zodat je op de hoogte wordt gesteld van elk nieuw huisdier?

   Onderbouw je antwoord met minimaal **2 ontwerpbeslissingen**.
