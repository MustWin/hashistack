# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER HashiCorp

# Update the repository and install Redis Server
RUN apt-get update && apt-get install -y redis-server

# Expose Redis port 6379
EXPOSE 6379

# Run Redis Server
ENTRYPOINT  ["/usr/bin/redis-server"]
