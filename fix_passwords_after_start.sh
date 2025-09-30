#!/bin/bash

echo "🔧 Converting passwords to plain text after services start..."

# Stop all services
echo "⏸️ Stopping all services..."
docker-compose down

# Wait a moment
sleep 3

# Start services first
echo "🚀 Starting services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 20

# Test if backend is healthy
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "✅ Backend is healthy!"
    
    # Now update passwords to plain text in PostgreSQL
    echo "🔧 Updating passwords to plain text..."
    docker exec click_exprice_db psql -U postgres -d click_exprice -c "UPDATE admins SET password = 'AdminPass123!' WHERE username = 'admin';"
    docker exec click_exprice_db psql -U postgres -d click_exprice -c "UPDATE admins SET password = 'TestPass123!' WHERE username = 'testadmin';"
    docker exec click_exprice_db psql -U postgres -d click_exprice -c "UPDATE admins SET password = '123456' WHERE username = 'simple';"
    
    echo "✅ Passwords updated to plain text!"
    
    echo "🧪 Testing logins..."
    echo "Testing admin login:"
    curl -X POST http://localhost:8080/api/auth/login \
        -H "Content-Type: application/json" \
        -d '{"username": "admin", "password": "AdminPass123!"}'
    
    echo ""
    echo "Testing simple login:"
    curl -X POST http://localhost:8080/api/auth/login \
        -H "Content-Type: application/json" \
        -d '{"username": "simple", "password": "123456"}'
else
    echo "❌ Backend health check failed"
fi

echo "✅ Password fix completed!"
