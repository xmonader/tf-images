#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
	    echo "This script must be run as root" >&2
	        exit 1
fi

# Check if API_KEY provided or not
if [ -z "$1" ]; then
    echo "Usage: $0 <API_KEY>"
    exit 2
fi

API_KEY=$1

# Install arch-install-scripts package to use arch-chroot
apt-get update
apt-get install arch-install-scripts -y

# Setup and Bootstrap
mkdir ubuntu-noble
debootstrap noble ubuntu-noble http://archive.ubuntu.com/ubuntu

# Prepare the chroot environment script
cat <<EOF > ubuntu-noble/root/setup_inside_chroot.sh
#!/bin/bash
export PATH=/usr/local/sbin/:/usr/local/bin/:/usr/sbin/:/usr/bin/:/sbin:/bin
rm /etc/resolv.conf
echo 'nameserver 1.1.1.1' > /etc/resolv.conf
apt-get update
apt-get install cloud-init openssh-server curl initramfs-tools linux-virtual -y
cloud-init clean
echo 'fs-virtiofs' >> /etc/initramfs-tools/modules
update-initramfs -c -k all
apt-get clean
EOF

chmod +x ubuntu-noble/root/setup_inside_chroot.sh

# Enter the new environment using arch-chroot and execute the setup script
arch-chroot ubuntu-noble /root/setup_inside_chroot.sh

# Clean up
rm ubuntu-noble/root/setup_inside_chroot.sh
rm -rf ubuntu-noble/dev/*

# Create a compressed archive of the configured system for uploading to hub.
tar -czf ubuntu-24.04_fullvm.tar.gz -C ubuntu-noble .

# Upload flist
# Ensure API_KEY is set
if [ -z "$API_KEY" ]; then
	    echo "API_KEY is not set. Please set your API_KEY environment variable." >&2
	        exit 2
fi

curl -X POST -H "Authorization: Bearer $API_KEY" -F "file=@ubuntu-24.04_fullvm.tar.gz" https://hub.grid.tf/api/flist/me/upload
