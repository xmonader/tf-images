FROM ubuntu:22.04

RUN apt update && \
  apt -y install wget openssh-server curl sudo ufw inotify-tools iproute2 bind9-dnsutils

RUN wget -O /sbin/zinit https://github.com/threefoldtech/zinit/releases/download/v0.2.14/zinit && \
  chmod +x /sbin/zinit

RUN wget -O /sbin/caddy 'https://caddyserver.com/api/download?os=linux&arch=amd64&p=github.com%2Fcaddyserver%2Freplace-response&idempotency=43631173212363' && \
  chmod +x /sbin/caddy

RUN curl -fsSL https://get.docker.com -o /usr/local/bin/install-docker.sh && \
  chmod +x /usr/local/bin/install-docker.sh

RUN sh /usr/local/bin/install-docker.sh

COPY ./Caddyfile /etc/caddy/
COPY ./scripts/ /scripts/
COPY ./zinit/ /etc/zinit/
RUN chmod +x /scripts/*.sh

ENTRYPOINT ["/sbin/zinit", "init"]
