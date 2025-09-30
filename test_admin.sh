#!/bin/bash

echo "🔍 Testing admin user in database..."

# Test if we can connect to the backend and check admin
echo "Testing backend health..."
curl -f http://localhost:8080/health

echo ""
echo "Testing admin creation again..."
curl -X POST http://localhost:8080/api/auth/create-admin \
    -H "Content-Type: application/json" \
    -d '{"username": "testadmin", "email": "test@clickexpress.ae", "password": "TestPass123!"}'

echo ""
echo "Testing login with test admin..."
curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "testadmin", "password": "TestPass123!"}'

echo ""
echo "Testing original admin login..."
curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "admin", "password": "AdminPass123!"}'
