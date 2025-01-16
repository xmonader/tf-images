#!/bin/bash

echo "$JITSI_HOSTNAME" > /etc/hostname
PUBLIC_IP=$(curl -s ifconfig.me)
echo "$PUBLIC_IP $JITSI_HOSTNAME" >> /etc/hosts
hostname "$JITSI_HOSTNAME"