# static-site Helm Chart

Dit is een **kopie van de `public-cloud-concepts` chart**, aangepast zodat mijn eigen statische webapplicatie uit Week 1 en 2 via Helm geïnstalleerd kan worden.

> De originele standaard chart staat in de map [`../public-cloud-concepts/`](../public-cloud-concepts/).

## Image

Het image is gebouwd vanuit de Dockerfile in `Week 1/Bestanden/` en wordt automatisch via GitHub Actions gepusht naar Docker Hub:

```
stensel8/public-cloud-concepts:latest
```

## Wat is aangepast ten opzichte van de originele chart?

| Bestand | Wijziging |
|---|---|
| `Chart.yaml` | Naam gewijzigd naar `static-site`, appVersion naar `1.0.0` |
| `values.yaml` | `image.repository` → `stensel8/public-cloud-concepts`, `image.tag` → `latest` |
| `templates/_helpers.tpl` | Alle template-namen hernoemd van `public-cloud-concepts.*` naar `static-site.*` |
| Alle andere templates | Template-aanroepen bijgewerkt naar `static-site.*` |

## Installeren

```bash
helm install static-site-v1 ./static-site
```

## Upgraden

```bash
helm upgrade static-site-v1 ./static-site
```

## Verwijderen

```bash
helm uninstall static-site-v1
```
