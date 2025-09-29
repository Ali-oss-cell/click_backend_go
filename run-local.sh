#!/bin/bash

# Click Exprice Backend - Local Development Runner
echo "🚀 Starting Click Exprice Backend in development mode..."

# Set environment variables
export DB_HOST=localhost
export DB_PORT=5432
export DB_USER=postgres
export DB_PASSWORD=password
export DB_NAME=click_exprice
export JWT_SECRET=click-exprice-super-secret-jwt-key-for-development-123456789
export SMTP_HOST=smtp.gmail.com
export SMTP_PORT=587
export SMTP_USERNAME=""
export SMTP_PASSWORD=""
export ADMIN_EMAIL=admin@clickexprice.com
export PORT=8080
export GIN_MODE=debug

echo "📋 Environment configured:"
echo "  - Database: $DB_HOST:$DB_PORT/$DB_NAME"
echo "  - Server: http://localhost:$PORT"
echo "  - Mode: $GIN_MODE"
echo ""

echo "⚠️  Make sure PostgreSQL is running on localhost:5432"
echo "   You can install it with: sudo dnf install postgresql postgresql-server"
echo "   Then start it with: sudo systemctl start postgresql"
echo ""

# Run the application
echo "🏃 Starting Go application..."
go run main.go
