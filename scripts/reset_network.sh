#!/bin/bash
set -e

KEEP_HOTSPOT="${1:-false}"

usage() {
    echo "Usage: $0 [keep-hotspot]"
    echo "Resets all network connections except optionally the hotspot"
    echo "Examples:"
    echo "  $0                 # Remove all connections including hotspot"
    echo "  $0 keep-hotspot    # Remove all connections except hotspot"
    exit 1
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

confirm() {
    read -p "This will remove all saved WiFi networks. Continue? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
    fi
}

log "DEXI Network Reset"

# Show current connections
echo "Current connections:"
nmcli connection show

echo
confirm

log "Removing saved network connections..."

# Get all connection UUIDs except hotspot if keeping it
if [ "$KEEP_HOTSPOT" = "keep-hotspot" ]; then
    CONNECTIONS=$(nmcli -t -f UUID,TYPE connection show | grep "802-11-wireless" | grep -v "dexi-hotspot" | cut -d: -f1)
    log "Keeping hotspot connection"
else
    CONNECTIONS=$(nmcli -t -f UUID,TYPE connection show | grep "802-11-wireless" | cut -d: -f1)
    log "Removing all wireless connections including hotspot"
fi

# Remove connections
if [ -n "$CONNECTIONS" ]; then
    echo "$CONNECTIONS" | while read -r uuid; do
        if [ -n "$uuid" ]; then
            CONNECTION_NAME=$(nmcli -t -f NAME connection show "$uuid" | cut -d: -f2)
            log "Removing connection: $CONNECTION_NAME"
            nmcli connection delete "$uuid"
        fi
    done
else
    log "No wireless connections to remove"
fi

# Restart NetworkManager to ensure clean state
log "Restarting NetworkManager..."
systemctl restart NetworkManager

log "Network reset complete!"
log "Use 'dexi-wifi' to configure new networks"
if [ "$KEEP_HOTSPOT" != "keep-hotspot" ]; then
    log "Use 'dexi-hotspot' to recreate the hotspot"
fi