#!/bin/bash

# Manual SSL Setup for Click Express Backend
echo "🔐 Setting up SSL certificates manually..."

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install Certbot
echo "🔧 Installing Certbot..."
apt install certbot python3-certbot-nginx -y

# Stop all services
echo "⏸️ Stopping all services..."
docker-compose down

# Use HTTP-only nginx config temporarily
echo "🔧 Using HTTP-only nginx configuration..."
cp nginx-no-ssl.conf nginx.conf

# Start only backend first
echo "🚀 Starting backend service..."
docker-compose up -d postgres backend

# Wait for backend to be ready
echo "⏳ Waiting for backend to be ready..."
sleep 30

# Check backend health
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "✅ Backend is healthy!"
else
    echo "❌ Backend health check failed!"
    exit 1
fi

# Get SSL certificate for main domain only (no www)
echo "🎫 Getting SSL certificate for clickexpress.ae only..."
certbot certonly --standalone -d clickexpress.ae --non-interactive --agree-tos --email info@clickexpress.ae

# Check if certificate was created
if [ -f "/etc/letsencrypt/live/clickexpress.ae/fullchain.pem" ]; then
    echo "✅ SSL certificate created successfully!"
    
    # Update nginx configuration with SSL
    echo "🔧 Updating nginx configuration with SSL..."
    
    # Create SSL nginx config
    cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:8080;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=contact:10m rate=2r/s;

    # HTTP server - redirect to HTTPS
    server {
        listen 80;
        server_name clickexpress.ae www.clickexpress.ae;
        
        # Redirect all HTTP traffic to HTTPS
        return 301 https://clickexpress.ae$request_uri;
    }

    # HTTPS server
    server {
        listen 443 ssl http2;
        server_name clickexpress.ae;

        # SSL Configuration
        ssl_certificate /etc/letsencrypt/live/clickexpress.ae/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/clickexpress.ae/privkey.pem;
        
        # Modern SSL configuration
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
        
        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # API routes
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # CORS headers
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Origin, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization" always;
            
            if ($request_method = 'OPTIONS') {
                add_header Access-Control-Allow-Origin "*";
                add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
                add_header Access-Control-Allow-Headers "Origin, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization";
                add_header Access-Control-Max-Age 1728000;
                add_header Content-Type "text/plain; charset=utf-8";
                add_header Content-Length 0;
                return 204;
            }
        }

        # Contact form with stricter rate limiting
        location /api/contacts {
            limit_req zone=contact burst=5 nodelay;
            
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # CORS headers
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Methods "POST, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Origin, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization" always;
            
            if ($request_method = 'OPTIONS') {
                add_header Access-Control-Allow-Origin "*";
                add_header Access-Control-Allow-Methods "POST, OPTIONS";
                add_header Access-Control-Allow-Headers "Origin, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization";
                add_header Access-Control-Max-Age 1728000;
                add_header Content-Type "text/plain; charset=utf-8";
                add_header Content-Length 0;
                return 204;
            }
        }

        # Health check
        location /health {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Static files (if you add any)
        location /static/ {
            alias /var/www/static/;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # Security: deny access to hidden files
        location ~ /\. {
            deny all;
        }
    }
}
EOF

    # Test nginx configuration
    echo "🧪 Testing nginx configuration..."
    nginx -t
    
    if [ $? -eq 0 ]; then
        echo "✅ Nginx configuration is valid!"
        
        # Start nginx with SSL
        echo "🚀 Starting nginx with SSL..."
        docker-compose up -d nginx
        
        # Set up auto-renewal
        echo "🔄 Setting up automatic certificate renewal..."
        (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet && docker-compose restart nginx") | crontab -
        
        echo "🎉 SSL setup completed successfully!"
        echo "Your API is now available at: https://clickexpress.ae"
        echo "HTTP traffic will be automatically redirected to HTTPS"
        
    else
        echo "❌ Nginx configuration test failed!"
        echo "Falling back to HTTP-only configuration..."
        cp nginx-no-ssl.conf nginx.conf
        docker-compose up -d nginx
    fi
    
else
    echo "❌ SSL certificate creation failed!"
    echo "Continuing with HTTP-only configuration..."
    cp nginx-no-ssl.conf nginx.conf
    docker-compose up -d nginx
fi

# Final health check
echo "🔍 Final health check..."
if curl -f http://localhost/health > /dev/null 2>&1; then
    echo "✅ Deployment completed successfully!"
    echo "Your API is available at:"
    echo "  - HTTP: http://clickexpress.ae"
    echo "  - HTTPS: https://clickexpress.ae (if SSL was successful)"
else
    echo "❌ Final health check failed!"
    echo "Check logs: docker-compose logs"
fi
