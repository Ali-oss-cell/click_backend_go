#!/bin/bash

echo "🔧 Fixing admin password with proper bcrypt hash..."

# Stop all services
echo "⏸️ Stopping all services..."
docker-compose down

# Wait a moment
sleep 3

# Create a Python script that generates a proper bcrypt hash
cat > fix_password_correct.py << 'EOF'
import sqlite3
import bcrypt

try:
    # Connect to the database
    conn = sqlite3.connect('click_exprice.db')
    cursor = conn.cursor()
    
    # Check if admin exists
    cursor.execute("SELECT id, username, email, password FROM admins WHERE username = 'admin'")
    admin = cursor.fetchone()
    
    if admin:
        print(f"Found admin: {admin[1]} ({admin[2]})")
        print(f"Current password hash: {admin[3][:20]}...")
        
        # Generate proper bcrypt hash for "AdminPass123!"
        password = "AdminPass123!"
        salt = bcrypt.gensalt()
        hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
        
        print(f"New password hash: {hashed.decode('utf-8')[:20]}...")
        
        # Update the password
        cursor.execute("UPDATE admins SET password = ? WHERE username = 'admin'", (hashed.decode('utf-8'),))
        conn.commit()
        
        print("✅ Password updated with proper bcrypt hash!")
        print("Username: admin")
        print("Password: AdminPass123!")
    else:
        print("❌ Admin user not found!")
        
    conn.close()
    
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
EOF

# Install bcrypt if not available
pip3 install bcrypt 2>/dev/null || echo "bcrypt already installed or not available"

# Run the Python script
python3 fix_password_correct.py

# Clean up
rm fix_password_correct.py

# Start services again
echo "🚀 Starting services..."
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

echo "✅ Admin password fix completed!"
