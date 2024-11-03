# Creating btc full node FList

This guide provides instructions on how to deploy  (Bitcoin Core) as a full node, on the Grid using an FList image.


## Building

in the btcnode directory

`docker build -t {user|org/btcnode:latest .`

## Deploying on grid 3

### convert the docker image to Zero-OS flist

Easiest way to convert the docker image to Flist is using [Docker Hub Converter tool](https://hub.grid.tf/docker-convert), make sure you already built and pushed the docker image to docker hub before using this tool.


### Entrypoint

- `/sbin/zinit init`

### Required Env Vars

- `SSH_KEY`: User SSH public key.
