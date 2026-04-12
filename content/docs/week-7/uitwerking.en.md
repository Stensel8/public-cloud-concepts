---
title: "Solution"
weight: 2
---

Week 7 focuses on serverless computing via AWS: a REST API with API Gateway and Lambda, and event-driven architectures.

---


## 7.1 REST API via API Gateway

Follow the AWS labs listed in the assignment to create and test a REST API. Add screenshots from your lab to your portfolio.

---

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

1. Create a Lambda function (`HelloWorld` or a custom name) with a Node.js or Python runtime.
2. Create a new REST API in API Gateway.
3. Add a resource (`/hello`) with a `GET` method.
4. Choose **Lambda Function** as the integration type and select the Lambda function.
5. Deploy to a stage.

Lambda receives a **proxy event** from API Gateway and returns a structured object:

```json
{
  "statusCode": 200,
  "headers": { "Content-Type": "application/json" },
  "body": "{\"message\": \"Hello from Lambda!\"}"
}
```

With **Lambda Proxy Integration**, API Gateway forwards the full HTTP request as JSON to Lambda (method, headers, query parameters, body). Lambda is responsible for the full response including the statusCode. Without proxy integration, you can use mapping templates to transform requests and responses, but that requires more configuration.

<!-- Add screenshots here: Lambda function creation, API Gateway resource configuration, and the test response -->

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

Focus your answer on how serverless fits event-driven architectures and support your choices with at least two design decisions.
