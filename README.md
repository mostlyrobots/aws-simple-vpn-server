# AWS Simple VPN Server - Let's Encrypt Setup

Automated Let's Encrypt certificate setup for StrongSwan VPN on Amazon Linux 2023.

## Usage

1. Edit `CONFIG.rc` with your domain and email:
```bash
VPN_DOMAIN="vpn.yourdomain.com"
EMAIL="admin@yourdomain.com"
```

2. Run the setup script:
```bash
sudo bash setup-letsencrypt.sh
```

## What it does

- Installs certbot on AL2023
- Uses TLS-ALPN-01 challenge on port 443
- Opens port 443 temporarily during validation
- Installs certificates to StrongSwan directories
- Sets up automatic renewal every 45 days
- Renews certificate on boot if needed

## Requirements

- Amazon Linux 2023
- StrongSwan installed
- Domain pointing to server's public IP
- Port 443 accessible from internet (temporarily during validation)
