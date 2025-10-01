#!/bin/bash

echo "🚀 Deploying Click Express Backend to DigitalOcean..."

# Stop any running containers
echo "📦 Stopping existing containers..."
docker-compose down

# Remove old containers and images
echo "🧹 Cleaning up old containers..."
docker-compose rm -f
docker system prune -f

# Build and start services
echo "🔨 Building and starting services..."
docker-compose up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Check if services are running
echo "🔍 Checking service status..."
docker-compose ps

# Test database connection
echo "🗄️ Testing database connection..."
docker-compose exec -T postgres psql -U postgres -d click_exprice -c "SELECT 1;" || echo "Database not ready yet"

# Create admin user
echo "👤 Creating admin user..."
curl -k -X POST https://clickexpress.ae/api/auth/create-admin \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "email": "admin@clickexpress.ae", 
    "password": "admin123"
  }' || echo "Admin creation failed"

# Test login
echo "🔐 Testing login..."
curl -k -X POST https://clickexpress.ae/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }'

echo "✅ Deployment complete!"
