#!/bin/bash

echo "🔍 Checking which database the backend is actually using..."

# Check backend logs for database connection messages
echo "1. Checking backend startup logs for database connection:"
docker-compose logs backend | grep -i "database\|postgres\|sqlite"

echo ""
echo "2. Checking if SQLite file exists:"
ls -la *.db 2>/dev/null || echo "No SQLite files found"

echo ""
echo "3. Testing if backend can connect to PostgreSQL:"
docker exec click_exprice_backend sh -c 'echo "SELECT 1;" | nc -w 1 postgres 5432 && echo "PostgreSQL connection works" || echo "PostgreSQL connection failed"'

echo ""
echo "4. Checking backend environment variables:"
docker exec click_exprice_backend env | grep -E "DB_|DATABASE"

echo ""
echo "5. Testing a simple database query from backend:"
# Create a simple test to see which database is being used
docker exec click_exprice_backend sh -c 'cat > /tmp/test_db.go << EOF
package main
import (
    "fmt"
    "go-click-exprice-backend/database"
    "go-click-exprice-backend/config"
)
func main() {
    cfg := config.LoadConfig()
    database.ConnectDB(cfg)
    var count int64
    database.DB.Model(&struct{}{}).Count(&count)
    fmt.Printf("Database connection successful, record count: %d\n", count)
}
EOF'

# This won't work because of Go module issues, but let's try a different approach
echo "6. Checking if backend is using the correct database by testing admin count:"
curl -X POST http://localhost:8080/api/auth/create-admin \
    -H "Content-Type: application/json" \
    -d '{"username": "debugtest", "email": "debug@test.com", "password": "debug123"}' 2>/dev/null

echo ""
echo "7. Checking if the new admin was created in PostgreSQL:"
docker exec click_exprice_db psql -U postgres -d click_exprice -c "SELECT username FROM admins WHERE username = 'debugtest';"
