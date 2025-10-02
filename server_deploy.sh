#!/bin/bash

echo "🚀 Deploying to DigitalOcean server..."

# SSH into server and run deployment
ssh root@164.92.161.93 << 'EOF'
cd /root/click_backend_go

echo "📥 Pulling latest changes..."
git stash
git pull origin main

echo "📦 Stopping existing containers..."
docker-compose down

echo "🧹 Cleaning up..."
docker-compose rm -f
docker system prune -f

echo "🔨 Building and starting services..."
docker-compose up --build -d

echo "⏳ Waiting for services to start..."
sleep 30

echo "🔍 Checking service status..."
docker-compose ps

echo "🗄️ Testing database connection..."
docker-compose exec -T postgres psql -U postgres -d click_exprice -c "SELECT 1;" || echo "Database not ready yet"

echo "👤 Creating admin user..."
curl -k -X POST https://clickexpress.ae/api/auth/create-admin \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "email": "admin@clickexpress.ae", 
    "password": "admin123"
  }' || echo "Admin creation failed"

echo "🔐 Testing login..."
curl -k -X POST https://clickexpress.ae/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }'

echo "✅ Deployment complete!"
EOF

echo "🎉 Server deployment finished!"
