#!/bin/bash

echo "🔍 Testing with a simple approach..."

# Check what's actually in the database
echo "Checking admin users in database:"
docker exec click_exprice_db psql -U postgres -d click_exprice -c "SELECT username, email, LENGTH(password) as password_length FROM admins;"

echo ""
echo "Testing if we can create a new admin with a known password..."

# Try creating an admin with a very simple password
curl -X POST http://localhost:8080/api/auth/create-admin \
    -H "Content-Type: application/json" \
    -d '{"username": "simple", "email": "simple@test.com", "password": "123456"}'

echo ""
echo "Testing login with simple password..."
curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "simple", "password": "123456"}'

echo ""
echo "Testing original admin login again..."
curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "admin", "password": "AdminPass123!"}'
