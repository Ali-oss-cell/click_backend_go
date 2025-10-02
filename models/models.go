package models

import (
	"time"

	"gorm.io/gorm"
)

// Blog represents a blog post
type Blog struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	Title     string         `json:"title" gorm:"not null"`
	Content   string         `json:"content" gorm:"type:text"`
	ImageName string         `json:"image_name"`
	ImageFile string         `json:"image_file"`
	Published bool           `json:"published" gorm:"default:false"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

// Contact represents a contact form submission
type Contact struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	Name      string         `json:"name" gorm:"not null"`
	Email     string         `json:"email" gorm:"not null"`
	Subject   string         `json:"subject"`
	Message   string         `json:"message" gorm:"type:text;not null"`
	Status    string         `json:"status" gorm:"default:'pending'"` // pending, read, replied
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

// Gallery represents a gallery image
type Gallery struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	ImageName string         `json:"image_name" gorm:"not null"`
	ImageFile string         `json:"image_file" gorm:"not null"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

// Admin represents the admin user
type Admin struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	Username  string    `json:"username" gorm:"unique;not null"`
	Email     string    `json:"email" gorm:"unique;not null"`
	Password  string    `json:"password" gorm:"not null"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
