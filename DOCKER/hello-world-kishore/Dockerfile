# Use an existing base image
FROM alpine:latest

# Set the working directory to /app
WORKDIR /app

# Copy the executable file into the container
COPY hello_world.sh .

# Set the file permissions
RUN chmod +x hello_world.sh

# Run the executable when the container starts
CMD ["/bin/sh", "./hello_world.sh && sleep 600 "]
