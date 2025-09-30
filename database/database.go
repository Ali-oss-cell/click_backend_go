package database

import (
	"fmt"
	"log"

	"go-click-exprice-backend/config"
	"go-click-exprice-backend/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDB(cfg *config.Config) {
	// Use PostgreSQL only - no fallback to SQLite
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%d sslmode=disable TimeZone=UTC",
		cfg.Database.Host,
		cfg.Database.User,
		cfg.Database.Password,
		cfg.Database.DBName,
		cfg.Database.Port,
	)

	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to PostgreSQL database:", err)
	}
	log.Println("PostgreSQL database connected successfully")
}

func Migrate() {
	err := DB.AutoMigrate(
		&models.Blog{},
		&models.Contact{},
		&models.Admin{},
	)
	if err != nil {
		log.Fatal("Failed to migrate database:", err)
	}

	log.Println("Database migration completed")
}
