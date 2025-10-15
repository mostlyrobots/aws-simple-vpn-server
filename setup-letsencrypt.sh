#!/bin/bash
set -e

# Load configuration
if [ ! -f "CONFIG.rc" ]; then
    echo "ERROR: CONFIG.rc not found"
    exit 1
fi
source CONFIG.rc

# Install certbot
dnf install -y certbot

# Create pre-hook script
cat > /usr/local/bin/certbot-pre-hook.sh << 'EOF'
#!/bin/bash
iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
EOF
chmod +x /usr/local/bin/certbot-pre-hook.sh

# Create post-hook script
cat > /usr/local/bin/certbot-post-hook.sh << 'EOF'
#!/bin/bash
iptables -D INPUT -p tcp --dport 443 -j ACCEPT
cp /etc/letsencrypt/live/*/fullchain.pem /etc/ipsec.d/certs/
cp /etc/letsencrypt/live/*/privkey.pem /etc/ipsec.d/private/
chmod 600 /etc/ipsec.d/private/privkey.pem
ipsec reload
EOF
chmod +x /usr/local/bin/certbot-post-hook.sh

# Get certificate
certbot certonly --standalone \
    --preferred-challenges tls-alpn-01 \
    -d "$VPN_DOMAIN" \
    --email "$EMAIL" \
    --agree-tos \
    --non-interactive \
    --pre-hook "/usr/local/bin/certbot-pre-hook.sh" \
    --post-hook "/usr/local/bin/certbot-post-hook.sh"

# Add cron job for renewal (every 45 days at 3am and at boot)
(crontab -l 2>/dev/null | grep -v certbot-renew; echo "0 3 */45 * * certbot renew --quiet --pre-hook '/usr/local/bin/certbot-pre-hook.sh' --post-hook '/usr/local/bin/certbot-post-hook.sh'"; echo "@reboot sleep 60 && certbot renew --quiet --pre-hook '/usr/local/bin/certbot-pre-hook.sh' --post-hook '/usr/local/bin/certbot-post-hook.sh'") | crontab -

echo "Setup complete. Certificate installed for $VPN_DOMAIN"
