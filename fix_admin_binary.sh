#!/bin/bash

echo "🔧 Fixing admin password hash using pre-compiled binary..."

# Create a simple Go program that we can compile and run
cat > fix_admin.go << 'EOF'
package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/mattn/go-sqlite3"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	// Connect to SQLite database
	db, err := sql.Open("sqlite3", "click_exprice.db")
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	defer db.Close()

	// Get current admin
	var id int
	var username, email, password string
	err = db.QueryRow("SELECT id, username, email, password FROM admins WHERE username = 'admin'").Scan(&id, &username, &email, &password)
	if err != nil {
		log.Fatal("Admin user not found:", err)
	}

	fmt.Printf("Found admin: %s (%s)\n", username, email)

	// Hash the new password
	newPassword := "AdminPass123!"
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		log.Fatal("Failed to hash password:", err)
	}

	// Update the password
	_, err = db.Exec("UPDATE admins SET password = ? WHERE username = 'admin'", string(hashedPassword))
	if err != nil {
		log.Fatal("Failed to update password:", err)
	}

	fmt.Println("✅ Admin password updated successfully!")
	fmt.Printf("Username: admin\n")
	fmt.Printf("Password: %s\n", newPassword)
}
EOF

# Install sqlite3 driver if not available
go mod init temp_fix 2>/dev/null || true
go get github.com/mattn/go-sqlite3
go get golang.org/x/crypto/bcrypt

# Compile the fix program
go build -o fix_admin fix_admin.go

# Stop backend to access database
echo "⏸️ Stopping backend service..."
docker-compose stop backend

# Run the fix
./fix_admin

# Clean up
rm fix_admin.go fix_admin go.mod go.sum

# Start backend again
echo "🚀 Starting backend service..."
docker-compose start backend

# Wait for backend to be healthy
echo "⏳ Waiting for backend to be ready..."
sleep 10

echo "✅ Admin password fix completed!"
