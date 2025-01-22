
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

Several environment variables need to be configured before deploying Funkwhale. SMTP configuration is optional—if not configured, Funkwhale will still function, but it will not send any emails (e.g., notifications, password resets).

### **Required for Basic Functionality**
- `FUNKWHALE_SUPERUSER_NAME`: The username for the Funkwhale superuser.
- `FUNKWHALE_SUPERUSER_EMAIL`: The email for the superuser account.
- `FUNKWHALE_SUPERUSER_PASSWORD`: The password for the superuser account.
- `Domain`: The domain name for the Funkwhale instance (e.g., `funkwhale.example.com`).
- `DJANGO_SECRET_KEY`: A unique secret key for Django. This environment variable is generated automatically by the **start script**.

### **Optional for SMTP Configuration**
If you want Funkwhale to send emails, such as notifications or password resets, you need to configure the following variables:

- `EMAIL_HOST`: The SMTP server address (e.g., `smtp.sendgrid.net`).
- `EMAIL_PORT`: The port used by the SMTP server (e.g., `587`).
- `EMAIL_USERNAME`: The username for SMTP authentication (e.g., `apikey` for SendGrid).
- `EMAIL_PASSWORD`: The password or API key for SMTP authentication.
- `EMAIL_PROTOCOL`: The protocol used for email communication. Supported options:
  - `smtp`: Plain SMTP communication.
  - `smtp+ssl`: SMTP with SSL encryption (port `465`).
  - `smtp+tls`: SMTP with TLS encryption (port `587`).
- `DEFAULT_FROM_EMAIL`: The default sender email address (e.g., `peter@funkwhale-test.com`).

If these variables are not set, Funkwhale will default to outputting emails to the console (`consolemail://`), and emails will not actually be sent.

### **Passing Environment Variables**
These environment variables are passed via `.env` files or Zinit service configurations. Ensure they are set properly before deployment to guarantee correct operation.

