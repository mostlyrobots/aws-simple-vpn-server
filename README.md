# AWS Simple VPN Server

Automated StrongSwan VPN server with Let's Encrypt certificates on Amazon Linux 2023.

## Quick Deploy with CloudFormation

1. Update the UserData URLs in `cloudformation.yaml` to point to your GitHub repo (or use local scripts)

2. Deploy the stack:
```bash
aws cloudformation create-stack \
  --stack-name vpn-server \
  --template-body file://cloudformation.yaml \
  --parameters \
    ParameterKey=VPNDomain,ParameterValue=vpn.yourdomain.com \
    ParameterKey=Email,ParameterValue=admin@yourdomain.com \
    ParameterKey=VPNUsername,ParameterValue=vpnuser \
    ParameterKey=VPNPassword,ParameterValue=YourSecurePassword \
    ParameterKey=KeyName,ParameterValue=your-key-pair
```

3. Get the server's public IP:
```bash
aws cloudformation describe-stacks \
  --stack-name vpn-server \
  --query 'Stacks[0].Outputs[?OutputKey==`ServerPublicIP`].OutputValue' \
  --output text
```

4. Point your domain to the server's IP address

5. Wait 5-10 minutes for setup to complete

## Manual Setup

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

- Creates VPC with public subnet
- Deploys EC2 instance (t3.micro) with Amazon Linux 2023
- Configures security group for SSH, Let's Encrypt, and IKEv2
- Installs and configures StrongSwan for IKEv2/EAP
- Gets Let's Encrypt certificate automatically
- Sets up automatic certificate renewal

## Requirements

- AWS account with EC2 key pair
- Domain name that you can point to the server's IP
- Ports required: 22 (SSH), 443 (Let's Encrypt), 500/UDP and 4500/UDP (IKEv2)
