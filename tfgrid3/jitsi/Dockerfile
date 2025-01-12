FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
apt -y install wget openssh-server

RUN wget -O /sbin/zinit https://github.com/threefoldtech/zinit/releases/download/v0.2.14/zinit && \
chmod +x /sbin/zinit

RUN apt upgrade -y


COPY zinit /etc/zinit
COPY start.sh /start.sh

RUN chmod +x /sbin/zinit && chmod +x /start.sh

COPY scripts /root/scripts
COPY config /root/config

RUN chmod +x /root/scripts/*.sh

RUN apt install -y curl gnupg2 nginx-full apt-transport-https \
    software-properties-common openjdk-11-jdk ufw && \
    apt-add-repository universe -y

RUN curl -sL https://prosody.im/files/prosody-debian-packages.key -o /etc/apt/keyrings/prosody-debian-packages.key && \
    echo "deb [signed-by=/etc/apt/keyrings/prosody-debian-packages.key] http://packages.prosody.im/debian $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/prosody-debian-packages.list && \
    curl -sL https://download.jitsi.org/jitsi-key.gpg.key | gpg --dearmor -o /usr/share/keyrings/jitsi-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/jitsi-keyring.gpg] https://download.jitsi.org stable/" | tee /etc/apt/sources.list.d/jitsi-stable.list && \
    apt update && \
    apt install -y lua5.2
ARG USERNAME=jitsi
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME 

USER $USERNAME
ENTRYPOINT  ["zinit", "init"]
