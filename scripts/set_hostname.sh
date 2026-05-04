#!/bin/bash
# Set the system hostname to dexi-<last 4 of wlan0 MAC> on first boot.
# Idempotent via a sentinel file at /var/lib/dexi/hostname-set.
set -e

SENTINEL=/var/lib/dexi/hostname-set
mkdir -p "$(dirname "$SENTINEL")"

if [ -f "$SENTINEL" ]; then
    exit 0
fi

# Wait briefly for wlan0 to appear (defensive — usually present at boot)
for _ in $(seq 1 30); do
    [ -f /sys/class/net/wlan0/address ] && break
    sleep 1
done

if [ ! -f /sys/class/net/wlan0/address ]; then
    echo "set_hostname: wlan0 not found, aborting" >&2
    exit 1
fi

FULL_MAC=$(cat /sys/class/net/wlan0/address)
PARTIAL_MAC=$(echo "$FULL_MAC" | awk -F: '{print $(NF-1)$NF}')
NEW_HOSTNAME="dexi-$PARTIAL_MAC"

hostnamectl set-hostname "$NEW_HOSTNAME"

# Keep /etc/hosts in sync so sudo and local resolution stay quiet.
if grep -qE "^127\.0\.1\.1[[:space:]]" /etc/hosts; then
    sed -i -E "s/^(127\.0\.1\.1[[:space:]]+).*/\1$NEW_HOSTNAME/" /etc/hosts
else
    echo "127.0.1.1 $NEW_HOSTNAME" >> /etc/hosts
fi

touch "$SENTINEL"
echo "set_hostname: hostname set to $NEW_HOSTNAME"
