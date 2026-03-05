# Use the official Nginx base image
FROM nginx:alpine

# Copy the static site (Bootstrap template + index.html) to the Nginx document root
COPY static-site/ /usr/share/nginx/html/

# Copy nginx config with cache-control headers (important for Blue-Green switches)
COPY nginx-default.conf /etc/nginx/conf.d/default.conf

# Copy entrypoint script that injects environment variables at runtime
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port 80 for web traffic
EXPOSE 80

# Entrypoint script injects env vars and starts nginx
ENTRYPOINT ["/entrypoint.sh"]
