# Security Testing Plan - Admin Authentication System

This document outlines comprehensive security testing for the hardcoded admin authentication system.

## Automated Tests

### Unit Tests (`adminUsers.test.ts`)
- ✅ **Password Hashing Security**
  - Secure bcrypt-based hashing with unique salts
  - Password verification correctness
  - Malformed hash handling
  
- ✅ **User Credential Management**
  - Proper credential map generation
  - Environment variable handling
  - Configuration validation

- ✅ **Database User Seeding**
  - Idempotent user creation
  - Admin role assignment
  - Edge case handling

- ✅ **Edge Cases**
  - Incomplete configuration handling
  - Mixed-case username normalization
  - Missing workspace scenarios

### Integration Tests

Run the unit tests:
```bash
cd dittofeed/packages/backend-lib
npm test -- adminUsers.test.ts
```

## Manual Security Testing

### 1. Authentication Endpoint Testing

#### Valid Login Tests
```bash
# Test User 1 (Ravee)
curl -X POST http://localhost:3001/api/public/single-tenant/login \
  -H "Content-Type: application/json" \
  -d '{"username": "Ravee", "password": "Krishna@125"}'

# Expected: 200 OK with session cookie

# Test User 2 (Ankit)  
curl -X POST http://localhost:3001/api/public/single-tenant/login \
  -H "Content-Type: application/json" \
  -d '{"username": "Ankit", "password": "Krishna@125"}'

# Expected: 200 OK with session cookie
```

#### Invalid Login Tests
```bash
# Wrong username
curl -X POST http://localhost:3001/api/public/single-tenant/login \
  -H "Content-Type: application/json" \
  -d '{"username": "WrongUser", "password": "Krishna@125"}'

# Expected: 401 "Invalid credentials" (no user enumeration)

# Wrong password
curl -X POST http://localhost:3001/api/public/single-tenant/login \
  -H "Content-Type: application/json" \
  -d '{"username": "Ravee", "password": "WrongPassword"}'

# Expected: 401 "Invalid credentials"

# Empty credentials
curl -X POST http://localhost:3001/api/public/single-tenant/login \
  -H "Content-Type: application/json" \
  -d '{"username": "", "password": ""}'

# Expected: 401 "Invalid credentials"

# Missing fields
curl -X POST http://localhost:3001/api/public/single-tenant/login \
  -H "Content-Type: application/json" \
  -d '{"username": "Ravee"}'

# Expected: 400 Bad Request (schema validation)
```

### 2. Session Security Testing

```bash
# Login and capture session cookie
RESPONSE=$(curl -c cookies.txt -X POST http://localhost:3001/api/public/single-tenant/login \
  -H "Content-Type: application/json" \
  -d '{"username": "Ravee", "password": "Krishna@125"}')

# Test authenticated endpoint with session
curl -b cookies.txt http://localhost:3001/api/settings

# Expected: 200 OK with data

# Test without session
curl http://localhost:3001/api/settings

# Expected: 401 Unauthorized
```

### 3. Attack Vector Testing

#### SQL Injection Attempts
```bash
# SQL injection in username
curl -X POST http://localhost:3001/api/public/single-tenant/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin'\'' OR 1=1--", "password": "any"}'

# Expected: 401 Invalid credentials (no SQL injection)

# SQL injection in password
curl -X POST http://localhost:3001/api/public/single-tenant/login \
  -H "Content-Type: application/json" \
  -d '{"username": "Ravee", "password": "any'\'' OR 1=1--"}'

# Expected: 401 Invalid credentials
```

#### Brute Force Testing
```bash
# Multiple failed login attempts (should implement rate limiting)
for i in {1..10}; do
  curl -X POST http://localhost:3001/api/public/single-tenant/login \
    -H "Content-Type: application/json" \
    -d '{"username": "Ravee", "password": "wrong'$i'"}'
  echo "Attempt $i"
done

# Expected: All return 401, consider rate limiting implementation
```

