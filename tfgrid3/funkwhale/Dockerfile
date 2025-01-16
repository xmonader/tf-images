FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    curl \
    gettext \
    gnupg \
    openssh-server \
    ufw \
    nginx \
    certbot \
    python3-certbot-nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download and install the latest Zinit
RUN curl -s https://api.github.com/repos/threefoldtech/zinit/releases/latest | \
    grep "browser_download_url" | \
    cut -d '"' -f 4 | \
    wget -qi - -O /sbin/zinit && \
    chmod +x /sbin/zinit

# Copy configuration scripts
COPY scripts/ufw.sh /usr/local/bin/
COPY scripts/dockerd.sh /usr/local/bin/
COPY scripts/start-fk.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/ufw.sh /usr/local/bin/dockerd.sh /usr/local/bin/start-fk.sh

# Add Zinit configuration files
ADD zinit /etc/zinit/

# Install Docker, Buildx, and Docker Compose
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common && \
    apt-get update && \
    apt-get install -y docker.io && \
    curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose


# Clean up any remaining temporary files
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose ports for HTTP and SSH access
EXPOSE 5000 222

# Command to run Zinit in the container
CMD ["/sbin/zinit", "init", "--container"]
