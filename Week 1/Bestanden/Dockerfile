FROM nginx:1-alpine-slim

# hadolint ignore=DL3017
RUN apk upgrade --no-cache

COPY static-site/ /usr/share/nginx/html/
COPY nginx-default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
