#!/bin/bash

echo "jitsi-videobridge2 jitsi-videobridge/jvb-hostname string $(hostname)" | debconf-set-selections
echo "jitsi-meet jitsi-meet/cert-choice select Generate a new self-signed certificate" | debconf-set-selections

apt install jitsi-meet -y