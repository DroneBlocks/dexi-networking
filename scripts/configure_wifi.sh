#!/bin/bash
set -e

SSID="$1"
PASSWORD="$2"
PRIORITY="${3:-10}"

usage() {
    echo "Usage: $0 <SSID> <PASSWORD> [PRIORITY]"
    echo "Example: $0 HomeNetwork mypassword 10"
    echo "Higher priority numbers connect first (default: 10)"
    exit 1
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Validate arguments
if [ $# -lt 2 ]; then
    usage
fi

# Sanitize connection name (replace spaces/special chars)
CONNECTION_NAME=$(echo "$SSID" | sed 's/[^a-zA-Z0-9]/_/g')

log "Configuring WiFi network '$SSID'..."

# Remove existing connection if it exists
nmcli connection delete "$CONNECTION_NAME" 2>/dev/null || true

# Create new WiFi connection
nmcli connection add type wifi con-name "$CONNECTION_NAME" ifname wlan0 ssid "$SSID" \
    wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$PASSWORD"

# Set priority (higher number = higher priority)
nmcli connection modify "$CONNECTION_NAME" connection.autoconnect-priority "$PRIORITY"

# Try to connect immediately
if nmcli connection up "$CONNECTION_NAME" 2>/dev/null; then
    log "Successfully connected to '$SSID'"
    log "Connection saved for automatic reconnection"
else
    log "WiFi network '$SSID' configured but not currently available"
    log "Will connect automatically when in range"
fi

# Show current connection status
sleep 2
nmcli connection show --active | grep -E "(NAME|$CONNECTION_NAME)" || log "Not currently connected"