---
title: "Uitwerking"
weight: 2
---

Week 7 richt zich op serverless computing via AWS: een REST API met API Gateway en Lambda, plus event-driven architecturen.

---

## 7.1 REST API via API Gateway

### Petstore via AWS API Gateway (importeren uit voorbeeld)

Het eerste deel van de opdracht gebruikt de voorbeeld-REST API die AWS meeleverde: een simpele Petstore. Je importeert dit via de AWS Console via **API Gateway > Create API > REST API > Import from example**.

Na het importeren staat er een API klaar met twee resources: `/pets` en `/pets/{petId}`.

**POST: een huisdier toevoegen**

Via HTTPie een POST-request naar de Invoke URL:

```
POST /pets
Content-Type: application/json

{
  "type": "dog",
  "price": 249.99
}
```

De API geeft een ID terug:

```json
{
  "pet": {
    "id": 42,
    "type": "dog",
    "price": 249.99
  },
  "message": "Your pet dog has been adopted."
}
```

**GET: het huisdier ophalen via het ID**

```
GET /pets/42
```

Geeft het eerder ingevoerde huisdier terug.

Dit werkt meteen zonder extra configuratie, want de Petstore-API gebruikt een mock integration. API Gateway geeft een hardcoded response terug zonder dat er een echte backend aan te pas komt. Dat is handig voor het snel testen van een API-structuur voordat je de backend bouwt.

### 7.2.3 Advies over de Petstore-architectuur

De Petstore zoals AWS hem levert is een mock: er is geen echte database, het geheugen is vluchtig en bij elke nieuwe deploy zijn de huisdieren weg. Dit is nuttig als demo, maar niet als je een echte applicatie wil bouwen.

**Hoe zou je dit productie-klaar maken?**

| Onderdeel | Mock (standaard) | Productie-aanbeveling |
|---|---|---|
| Backend | Hardcoded mock-responses in API Gateway | Lambda-functie als integration type |
| Opslag | Geen, alles tijdelijk | DynamoDB-tabel voor pets (key: petId) |
| ID aanmaken | Statisch in de mock | Lambda genereert een UUID |
| Authenticatie | Geen | API Key of Cognito User Pool |
| Error handling | Geen 404 bij onbekend ID | Lambda checkt of pet bestaat, geeft 404 terug |

**Aanbevolen opbouw met Lambda en DynamoDB:**

1. De POST `/pets` aanroep triggert een Lambda die de pet opslaat in DynamoDB met een gegenereerd ID.
2. De GET `/pets/{petId}` aanroep triggert een Lambda die de pet ophaalt via het ID. Als de pet niet bestaat, geeft Lambda een `404` terug met een duidelijke foutmelding.
3. API Gateway regelt authenticatie via een API Key: clients moeten een geldige key meesturen in de header `x-api-key`.

Dit is precies het patroon dat ik in het tweede deel van de opdracht heb opgezet met de Lambda-proxy integration, maar dan met een echte database eronder.

---

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

---

### Petstore met event-driven architectuur

**Hoe host je de Petstore met een event-driven architectuur zodat je op de hoogte wordt gesteld bij elk nieuw huisdier?**

In een event-driven Petstore reageert het systeem op events in plaats van dat het continu actief op requests wacht. Het toevoegen van een huisdier is het event dat de rest van het systeem in beweging zet.

**Globale werking:**

1. Een client stuurt een `POST /pets` naar API Gateway.
2. API Gateway roept een Lambda-functie aan.
3. De Lambda slaat het huisdier op in DynamoDB en publiceert daarna een bericht naar een SNS-topic.
4. SNS stuurt dat bericht door naar alle abonnees: een e-mailadres, een SQS-wachtrij, een andere Lambda, of een webhook.

```
Client → API Gateway → Lambda (opslaan + publiceren) → DynamoDB
                                                      ↘ SNS → e-mail / SQS / webhook
```

**Ontwerpbeslissing 1: SNS voor notificaties (fan-out)**

Ik gebruik Amazon SNS als berichtenbus. SNS ondersteunt meerdere abonnees tegelijkertijd: als er een nieuw huisdier is, ontvangen alle geregistreerde abonnees het bericht gelijktijdig. Dat heet fan-out. Dit is de juiste keuze als meerdere systemen of mensen op de hoogte moeten worden gesteld van hetzelfde event.

De Lambda publiceert na elke succesvolle opslag in DynamoDB een bericht naar het SNS-topic `pet-added`:

```python
import boto3, json, uuid

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')
table = dynamodb.Table('pets')
TOPIC_ARN = 'arn:aws:sns:us-east-1:123456789:pet-added'

def handler(event, context):
    body = json.loads(event['body'])
    pet_id = str(uuid.uuid4())
    table.put_item(Item={'petId': pet_id, **body})
    sns.publish(
        TopicArn=TOPIC_ARN,
        Message=json.dumps({'petId': pet_id, **body}),
        Subject='Nieuw huisdier toegevoegd'
    )
    return {'statusCode': 201, 'body': json.dumps({'petId': pet_id})}
```

**Ontwerpbeslissing 2: DynamoDB Streams voor verdere verwerking**

Naast de directe SNS-publicatie zet ik DynamoDB Streams aan op de `pets`-tabel. Elke schrijfoperatie op de tabel genereert automatisch een stream-event. Een aparte Lambda luistert naar die stream en kan de data verder verwerken, bijvoorbeeld het aanmaken van een thumbnail, het bijwerken van statistieken, of het loggen naar CloudWatch.

Het verschil met de SNS-aanpak: DynamoDB Streams werken op databaseniveau. Ook als de eerste Lambda vergeet te publiceren, vangt de stream-Lambda het event alsnog op. Dit maakt het systeem robuuster. De twee mechanismen vullen elkaar aan:

| | SNS in Lambda | DynamoDB Streams |
|---|---|---|
| Trigger | Handmatig vanuit de Lambda | Automatisch bij elke schrijf naar DynamoDB |
| Gebruik | Notificaties naar externe abonnees | Verdere interne verwerking |
| Betrouwbaarheid | Afhankelijk van of Lambda het aanroept | Altijd actief, onafhankelijk van de Lambda-logica |

**Resultaat:** Door API Gateway, Lambda, DynamoDB, SNS en DynamoDB Streams te combineren, bouw je een volledig event-driven Petstore waarbij elke nieuwe pet automatisch een notificatie verstuurt en verdere verwerking triggert, zonder dat er polling of permanente verbindingen nodig zijn.
