
# Funkwhale for ThreeFold Grid

This Directory contains the configuration files and setup required to deploy **Funkwhale**, a self-hosted, decentralized audio platform. The directory includes Docker Compose files, service scripts, and configurations necessary for running Funkwhale.


## Building the Funkwhale Image

- ### To build the Docker image for Funkwhale, you can follow these steps:

 #### Build the Docker image and tag it for the threefolddev repository::
```
cd tf-image/tfgrid3/funkwhale/ 
docker build -t threefolddev/funkwhale:$FUNKWHALE_VERSION .
```
#### Log in to the Docker registry:
```docker login ```
#### Push the image to the threefolddev account:
```docker push threefolddev/funkwhale:$FUNKWHALE_VERSION```

#### Convert the docker image to Zero-OS flist
Convert the docker image to Flist is using [Docker Hub Converter tool](https://hub.grid.tf/docker-convert), make sure you already built and pushed the docker image to docker hub before using this tool.


## Environment Variables

Several environment variables need to be configured before deploying Funkwhale:

- `FUNKWHALE_SUPERUSER_NAME`: The username for the Funkwhale superuser.
- `FUNKWHALE_SUPERUSER_EMAIL`: The email for the superuser account.
- `FUNKWHALE_SUPERUSER_PASSWORD`: Password for the superuser account.
- `FUNKWHALE_VERSION`: The version of Funkwhale to use (default: `1.4.0`).
- `Domain`: The domain name for the Funkwhale instance (e.g., `funkwhale.example.com`).
- `DJANGO_SECRET_KEY`: A unique secret key for Django. This environment variable is generated automatically by the **start script**.

These variables are passed via `.env` files or Zinit service configurations. Ensure they are set properly before deployment.

## SSL Configuration
This setup uses Certbot to generate and configure SSL certificates for your domain. Ensure the domain is properly configured with DNS settings that point to your server. The certificates are generated automatically during the deployment process.


