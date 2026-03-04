# Use the official Nginx base image
FROM nginx:alpine

# Copy the static site (Bootstrap template + index.html) to the Nginx document root
COPY static-site/ /usr/share/nginx/html/

# Slot-indicator: vervang placeholders in de HTML met de waarden die de pipeline meegeeft.
# SLOT       = "blue" of "green"
# SLOT_COLOR = bijbehorende hex-kleur (#1a56db voor blue, #057a55 voor green)
ARG SLOT=blue
ARG SLOT_COLOR=#1a56db
RUN sed -i "s/__SLOT__/${SLOT}/g; s/__SLOT_COLOR__/${SLOT_COLOR}/g" \
    /usr/share/nginx/html/index.html

# Expose port 80 for web traffic
EXPOSE 80

# Command to start Nginx when the container is run
CMD ["nginx", "-g", "daemon off;"]
