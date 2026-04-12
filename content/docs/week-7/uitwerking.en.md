---
title: "Solution"
weight: 2
---

Week 7 focuses on serverless computing via AWS: a REST API with API Gateway and Lambda, and event-driven architectures.

---

## 7.1 REST API via API Gateway

### Method and integration

In API Gateway the `method` is the client-facing contract (HTTP verb, path, auth and validation). The `integration` is the backend mapping: where API Gateway forwards the request (HTTP endpoint, Lambda, AWS service) and how responses are transformed back to the client.

Method: the client-facing side

- Which HTTP verb and path the client calls (for example `POST /pets`)
- Which authentication is required (API Key, IAM, Cognito, or none)
- Request validation (query params, headers, body schema)
- Which HTTP status codes the client may receive

Integration: the backend side

- Where the request is sent (HTTP, Lambda, AWS service, mock)
- How the request is transformed before sending (integration request mapping)
- How the backend response is mapped back to the client (integration response mapping)

These responsibilities are configured separately: you can secure the method while the integration calls a Lambda, or use a mock integration during development.

---

### Lambda as backend

Via the lab [Build an API Gateway REST API with Lambda integration](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-api-as-simple-proxy-for-lambda.html):

1. Create a Lambda function (`GetStartedLambdaProxyIntegration`) with Python runtime.
2. Create a new REST API in API Gateway.
3. Add a resource (`/helloworld`) with an `ANY` method.
4. Choose **Lambda Function** as the integration type, enable **Lambda Proxy Integration**, and select the Lambda function.
5. Deploy to a stage.

Lambda receives a **proxy event** from API Gateway and returns a structured object:

```json
{
  "statusCode": 200,
  "headers": { "Content-Type": "application/json" },
  "body": "{\"message\": \"Hello Sten\"}"
}
```

With **Lambda Proxy Integration**, API Gateway forwards the full HTTP request as JSON to Lambda (method, headers, query parameters, body). Lambda is responsible for the full response including the statusCode. Without proxy integration, you can use mapping templates to transform requests and responses, but that requires more configuration.

### Creating the Lambda function

In the AWS Learner Lab it was not possible to create a new IAM role. This is a standard student restriction; the solution was to use the existing **LabRole**, which already has the necessary permissions for Lambda and API Gateway.

![Lambda function created with Python 3.14 and LabRole](/docs/week-7/media/uitwerking/lambda-aanmaken.avif)

The sample code from the AWS documentation was pasted in and deployed:

![Lambda code pasted and deployed](/docs/week-7/media/uitwerking/lambda-code-deployen.avif)

### Configuring API Gateway

REST API created, resource `/helloworld` added, and the method configured with Lambda Proxy Integration:

![REST API created](/docs/week-7/media/uitwerking/api-aanmaken.avif)

![Resource /helloworld created](/docs/week-7/media/uitwerking/resource-aanmaken.avif)

![Method ANY configured with Lambda Proxy Integration](/docs/week-7/media/uitwerking/method-configureren.avif)

### Deploying

API deployed to a new stage named `test`:

![API deployed to test stage](/docs/week-7/media/uitwerking/api-deployen.avif)

The Invoke URL was: `https://oubfrz862l.execute-api.us-east-1.amazonaws.com/test`

### Testing with HTTPie

For testing I used [HTTPie](https://httpie.io/app) instead of Postman. The Lambda function accepts three variants for the `greeter` value: via query parameter, via a header, or via a JSON body. All three should return `Hello, {name}!`.

**Option 1: query parameter**

Worked immediately:

![Test via query parameter - 200 OK](/docs/week-7/media/uitwerking/test-query-parameter.avif)

**Options 2 and 3: header and POST body**

On the first attempt API Gateway returned a `403 Forbidden` with the message "Missing Authentication Token". In API Gateway this error often appears when a route is not recognised or the request is not correctly structured.

![Test via header - first attempt 403](/docs/week-7/media/uitwerking/test-header-fout.avif)

![Test via POST body - first attempt 403](/docs/week-7/media/uitwerking/test-post-fout.avif)

After closer inspection it turned out to be a typo: the header value did not exactly match what Lambda expected. After correcting it both worked:

![Test via header - second attempt 200 OK](/docs/week-7/media/uitwerking/test-header-succes.avif)

![Test via POST body - second attempt 200 OK](/docs/week-7/media/uitwerking/test-post-succes.avif)

---

## 7.2 Event-driven architectures

### Serverless and event-driven

Serverless computing and event-driven architectures are closely related: serverless functions do not run continuously, but are triggered by an **event**.

A traditional server actively waits for requests (polling or an open connection). A serverless function does not exist until an event occurs; the cloud provider instantiates the function when needed and removes it afterwards. This makes serverless inherently event-driven.

**What events trigger a Lambda function?**

| Event source | Example |
|---|---|
| HTTP request | API Gateway → POST /pets |
| Message | SQS queue, SNS topic |
| File upload | S3 PUT object |
| Schedule | EventBridge Scheduler (cron) |
| Database change | DynamoDB Streams |
| Another Lambda | Direct invocation |

In all cases the same pattern applies: **something happens → a function responds**. That is the essence of event-driven architectures. The functions are stateless, loosely coupled, and scale automatically with the number of events.
