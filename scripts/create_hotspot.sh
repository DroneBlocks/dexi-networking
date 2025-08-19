#!/bin/bash
set -e

SSID="$1"
PASSWORD="$2"
INTERFACE="${3:-wlan0}"

usage() {
    echo "Usage: $0 <SSID> <PASSWORD> [INTERFACE]"
    echo "Example: $0 dexi_a4b2 droneblocks wlan0"
    exit 1
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Validate arguments
if [ $# -lt 2 ]; then
    usage
fi

if [ ${#PASSWORD} -lt 8 ]; then
    echo "Error: Password must be at least 8 characters"
    exit 1
fi

log "Creating hotspot '$SSID' on interface $INTERFACE..."

# Remove existing hotspot connection if it exists
nmcli connection delete "dexi-hotspot" 2>/dev/null || true

# Create new hotspot connection
nmcli connection add type wifi ifname "$INTERFACE" con-name "dexi-hotspot" autoconnect yes \
    wifi.mode ap wifi.ssid "$SSID" wifi.band bg \
    wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$PASSWORD" \
    ipv4.method shared ipv4.addresses 192.168.4.1/24

# Set lower priority so user networks take precedence
nmcli connection modify "dexi-hotspot" connection.autoconnect-priority -10

log "Hotspot '$SSID' created successfully!"
log "Password: $PASSWORD"
log "IP Address: 192.168.4.1"
log "DHCP Range: 192.168.4.2-192.168.4.254"