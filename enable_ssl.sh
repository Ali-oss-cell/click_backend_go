#!/bin/bash

# Enable SSL for Click Express Backend
echo "🔐 Enabling SSL for Click Express Backend..."

# Check if SSL certificates exist
if [ ! -f "/etc/letsencrypt/live/clickexpress.ae/fullchain.pem" ]; then
    echo "❌ SSL certificates not found!"
    echo "Please run the SSL setup first: ./setup_ssl_manual.sh"
    exit 1
fi

echo "✅ SSL certificates found!"

# Stop nginx
echo "⏸️ Stopping nginx..."
docker-compose stop nginx

# Use SSL nginx config
echo "🔧 Updating nginx configuration for SSL..."
cp nginx-ssl.conf nginx.conf

# Test nginx configuration
echo "🧪 Testing nginx configuration..."
docker run --rm -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro nginx:alpine nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Nginx configuration is valid!"
    
    # Start nginx with SSL
    echo "🚀 Starting nginx with SSL..."
    docker-compose up -d nginx
    
    # Wait for nginx to start
    sleep 5
    
    # Test HTTPS
    echo "🧪 Testing HTTPS..."
    if curl -f https://clickexpress.ae/health > /dev/null 2>&1; then
        echo "✅ HTTPS is working!"
        echo "🎉 SSL enabled successfully!"
        echo ""
        echo "Your API is now available at:"
        echo "  - HTTP: http://clickexpress.ae (redirects to HTTPS)"
        echo "  - HTTPS: https://clickexpress.ae"
        echo ""
        echo "Test your API:"
        echo "  curl https://clickexpress.ae/health"
        echo "  curl https://clickexpress.ae/api/blogs/public"
    else
        echo "❌ HTTPS test failed!"
        echo "Check nginx logs: docker-compose logs nginx"
    fi
    
else
    echo "❌ Nginx configuration test failed!"
    echo "Falling back to HTTP-only configuration..."
    cp nginx-no-ssl.conf nginx.conf
    docker-compose up -d nginx
fi
