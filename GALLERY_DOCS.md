# 🖼️ **Gallery API Documentation**

## **Simple Gallery Management**

### **Public Endpoints (No Authentication Required)**

#### **Get All Gallery Images**
**GET** `/api/galleries`
- **Description**: Get all gallery images
- **Authentication**: None required
- **Response**:
```json
[
  {
    "id": 1,
    "image_name": "sunset.jpg",
    "image_file": "sunset_123456.jpg",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z"
  },
  {
    "id": 2,
    "image_name": "mountain.jpg",
    "image_file": "mountain_789012.jpg",
    "created_at": "2024-01-14T15:20:00Z",
    "updated_at": "2024-01-14T15:20:00Z"
  }
]
```

---

### **Admin Endpoints (Authentication Required)**

#### **Create Gallery Image**
**POST** `/api/galleries`
- **Description**: Create a new gallery image
- **Authentication**: Required
- **Request Body**:
```json
{
  "image_name": "sunset.jpg",
  "image_file": "sunset_123456.jpg"
}
```
- **Response**: Same format as above with generated ID

#### **Get All Gallery Images (Admin)**
**GET** `/api/galleries/admin`
- **Description**: Get all gallery images (admin view)
- **Authentication**: Required
- **Response**: Same format as public galleries

#### **Get Single Gallery Image (Admin)**
**GET** `/api/galleries/admin/{id}`
- **Description**: Get a specific gallery image by ID
- **Authentication**: Required
- **Parameters**: `id` (integer) - Gallery ID
- **Response**:
```json
{
  "id": 1,
  "image_name": "sunset.jpg",
  "image_file": "sunset_123456.jpg",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

#### **Update Gallery Image**
**PUT** `/api/galleries/{id}`
- **Description**: Update an existing gallery image
- **Authentication**: Required
- **Parameters**: `id` (integer) - Gallery ID
- **Request Body**:
```json
{
  "image_name": "new_sunset.jpg",
  "image_file": "new_sunset_123456.jpg"
}
```
- **Response**: Updated gallery object

#### **Delete Gallery Image**
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

---

## **Gallery Data Model**

```json
{
  "id": "integer (auto-generated)",
  "image_name": "string (required)",
  "image_file": "string (required)",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### **Field Descriptions:**
- **`id`**: Auto-generated unique identifier
- **`image_name`**: Original filename of the image (required)
- **`image_file`**: Processed/stored filename (required)
- **`created_at`**: Timestamp when record was created
- **`updated_at`**: Timestamp when record was last updated

---

## **Usage Examples**

### **1. Get All Gallery Images (Public)**
```bash
curl -X GET "https://your-api.com/api/galleries"
```

### **2. Create New Gallery Image (Admin)**
```bash
curl -X POST "https://your-api.com/api/galleries" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "image_name": "mountain.jpg",
    "image_file": "mountain_123456.jpg"
  }'
```

### **3. Update Gallery Image (Admin)**
```bash
curl -X PUT "https://your-api.com/api/galleries/1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "image_name": "updated_mountain.jpg",
    "image_file": "updated_mountain_123456.jpg"
  }'
```

### **4. Delete Gallery Image (Admin)**
```bash
curl -X DELETE "https://your-api.com/api/galleries/1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## **Features**

✅ **Simple Structure**: Only essential fields (id, image_name, image_file)  
✅ **Public Access**: Anyone can view gallery images  
✅ **Admin Management**: Full CRUD operations for admins  
✅ **Soft Deletes**: Images are soft-deleted (can be recovered)  
✅ **Authentication**: JWT-based authentication for admin operations  
✅ **Ordered by Date**: Images ordered by creation date (newest first)  

---

## **API Endpoints Summary**

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/galleries` | No | Get all gallery images (public) |
| GET | `/api/galleries/admin` | Yes | Get all gallery images (admin) |
| GET | `/api/galleries/admin/{id}` | Yes | Get specific gallery image |
| POST | `/api/galleries` | Yes | Create new gallery image |
| PUT | `/api/galleries/{id}` | Yes | Update gallery image |
| DELETE | `/api/galleries/{id}` | Yes | Delete gallery image |

The gallery system is now super simple and ready to use! 🚀
