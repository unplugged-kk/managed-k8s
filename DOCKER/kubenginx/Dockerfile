# Use an official Nginx runtime as a parent image
FROM nginx:latest

# Copy the custom Nginx configuration file to the image
COPY nginx.conf /etc/nginx/nginx.conf

COPY index.html /usr/share/nginx/html/index.html

# Expose port 80 to the Docker host
EXPOSE 80

# Start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]
