FROM debian:stable-slim

RUN apt-get update && DEBIAN_FRONTEND=noninteractive\
    apt-get -qq install curl net-tools iputils-ping openssh-server docker.io \
    fswatch jq rsync sudo iproute2 git gettext-base python3 gnupg avahi-daemon avahi-discover libnss-mdns \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L "https://github.com/docker/compose/releases/download/X.Y.Z/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
	chmod +x /usr/local/bin/docker-compose

# Download and install latest zinit
RUN curl -s https://api.github.com/repos/threefoldtech/zinit/releases/latest | \
    grep "browser_download_url" | \
    cut -d '"' -f 4 | \
    wget -qi - -O /sbin/zinit

RUN chmod +x /sbin/zinit

COPY zinit /etc/zinit

ENTRYPOINT [ "/sbin/zinit", "init" ]
