FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt -y install wget curl vim net-tools iputils-ping openssh-server

# Download and install latest zinit
RUN curl -s https://api.github.com/repos/threefoldtech/zinit/releases/latest | \
    grep "browser_download_url" | \
    cut -d '"' -f 4 | \
    wget -qi - -O /sbin/zinit

RUN chmod +x /sbin/zinit

ENV ALGORAND_DATA=/var/lib/algorand
RUN echo export ALGORAND_DATA=/var/lib/algorand >> ~/.bashrc

RUN curl -O https://releases.algorand.com/key.pub &&\
    apt-get update &&\
    apt-get install -y gnupg2 software-properties-common &&\
    apt-key add key.pub &&\
    add-apt-repository "deb [arch=amd64] https://releases.algorand.com/deb/ stable main" &&\
    apt-get update &&\
    apt-get install -y algorand-devtools algorand

RUN apt update && \
    apt -y install expect 

RUN apt-get update &&\
    apt-get install \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg &&\
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null &&\ 
    apt-get update &&\
    apt-get install -y docker-ce docker-ce-cli containerd.io

RUN wget https://github.com/docker/compose/releases/download/v2.1.0/docker-compose-linux-x86_64 &&\
    mv ./docker-compose-linux-x86_64 /usr/local/bin/docker-compose &&\
    chmod a+x /usr/local/bin/docker-compose

COPY indexer /indexer
RUN mkdir -p /var/algorand/data &&\
    mkdir  -p /var/lib/postgresql/data/ &&\
    cp /indexer/config.json /var/algorand/config.json

COPY scripts /scripts
RUN chmod -R +x /scripts

RUN mkdir -p /etc/zinit
COPY zinit /etc/zinit

ENTRYPOINT [ "/sbin/zinit", "init" ]

# IMAGE_TAG: threefolddev/algorand:v1.0-all
