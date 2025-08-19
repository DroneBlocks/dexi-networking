#!/bin/bash
set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Installing DEXI networking dependencies..."

# Install NetworkManager if not present
if ! command -v nmcli &> /dev/null; then
    log "Installing NetworkManager..."
    apt-get update
    apt-get install -y network-manager
fi

# Enable NetworkManager
systemctl enable NetworkManager

# Create scripts directory in PATH
mkdir -p /usr/local/bin/dexi

# Copy scripts to system location
cp scripts/*.sh /usr/local/bin/dexi/
chmod +x /usr/local/bin/dexi/*.sh

# Create symlinks for easy access
ln -sf /usr/local/bin/dexi/configure_wifi.sh /usr/local/bin/dexi-wifi
ln -sf /usr/local/bin/dexi/create_hotspot.sh /usr/local/bin/dexi-hotspot
ln -sf /usr/local/bin/dexi/network_status.sh /usr/local/bin/dexi-status
ln -sf /usr/local/bin/dexi/reset_network.sh /usr/local/bin/dexi-reset

log "DEXI networking installed successfully!"
log "Available commands: dexi-wifi, dexi-hotspot, dexi-status, dexi-reset"