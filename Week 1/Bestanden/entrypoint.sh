#!/bin/sh
# Entrypoint script voor nginx container
# Injecteert runtime environment variables in HTML

# Standaardwaarden als env vars niet gezet zijn
SLOT=${SLOT:-"unknown"}
SLOT_COLOR=${SLOT_COLOR:-"#999999"}

# Vervang placeholders in index.html met environment variables
# envsubst is meestal al aanwezig in alpine, maar we installeren het zeker
if ! command -v envsubst &> /dev/null; then
  apk add --no-cache gettext
fi

envsubst < /usr/share/nginx/html/index.html > /usr/share/nginx/html/index.html.tmp
mv /usr/share/nginx/html/index.html.tmp /usr/share/nginx/html/index.html

# Start nginx
exec nginx -g "daemon off;"
