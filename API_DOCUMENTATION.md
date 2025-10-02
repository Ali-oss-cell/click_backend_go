# Click Exprice Backend API Documentation

## Overview
This is a Go-based REST API backend for the Click Exprice logistics/shipping platform. The API provides endpoints for blog management, contact form handling, and admin authentication.

## Base URL
- **Development**: `http://localhost:8080`
- **Production**: `https://your-domain.com`

## Authentication
The API uses JWT (JSON Web Token) for authentication. Include the token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

## API Endpoints

### 1. Health Check
**GET** `/health`
- **Description**: Check if the API is running
- **Authentication**: None required
- **Response**:
```json
{
  "status": "ok"
}
```

### 2. Authentication

#### Login
**POST** `/api/auth/login`
- **Description**: Authenticate admin user
- **Authentication**: None required
- **Request Body**:
```json
{
  "username": "admin",
  "password": "password123"
}
```
- **Response**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "username": "admin",
  "message": "Login successful"
}
```

#### Create Admin (Setup Only)
**POST** `/api/auth/create-admin`
- **Description**: Create initial admin user (use only during setup)
- **Authentication**: None required
- **Request Body**:
```json
{
  "username": "admin",
  "email": "admin@clickexpress.ae",
  "password": "securepassword123"
}
```

### 3. Blog Management

#### Get All Blogs (Admin)
**GET** `/api/blogs`
- **Description**: Get all blog posts (including unpublished)
- **Authentication**: Required
- **Response**:
```json
[
  {
    "id": 1,
    "title": "Blog Post Title",
    "content": "Blog post content...",
    "image_name": "image.jpg",
    "image_file": "path/to/image.jpg",
    "published": true,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
]
```

#### Get Single Blog (Admin)
**GET** `/api/blogs/{id}`
- **Description**: Get a specific blog post by ID
- **Authentication**: Required
- **Parameters**: `id` (integer) - Blog post ID

#### Create Blog Post
**POST** `/api/blogs`
- **Description**: Create a new blog post
- **Authentication**: Required
- **Request Body**:
```json
{
  "title": "New Blog Post",
  "content": "Blog post content...",
  "image_name": "image.jpg",
  "image_file": "path/to/image.jpg",
  "published": false
}
```

#### Update Blog Post
**PUT** `/api/blogs/{id}`
- **Description**: Update an existing blog post
- **Authentication**: Required
- **Parameters**: `id` (integer) - Blog post ID
- **Request Body**: Same as create blog post

#### Delete Blog Post
**DELETE** `/api/blogs/{id}`
- **Description**: Delete a blog post
- **Authentication**: Required
- **Parameters**: `id` (integer) - Blog post ID
- **Response**:
```json
{
  "message": "Blog deleted successfully"
}
```

#### Get Public Blogs
**GET** `/api/blogs/public`
- **Description**: Get only published blog posts (public access)
- **Authentication**: None required
- **Response**: Same format as admin blogs, but only published posts

### 4. Contact Management

#### Submit Contact Form
**POST** `/api/contacts`
- **Description**: Submit a contact form (public)
- **Authentication**: None required
- **Request Body**:
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "subject": "Inquiry about services",
  "message": "I would like to know more about your services..."
}
```
- **Response**: Returns the created contact submission
- **Note**: This endpoint automatically sends:
  - Notification email to admin
  - Confirmation email to the user

#### Get All Contacts (Admin)
**GET** `/api/contacts`
- **Description**: Get all contact form submissions
- **Authentication**: Required
- **Response**:
```json
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "subject": "Inquiry about services",
    "message": "I would like to know more...",
    "status": "pending",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
]
```

#### Get Single Contact (Admin)
**GET** `/api/contacts/{id}`
- **Description**: Get a specific contact submission by ID
- **Authentication**: Required
- **Parameters**: `id` (integer) - Contact ID

#### Update Contact Status (Admin)
**PUT** `/api/contacts/{id}`
- **Description**: Update contact submission status
- **Authentication**: Required
- **Parameters**: `id` (integer) - Contact ID
- **Request Body**:
```json
{
  "status": "read"
}
```
- **Status Options**: `pending`, `read`, `replied`

#### Delete Contact (Admin)
**DELETE** `/api/contacts/{id}`
- **Description**: Delete a contact submission
- **Authentication**: Required
- **Parameters**: `id` (integer) - Contact ID
- **Response**:
```json
{
  "message": "Contact deleted successfully"
}
```

### 5. Gallery Management

#### Get All Gallery Images (Public)
**GET** `/api/galleries`
- **Description**: Get all gallery images
- **Authentication**: None required
- **Response**:
```json
[
  {
    "id": 1,
    "title": "Beautiful Sunset",
    "description": "A stunning sunset over the mountains",
    "image_name": "sunset.jpg",
    "image_file": "sunset_123456.jpg",
    "image_url": "https://example.com/images/sunset_123456.jpg",
    "category": "nature",
    "order": 1,
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  }
]
```

#### Get Gallery Images by Category (Public)
**GET** `/api/galleries/category/{category}`
- **Description**: Get gallery images filtered by category
- **Authentication**: None required
- **Parameters**: `category` (string) - Category name
- **Response**: Same format as above, filtered by category

#### Create Gallery Image (Admin)
**POST** `/api/galleries`
- **Description**: Create a new gallery image
- **Authentication**: Required
- **Request Body**:
```json
{
  "title": "Beautiful Sunset",
  "description": "A stunning sunset over the mountains",
  "image_name": "sunset.jpg",
  "image_file": "sunset_123456.jpg",
  "image_url": "https://example.com/images/sunset_123456.jpg",
  "category": "nature",
  "order": 1
}
```

#### Get All Gallery Images (Admin)
**GET** `/api/galleries/admin`
- **Description**: Get all gallery images (admin view)
- **Authentication**: Required
- **Response**: Same format as public galleries

#### Get Single Gallery Image (Admin)
**GET** `/api/galleries/admin/{id}`
- **Description**: Get a specific gallery image by ID
- **Authentication**: Required
- **Parameters**: `id` (integer) - Gallery ID

#### Update Gallery Image (Admin)
**PUT** `/api/galleries/{id}`
- **Description**: Update an existing gallery image
- **Authentication**: Required
- **Parameters**: `id` (integer) - Gallery ID
- **Request Body**: Same format as create, all fields optional

#### Delete Gallery Image (Admin)
**DELETE** `/api/galleries/{id}`
- **Description**: Delete a gallery image
- **Authentication**: Required
- **Parameters**: `id` (integer) - Gallery ID
- **Response**:
```json
{
  "message": "Gallery image deleted successfully"
}
```

## Data Models

### Blog Model
```json
{
  "id": "integer (auto-generated)",
  "title": "string (required)",
  "content": "string (text)",
  "image_name": "string (optional)",
  "image_file": "string (optional)",
  "published": "boolean (default: false)",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Contact Model
```json
{
  "id": "integer (auto-generated)",
  "name": "string (required)",
  "email": "string (required)",
  "subject": "string (optional)",
  "message": "string (required)",
  "status": "string (default: 'pending')",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Gallery Model
```json
{
  "id": "integer (auto-generated)",
  "title": "string (required)",
  "description": "string (optional)",
  "image_name": "string (required)",
  "image_file": "string (required)",
  "image_url": "string (optional)",
  "category": "string (optional)",
  "order": "integer (default: 0)",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Admin Model
```json
{
  "id": "integer (auto-generated)",
  "username": "string (unique, required)",
  "email": "string (unique, required)",
  "password": "string (required)",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

## Error Responses

### 400 Bad Request
```json
{
  "error": "Invalid request data"
}
```

### 401 Unauthorized
```json
{
  "error": "Invalid credentials"
}
```

### 404 Not Found
```json
{
  "error": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error"
}
```

## CORS Configuration
The API is configured with CORS to allow requests from any origin:
- **Access-Control-Allow-Origin**: `*`
- **Access-Control-Allow-Methods**: `GET, POST, PUT, DELETE, OPTIONS`
- **Access-Control-Allow-Headers**: `Origin, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization`

## Email Integration
The API includes email functionality for:
- **Contact Form Notifications**: Admin receives email when contact form is submitted
- **User Confirmations**: Users receive confirmation email after submitting contact form

Email configuration uses SMTP with the following settings:
- **Host**: smtp.hostinger.com
- **Port**: 465 (SSL/TLS)
- **Authentication**: Username/Password

## Database
- **Type**: PostgreSQL (production) / SQLite (development)
- **ORM**: GORM
- **Auto-migration**: Enabled for all models

## Environment Variables
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
SMTP_HOST=smtp.hostinger.com
SMTP_PORT=465
SMTP_USERNAME=info@clickexpress.ae
SMTP_PASSWORD=your-password
ADMIN_EMAIL=info@clickexpress.ae

# Server
PORT=8080
GIN_MODE=release
```

## Frontend Integration Examples

### JavaScript/React Example
```javascript
// Login
const login = async (username, password) => {
  const response = await fetch('/api/auth/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ username, password }),
  });
  return response.json();
};

// Get public blogs
const getPublicBlogs = async () => {
  const response = await fetch('/api/blogs/public');
  return response.json();
};

// Submit contact form
const submitContact = async (contactData) => {
  const response = await fetch('/api/contacts', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(contactData),
  });
  return response.json();
};

// Admin: Get all contacts (with auth)
const getContacts = async (token) => {
  const response = await fetch('/api/contacts', {
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });
  return response.json();
};
```

### Axios Example
```javascript
// Setup axios instance
const api = axios.create({
  baseURL: 'https://your-api-domain.com',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add auth interceptor
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Usage
const getBlogs = () => api.get('/api/blogs');
const createBlog = (blogData) => api.post('/api/blogs', blogData);
const updateContact = (id, status) => api.put(`/api/contacts/${id}`, { status });
```

## Testing
The API includes comprehensive Postman collection with:
- Health check tests
- Authentication flow tests
- CRUD operations for all endpoints
- Error handling tests
- CORS tests

## Deployment
- **Docker**: Included with docker-compose.yml
- **Production**: Configured for PostgreSQL
- **Environment**: Production-ready with proper security settings

## Security Notes
- JWT tokens expire after 24 hours
- Passwords are stored in plain text (consider hashing for production)
- CORS is configured for all origins (restrict in production)
- Admin creation endpoint should be disabled after initial setup

## Support
For technical support or questions about the API, contact the backend development team.
