#!/bin/bash

echo "🔧 Fixing admin password hash..."

# Create a temporary Go script to fix the admin password
cat > fix_admin_temp.go << 'EOF'
package main

import (
	"fmt"
	"log"

	"go-click-exprice-backend/models"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func main() {
	db, err := gorm.Open(sqlite.Open("click_exprice.db"), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	var admin models.Admin
	if err := db.Where("username = ?", "admin").First(&admin).Error; err != nil {
		log.Fatal("Admin user not found:", err)
	}

	fmt.Printf("Current admin: %s, %s\n", admin.Username, admin.Email)
	
	// Hash the password properly
	newPassword := "AdminPass123!"
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		log.Fatal("Failed to hash password:", err)
	}

	admin.Password = string(hashedPassword)
	if err := db.Save(&admin).Error; err != nil {
		log.Fatal("Failed to update admin password:", err)
	}

	fmt.Println("✅ Admin password updated successfully!")
	fmt.Printf("Username: admin\n")
	fmt.Printf("Password: %s\n", newPassword)
}
EOF

# Run the fix script
go run fix_admin_temp.go

# Clean up
rm fix_admin_temp.go

echo "✅ Admin password fix completed!"
