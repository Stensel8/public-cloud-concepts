# Use the official Nginx base image
FROM nginx:alpine

# Pre-install gettext (voor envsubst in entrypoint)
# Dit gebeurt 1x bij build, niet per pod start -> sneller
RUN apk add --no-cache gettext

# Copy the static site (Bootstrap template + index.html) to the Nginx document root
COPY static-site/ /usr/share/nginx/html/

# Copy index.html naar index.html.tpl voor template-based substitution
# Het origineel (in git) heeft ${SLOT} en ${SLOT_COLOR} placeholders.
# Deze worden bij container startup vervangen via envsubst.
RUN mv /usr/share/nginx/html/index.html /usr/share/nginx/html/index.html.tpl

# Copy nginx config with cache-control headers (important for Blue-Green switches)
COPY nginx-default.conf /etc/nginx/conf.d/default.conf

# Copy entrypoint script that injects environment variables at runtime
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port 80 for web traffic
EXPOSE 80

# Entrypoint script injects env vars and starts nginx
ENTRYPOINT ["/entrypoint.sh"]
