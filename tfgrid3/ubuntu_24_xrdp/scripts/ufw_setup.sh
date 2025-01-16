#!/bin/bash

mount /dev/vda /mnt
source /mnt/zosrc
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow from ${LOCALIP}/32 to any port 3389
ufw limit ssh
ufw --force enable