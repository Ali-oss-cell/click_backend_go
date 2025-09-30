#!/bin/bash

echo "🔧 Fixing admin in PostgreSQL database..."

# Stop all services
echo "⏸️ Stopping all services..."
docker-compose down

# Wait a moment
sleep 3

# Start only PostgreSQL first
echo "🚀 Starting PostgreSQL..."
docker-compose up -d postgres

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
sleep 10

# Create a script to fix admin in PostgreSQL
cat > fix_admin_postgres.py << 'EOF'
import psycopg2
import bcrypt

try:
    # Connect to PostgreSQL
    conn = psycopg2.connect(
        host="localhost",
        port="5432",
        user="postgres",
        password="ClickExprice2024!SecureDB",
        database="click_exprice"
    )
    cursor = conn.cursor()
    
    # Check if admin exists
    cursor.execute("SELECT id, username, email FROM admins WHERE username = 'admin'")
    admin = cursor.fetchone()
    
    if admin:
        print(f"Found admin: {admin[1]} ({admin[2]})")
        
        # Generate proper bcrypt hash
        password = "AdminPass123!"
        hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
        
        # Update the password
        cursor.execute("UPDATE admins SET password = %s WHERE username = 'admin'", (hashed.decode('utf-8'),))
        conn.commit()
        
        print("✅ Password updated in PostgreSQL!")
    else:
        print("❌ Admin user not found in PostgreSQL!")
        
    conn.close()
    
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
EOF

# Install required packages
pip3 install psycopg2-binary bcrypt 2>/dev/null || echo "Packages already installed or not available"

# Run the fix
python3 fix_admin_postgres.py

# Clean up
rm fix_admin_postgres.py

# Start all services
echo "🚀 Starting all services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 15

# Test if backend is healthy
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "✅ Backend is healthy!"
else
    echo "❌ Backend health check failed"
fi

echo "✅ Admin fix completed!"
