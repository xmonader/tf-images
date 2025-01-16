FROM ubuntu:24.04

RUN apt update && \
  apt -y install wget openssh-server nginx

RUN wget -O /sbin/zinit https://github.com/threefoldtech/zinit/releases/download/v0.2.14/zinit && \
  chmod +x /sbin/zinit

COPY zinit /etc/zinit
COPY start.sh /start.sh

RUN chmod +x /sbin/zinit && chmod +x /start.sh
ENTRYPOINT  ["zinit", "init"]
