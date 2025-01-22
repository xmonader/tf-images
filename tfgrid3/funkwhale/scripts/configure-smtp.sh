#!/bin/bash

# Path to the .env file
ENV_FILE="/srv/funkwhale/.env"

# Check if all required variables are set
if [[ -z "$EMAIL_HOST" || -z "$EMAIL_PORT" || -z "$EMAIL_USERNAME" || -z "$EMAIL_PASSWORD" || -z "$EMAIL_PROTOCOL" || -z "$DEFAULT_FROM_EMAIL" ]]; then
  echo "Missing required SMTP variables. Disabling SMTP."
else
  echo "All required SMTP variables are set. Configuring SMTP."
  EMAIL_CONFIG="${EMAIL_PROTOCOL}://${EMAIL_USERNAME}:${EMAIL_PASSWORD}@${EMAIL_HOST}:${EMAIL_PORT}"
  sed -i "/^# EMAIL_CONFIG=dummymail/s|^# EMAIL_CONFIG=.*|EMAIL_CONFIG=${EMAIL_CONFIG}|" "$ENV_FILE"
  sed -i "/^# DEFAULT_FROM_EMAIL=/s|^# DEFAULT_FROM_EMAIL=.*|DEFAULT_FROM_EMAIL=${DEFAULT_FROM_EMAIL}|" "$ENV_FILE"
fi
