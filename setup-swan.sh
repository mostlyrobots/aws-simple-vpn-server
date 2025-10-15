#!/bin/bash
set -e

# Load configuration
if [ ! -f "CONFIG.rc" ]; then
    echo "ERROR: CONFIG.rc not found"
    exit 1
fi
source CONFIG.rc

# Install Libreswan
dnf install -y libreswan

# Configure ipsec.conf
cat > /etc/ipsec.conf << EOF
config setup
    logfile=/var/log/pluto.log
    plutodebug=none
    uniqueids=no

conn ikev2-vpn
    auto=add
    compress=no
    type=tunnel
    keyexchange=ikev2
    fragmentation=yes
    forceencaps=yes
    
    # Server
    leftcert=${VPN_DOMAIN}
    leftid=@${VPN_DOMAIN}
    leftsendcert=always
    leftsubnet=0.0.0.0/0
    
    # Client
    right=%any
    rightid=%any
    rightauth=eap-mschapv2
    rightaddresspool=10.10.10.100-10.10.10.200
    rightdns=8.8.8.8,8.8.4.4
    
    # Encryption
    ike=aes256-sha2;modp2048
    esp=aes256-sha2
    
    eap_identity=%identity
EOF

# Configure ipsec.secrets
cat > /etc/ipsec.secrets << EOF
: RSA ${VPN_DOMAIN}

# EAP users (username : EAP "password")
${VPN_USERNAME} : EAP "${VPN_PASSWORD}"
EOF
chmod 600 /etc/ipsec.secrets

# Enable IP forwarding
cat > /etc/sysctl.d/99-vpn.conf << EOF
net.ipv4.ip_forward = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
EOF
sysctl -p /etc/sysctl.d/99-vpn.conf

# Configure iptables NAT
iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o eth0 -j MASQUERADE
iptables -A FORWARD -s 10.10.10.0/24 -j ACCEPT
iptables -A FORWARD -d 10.10.10.0/24 -j ACCEPT

# Save iptables rules
iptables-save > /etc/sysconfig/iptables

# Enable and start Libreswan
systemctl enable ipsec
systemctl restart ipsec

echo "Libreswan configured for IKEv2/EAP"
echo "Username: ${VPN_USERNAME}"
echo "Connect using: ${VPN_DOMAIN}"
