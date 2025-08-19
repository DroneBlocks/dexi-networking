# DEXI Networking

Simple, reliable networking scripts for DEXI Raspberry Pi devices.

## Features

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
```

### Create Hotspot
```bash
# Create hotspot with unique name based on device MAC
PARTIAL_MAC=$(cat /sys/class/net/wlan0/address | awk -F: '{print $(NF-1)$NF}')
sudo dexi-hotspot "dexi_$PARTIAL_MAC" "droneblocks"

# Or create custom hotspot
sudo dexi-hotspot "my-custom-name" "mypassword"
```

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

1. **Priority System**: Networks with higher priority numbers connect first
2. **Automatic Fallback**: If no saved networks are available, hotspot activates
3. **MAC-based Naming**: Each device gets a unique hotspot name like `dexi_a4b2`
4. **Persistent Configuration**: All settings survive reboots

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
./scripts/create_hotspot.sh "dexi_$PARTIAL_MAC" "droneblocks"
```

## Troubleshooting

- **No WiFi interface**: Check if `wlan0` exists with `ip link show`
- **Permission denied**: Run commands with `sudo`
- **NetworkManager not running**: Run `sudo systemctl start NetworkManager`
- **Can't scan networks**: Try `sudo nmcli device wifi rescan`