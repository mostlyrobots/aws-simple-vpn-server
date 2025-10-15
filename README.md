# AWS Simple VPN Server - Let's Encrypt Setup

Automated Let's Encrypt certificate setup for StrongSwan VPN on Amazon Linux 2023.

## Setup

1. Edit `CONFIG.rc` with your settings:
```bash
VPN_DOMAIN="vpn.yourdomain.com"
EMAIL="admin@yourdomain.com"
VPN_USERNAME="vpnuser"
VPN_PASSWORD="changeme"
```

2. Configure StrongSwan:
```bash
sudo bash setup-strongswan.sh
```

3. Get Let's Encrypt certificate:
```bash
sudo bash setup-letsencrypt.sh
```

## Connecting from Apple Devices

### iPhone/iPad
1. Settings → VPN → Add VPN Configuration
2. Type: IKEv2
3. Description: My VPN
4. Server: vpn.yourdomain.com
5. Remote ID: vpn.yourdomain.com
6. Local ID: (leave blank)
7. User Authentication: Username
8. Username: vpnuser
9. Password: changeme

### macOS
1. System Settings → Network → VPN
2. Add VPN Configuration
3. Type: IKEv2
4. Server Address: vpn.yourdomain.com
5. Remote ID: vpn.yourdomain.com
6. Authentication: Username
7. Username: vpnuser
8. Password: changeme

## What it does

- Installs and configures StrongSwan for IKEv2/EAP
- Installs certbot on AL2023
- Uses TLS-ALPN-01 challenge on port 443
- Opens port 443 temporarily during validation
- Installs certificates to StrongSwan directories
- Sets up automatic renewal every 45 days
- Renews certificate on boot if needed

## Requirements

- Amazon Linux 2023
- Domain pointing to server's public IP
- Port 443 accessible from internet (temporarily during validation)
- Port 500/UDP and 4500/UDP open for IKEv2
