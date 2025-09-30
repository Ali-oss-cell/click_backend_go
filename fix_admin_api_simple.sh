#!/bin/bash

echo "🔧 Simple fix: Delete database and create new admin via API..."

# Stop all services
echo "⏸️ Stopping all services..."
docker-compose down

# Wait a moment
sleep 3

# Remove the database file to start fresh
echo "🗑️ Removing database files..."
rm -f click_exprice.db
docker volume rm click_backend_go_postgres_data 2>/dev/null || true

# Start services
echo "🚀 Starting services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 20

# Test if backend is healthy
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "✅ Backend is healthy!"
    
    # Create new admin using the API
    echo "🔧 Creating new admin user via API..."
    response=$(curl -X POST http://localhost:8080/api/auth/create-admin \
        -H "Content-Type: application/json" \
        -d '{"username": "admin", "email": "admin@clickexpress.ae", "password": "AdminPass123!"}')
    
    echo "API Response: $response"
    
    if [[ $response == *"admin"* ]]; then
        echo "✅ New admin created successfully!"
        echo "Username: admin"
        echo "Password: AdminPass123!"
    else
        echo "❌ Failed to create admin"
    fi
else
    echo "❌ Backend health check failed"
fi

echo "✅ Admin fix completed!"
