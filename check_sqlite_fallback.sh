#!/bin/bash

echo "🔍 Checking if backend is using SQLite fallback..."

echo "1. Checking for SQLite files:"
ls -la *.db 2>/dev/null || echo "No SQLite files found"

echo ""
echo "2. Checking backend logs for database connection:"
docker-compose logs backend | grep -i "database\|postgres\|sqlite"

echo ""
echo "3. Testing if backend can connect to PostgreSQL:"
docker exec click_exprice_backend sh -c 'echo "SELECT 1;" | nc -w 1 postgres 5432 && echo "PostgreSQL connection works" || echo "PostgreSQL connection failed"'

echo ""
echo "4. Checking if there are any SQLite files in the backend container:"
docker exec click_exprice_backend ls -la *.db 2>/dev/null || echo "No SQLite files in backend container"

echo ""
echo "5. Testing if the issue is database connection timing:"
# Create a simple test to see if the issue is timing
curl -X POST http://localhost:8080/api/auth/create-admin \
    -H "Content-Type: application/json" \
    -d '{"username": "fallbacktest", "email": "fallback@test.com", "password": "fallbackpass"}'

echo ""
echo "6. Waiting 10 seconds before login:"
sleep 10

echo "7. Trying to login:"
curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "fallbacktest", "password": "fallbackpass"}'