#### Session Fixation/Hijacking
```bash
# Test session security
curl -c session1.txt -X POST http://localhost:3001/api/public/single-tenant/login \
  -H "Content-Type: application/json" \
  -d '{"username": "Ravee", "password": "Krishna@125"}'

# Try to reuse session from different IP (if testing remotely)
curl -b session1.txt http://localhost:3001/api/settings

# Expected: Session should work, but implement IP validation if needed
```

### 4. Bypass Attempt Testing

#### Direct API Access Attempts
```bash
# Try to access protected endpoints without auth
curl http://localhost:3001/api/users
curl http://localhost:3001/api/journeys  
curl http://localhost:3001/api/settings

# Expected: All return 401 Unauthorized

# Try OAuth endpoints (should not exist in single-tenant mode)
curl http://localhost:3001/oauth2/initiate/gmail
curl http://localhost:3001/oauth2/callback/gmail

# Expected: 404 Not Found
```

#### Configuration Bypass Attempts
```bash
# Try to change auth mode via headers or params
curl -X POST http://localhost:3001/api/public/single-tenant/login \
  -H "Content-Type: application/json" \
  -H "Auth-Mode: anonymous" \
  -d '{"username": "Ravee", "password": "Krishna@125"}'

# Expected: Normal login process, headers ignored
```

### 5. Environment Variable Security

#### Configuration Validation
```bash
# Check that sensitive values are not exposed
curl http://localhost:3001/api/health
curl http://localhost:3001/api/status

# Expected: No sensitive environment variables in response

# Check for config endpoints
curl http://localhost:3001/api/config
curl http://localhost:3001/internal-api/config

# Expected: 404 or protected access
```

### 6. Production Security Checklist

#### SSL/TLS Configuration
- [ ] HTTPS enforced in production
- [ ] `SESSION_COOKIE_SECURE=true` with HTTPS
- [ ] Strong SSL cipher suites
- [ ] HSTS headers configured

#### Environment Security  
- [ ] Environment variables not exposed in logs
- [ ] No default passwords in production
- [ ] Secure `SECRET_KEY` generated and configured
- [ ] Database credentials secured

#### Network Security
- [ ] Application not directly exposed to internet
- [ ] Reverse proxy with rate limiting
- [ ] Database access restricted to application only
- [ ] Firewall rules properly configured

#### Monitoring & Alerting
- [ ] Failed login attempts monitored
- [ ] Multiple failed attempts trigger alerts
- [ ] Successful login audit logging
- [ ] Configuration error alerting

## Security Test Results

### Expected Secure Behaviors
1. **No User Enumeration** - Same error message for invalid username or password
2. **Secure Password Storage** - Passwords hashed with bcrypt and salt
3. **Session Security** - Secure session cookies with proper attributes
4. **Access Control** - All protected endpoints require authentication
5. **Configuration Security** - No sensitive data exposure via APIs
6. **Attack Resistance** - SQL injection and other attacks are blocked

### Red Flags to Investigate
- Any different error messages that reveal valid usernames
- Password hashes visible in logs or responses
- Successful authentication with invalid credentials
- Access to protected endpoints without session
- Sensitive configuration data in API responses
- Successful SQL injection or XSS attacks

## Automated Security Scanning

### Tools to Use
```bash
# OWASP ZAP
docker run -t owasp/zap2docker-stable zap-baseline.py -t http://localhost:3001

# Nikto web scanner  
nikto -h http://localhost:3001

# nmap port scanning
nmap -sV localhost

# SQL injection testing with sqlmap
sqlmap -u "http://localhost:3001/api/public/single-tenant/login" \
  --data='{"username":"test","password":"test"}' \
  --headers="Content-Type: application/json"
```

### Performance Testing
```bash
# Load testing with authentication
ab -n 1000 -c 10 -p login.json -T application/json \
  http://localhost:3001/api/public/single-tenant/login

# Monitor for memory leaks or performance issues
```

## Reporting Security Issues

If any security vulnerabilities are discovered:

1. **Document the issue** with steps to reproduce
2. **Assess the severity** based on impact and exploitability  
3. **Fix immediately** for critical issues
4. **Update tests** to prevent regression
5. **Review similar code** for the same vulnerability pattern

## Conclusion

This security testing plan ensures the admin authentication system is robust against common attack vectors and follows security best practices for a production internal application.