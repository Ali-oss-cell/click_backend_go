# Go Click Exprice Backend

A Go backend API for managing blogs and contact forms with admin authentication.

## Features

- **Blog Management**: CRUD operations for blog posts with image support
- **Contact Form**: Public contact form with email notifications
- **Admin Authentication**: JWT-based authentication for admin users
- **Email Integration**: SMTP email notifications for contact submissions
- **PostgreSQL Database**: Robust data storage with GORM ORM

## API Endpoints

### Public Endpoints
- `GET /api/blogs/public` - Get published blog posts
- `POST /api/contacts` - Submit contact form
- `POST /api/auth/login` - Admin login
- `POST /api/auth/create-admin` - Create admin user (setup only)

### Protected Endpoints (Admin Only)
- `GET /api/blogs` - Get all blog posts
- `GET /api/blogs/:id` - Get single blog post
- `POST /api/blogs` - Create blog post
- `PUT /api/blogs/:id` - Update blog post
- `DELETE /api/blogs/:id` - Delete blog post
- `GET /api/contacts` - Get all contact submissions
- `GET /api/contacts/:id` - Get single contact submission
- `PUT /api/contacts/:id` - Update contact status
- `DELETE /api/contacts/:id` - Delete contact submission

## Setup

1. **Install Dependencies**
   ```bash
   go mod tidy
   ```

2. **Configure Environment**
   ```bash
   cp config.env.example .env
   # Edit .env with your configuration
   ```

3. **Database Setup**
   - Install PostgreSQL
   - Create database: `click_exprice`
   - Update database credentials in `.env`

4. **Run the Application**
   ```bash
   go run main.go
   ```

5. **Create Admin User**
   ```bash
   curl -X POST http://localhost:8080/api/auth/create-admin \
     -H "Content-Type: application/json" \
     -d '{"username":"admin","email":"admin@example.com","password":"yourpassword"}'
   ```

## Configuration

Environment variables in `.env`:

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=click_exprice

# JWT
JWT_SECRET=your-secret-key-here

# SMTP
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
ADMIN_EMAIL=admin@yourapp.com

# Server
PORT=8080
GIN_MODE=debug
```

## Usage

### Authentication
Include JWT token in Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

### Blog Post Structure
```json
{
  "title": "Blog Post Title",
  "content": "Blog post content...",
  "image_name": "image.jpg",
  "image_file": "base64-encoded-image-data",
  "published": true
}
```

### Contact Form Structure
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "subject": "Inquiry",
  "message": "Your message here..."
}
```

## Development

- **Database**: PostgreSQL with GORM
- **Authentication**: JWT tokens
- **Email**: SMTP integration
- **Framework**: Gin web framework
- **ORM**: GORM for database operations
# click_backend_go
