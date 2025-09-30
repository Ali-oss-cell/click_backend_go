#!/bin/bash

echo "🔍 Checking admin user status..."

# Stop backend to access database
echo "⏸️ Stopping backend service..."
docker-compose stop backend

# Wait a moment
sleep 2

# Create a simple script to check admin users
cat > check_admin.py << 'EOF'
import sqlite3

try:
    # Connect to the database
    conn = sqlite3.connect('click_exprice.db')
    cursor = conn.cursor()
    
    # Check if admins table exists
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='admins'")
    table_exists = cursor.fetchone()
    
    if table_exists:
        print("✅ Admins table exists")
        
        # Get all admin users
        cursor.execute("SELECT id, username, email, created_at FROM admins")
        admins = cursor.fetchall()
        
        if admins:
            print(f"📊 Found {len(admins)} admin user(s):")
            for admin in admins:
                print(f"  - ID: {admin[0]}, Username: {admin[1]}, Email: {admin[2]}, Created: {admin[3]}")
        else:
            print("❌ No admin users found")
    else:
        print("❌ Admins table does not exist")
        
    conn.close()
    
except Exception as e:
    print(f"❌ Error: {e}")
EOF

# Run the check
python3 check_admin.py

# Clean up
rm check_admin.py

# Start backend again
echo "🚀 Starting backend service..."
docker-compose start backend

# Wait for backend to be healthy
echo "⏳ Waiting for backend to be ready..."
sleep 10

echo "✅ Admin check completed!"
