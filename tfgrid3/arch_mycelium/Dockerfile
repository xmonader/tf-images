FROM archlinux:base-20240101.0.204074

# Update system and install packages
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm wget curl git openssh ufw

# Download and install latest zinit
RUN curl -s https://api.github.com/repos/threefoldtech/zinit/releases/latest | \
    grep "browser_download_url" | \
    cut -d '"' -f 4 | \
    wget -qi - -O /sbin/zinit

RUN chmod +x /sbin/zinit
COPY scripts/ufw.sh /usr/local/bin/

# Adding zinit config files
ADD zinit /etc/zinit/

# Cleaning up
RUN pacman -Scc --noconfirm

# Command to run the zinit
CMD ["/sbin/zinit", "init", "--container"]
