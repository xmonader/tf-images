#!/bin/bash

sed -i "s/{JITSI_HOSTNAME}/$JITSI_HOSTNAME/g" /root/config/nginx.conf
cp /root/config/nginx.conf "/etc/nginx/sites-enabled/${JITSI_HOSTNAME}.conf"
/usr/sbin/nginx