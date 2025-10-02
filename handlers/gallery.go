package handlers

import (
	"net/http"
	"strconv"

	"go-click-exprice-backend/database"
	"go-click-exprice-backend/models"

	"github.com/gin-gonic/gin"
)

// GetGalleries returns all gallery images (admin only)
func GetGalleries(c *gin.Context) {
	var galleries []models.Gallery
	if err := database.DB.Order("created_at DESC").Find(&galleries).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch galleries"})
		return
	}
	c.JSON(http.StatusOK, galleries)
}

// GetGallery returns a single gallery image by ID
func GetGallery(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid gallery ID"})
		return
	}

	var gallery models.Gallery
	if err := database.DB.First(&gallery, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Gallery not found"})
		return
	}

	c.JSON(http.StatusOK, gallery)
}

// CreateGallery creates a new gallery image (admin only)
func CreateGallery(c *gin.Context) {
	var gallery models.Gallery
	if err := c.ShouldBindJSON(&gallery); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := database.DB.Create(&gallery).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create gallery image"})
		return
	}

	c.JSON(http.StatusCreated, gallery)
}

// UpdateGallery updates an existing gallery image (admin only)
func UpdateGallery(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid gallery ID"})
		return
	}

	var gallery models.Gallery
	if err := database.DB.First(&gallery, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Gallery not found"})
		return
	}

	if err := c.ShouldBindJSON(&gallery); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := database.DB.Save(&gallery).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update gallery image"})
		return
	}

	c.JSON(http.StatusOK, gallery)
}

// DeleteGallery deletes a gallery image (admin only)
func DeleteGallery(c *gin.Context) {
	id, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid gallery ID"})
		return
	}

	if err := database.DB.Delete(&models.Gallery{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete gallery image"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Gallery image deleted successfully"})
}

// GetPublicGalleries returns all gallery images (public)
func GetPublicGalleries(c *gin.Context) {
	var galleries []models.Gallery
	if err := database.DB.Order("created_at DESC").Find(&galleries).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch galleries"})
		return
	}
	c.JSON(http.StatusOK, galleries)
}
