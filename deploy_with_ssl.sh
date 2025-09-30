#!/bin/bash

# Deploy Click Express Backend with SSL Setup
echo "🚀 Starting Click Express Backend Deployment with SSL..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "[ERROR] Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Copy environment file
echo "[INFO] Setting up environment..."
cp production.env .env

# Stop existing services
echo "[INFO] Stopping existing services..."
docker-compose down

# Use nginx config without SSL first
echo "[INFO] Using temporary nginx config (no SSL)..."
cp nginx-no-ssl.conf nginx.conf

# Start services without SSL
echo "[INFO] Starting services..."
docker-compose up --build -d

# Wait for services to be ready
echo "[INFO] Waiting for services to be ready..."
sleep 30

# Check backend health
echo "[INFO] Checking backend health..."
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "[INFO] ✅ Backend is healthy!"
else
    echo "[ERROR] ❌ Backend health check failed!"
    docker-compose logs backend
    exit 1
fi

# Check nginx
echo "[INFO] Checking nginx..."
if curl -f http://localhost/health > /dev/null 2>&1; then
    echo "[INFO] ✅ Nginx proxy is working!"
else
    echo "[WARNING] ⚠️  Nginx proxy check failed. Check logs with: docker-compose logs nginx"
    docker-compose logs nginx
fi

# Now set up SSL
echo "[INFO] Setting up SSL certificates..."

# Install Certbot if not installed
if ! command -v certbot &> /dev/null; then
    echo "[INFO] Installing Certbot..."
    apt update
    apt install certbot python3-certbot-nginx -y
fi

# Stop nginx temporarily for certificate generation
echo "[INFO] Stopping nginx for certificate generation..."
docker-compose stop nginx

# Get SSL certificate
echo "[INFO] Getting SSL certificate from Let's Encrypt..."
certbot certonly --standalone -d clickexpress.ae -d www.clickexpress.ae --non-interactive --agree-tos --email info@clickexpress.ae

# Check if certificate was created
if [ -f "/etc/letsencrypt/live/clickexpress.ae/fullchain.pem" ]; then
    echo "[INFO] ✅ SSL certificate created successfully!"
    
    # Update nginx configuration with SSL
    echo "[INFO] Updating nginx configuration with SSL..."
    # Restore the SSL nginx config
    git checkout nginx.conf
    
    # Test nginx configuration
    echo "[INFO] Testing nginx configuration..."
    nginx -t
    
    if [ $? -eq 0 ]; then
        echo "[INFO] ✅ Nginx configuration is valid!"
        
        # Start nginx with SSL
        echo "[INFO] Starting nginx with SSL..."
        docker-compose up -d nginx
        
        # Set up auto-renewal
        echo "[INFO] Setting up automatic certificate renewal..."
        (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet && docker-compose restart nginx") | crontab -
        
        echo "[INFO] 🎉 SSL setup completed successfully!"
        echo "[INFO] Your API is now available at: https://clickexpress.ae"
        echo "[INFO] HTTP traffic will be automatically redirected to HTTPS"
        
    else
        echo "[ERROR] ❌ Nginx configuration test failed!"
        echo "[INFO] Falling back to HTTP-only configuration..."
        cp nginx-no-ssl.conf nginx.conf
        docker-compose up -d nginx
    fi
    
else
    echo "[WARNING] ⚠️  SSL certificate creation failed!"
    echo "[INFO] Continuing with HTTP-only configuration..."
    cp nginx-no-ssl.conf nginx.conf
    docker-compose up -d nginx
fi

# Final health check
echo "[INFO] Final health check..."
if curl -f http://localhost/health > /dev/null 2>&1; then
    echo "[INFO] ✅ Deployment completed successfully!"
    echo "[INFO] Your API is available at:"
    echo "[INFO]   - HTTP: http://clickexpress.ae"
    echo "[INFO]   - HTTPS: https://clickexpress.ae (if SSL was successful)"
    echo "[INFO] "
    echo "[INFO] Useful commands:"
    echo "[INFO]   - View logs: docker-compose logs -f"
    echo "[INFO]   - Stop services: docker-compose down"
    echo "[INFO]   - Restart services: docker-compose restart"
    echo "[INFO]   - Update services: docker-compose up --build -d"
else
    echo "[ERROR] ❌ Final health check failed!"
    echo "[INFO] Check logs: docker-compose logs"
fi
