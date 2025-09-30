#!/bin/bash

echo "🔍 Complete debugging of login issue..."

echo "1. Checking what's actually in the database:"
docker exec click_exprice_db psql -U postgres -d click_exprice -c "SELECT username, email, password FROM admins;"

echo ""
echo "2. Testing direct database query from backend container:"
docker exec click_exprice_backend sh -c 'echo "SELECT username, password FROM admins WHERE username = '\''admin'\'';" | psql -h postgres -U postgres -d click_exprice'

echo ""
echo "3. Testing login with exact database values:"
# Get the exact password from database
DB_PASSWORD=$(docker exec click_exprice_db psql -U postgres -d click_exprice -t -c "SELECT password FROM admins WHERE username = 'admin';" | tr -d ' \n')
echo "Database password: '$DB_PASSWORD'"

curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d "{\"username\": \"admin\", \"password\": \"$DB_PASSWORD\"}"

echo ""
echo "4. Testing with hardcoded values:"
curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "admin", "password": "AdminPass123!"}'

echo ""
echo "5. Checking backend logs during login:"
curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "admin", "password": "AdminPass123!"}' &

sleep 2
docker-compose logs backend --tail=3
