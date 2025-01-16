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
echo "ubuntu-noble" > /etc/hostname
apt-get update
apt-get install cloud-init openssh-server curl initramfs-tools -y
cloud-init clean
apt-get install linux-image-6.8.0-31-generic -y
echo 'fs-virtiofs' >> /etc/initramfs-tools/modules
update-initramfs -c -k all
update-grub
apt-get clean
EOF

chmod +x ubuntu-noble/root/setup_inside_chroot.sh

# Enter the new environment using arch-chroot and execute the setup script
arch-chroot ubuntu-noble /root/setup_inside_chroot.sh

# Clean up
rm ubuntu-noble/root/setup_inside_chroot.sh
rm -rf ubuntu-noble/dev/*

# Check if extract-vmlinux is available and install if it's not
if ! command -v extract-vmlinux &>/dev/null; then
	    echo "extract-vmlinux not found, installing..."
	    curl -O https://raw.githubusercontent.com/torvalds/linux/master/scripts/extract-vmlinux
	    chmod +x extract-vmlinux
            mv extract-vmlinux /usr/local/bin
fi

# Kernel Extraction
extract-vmlinux ubuntu-noble/boot/vmlinuz | tee ubuntu-noble/boot/vmlinuz-6.8.0-31-generic.elf > /dev/null
mv ubuntu-noble/boot/vmlinuz-6.8.0-31-generic.elf ubuntu-noble/boot/vmlinuz-6.8.0-31-generic

# Create a compressed archive of the configured system for uploading to hub.
tar -czf ubuntu-24.04_fullvm.tar.gz -C ubuntu-noble .

# Upload flist
# Ensure API_KEY is set
if [ -z "$API_KEY" ]; then
	    echo "API_KEY is not set. Please set your API_KEY environment variable." >&2
	        exit 2
fi

curl -X POST -H "Authorization: Bearer $API_KEY" -F "file=@ubuntu-24.04_fullvm.tar.gz" https://hub.grid.tf/api/flist/me/upload
