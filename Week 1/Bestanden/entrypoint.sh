#!/bin/sh
# Entrypoint script voor nginx container
# 
# Blue-Green deployment: injecteert slot-indicator in HTML op basis van
# environment variables die via de Kubernetes deployment zijn ingesteld.
# 
# Env vars (gezet via deployment-blue.yml / deployment-green.yml):
#   SLOT       = "blue" of "green"
#   SLOT_COLOR = hex-kleur (#1a56db of #057a55)
# 
# Dit script:
#   1. Selecteert env vars (nodig voor envsubst)
#   2. Genereert index.html uit index.html.tpl via envsubst met expliciete variabelen
#   3. Start nginx
# 
# Voordeel: index.html.tpl staat in git (schoon, geen environment-teksten),
# maar index.html wordt gegenereerd per pod (dynamisch per slot).
# Dit maakt PR's van development -> main mogelijk zonder vervuiling.

# Zet standaardwaarden als não beschikbaar van Kubernetes
SLOT="${SLOT:-unknown}"
SLOT_COLOR="${SLOT_COLOR:-#999999}"

# Genereer index.html uit template met substitutie
# Gebruik -v flags voor expliciete export naar envsubst
# (index.html.tpl bevat ${SLOT} en ${SLOT_COLOR} placeholders)
( export SLOT; export SLOT_COLOR; \
  cat /usr/share/nginx/html/index.html.tpl | envsubst ) > /usr/share/nginx/html/index.html

# Verifieer: log de gesubstitueerde balk voor debugging
echo "[ENTRYPOINT] Deployed with SLOT=${SLOT}, SLOT_COLOR=${SLOT_COLOR}"

# Start nginx
exec nginx -g "daemon off;"
