# Opdrachten Week 4

## 4.1 Helm

Helm is de pakketbeheerder voor Kubernetes. In plaats van handmatig losse `deployment.yaml`- en `service.yaml`-bestanden toe te passen, bundelt Helm alles in een **chart**: één installeerbaar pakket. Deze week installeer je Helm en gebruik je het om de applicatie uit vorige weken op een Kubernetes-cluster te deployen.

Er zijn drie belangrijke concepten in Helm:

1. De **chart** is een bundel met alle informatie die nodig is om een instantie van een Kubernetes-applicatie te maken.
2. De **config** (bijv. `values.yaml`) bevat configuratie-informatie die samengevoegd kan worden met een chart om een release-object te maken.
3. Een **release** is een draaiende instantie van een chart, gecombineerd met een specifieke configuratie.

Installeer Helm via de officiële documentatie: <https://helm.sh/docs/intro/install/>

Doe het volgende:

1. Installeer Helm op je werkstation of in Google Cloud Shell.

2. Maak een Helm-chart aan voor de applicatie uit vorige weken:

   ```bash
   helm create <chartnaam>
   ```

   Bestudeer de gegenereerde mapstructuur (`Chart.yaml`, `templates/`, `values.yaml`) en leg uit wat elk onderdeel doet.

3. Pas `values.yaml` aan zodat de chart jouw eigen Docker-image gebruikt (van DockerHub of Artifact Registry) in plaats van de standaard nginx-image. Stel ook het servicetype in op `LoadBalancer`.

4. Installeer de chart op je GKE-cluster:

   ```bash
   helm install <release-naam> <chartnaam>
   ```

   Controleer de deployment met:

   ```bash
   helm ls
   kubectl get pods
   kubectl get services
   kubectl get deployments
   ```

5. Upgrade de release door het aantal replica's aan te passen in een eigen `myvalues.yaml`-bestand:

   ```bash
   helm upgrade -f <myvalues.yaml> <release> <chart>
   ```

   Controleer of het aantal draaiende pods is veranderd.

6. Rol terug naar de vorige revisie:

   ```bash
   helm rollback <release> 1
   ```

   Controleer met `helm ls` dat het revisienummer is toegenomen en met `kubectl get pods` dat het aantal pods terug is op het originele aantal.

7. Verwijder de release wanneer je klaar bent:

   ```bash
   helm delete <release>
   ```

8. Zoek een bestaande chart op Artifact Hub (<https://artifacthub.io/>) voor een bekende applicatie (bijv. WordPress of een andere applicatie naar keuze). Installeer deze via `helm repo add` en `helm install`. Laat zien dat de applicatie draait.

---

## 4.2 Cloud Identity & IAM

Deze week behandelen we ook **Identity and Access Management (IAM)** in de cloud. Bestudeer de volgende onderwerpen en zorg dat je ze kunt uitleggen:

- **Microsoft Entra ID** (voorheen Azure Active Directory): <https://learn.microsoft.com/en-us/entra/identity-platform/v2-overview>
- **Identity Providers (IdP's)**: wat het zijn en waarom je er een nodig hebt: <https://www.okta.com/identity-101/why-your-company-needs-an-identity-provider/>
- **Microsoft Intune** (MDM/MAM) en Conditional Access: <https://learn.microsoft.com/en-us/mem/intune/protect/conditional-access>
- **OAuth 2.0**, de resource owner password credentials flow: <https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth-ropc>
- **OpenID Connect** op het Microsoft identity platform: <https://learn.microsoft.com/en-us/entra/identity-platform/v2-protocols-oidc>
- **SAML single sign-on**: wat het is en hoe GitHub Enterprise het gebruikt: <https://docs.github.com/en/enterprise-cloud@latest/organizations/managing-saml-single-sign-on-for-your-organization/about-identity-and-access-management-with-saml-single-sign-on>

Beantwoord de volgende vragen:

1. Wat is het verschil tussen **Active Directory** (on-premise) en **Microsoft Entra ID** (cloud)?

2. Wat is **Single Sign-On (SSO)** en hoe werkt het samen met SAML?

3. Wat is **Conditional Access** en hoe verschilt het van gewone RBAC?

4. Beschrijf de **OAuth 2.0**-autorisatiestroom in eigen woorden. Wat is het verschil tussen OAuth 2.0 en OpenID Connect?

5. Stel een proefversie in van GitHub Enterprise Cloud en configureer **SAML SSO** voor je GitHub-organisatie: <https://docs.github.com/en/enterprise-cloud@latest/admin/overview/setting-up-a-trial-of-github-enterprise-cloud>

---

## 4.3 Casestudy: EHR Healthcare

Lees de casestudy `master_case_study_ehr_healthcare.pdf` (beschikbaar op Brightspace). Beantwoord op basis van de casestudy en wat je deze week hebt geleerd over IAM de volgende vragen:

1. Welke **identity and access management**-uitdagingen heeft EHR Healthcare?
2. Welke oplossing(en) zou jij aanbevelen (bijv. Entra ID, Okta, SAML SSO, Conditional Access) en waarom?
3. Hoe zou je **RBAC** toepassen om de toegang tot gevoelige patiëntgegevens te beperken?
