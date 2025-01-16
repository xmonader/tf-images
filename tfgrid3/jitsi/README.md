# Jitsi TF Image

The image contains:

- prosody xmpp server -- a communication server
- jicofo(used by Jitsi) -- conference orchestrator
- jitsi-videobridge(jvb) -- WebRTC compatible video router

Exposed ports:

- 80
- 443
- 10000
- 22
- 3478
- 5349

# Usage

If you want to build the image from scratch, follow the steps below:

1- Clone the repository and navigate to the jitsi directory

```bash
git clone git git@github.com:threefoldtech/tf-images.git
cd tfgrid3/jitsi
```

2- Edit it however you please

3- Build the image

```bash
docker build -t jitsi .
```

The following is just one way to convert the image to an flist, you can use any other method you prefer.

4- Push the image to docker hub

```bash
docker tag jitsi {dockerhub-username}/jitsi
```

5- Convert it to an flist using the convertor in [Zero-OS Hub](https://hub.grid.tf/docker-convert)

6- Deploy the container on the grid using the flist URL you got from the previous step

# Environment Variables

- `SSH_KEY` -- the ssh key to be used to access the container
- `JITSI_HOSTNAME` -- this is the domain name that will be used to access the jitsi server(fqdn)

---

- Current Docker Hub image: [eyadhussein/jitsi](https://hub.docker.com/repository/docker/eyadhussein/jitsi)
- Current flist: [jitsi flist](https://hub.grid.tf/eyadhussein.3bot/eyadhussein-jitsi-latest.flist.md)
