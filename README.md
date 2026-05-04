# DEXI Networking

Simple, reliable networking scripts for DEXI Raspberry Pi devices.

## Features

- **Automatic Hostname**: Sets system hostname to `dexi-<MAC suffix>` on first boot
- **Automatic Hotspot**: Creates unique hotspot based on device MAC address
- **WiFi Configuration**: Easy command-line WiFi network setup
- **Priority Management**: Higher priority networks connect first
- **Status Monitoring**: Check network status and connectivity
- **Reset Capability**: Clean network configuration reset

## Installation

```bash
sudo ./install.sh
```

This installs NetworkManager and creates system-wide commands:
- `dexi-wifi` - Configure WiFi networks
- `dexi-hotspot` - Create WiFi hotspot
- `dexi-status` - Check network status
- `dexi-reset` - Reset network configuration

## Usage Examples

### Configure Home/School WiFi
```bash
# Add your home network (high priority)
sudo dexi-wifi "HomeNetwork" "your-password" 20

# Add school network (lower priority)
sudo dexi-wifi "SchoolWiFi" "school-password" 10

# Add an open network (no password)
sudo dexi-wifi "OpenNetwork"
```

### Create Hotspot
```bash
# Create hotspot with unique name based on device MAC (matches hostname)
# This immediately activates the hotspot and disconnects from other networks
PARTIAL_MAC=$(cat /sys/class/net/wlan0/address | awk -F: '{print $(NF-1)$NF}')
sudo dexi-hotspot "dexi-$PARTIAL_MAC" "droneblocks"

# Or create custom hotspot
sudo dexi-hotspot "my-custom-name" "mypassword"
```

### Change Hotspot Password
```bash
# Update the hotspot password
sudo nmcli connection modify "dexi-hotspot" wifi-sec.psk "NEW_PASSWORD"

# Reboot to apply the change
sudo reboot
```

Note: The password change is saved immediately but requires a reboot to take effect. Connected clients will remain connected until the reboot.

### Check Network Status
```bash
dexi-status
```

### Reset Network Configuration
```bash
# Remove all networks including hotspot
sudo dexi-reset

# Remove all networks but keep hotspot
sudo dexi-reset keep-hotspot
```

## How It Works

1. **Priority System**: Networks with higher priority numbers connect first. WiFi networks default to priority 10; the hotspot uses priority 0 as a fallback.
2. **Automatic Fallback**: If no saved WiFi networks are available, the hotspot activates automatically
3. **MAC-based Naming**: Each device gets a unique hostname and hotspot name like `dexi-a4b2`
4. **Persistent Configuration**: All settings survive reboots

## Hostname

On first boot the `dexi-set-hostname.service` systemd unit sets the system hostname to `dexi-<last 4 of wlan0 MAC>` (e.g. `dexi-a4b2`). The unit is gated by a sentinel file at `/var/lib/dexi/hostname-set` so it only ever runs once. With avahi running, the device is reachable as `dexi-a4b2.local` from any mDNS-aware client (macOS, modern Windows, Linux with avahi).

To force the hostname to be re-derived (e.g. after swapping wifi hardware):

```bash
sudo rm /var/lib/dexi/hostname-set
sudo systemctl start dexi-set-hostname.service
sudo reboot
```

## Integration with DEXI OS Build

Add to your provision script:
```bash
# Clone and install networking
cd /tmp
git clone https://github.com/DroneBlocks/dexi-networking.git
cd dexi-networking
./install.sh

# Create unique hotspot
PARTIAL_MAC=$(cat /sys/class/net/wlan0/address | awk -F: '{print $(NF-1)$NF}')
./scripts/create_hotspot.sh "dexi-$PARTIAL_MAC" "droneblocks"
```

## Troubleshooting

- **No WiFi interface**: Check if `wlan0` exists with `ip link show`
- **Permission denied**: Run commands with `sudo`
- **NetworkManager not running**: Run `sudo systemctl start NetworkManager`
- **Can't scan networks**: Try `sudo nmcli device wifi rescan`