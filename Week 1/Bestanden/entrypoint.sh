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
#   1. Exporteert env vars (nodig voor envsubst)
#   2. Genereert index.html uit index.html.tpl via envsubst
#   3. Start nginx
# 
# Voordeel: index.html.tpl staat in git (schoon, geen environment-teksten),
# maar index.html wordt gegenereerd per pod (dynamisch per slot).
# Dit maakt PR's van development -> main mogelijk zonder vervuiling.

# Exporteer env vars zodat envsubst ze kan lezen
export SLOT=${SLOT:-"unknown"}
export SLOT_COLOR=${SLOT_COLOR:-"#999999"}

# Genereer index.html uit template met substitutie
# (index.html.tpl bevat ${SLOT} en ${SLOT_COLOR} placeholders)
envsubst < /usr/share/nginx/html/index.html.tpl > /usr/share/nginx/html/index.html

# Start nginx
exec nginx -g "daemon off;"
