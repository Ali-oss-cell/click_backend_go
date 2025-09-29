# Click Exprice Backend - Deployment Guide

This guide will help you deploy the Click Exprice backend to your server.

## 🚀 Quick Deployment

### Prerequisites
- Docker and Docker Compose installed on your server
- Git (to clone the repository)
- Basic knowledge of Linux commands

### 1. Clone and Setup
```bash
# Clone your repository
git clone <your-repo-url>
cd go-click-exprice-backend

# Make deployment script executable
chmod +x deploy.sh
```

### 2. Configure Environment
```bash
# Copy production environment template
cp production.env .env

# Edit the .env file with your actual values
nano .env
```

**Important Environment Variables:**
- `DB_PASSWORD`: Set a strong password for PostgreSQL
- `JWT_SECRET`: Generate a long, random secret key
- `SMTP_USERNAME`: Your email address for sending notifications
- `SMTP_PASSWORD`: Your email app password (not regular password)
- `ADMIN_EMAIL`: Email where contact form submissions will be sent

### 3. Deploy
```bash
# Run the deployment script
./deploy.sh
```

## 🔧 Manual Deployment

If you prefer to deploy manually:

```bash
# Build and start services
docker-compose up --build -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

## 📋 Post-Deployment Setup

### 1. Create Admin User
After deployment, create your admin user:

```bash
curl -X POST http://your-server-ip/api/auth/create-admin \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "email": "admin@yourdomain.com",
    "password": "your-secure-password"
  }'
```

### 2. Test the API
```bash
# Health check
curl http://your-server-ip/health

# Test public blog endpoint
curl http://your-server-ip/api/blogs/public

# Test contact form
curl -X POST http://your-server-ip/api/contacts \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "subject": "Test Message",
    "message": "This is a test message"
  }'
```

## 🔒 Security Considerations

### 1. Change Default Passwords
- Update `DB_PASSWORD` in `.env`
- Generate a strong `JWT_SECRET`
- Use strong admin password

### 2. Configure Firewall
```bash
# Allow only necessary ports
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS (if using SSL)
sudo ufw enable
```

### 3. SSL/HTTPS Setup
1. Get SSL certificates (Let's Encrypt recommended)
2. Update nginx.conf with SSL configuration
3. Redirect HTTP to HTTPS

## 📊 Monitoring

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f postgres
docker-compose logs -f nginx
```

### Check Status
```bash
# Container status
docker-compose ps

# Resource usage
docker stats
```

## 🔄 Updates

### Update Application
```bash
# Pull latest changes
git pull

# Rebuild and restart
docker-compose up --build -d
```

### Database Backup
```bash
# Backup database
docker-compose exec postgres pg_dump -U postgres click_exprice > backup.sql

# Restore database
docker-compose exec -T postgres psql -U postgres click_exprice < backup.sql
```

## 🐛 Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Check what's using the port
   sudo netstat -tlnp | grep :80
   sudo netstat -tlnp | grep :8080
   ```

2. **Database Connection Failed**
   - Check if PostgreSQL container is running
   - Verify database credentials in `.env`
   - Check logs: `docker-compose logs postgres`

3. **Email Not Working**
   - Verify SMTP credentials
   - Check if your email provider requires app passwords
   - Test with a simple email first

4. **Permission Issues**
   ```bash
   # Fix file permissions
   sudo chown -R $USER:$USER .
   chmod +x deploy.sh
   ```

### Reset Everything
```bash
# Stop and remove all containers and volumes
docker-compose down -v
docker system prune -a

# Start fresh
./deploy.sh
```

## 📞 Support

If you encounter issues:
1. Check the logs: `docker-compose logs -f`
2. Verify your `.env` configuration
3. Ensure all required ports are open
4. Check if Docker and Docker Compose are properly installed

## 🎯 Production Checklist

- [ ] Strong database password set
- [ ] JWT secret key generated
- [ ] SMTP credentials configured
- [ ] Admin user created
- [ ] Firewall configured
- [ ] SSL certificates installed
- [ ] Domain name configured
- [ ] Monitoring setup
- [ ] Backup strategy implemented
