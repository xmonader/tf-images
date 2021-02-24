FROM crystallang/crystal:0.35.1-alpine

RUN apk add --no-cache git libssh2-static libssh2 libssh2-dev
RUN mkdir -p /sandbox/code/github/crystaluniverse/publishingtools
RUN git clone https://github.com/crystaluniverse/publishingtools.git /sandbox/code/github/crystaluniverse/publishingtools
WORKDIR /sandbox/code/github/crystaluniverse/publishingtools
RUN shards build
RUN rm -rf ./lib
COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]
