#!/bin/bash

echo "🔍 Testing password hashing directly in the backend container..."

# Create a simple Go test inside the backend container
docker exec click_exprice_backend sh -c 'cat > /tmp/test_hash.go << EOF
package main

import (
    "fmt"
    "golang.org/x/crypto/bcrypt"
)

func main() {
    password := "AdminPass123!"
    
    // Generate hash
    hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
    if err != nil {
        fmt.Println("Error generating hash:", err)
        return
    }
    
    fmt.Println("Generated hash:", string(hash))
    
    // Test comparison
    err = bcrypt.CompareHashAndPassword(hash, []byte(password))
    if err != nil {
        fmt.Println("Error comparing hash:", err)
    } else {
        fmt.Println("✅ Hash comparison successful!")
    }
}
EOF'

# Run the test
echo "Running password hash test..."
docker exec click_exprice_backend go run /tmp/test_hash.go

# Clean up
docker exec click_exprice_backend rm /tmp/test_hash.go
