#!/bin/bash

# SSL Setup Script for Click Express Backend
# This script sets up Let's Encrypt SSL certificates

echo "🔐 Setting up SSL certificates for Click Express..."

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install Certbot
echo "🔧 Installing Certbot..."
apt install certbot python3-certbot-nginx -y

# Stop nginx temporarily
echo "⏸️ Stopping Nginx..."
systemctl stop nginx

# Get SSL certificate
echo "🎫 Getting SSL certificate from Let's Encrypt..."
certbot certonly --standalone -d clickexpress.ae -d www.clickexpress.ae --non-interactive --agree-tos --email admin@clickexpress.ae

# Check if certificate was created
if [ -f "/etc/letsencrypt/live/clickexpress.ae/fullchain.pem" ]; then
    echo "✅ SSL certificate created successfully!"
    
    # Update nginx configuration
    echo "🔧 Updating Nginx configuration..."
    cp nginx.conf /etc/nginx/nginx.conf
    
    # Test nginx configuration
    echo "🧪 Testing Nginx configuration..."
    nginx -t
    
    if [ $? -eq 0 ]; then
        echo "✅ Nginx configuration is valid!"
        
        # Start nginx
        echo "🚀 Starting Nginx with SSL..."
        systemctl start nginx
        systemctl enable nginx
        
        # Set up auto-renewal
        echo "🔄 Setting up automatic certificate renewal..."
        (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -
        
        echo "🎉 SSL setup completed successfully!"
        echo "Your API is now available at: https://clickexpress.ae"
        echo "HTTP traffic will be automatically redirected to HTTPS"
        
    else
        echo "❌ Nginx configuration test failed!"
        exit 1
    fi
    
else
    echo "❌ SSL certificate creation failed!"
    echo "Please check your domain DNS settings and try again."
    exit 1
fi

echo "🔍 Testing SSL configuration..."
curl -I https://clickexpress.ae/health

echo "✅ SSL setup complete!"
