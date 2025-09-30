#!/bin/bash

# Enable SSL for Click Express Backend - Fixed Version
echo "🔐 Enabling SSL for Click Express Backend..."

# Check if SSL certificates exist
if [ ! -f "/etc/letsencrypt/live/clickexpress.ae/fullchain.pem" ]; then
    echo "❌ SSL certificates not found!"
    echo "Please run the SSL setup first: ./setup_ssl_manual.sh"
    exit 1
fi

echo "✅ SSL certificates found!"

# Stop all services
echo "⏸️ Stopping all services..."
docker-compose down

# Start backend first
echo "🚀 Starting backend services..."
docker-compose up -d postgres backend

# Wait for backend to be ready
echo "⏳ Waiting for backend to be ready..."
sleep 30

# Check if backend is healthy
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "✅ Backend is healthy!"
else
    echo "❌ Backend health check failed!"
    echo "Starting nginx with HTTP-only configuration..."
    cp nginx-no-ssl.conf nginx.conf
    docker-compose up -d nginx
    exit 1
fi

# Use SSL nginx config
echo "🔧 Updating nginx configuration for SSL..."
cp nginx-ssl.conf nginx.conf

# Test nginx configuration (now that backend is running)
echo "🧪 Testing nginx configuration..."
docker run --rm -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro --network click_backend_go_click_exprice_network nginx:alpine nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Nginx configuration is valid!"
    
    # Start nginx with SSL
    echo "🚀 Starting nginx with SSL..."
    docker-compose up -d nginx
    
    # Wait for nginx to start
    sleep 10
    
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
        echo "Falling back to HTTP-only configuration..."
        cp nginx-no-ssl.conf nginx.conf
        docker-compose restart nginx
    fi
    
else
    echo "❌ Nginx configuration test failed!"
    echo "Falling back to HTTP-only configuration..."
    cp nginx-no-ssl.conf nginx.conf
    docker-compose up -d nginx
fi
