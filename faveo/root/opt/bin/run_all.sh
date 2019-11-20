#!/usr/bin/env bash

chmod +x /opt/bin/*
echo "runing mariadb"
/bin/bash /opt/bin/mariadb_entry.sh

echo "mariaserver running"
echo "running faveo server"
chown -R www-data:www-data /var/run/php

# prepare for ssh service
chmod 400 -R /etc/ssh/
mkdir -p /run/sshd
[ -d /root/.ssh/ ] || mkdir /root/.ssh

# prepare for supervisor service

[ -d /var/log/php-fpm ] || mkdir -p /var/log/php-fpm

chown -R www-data:www-data /var/log/supervisor
chmod -R 0777 /usr/share/nginx/storage
chmod 0644 /etc/cron.d/faveo-cron

# use supervisord to start ssh, mysql and nginx and php-fpm

supervisord -c /etc/supervisor/supervisord.conf

exec "$@"