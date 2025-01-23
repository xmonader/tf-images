FROM ubuntu:23.04
ENV DEBIAN_FRONTEND=noninteractive

# Install pcakages
RUN sed -i 's|http://archive.ubuntu.com/ubuntu|http://old-releases.ubuntu.com/ubuntu|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu|http://old-releases.ubuntu.com/ubuntu|g' /etc/apt/sources.list && \
    apt update && \
    apt upgrade -y && \
    apt install -y wget curl git openssh-server ufw

# Download and install latest zinit
RUN curl -s https://api.github.com/repos/threefoldtech/zinit/releases/latest | \
    grep "browser_download_url" | \
    cut -d '"' -f 4 | \
    wget -qi - -O /sbin/zinit
    
RUN chmod +x /sbin/zinit
COPY scripts/ufw.sh /usr/local/bin/

# Adding zinit config files
ADD zinit  /etc/zinit/  

# Cleaning up
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Command to run the zinit
CMD ["/sbin/zinit", "init", "--container"]
