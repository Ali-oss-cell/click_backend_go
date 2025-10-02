package routes

import (
	"go-click-exprice-backend/config"
	"go-click-exprice-backend/handlers"
	"go-click-exprice-backend/middleware"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(cfg *config.Config) *gin.Engine {
	r := gin.Default()

	// CORS is handled by Nginx - removed CORS middleware from Go app
	// r.Use(middleware.CORSMiddleware()) // ← REMOVED to avoid duplicate headers

	// Add config to context
	r.Use(func(c *gin.Context) {
		c.Set("config", cfg)
		c.Next()
	})

	// Public routes
	public := r.Group("/api")
	{
		// Blog public routes
		public.GET("/blogs/public", handlers.GetPublicBlogs)

		// Contact routes
		public.POST("/contacts", handlers.CreateContact)

		// Auth routes
		public.POST("/auth/login", handlers.Login)
		public.POST("/auth/create-admin", handlers.CreateAdmin) // For initial setup only
	}

	// Protected routes (require authentication)
	protected := r.Group("/api")
	protected.Use(middleware.AuthMiddleware(cfg))
	{
		// Blog management (admin only)
		protected.GET("/blogs", handlers.GetBlogs)
		protected.GET("/blogs/:id", handlers.GetBlog)
		protected.POST("/blogs", handlers.CreateBlog)
		protected.PUT("/blogs/:id", handlers.UpdateBlog)
		protected.DELETE("/blogs/:id", handlers.DeleteBlog)

		// Contact management (admin only)
		protected.GET("/contacts", handlers.GetContacts)
		protected.GET("/contacts/:id", handlers.GetContact)
		protected.PUT("/contacts/:id", handlers.UpdateContact)
		protected.DELETE("/contacts/:id", handlers.DeleteContact)
	}

	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	return r
}
