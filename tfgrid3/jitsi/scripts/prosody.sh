#!/bin/bash

set -e

USER=prosody
PIDFILE=/run/prosody/prosody.pid

mkdir -p "$(dirname "$PIDFILE")"
chown "$USER:adm" "$(dirname "$PIDFILE")"

echo "Starting Prosody XMPP Server as user $USER..."
if su -s /bin/bash -c /usr/bin/prosody "$USER"; then
    echo "Prosody started successfully."
else
    echo "Failed to start Prosody."
    exit 1
fi
