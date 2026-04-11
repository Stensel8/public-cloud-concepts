---
title: "Solution"
weight: 2
---

Week 6 covers splitting a monolithic application into microservices on GKE, and adding an API Gateway as an access layer.

---

## 6.1 Microservices on GKE

The lab [Migrating a Monolithic Website to Microservices on Google Kubernetes Engine](https://www.cloudskillsboost.google/focuses/11953) was successfully completed with a score of 100%.

![Google Cloud Skills Boost: lab Migrating a Monolithic Website to Microservices completed with Assessment 100%, Passed](/docs/week-6/media/uitwerking/lab-voltooid.avif)

The lab starts with a webshop running as a single large container. In three steps it gets split into separate services on Kubernetes. First the orders module is extracted as its own Deployment, then the products module, and finally the frontend. By the end the monolith no longer exists and the three services scale completely independently. They find each other internally via the cluster DNS.

---

### Adding an API Gateway

Without an API Gateway, each microservice has its own external IP address via a LoadBalancer Service. That works, but it is not ideal: clients need to know where each service lives, authentication has to be configured per service, and TLS is separate per service as well.

An API Gateway solves this by acting as a single entry point. All requests arrive at the gateway, which forwards them to the right service. The services themselves become ClusterIP instead of LoadBalancer, so they are no longer directly reachable from outside.

Via [Secure traffic to a service with Google Cloud Console](https://cloud.google.com/api-gateway/docs/secure-traffic-console) the setup works as follows. You create an OpenAPI definition describing the routes and specifying which backend each path forwards to. You upload that file as an API config, and then create the gateway that uses it.

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

Authentication is enabled by adding a `securityDefinitions` block to the OpenAPI definition. If someone sends a request without a valid API Key, the gateway immediately returns a 403 before the request even reaches the services.

The main advantage is that you now have one place for everything related to access control. Adding a new service? Add a route to the OpenAPI definition and deploy a new config. Clients notice nothing because the gateway URL stays the same.
