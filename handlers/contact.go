package handlers

import (
	"net/http"
	"strconv"

	"go-click-exprice-backend/config"
	"go-click-exprice-backend/database"
	"go-click-exprice-backend/models"
	"go-click-exprice-backend/services"

	"github.com/gin-gonic/gin"
)

// GetContacts returns all contact submissions (admin only)
func GetContacts(c *gin.Context) {
	var contacts []models.Contact
	if err := database.DB.Find(&contacts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch contacts"})
		return
	}
	c.JSON(http.StatusOK, contacts)
}

// GetContact returns a single contact submission by ID (admin only)
func GetContact(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid contact ID"})
		return
	}

	var contact models.Contact
	if err := database.DB.First(&contact, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Contact not found"})
		return
	}

	c.JSON(http.StatusOK, contact)
}

// CreateContact creates a new contact submission (public)
func CreateContact(c *gin.Context) {
	var contact models.Contact
	if err := c.ShouldBindJSON(&contact); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := database.DB.Create(&contact).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create contact submission"})
		return
	}

	// Send email notification to admin
	emailService := services.NewEmailService(&c.MustGet("config").(*config.Config).SMTP)
	if err := emailService.SendContactEmail(contact.Name, contact.Email, contact.Subject, contact.Message); err != nil {
		// Log error but don't fail the request
		c.Header("X-Email-Error", "Failed to send notification email")
	}

	// Send confirmation email to user
	if err := emailService.SendConfirmationEmail(contact.Email, contact.Name); err != nil {
		// Log error but don't fail the request
		c.Header("X-Confirmation-Email-Error", "Failed to send confirmation email")
	}

	c.JSON(http.StatusCreated, contact)
}

// UpdateContact updates a contact submission status (admin only)
func UpdateContact(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid contact ID"})
		return
	}

	var contact models.Contact
	if err := database.DB.First(&contact, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Contact not found"})
		return
	}

	var updateData struct {
		Status string `json:"status"`
	}

	if err := c.ShouldBindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	contact.Status = updateData.Status
	if err := database.DB.Save(&contact).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update contact"})
		return
	}

	c.JSON(http.StatusOK, contact)
}

// DeleteContact deletes a contact submission (admin only)
func DeleteContact(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid contact ID"})
		return
	}

	if err := database.DB.Delete(&models.Contact{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete contact"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Contact deleted successfully"})
}
