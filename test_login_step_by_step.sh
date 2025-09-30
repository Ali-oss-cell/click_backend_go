#!/bin/bash

echo "🔍 Testing login step by step..."

echo "1. Testing with the debugtest user we just created:"
curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "debugtest", "password": "debug123"}'

echo ""
echo "2. Testing with simple user (123456 password):"
curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "simple", "password": "123456"}'

echo ""
echo "3. Testing with admin user:"
curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "admin", "password": "AdminPass123!"}'

echo ""
echo "4. Testing with exact database values (no special characters):"
curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "admin", "password": "AdminPass123"}'

echo ""
echo "5. Testing with different username case:"
curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "ADMIN", "password": "AdminPass123!"}'

echo ""
echo "6. Checking if there are any whitespace issues:"
# Get exact username from database
EXACT_USERNAME=$(docker exec click_exprice_db psql -U postgres -d click_exprice -t -c "SELECT username FROM admins WHERE username = 'admin';" | tr -d ' \n')
echo "Exact username from DB: '$EXACT_USERNAME'"
curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d "{\"username\": \"$EXACT_USERNAME\", \"password\": \"AdminPass123!\"}"
