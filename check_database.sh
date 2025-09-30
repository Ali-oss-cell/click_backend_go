#!/bin/bash

echo "🔍 Checking which database is being used..."

# Check if SQLite file exists
if [ -f "click_exprice.db" ]; then
    echo "✅ SQLite database file exists"
    echo "SQLite file size: $(ls -lh click_exprice.db | awk '{print $5}')"
else
    echo "❌ SQLite database file not found"
fi

# Check PostgreSQL connection
echo ""
echo "🔍 Testing PostgreSQL connection..."
docker exec click_exprice_db psql -U postgres -d click_exprice -c "SELECT COUNT(*) FROM admins;" 2>/dev/null || echo "❌ PostgreSQL connection failed"

# Check if there are any database files
echo ""
echo "🔍 Database files in current directory:"
ls -la *.db 2>/dev/null || echo "No .db files found"

# Check Docker volumes
echo ""
echo "🔍 Docker volumes:"
docker volume ls | grep postgres || echo "No postgres volumes found"
