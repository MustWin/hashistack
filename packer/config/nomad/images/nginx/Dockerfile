############################################################
# Dockerfile to build Nginx Installed Containers
# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER HashiCorp

# Install Nginx

# Add application repository URL to the default sources
# RUN echo "deb http://archive.ubuntu.com/ubuntu/ raring main universe" >> /etc/apt/sources.list

# Update the repository
RUN apt-get update

# Install necessary tools
RUN apt-get install -y wget dialog net-tools curl unzip nginx

# Remove the default Nginx configuration file
RUN rm -v /etc/nginx/nginx.conf

# Copy a configuration file from the current directory
ADD nginx.conf /etc/nginx/

# Append "daemon off;" to the beginning of the configuration
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Install consul-template
RUN cd /tmp

# Download consul-template
RUN curl -L https://releases.hashicorp.com/consul-template/0.11.1/consul-template_0.11.1_linux_amd64.zip > consul_template.zip

# Unzip consul-template
RUN unzip consul_template.zip -d /usr/local/bin

# Update consul-template permissions
RUN chmod 0755 /usr/local/bin/consul-template && \
    chown root:root /usr/local/bin/consul-template

# Create consul-template configuration folders
RUN mkdir -p /etc/consul_template.d && \
    chmod 755 /etc/consul_template.d && \
    mkdir -p /opt/consul_template && \
    chmod 755 /opt/consul_template

# Copy custom configuration files from the current directory
ADD consul_template/nginx.hcl /etc/consul_template.d/
ADD consul_template/nginx.ctmpl /opt/consul_template/

# Expose ports
EXPOSE 80

# Set the default command to execute when creating a new container
CMD /usr/local/bin/consul-template -config "/etc/consul_template.d" >>/var/log/consul_template.log 2>&1
