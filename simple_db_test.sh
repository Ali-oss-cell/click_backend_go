#!/bin/bash

echo "🔍 Simple database test..."

echo "1. Creating a new admin and immediately testing login:"
curl -X POST http://localhost:8080/api/auth/create-admin \
    -H "Content-Type: application/json" \
    -d '{"username": "quicktest", "email": "quick@test.com", "password": "quickpass"}'

echo ""
echo "2. Immediately trying to login:"
curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "quicktest", "password": "quickpass"}'

echo ""
echo "3. Checking if the admin was created in PostgreSQL:"
docker exec click_exprice_db psql -U postgres -d click_exprice -c "SELECT username, email FROM admins WHERE username = 'quicktest';"

echo ""
echo "4. Testing with a very simple password (no special characters):"
curl -X POST http://localhost:8080/api/auth/create-admin \
    -H "Content-Type: application/json" \
    -d '{"username": "simpletest", "email": "simple@test.com", "password": "password"}'

echo ""
echo "5. Testing login with simple password:"
curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "simpletest", "password": "password"}'
