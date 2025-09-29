#!/bin/bash

# Click Exprice Backend Deployment Script
# This script deploys the Go backend to your server

set -e

echo "🚀 Starting Click Exprice Backend Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_warning ".env file not found. Creating from template..."
    if [ -f "production.env" ]; then
        cp production.env .env
        print_warning "Please edit .env file with your actual configuration before running again."
        exit 1
    else
        print_error "No environment template found. Please create .env file manually."
        exit 1
    fi
fi

# Stop existing containers
print_status "Stopping existing containers..."
docker-compose down

# Build and start services
print_status "Building and starting services..."
docker-compose up --build -d

# Wait for services to be ready
print_status "Waiting for services to be ready..."
sleep 10

# Check if backend is healthy
print_status "Checking backend health..."
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    print_status "✅ Backend is healthy!"
else
    print_warning "⚠️  Backend health check failed. Check logs with: docker-compose logs backend"
fi

# Check if nginx is running
if curl -f http://localhost/health > /dev/null 2>&1; then
    print_status "✅ Nginx proxy is working!"
else
    print_warning "⚠️  Nginx proxy check failed. Check logs with: docker-compose logs nginx"
fi

print_status "🎉 Deployment completed!"
print_status "Your API is available at:"
print_status "  - Direct backend: http://localhost:8080"
print_status "  - Through nginx: http://localhost"
print_status ""
print_status "Useful commands:"
print_status "  - View logs: docker-compose logs -f"
print_status "  - Stop services: docker-compose down"
print_status "  - Restart services: docker-compose restart"
print_status "  - Update services: docker-compose up --build -d"
