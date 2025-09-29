package database

import (
	"log"

	"go-click-exprice-backend/config"
	"go-click-exprice-backend/models"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var SQLiteDB *gorm.DB

func ConnectSQLite(cfg *config.Config) {
	var err error
	SQLiteDB, err = gorm.Open(sqlite.Open("click_exprice.db"), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to SQLite database:", err)
	}

	log.Println("SQLite database connected successfully")
}

func MigrateSQLite() {
	err := SQLiteDB.AutoMigrate(
		&models.Blog{},
		&models.Contact{},
		&models.Admin{},
	)
	if err != nil {
		log.Fatal("Failed to migrate SQLite database:", err)
	}

	log.Println("SQLite database migration completed")
}
