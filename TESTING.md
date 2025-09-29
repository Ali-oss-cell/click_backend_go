# Click Exprice Backend - Testing Guide

## 🧪 **Postman Collection**

I've created a comprehensive Postman collection (`API_TESTS.postman_collection.json`) with all the tests you need.

### **Import Instructions:**
1. Open Postman
2. Click "Import" button
3. Select the `API_TESTS.postman_collection.json` file
4. Set your base URL in the collection variables

### **Test Sequence:**
1. **Health Check** - Verify server is running
2. **Create Admin User** - Set up admin account
3. **Admin Login** - Get authentication token
4. **Create Blog Post** - Test blog creation
5. **Get All Blogs** - Test admin blog listing
6. **Get Public Blogs** - Test public blog access
7. **Submit Contact Form** - Test contact form submission
8. **Get Contacts** - Test admin contact management
9. **Update Contact Status** - Test contact status updates
10. **Error Tests** - Test invalid login and unauthorized access

## 🗄️ **Database Configuration**

### **Recommended Database Settings:**
```env
# Database Configuration
DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=ClickExprice2024!SecureDB
DB_NAME=click_exprice
```

### **Database Name & Credentials:**
- **Database Name**: `click_exprice`
- **Username**: `postgres`
- **Password**: `ClickExprice2024!SecureDB` (change this!)
- **Host**: `postgres` (for Docker) or `localhost` (for local development)

## 📧 **SMTP Configuration**

### **Gmail SMTP (Recommended):**
```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
ADMIN_EMAIL=admin@yourdomain.com
```

### **SMTP Setup Steps:**

#### **1. Gmail Setup:**
1. Enable 2-Factor Authentication on your Gmail account
2. Generate an "App Password":
   - Go to Google Account settings
   - Security → 2-Step Verification → App passwords
   - Generate password for "Mail"
   - Use this password (not your regular Gmail password)

#### **2. Other Email Providers:**

**Outlook/Hotmail:**
```env
SMTP_HOST=smtp-mail.outlook.com
SMTP_PORT=587
```

**Yahoo:**
```env
SMTP_HOST=smtp.mail.yahoo.com
SMTP_PORT=587
```

**Custom SMTP:**
```env
SMTP_HOST=your-smtp-server.com
SMTP_PORT=587
```

## 🔧 **Complete Environment Configuration**

Create a `.env` file with these settings:

```env
# Database Configuration
DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=ClickExprice2024!SecureDB
DB_NAME=click_exprice

# JWT Configuration - CHANGE THIS!
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production-make-it-very-long-and-random-123456789

# SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-gmail-app-password
ADMIN_EMAIL=admin@yourdomain.com

# Server Configuration
PORT=8080
GIN_MODE=release
```

## 🚀 **Quick Test Commands**

### **1. Health Check:**
```bash
curl http://localhost:8080/health
```

### **2. Create Admin User:**
```bash
curl -X POST http://localhost:8080/api/auth/create-admin \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "email": "admin@clickexprice.com",
    "password": "AdminPass123!"
  }'
```

### **3. Login:**
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "AdminPass123!"
  }'
```

### **4. Test Contact Form:**
```bash
curl -X POST http://localhost:8080/api/contacts \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "subject": "Test Message",
    "message": "This is a test message from the API"
  }'
```

### **5. Get Public Blogs:**
```bash
curl http://localhost:8080/api/blogs/public
```

## 📋 **Testing Checklist**

### **Before Testing:**
- [ ] Database is running and accessible
- [ ] Environment variables are set correctly
- [ ] SMTP credentials are valid
- [ ] Server is running on correct port

### **API Tests:**
- [ ] Health endpoint responds
- [ ] Admin user can be created
- [ ] Login returns JWT token
- [ ] Blog CRUD operations work
- [ ] Contact form submission works
- [ ] Email notifications are sent
- [ ] Authentication protects admin endpoints
- [ ] CORS headers are present

### **Email Tests:**
- [ ] Contact form sends notification to admin
- [ ] User receives confirmation email
- [ ] Email content is properly formatted
- [ ] SMTP connection is stable

## 🐛 **Troubleshooting**

### **Common Issues:**

1. **Database Connection Failed:**
   - Check if PostgreSQL is running
   - Verify database credentials
   - Ensure database exists

2. **Email Not Sending:**
   - Verify SMTP credentials
   - Check if app password is correct
   - Test SMTP connection manually

3. **Authentication Failed:**
   - Check JWT secret is set
   - Verify token format
   - Check token expiration

4. **CORS Issues:**
   - Check nginx configuration
   - Verify CORS headers
   - Test with different origins

## 📊 **Performance Testing**

### **Load Testing with Apache Bench:**
```bash
# Test health endpoint
ab -n 1000 -c 10 http://localhost:8080/health

# Test blog listing
ab -n 100 -c 5 http://localhost:8080/api/blogs/public

# Test contact form
ab -n 50 -c 2 -p contact.json -T application/json http://localhost:8080/api/contacts
```

### **Contact Form Test Data:**
Create `contact.json`:
```json
{
  "name": "Load Test User",
  "email": "loadtest@example.com",
  "subject": "Load Test",
  "message": "This is a load test message"
}
```

## 🎯 **Production Testing**

### **Security Tests:**
- [ ] SQL injection attempts fail
- [ ] XSS attempts are blocked
- [ ] Rate limiting works
- [ ] Authentication is required for admin endpoints
- [ ] CORS is properly configured

### **Functionality Tests:**
- [ ] All CRUD operations work
- [ ] Email notifications are sent
- [ ] File uploads work (if implemented)
- [ ] Error handling is proper
- [ ] Logging is working

Your API is now ready for comprehensive testing! 🚀
