FROM ubuntu

# Some ENV variables
ENV PATH="/mattermost/bin:${PATH}"
ENV MM_VERSION=5.25.0

# Build argument to set Mattermost edition
ARG edition=team
ARG PUID=2000
ARG PGID=2000
ARG MM_BINARY=
ENV DEBIAN_FRONTEND=noninteractive

# Install some needed packages
RUN apt-get update \
    && apt-get install -y curl jq sudo libffi-dev netcat-openbsd tzdata libcap2-bin postgresql postgresql postgresql-contrib openssh-server ufw\
    && rm -rf /tmp/* \
    && wget -O /sbin/zinit https://github.com/threefoldtech/zinit/releases/download/v0.2.14/zinit \
    && chmod +x /sbin/zinit \
    && mkdir -p /etc/zinit
COPY scripts /etc/zinit
# Get Mattermost
COPY mattermost-team-linux-amd64.tar.gz /
RUN mkdir -p /mattermost/data /mattermost/plugins /mattermost/client/plugins \
    && tar -xvf  mattermost-team-linux-amd64.tar.gz \
    && cp /mattermost/config/config.json /config.json.save \
    && rm -rf /mattermost/config/config.json \
    && addgroup --gid ${PGID} mattermost \
    && useradd -p mattermost -d  /mattermost -u 2000 -m -g mattermost mattermost \
    && usermod -G sudo mattermost \
    && chown -R mattermost:mattermost /mattermost /config.json.save /mattermost/plugins /mattermost/client/plugins \
    && setcap cap_net_bind_service=+ep /mattermost/bin/mattermost \
    && chmod 0600 /etc/ssl/private/ssl-cert-snakeoil.key

USER root

#Healthcheck to make sure container is ready
HEALTHCHECK CMD curl --fail http://localhost:8000 || exit 1

# Configure entrypoint and command
#COPY entrypoint.sh /
ENTRYPOINT ["/sbin/zinit", "init"]
WORKDIR /mattermost
CMD ["mattermost"]

# Expose port 8000 of the container
EXPOSE 8000

# Declare volumes for mount point directories
VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config", "/mattermost/plugins", "/mattermost/client/plugins"]
