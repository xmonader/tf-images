# grid3_Umbrel

Get Umbrel up and running on grid3.

This image based on Debian.

## What in this image

- Docker
- Docker-compose
- include preinstalled openssh-client, yq, openssh-server, curl, iproute2, python3 and some other packages.
- [zinit](https://github.com/threefoldtech/zinit) process manager which is configured with these services:

  - **sshd**: starting OpenSSH server daemon
  - **ssh_config**: Add the user SSH key to authorized_keys, so he can log in remotely to the host which running this image.
  - **dockerd**: run docker daemon
  - **config**: run [umbrel-install](./scripts/umbrel-install.sh)
    - this will install [Umbrel](https://github.com/getumbrel/umbrel) v0.5.3
    - manipulate the [start](https://github.com/getumbrel/umbrel/blob/master/scripts/start) script to
      1. enable ipv6 in docker-compose using yq
      2. just pull the docker images of [docker-compose.yml](https://github.com/getumbrel/umbrel/blob/master/docker-compose.yml) instead of running them.
      3. run the [start](https://github.com/getumbrel/umbrel/blob/master/scripts/start) script with those modifications.
  - **Umbrel**:
    1. start Umbrel by running [Umbrel-start](./scripts/umbrel-start.sh)
        > This script is a modified version of the start script avoid some remote-access, installed apps, and restart issues.
        - This script will check for the `REBOOT_SIGNAL_FILE` and if it exists and has `true`, it will run [stop](https://github.com/getumbrel/umbrel/blob/master/scripts/stop) script.
        - it will run the a modified version of the start script to start Umbrel, and tor-server < if remote access enabled > and the installed apps.
    2. run `docker-compose up  --no-recreate;` only to make it monitored by zinit.
      > `--no-recreate` used because the [umbrel-start](./scripts/umbrel-start.sh) script will run docker-compose up so no need to recreate any of them.
  - **register**: try to register with user credentials, if the curl returns `No route to host` it will sleep for 2 seconds and try again.

## Building

in the umbrel directory

`docker build -t {user|org}/grid3_umbrel_docker:latest .`

## Deploying on grid 3

### convert the docker image to Zero-OS flist

Easiest way to convert the docker image to Flist is using [Docker Hub Converter tool](https://hub.grid.tf/docker-convert), make sure you already built and pushed the docker image to docker hub before using this tool.

### Deploying

Easiest way to deploy a VM using the flist is to head to to our [playground](https://play.grid.tf) and deploy a Virtual Machine by providing this flist URL.

> make sure to provide the correct entrypoint, and required env vars.

or use the dedicated Umbrel weblet if available, which will deploy an instance that satisfies the above perquisites.

> TODO: add terraform example file

## Flist

### URL

````link
https://hub.grid.tf/tf-official-apps/umbrel-latest.flist
````

### Entrypoint

- `/sbin/zinit init`

### Required Env Vars

- `SSH_KEY`: User SSH public key.
- `USERNAME`: this will be used in registration to Umbrel dashboard.
- `PASSWORD`: this will be used in registration, and login to Umbrel dashboard, must be 12 characters or longer.

### Optional Env Vars

- `UMBREL_DISK`
  This env will be used to configure the installation process, to make Umbrel installed on `"${UMBREL_DISK}/umbrel"`

  - If the UMBREL_DISK not specified, the install path will be `/umbrel`

> For advanced configuration, please check the envs mentioned in [umbrel-dashboard](https://github.com/getumbrel/umbrel-dashboard), [umbrel-manager](https://github.com/getumbrel/umbrel-manager), and [.env-example](https://github.com/getumbrel/umbrel/blob/master/templates/.env-sample) file.

## Your Umbrel

- you can login to your Umbrel dashboard simply by navigating to the machine ip and enter your `PASSWORD`

> **Warning**: Due to the nature of the grid, shutdown, or restart your umbrel from the dashboard **MAY** make some unwanted behaviors.
