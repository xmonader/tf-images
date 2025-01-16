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

mkdir -p ./logs

# Function to log messages with timestamps
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a ./logs/setup.log
}

log_message "Starting script execution"
log_message "Installing arch-install-scripts package..."
apt-get update
apt-get install arch-install-scripts debootstrap -y

log_message "Starting debootstrap..."
mkdir -p ubuntu-noble

debootstrap noble ubuntu-noble http://archive.ubuntu.com/ubuntu
log_message "Debootstrap completed."

log_message "Preparing chroot environment script..."
cat <<'EOF' > ubuntu-noble/root/setup_inside_chroot.sh
#!/bin/bash
set -x  # This will print each command before it's executed
export PATH=/usr/local/sbin/:/usr/local/bin/:/usr/sbin/:/usr/bin/:/sbin:/bin

echo "Starting setup inside chroot"

# Pre-configure tzdata
echo "tzdata tzdata/Areas select Etc" | debconf-set-selections
echo "tzdata tzdata/Zones/Etc select UTC" | debconf-set-selections

# Set timezone to UTC
ln -fs /usr/share/zoneinfo/UTC /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

echo "Configuring DNS..."
rm /etc/resolv.conf
echo 'nameserver 1.1.1.1' > /etc/resolv.conf

echo "Updating package lists..."
apt-get update -y || echo "ERROR: Failed to update package lists"

echo "Installing initial packages..."
apt-get install -y cloud-init openssh-server curl initramfs-tools ufw || echo "ERROR: Failed to install initial packages"

echo "Cleaning cloud-init..."
cloud-init clean

echo "Installing extra kernel modules..."
apt-get install linux-virtual -y || echo "ERROR: Failed to install extra kernel modules"

echo "Configuring initramfs..."
echo 'fs-virtiofs' >> /etc/initramfs-tools/modules
update-initramfs -c -k all

# Install XFCE and XRDP
echo "Installing XFCE and XRDP..."
DEBIAN_FRONTEND=noninteractive add-apt-repository -y universe
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y xfce4 xfce4-goodies xrdp sudo || echo "ERROR: Failed to install xrdp"

# Create a non-root user for XRDP
echo "Creating non-root user for XRDP..."
useradd -m -s /bin/bash xrdpuser
echo "xrdpuser:xrdppassword" | chpasswd
usermod -aG sudo xrdpuser

# Configure XRDP for the new user
echo "Configuring XRDP for the new user..."
echo "xfce4-session" > /home/xrdpuser/.xsession
chown xrdpuser:xrdpuser /home/xrdpuser/.xsession

# Configure XRDP
echo "Configuring XRDP..."
sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
systemctl enable xrdp || echo "WARNING: Failed to enable XRDP service"

echo "Cleaning up packages..."
apt-get clean

# Set correct ownership and permissions for sudo
echo "Setting sudo permissions..."
chown root:root /usr/bin/sudo
chmod 4755 /usr/bin/sudo

echo "Setting execute permissions for custom scripts..."
chmod +x /usr/local/bin/*

# Enable the services
echo "Enabling custom services..."
systemctl enable set_sudo_permissions.service || echo "WARNING: Failed to enable set_sudo_permissions service"
systemctl enable user_password.service || echo "WARNING: Failed to enable user_password service"
systemctl enable ufw_setup.service || echo "WARNING: Failed to enable ufw_setup service"
systemctl enable xrdp_setup.service || echo "WARNING: Failed to enable xrdp_setup service"

echo "Chroot setup completed"
EOF

chmod +x ubuntu-noble/root/setup_inside_chroot.sh

log_message "Copying services and scripts into the VM..."
cp ./services/* ubuntu-noble/etc/systemd/system/ 2>/dev/null || log_message "WARNING: Could not copy service files"
cp ./scripts/* ubuntu-noble/usr/local/bin/ 2>/dev/null || log_message "WARNING: Could not copy script files"

log_message "Entering chroot environment..."
arch-chroot ubuntu-noble /root/setup_inside_chroot.sh 2>&1 | tee -a ./logs/chroot_setup.log
log_message "Chroot setup completed."

log_message "Cleaning up..."
rm ubuntu-noble/root/setup_inside_chroot.sh
rm -rf ubuntu-noble/dev/*

log_message "Creating tar archive..."
tar -czf ubuntu-24.04_vm_xrdp.tar.gz -C ubuntu-noble .
log_message "Tar archive created."

log_message "Uploading to Threefold Hub..."
curl -v -X POST -H "Authorization: Bearer $API_KEY" -F "file=@ubuntu-24.04_vm_xrdp.tar.gz" https://hub.grid.tf/api/flist/me/upload
log_message "Upload completed."

log_message "Script execution completed"