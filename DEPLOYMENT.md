# Secure Deployment Guide - Krishna Bhumi Lead Nurturing Tool

This guide covers secure deployment of the Dittofeed-based lead nurturing tool with hardcoded admin authentication.

## Security Overview

This deployment uses **secure single-tenant authentication** with:
- 2 hardcoded admin users (Ravee and Ankit)
- Bcrypt password hashing with salt
- Session-based authentication 
- No OAuth, registration, or anonymous access
- Environment variable configuration for Docker

## Quick Start

### 1. Environment Setup

```bash
# Copy the environment template
cp .env.docker.template .env

# Edit the configuration (REQUIRED)
nano .env
```

### 2. Required Environment Variables

```bash
# Authentication (REQUIRED)
AUTH_MODE=single-tenant
ADMIN_USER_1_NAME=Ravee
ADMIN_USER_1_PASSWORD=Krishna@125
ADMIN_USER_2_NAME=Ankit  
ADMIN_USER_2_PASSWORD=Krishna@125

# Security (REQUIRED - Generate a secure key!)
SECRET_KEY=your-32-byte-base64-secret-key-here
SESSION_COOKIE_SECURE=true

# Database (REQUIRED)
DATABASE_PASSWORD=your_secure_db_password
CLICKHOUSE_PASSWORD=your_secure_ch_password

# Application URL (REQUIRED for production)
DASHBOARD_URL=https://your-domain.com
```

### 3. Deploy with Docker Compose

```bash
# Start all services
docker-compose up -d

# Check logs
docker-compose logs -f dittofeed

# Check status
docker-compose ps
```

### 4. Access the Application

- URL: `http://localhost:3000` (or your DASHBOARD_URL)
- Login with:
  - Username: `Ravee`, Password: `Krishna@125`
  - Username: `Ankit`, Password: `Krishna@125`

## Security Configuration

### Generate Secure Keys

```bash
# Generate a secure SECRET_KEY
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"

# Generate secure database passwords
openssl rand -base64 32
```

### Production Security Checklist

- [ ] Change default passwords in `.env`
- [ ] Generate and set a secure `SECRET_KEY`
- [ ] Set `SESSION_COOKIE_SECURE=true` with HTTPS
- [ ] Use strong database passwords
- [ ] Restrict network access to containers
- [ ] Enable Docker secrets in production
- [ ] Configure reverse proxy with HTTPS
- [ ] Set up log monitoring
- [ ] Configure database backups
- [ ] Disable unused ports

## Authentication Details

### Login Process
1. User submits username/password to `/api/public/single-tenant/login`
2. System validates against environment-configured admin users
3. Passwords are verified using bcrypt with salt
4. Valid login creates secure session cookie
5. All subsequent requests require valid session

### User Management
- Users are automatically seeded on application startup
- No registration or user creation endpoints
- No password reset functionality
- Only the 2 configured admin users can access the system

### Security Features
- **Bcrypt password hashing** with 32-byte salt
- **Session-based authentication** with secure cookies
- **No user enumeration** - consistent error messages
- **Audit logging** - successful logins are logged
- **Error handling** - graceful degradation on auth failures
- **Rate limiting** - (configure via reverse proxy)

## Production Deployment

### Docker Production Build

```dockerfile
# Example production Dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS runtime  
RUN addgroup -g 1001 -S nodejs
RUN adduser -S dittofeed -u 1001
WORKDIR /app
COPY --from=builder --chown=dittofeed:nodejs /app .
USER dittofeed
EXPOSE 3000 3001
CMD ["npm", "start"]
```

### Reverse Proxy (Nginx)

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
    
    # Rate limiting
    limit_req zone=login_limit burst=5 nodelay;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Environment Variables Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `AUTH_MODE` | ✓ | - | Must be `single-tenant` |
| `ADMIN_USER_1_NAME` | ✓ | - | First admin username |
| `ADMIN_USER_1_PASSWORD` | ✓ | - | First admin password |
| `ADMIN_USER_2_NAME` | ✓ | - | Second admin username |
| `ADMIN_USER_2_PASSWORD` | ✓ | - | Second admin password |
| `SECRET_KEY` | ✓ | - | 32-byte base64 session key |
| `DATABASE_URL` | ✓ | - | PostgreSQL connection string |
| `CLICKHOUSE_HOST` | ✓ | - | ClickHouse server URL |
| `DASHBOARD_URL` | ✓ | - | Application base URL |
| `SESSION_COOKIE_SECURE` | - | true | Use secure cookies (HTTPS) |
| `LOG_LEVEL` | - | info | Logging verbosity |

## Troubleshooting

### Login Issues
```bash
# Check admin user configuration
docker-compose logs dittofeed | grep -i "admin user"

# Check authentication attempts
docker-compose logs dittofeed | grep -i "login"
```

### Database Issues
```bash
# Check database connection
docker-compose logs postgres
docker-compose exec postgres pg_isready -U dittofeed

# Check ClickHouse
docker-compose logs clickhouse
docker-compose exec clickhouse clickhouse-client --query "SELECT 1"
```

### Common Issues
1. **SECRET_KEY not set** - Generate and configure a secure key
2. **Database connection failed** - Check DATABASE_URL and credentials  
3. **Admin users not found** - Verify ADMIN_USER_* environment variables
4. **Session issues** - Check SESSION_COOKIE_SECURE setting with HTTPS

## Monitoring & Maintenance

### Log Monitoring
- Monitor authentication attempts
- Track failed login attempts
- Alert on configuration errors
- Monitor database connections

### Backup Strategy
- Database: Regular PostgreSQL backups
- ClickHouse: Data and schema backups
- Environment: Secure backup of `.env` file

### Updates
- Regular security updates for base images
- Monitor for Dittofeed updates
- Test updates in staging environment first

## Support

For issues with this secure deployment:
1. Check the logs using the troubleshooting commands above
2. Verify all required environment variables are set
3. Ensure database services are healthy
4. Check network connectivity between services