#!/bin/bash

# Mount the device (requires root privileges)
mount /dev/vda /mnt

# Source the file (make sure it exists)
source /mnt/zosrc

# Only change password if PASSWORD is set
if [ -n "${PASSWORD}" ]; then
    echo "Changing the password..."
    echo "xrdpuser:${PASSWORD}" | chpasswd
else
    echo "PASSWORD not set. Skipping password change."
fi