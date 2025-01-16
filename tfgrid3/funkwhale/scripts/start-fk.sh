#!/bin/bash
set -ex

# Check if FUNKWHALE_VERSION is set, if not, default to 1.4.0
FUNKWHALE_VERSION=${FUNKWHALE_VERSION:-1.4.0}

# Change to Funkwhale directory
cd /srv/funkwhale/

# Download the Docker Compose and environment files for the specified version
curl -L -o docker-compose.yml "https://dev.funkwhale.audio/funkwhale/funkwhale/raw/${FUNKWHALE_VERSION}/deploy/docker-compose.yml"
curl -L -o .env "https://dev.funkwhale.audio/funkwhale/funkwhale/raw/${FUNKWHALE_VERSION}/deploy/env.prod.sample"

# Set appropriate permissions for the .env file
chmod 600 .env

# Generate a random Django secret key and update the .env file
DJANGO_SECRET=$(openssl rand -base64 45)
sed -i "s#^DJANGO_SECRET_KEY=.*#DJANGO_SECRET_KEY=$DJANGO_SECRET#" .env

# Add environment variables to the .env file
sed -i "s#^FUNKWHALE_VERSION=.*#FUNKWHALE_VERSION=$FUNKWHALE_VERSION#" .env
sed -i "s#^FUNKWHALE_HOSTNAME=.*#FUNKWHALE_HOSTNAME=$Domain#" .env

# Pull the latest Docker images for Funkwhale
docker-compose pull

# Start PSQL service
docker-compose up -d postgres

# Run database migrations
docker-compose run --rm api funkwhale-manage migrate

# Create a superuser using the provided credentials
docker-compose run --rm -T api funkwhale-manage fw users create --superuser <<EOF
$FUNKWHALE_SUPERUSER_NAME
$FUNKWHALE_SUPERUSER_PASSWORD
$FUNKWHALE_SUPERUSER_EMAIL
EOF

# Start Funkwhale services
docker-compose up -d

# Check if $Domain is set before proceeding with SSL generation
if [ -z "$Domain" ]; then
    echo "No Domain provided. Skipping SSL setup and exiting."
    exit 0
fi

# Download and apply the Funkwhale Nginx proxy configuration
curl -L -o /etc/nginx/funkwhale_proxy.conf "https://dev.funkwhale.audio/funkwhale/funkwhale/raw/$FUNKWHALE_VERSION/deploy/funkwhale_proxy.conf"
curl -L -o /etc/nginx/sites-available/funkwhale.template "https://dev.funkwhale.audio/funkwhale/funkwhale/raw/$FUNKWHALE_VERSION/deploy/docker.proxy.template"

# Apply environment variables to the Nginx template and create the final Nginx configuration
set -a && source /srv/funkwhale/.env && set +a
envsubst "`env | awk -F = '{printf \" $%s\", $$1}'`" < /etc/nginx/sites-available/funkwhale.template > /etc/nginx/sites-available/funkwhale.conf

# Comment out SSL cert lines temporarily to allow HTTP access before SSL setup
sed -i "s/listen      443 ssl http2\;/#listen      443 ssl http2\;/" /etc/nginx/sites-available/funkwhale.conf
sed -i "s/listen \[::\]:443 ssl http2;/#listen \[::\]:443 ssl http2;/" /etc/nginx/sites-available/funkwhale.conf
sed -i "s/ssl_certificate/\#ssl_certificate/" /etc/nginx/sites-available/funkwhale.conf

# Enable the Funkwhale Nginx site and create a backup of the current configuration
ln -s /etc/nginx/sites-available/funkwhale.conf /etc/nginx/sites-enabled/
cp /etc/nginx/sites-available/funkwhale.conf /etc/nginx/sites-available/funkwhale.conf.bak

# Generate SSL certificate using Certbot
certbot --nginx -d $Domain --non-interactive --agree-tos --register-unsafely-without-email

# Restore the original Nginx configuration from the backup
mv /etc/nginx/sites-available/funkwhale.conf.bak /etc/nginx/sites-available/funkwhale.conf

# Uncomment the SSL lines after Certbot finishes
sed -i "s/\#ssl_certificate/ssl_certificate/" /etc/nginx/sites-available/funkwhale.conf
sed -i "s/\#listen/listen/" /etc/nginx/sites-available/funkwhale.conf

# Add HTTP to HTTPS redirection in the Nginx configuration
sed -i "11a \    if (\$host = $Domain) {\n        return 301 https://\$host\$request_uri;\n    }" /etc/nginx/sites-available/funkwhale.conf

# Restart Nginx to apply the New SSL configuration
zinit stop nginx
zinit start nginx
