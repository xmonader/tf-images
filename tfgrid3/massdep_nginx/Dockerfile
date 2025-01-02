FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    curl \
    wget \
    openssh-server \
    gnupg \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and install Zinit
RUN curl -s https://api.github.com/repos/threefoldtech/zinit/releases/latest | \
    grep "browser_download_url" | \
    cut -d '"' -f 4 | \
    wget -qi - -O /sbin/zinit

RUN chmod +x /sbin/zinit

# Create necessary directories for Nginx
RUN mkdir -p /run/nginx /var/log/nginx 

# Adding zinit config files
ADD zinit  /etc/zinit/

# Expose the HTTP port
EXPOSE 80

# Command to start Zinit (which will manage Nginx)
CMD ["/usr/sbin/zinit", "init", "--container"]
#CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
