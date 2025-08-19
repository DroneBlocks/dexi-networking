#!/bin/bash

# DEXI Networking Usage Examples
# These are example commands showing how to use the DEXI networking scripts

echo "=== DEXI Networking Usage Examples ==="
echo

echo "1. Install networking (run during OS build):"
echo "   sudo ./install.sh"
echo

echo "2. Create unique hotspot based on device MAC:"
echo "   PARTIAL_MAC=\$(cat /sys/class/net/wlan0/address | awk -F: '{print \$(NF-1)\$NF}')"
echo "   sudo dexi-hotspot \"dexi_\$PARTIAL_MAC\" \"droneblocks\""
echo

echo "3. Configure home WiFi (high priority):"
echo "   sudo dexi-wifi \"HomeNetwork\" \"your-password\" 20"
echo

echo "4. Configure school WiFi (lower priority):"
echo "   sudo dexi-wifi \"SchoolWiFi\" \"school-password\" 10"
echo

echo "5. Check network status:"
echo "   dexi-status"
echo

echo "6. Reset all networks but keep hotspot:"
echo "   sudo dexi-reset keep-hotspot"
echo

echo "7. Reset everything:"
echo "   sudo dexi-reset"
echo

echo "=== Priority System ==="
echo "Higher numbers = higher priority:"
echo "- Home networks: 15-25"
echo "- Work/School: 10-15"
echo "- Guest networks: 5-10"
echo "- Hotspot: -10 (always lowest)"