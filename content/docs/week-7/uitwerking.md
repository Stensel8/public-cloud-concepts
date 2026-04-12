---
title: "Uitwerking"
weight: 2
---

Week 7 richt zich op serverless computing via AWS: een REST API met API Gateway en Lambda, plus event-driven architecturen.

---

## 7.1 REST API via API Gateway

### Method en integration

In API Gateway is de `method` het client-facing contract (HTTP-werkwoord, pad, authenticatie en validatie). De `integration` beschrijft de backend-mapping: waar API Gateway de request naartoe stuurt (HTTP-endpoint, Lambda, AWS-service) en hoe de response terug wordt gemapt naar de client.

Method: de kant die de client ziet

- Welk HTTP-werkwoord en pad de client aanroept (bijv. `POST /pets`)
- Welke authenticatie vereist is (API Key, IAM, Cognito of geen)
- Request-validatie (query params, headers, body schema)
- Welke HTTP-statuscodes de client kan ontvangen

Integration: de backend-kant

- Waar de request naartoe gaat (HTTP, Lambda, AWS-service, mock)
- Hoe de request wordt getransformeerd voordat deze wordt verstuurd (integration request mapping)
- Hoe de backend-respons terug naar de client wordt gemapt (integration response mapping)

Deze verantwoordelijkheden configureer je apart: beveilig de method en laat de integration naar een Lambda verwijzen, of gebruik tijdens ontwikkeling een mock integration.

---

### Lambda als backend

Via het lab [Build an API Gateway REST API with Lambda integration](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-api-as-simple-proxy-for-lambda.html):

1. Maak een Lambda-functie aan (`GetStartedLambdaProxyIntegration`) met Python runtime.
2. Maak een nieuwe REST API aan in API Gateway.
3. Voeg een resource toe (`/helloworld`) met een `ANY`-method.
4. Kies **Lambda Function** als integration type, vink **Lambda Proxy Integration** aan, en selecteer de Lambda-functie.
5. Deploy naar een stage.

Lambda ontvangt een **proxy event** van API Gateway en retourneert een gestructureerd object:

```json
{
  "statusCode": 200,
  "headers": { "Content-Type": "application/json" },
  "body": "{\"message\": \"Hello Sten\"}"
}
```

Met **Lambda Proxy Integration** stuurt API Gateway het volledige HTTP-request als JSON door naar Lambda (method, headers, query parameters, body). Lambda is verantwoordelijk voor de volledige response inclusief statusCode. Zonder proxy integration kun je mapping templates gebruiken om de request/response te transformeren, maar dat vereist meer configuratie.

### Lambda aanmaken

In het AWS Learner Lab kon ik geen nieuwe IAM-rol aanmaken. Dit is een standaard studentbeperking; de oplossing was om de bestaande **LabRole** te gebruiken, die al de nodige rechten heeft voor Lambda en API Gateway.

![Lambda functie aangemaakt met Python 3.14 en LabRole](/docs/week-7/media/uitwerking/lambda-aanmaken.avif)

Daarna de voorbeeldcode van de AWS-documentatie erin geplakt en gedeployed:

![Lambda code geplakt en gedeployed](/docs/week-7/media/uitwerking/lambda-code-deployen.avif)

### API Gateway configureren

REST API aanmaken, resource `/helloworld` toevoegen, en de method instellen met Lambda Proxy Integration:

![REST API aanmaken](/docs/week-7/media/uitwerking/api-aanmaken.avif)

![Resource /helloworld aanmaken](/docs/week-7/media/uitwerking/resource-aanmaken.avif)

![Method ANY configureren met Lambda Proxy Integration](/docs/week-7/media/uitwerking/method-configureren.avif)

### Deployen

API deployen naar een nieuwe stage genaamd `test`:

![API deployen naar test stage](/docs/week-7/media/uitwerking/api-deployen.avif)

De Invoke URL werd: `https://oubfrz862l.execute-api.us-east-1.amazonaws.com/test`

### Testen met HTTPie

Voor het testen heb ik [HTTPie](https://httpie.io/app) gebruikt in plaats van Postman. Ik gebruik dit vaker en vond het een goede kans om dat even te laten zien. HTTPie geeft requests en responses overzichtelijk weer en werkt lekker snel voor dit soort one-off tests.

De Lambda-functie accepteert drie varianten voor de `greeter`-waarde: via query parameter, via een header, of via een JSON-body. Alle drie zouden `Hello, {naam}!` terug moeten geven.

**Optie 1: query parameter**

Werkte meteen:

![Test via query parameter - 200 OK](/docs/week-7/media/uitwerking/test-query-parameter.avif)

**Optie 2 en 3: header en POST-body**

Bij de eerste poging gaf API Gateway een `403 Forbidden` terug met de melding "Missing Authentication Token". Dat lijkt een authenticatieprobleem, maar in API Gateway is dit vaak de foutmelding die verschijnt als een route niet herkend wordt of de request niet goed is opgebouwd.

![Test via header - eerste poging 403](/docs/week-7/media/uitwerking/test-header-fout.avif)

![Test via POST-body - eerste poging 403](/docs/week-7/media/uitwerking/test-post-fout.avif)

Na beter kijken bleek het een invoerfout aan mijn kant: de header-waarde klopte niet helemaal met wat de Lambda verwachtte. Na aanpassen werkten beide:

![Test via header - tweede poging 200 OK](/docs/week-7/media/uitwerking/test-header-succes.avif)

![Test via POST-body - tweede poging 200 OK](/docs/week-7/media/uitwerking/test-post-succes.avif)

---

## 7.2 Event-driven architecturen

### Serverless en event-driven

Serverless computing en event-driven architecturen zijn nauw verwant: serverless functies draaien niet continu, maar worden geactiveerd door een **event**.

Een traditionele server wacht actief op requests (polling of een open verbinding). Een serverless functie bestaat alleen wanneer er een event plaatsvindt: de cloudprovider instantieert de functie wanneer nodig en verwijdert deze daarna. Dit maakt serverless van nature event-driven.

**Welke events activeren een Lambda-functie?**

| Event source | Voorbeeld |
|---|---|
| HTTP request | API Gateway → POST /pets |
| Message | SQS queue, SNS topic |
| Bestandsupload | S3 PUT object |
| Tijdschema | EventBridge Scheduler (cron) |
| Databasewijziging | DynamoDB Streams |
| Andere Lambda | Direct invocation |

In alle gevallen geldt hetzelfde patroon: **iets gebeurt → een functie reageert**. Dat is de kern van event-driven architecturen. De functies zijn stateless, los gekoppeld, en schalen automatisch met het aantal events.
