package main

import (
	"log"

	"go-click-exprice-backend/config"
	"go-click-exprice-backend/database"
	"go-click-exprice-backend/routes"

	"github.com/gin-gonic/gin"
)

func main() {
	// Load configuration
	cfg := config.LoadConfig()

	// Set Gin mode
	gin.SetMode(cfg.Server.GinMode)

	// Connect to database
	database.ConnectDB(cfg)
	database.Migrate()

	// Setup routes
	r := routes.SetupRoutes(cfg)

	// Start server
	log.Printf("Server starting on port %s", cfg.Server.Port)
	if err := r.Run(":" + cfg.Server.Port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
