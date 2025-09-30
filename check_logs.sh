#!/bin/bash

echo "🔍 Checking backend logs for login attempts..."

# Check recent backend logs
echo "Recent backend logs:"
docker-compose logs backend --tail=20

echo ""
echo "Testing login and checking logs in real-time..."
# Test login and watch logs
curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "admin", "password": "AdminPass123!"}' &

# Wait a moment and check logs
sleep 2
echo ""
echo "Logs after login attempt:"
docker-compose logs backend --tail=5
