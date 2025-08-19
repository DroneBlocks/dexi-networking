#!/bin/bash

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

print_section() {
    echo
    echo "=== $1 ==="
}

print_section "DEXI Network Status"

# Check if NetworkManager is running
if ! systemctl is-active NetworkManager >/dev/null 2>&1; then
    echo "❌ NetworkManager is not running"
    exit 1
fi

# Show active connections
print_section "Active Connections"
ACTIVE=$(nmcli connection show --active)
if [ -n "$ACTIVE" ]; then
    echo "$ACTIVE"
else
    echo "No active connections"
fi

# Show WiFi status
print_section "WiFi Interface Status"
nmcli device status | grep wifi || echo "No WiFi devices found"

# Show available networks
print_section "Available WiFi Networks"
nmcli device wifi list 2>/dev/null | head -10 || echo "Unable to scan for networks"

# Show saved connections
print_section "Saved Connections"
nmcli connection show | grep -E "(wifi|802-11-wireless)" || echo "No saved WiFi connections"

# Show IP addresses
print_section "IP Addresses"
ip addr show wlan0 2>/dev/null | grep "inet " | awk '{print $2}' || echo "No IP address assigned"

# Test internet connectivity
print_section "Internet Connectivity"
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo "✅ Internet connection: Working"
else
    echo "❌ Internet connection: Not available"
fi

# Show hotspot status
print_section "Hotspot Status"
if nmcli connection show --active | grep -q "dexi-hotspot"; then
    echo "✅ Hotspot: Active"
    HOTSPOT_INFO=$(nmcli connection show dexi-hotspot | grep -E "(wifi.ssid|ipv4.addresses)")
    echo "$HOTSPOT_INFO"
else
    echo "❌ Hotspot: Inactive"
fi