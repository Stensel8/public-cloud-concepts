---
title: "Assignment"
weight: 1
---

The week 7 assignment focuses on a Proof of Concept based on a Cloud reference architecture, specifically the serverless and event-driven architectures section.

**Learning objectives:**

- Analyse serverless concepts (Google Cloud Functions / AWS Lambda / Azure Functions)
- Use API Gateways
- Work with OpenAPI definitions
- Explore event-driven architectures (Pub-Sub)

---

## 7.1 REST API via API Gateway

1. Read the sources on serverless computing and API Gateway as preparation.

   Go to the AWS Learner Lab and create an API Gateway using the REST API example: [Creating a REST API by importing an example](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-api-from-example.html).

   - POST a favourite pet, retrieve the generated ID, and perform a GET request for that pet via Postman.
   - If this does not work, show what happens and try to explain why.
   - Describe the relationship between a **method** and an **integration**.

   Add screenshots to your portfolio.

2. Create a REST API with a Lambda function as the backend via the lab: [Build an API Gateway REST API with Lambda integration](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-api-as-simple-proxy-for-lambda.html).

---

## 7.2 Event-driven architectures

3. Read the sources on event-driven architectures and the Pub-Sub pattern as preparation.

   - Explain how serverless computing fits within the concept of event-driven architectures.
   - How could you host the Petstore application using an event-driven architecture so that you are notified of every new pet?

   Support your answer with at least **2 design decisions**.
