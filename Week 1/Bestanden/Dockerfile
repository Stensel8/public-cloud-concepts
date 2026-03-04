# Use the official Nginx base image
FROM nginx:alpine

# Copy the static site (Bootstrap template + index.html) to the Nginx document root
COPY static-site/ /usr/share/nginx/html/

# Expose port 80 for web traffic
EXPOSE 80

# Command to start Nginx when the container is run
CMD ["nginx", "-g", "daemon off;"]
