# Security Hardening - HSTS & Security Headers Implementation

## 🔒 Security Headers & TLS Hardening Plan

### 🎯 Security Ziele

#### Immediate Goals
- **TLS A+ Rating**: SSL Labs Perfect Score
- **Security Headers**: Complete OWASP implementation
- **HSTS Implementation**: Max-age 31536000 (1 Jahr)
- **CORS Configuration**: API-spezifische Policies
- **Rate Limiting**: DDoS Protection

#### Target Security Score
- **Mozilla Observatory**: A+ (90+/100)
- **Lighthouse Security**: 100/100
- **SSL Labs**: A+ Rating
- **SecurityHeaders.com**: A+ Rating

## 🌐 HTTP Security Headers Implementation

### 1. Strict-Transport-Security (HSTS)

#### Apache Configuration (.htaccess)
```apache
# HSTS - Force HTTPS for 1 year including subdomains
Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"

# Redirect HTTP to HTTPS
RewriteEngine On
RewriteCond %{HTTPS} !=on
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

#### Nginx Configuration
```nginx
# HSTS Header für alle HTTPS responses
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

# HTTP to HTTPS redirect
server {
    listen 80;
    server_name [domain] crm.[domain] api.[domain];
    return 301 https://$server_name$request_uri;
}
```

#### HSTS Preload Submission
```bash
# Domain für HSTS Preload List einreichen
# https://hstspreload.org/
# Requirements:
# - Valid certificate
# - Redirect HTTP to HTTPS
# - HSTS on base domain with max-age >= 31536000
# - includeSubDomains directive
# - preload directive
```

### 2. Content Security Policy (CSP)

#### Phase 1: Report-Only Mode
```apache
# CSP Report-Only (Testing Phase)
Header always set Content-Security-Policy-Report-Only "
    default-src 'self';
    script-src 'self' 'unsafe-inline' 'unsafe-eval' 
        https://cdn.jsdelivr.net 
        https://code.jquery.com 
        https://cdnjs.cloudflare.com;
    style-src 'self' 'unsafe-inline' 
        https://fonts.googleapis.com 
        https://cdn.jsdelivr.net;
    font-src 'self' 
        https://fonts.gstatic.com;
    img-src 'self' data: 
        https://images.unsplash.com 
        https://via.placeholder.com;
    connect-src 'self' 
        https://api.[domain];
    frame-src 'none';
    object-src 'none';
    base-uri 'self';
    form-action 'self';
    report-uri /csp-report;
"
```

#### Phase 2: Enforcement Mode
```apache
# CSP Enforcement (Nach Testing)
Header always set Content-Security-Policy "
    default-src 'self';
    script-src 'self' 'nonce-[random]';
    style-src 'self' 'nonce-[random]';
    font-src 'self' https://fonts.gstatic.com;
    img-src 'self' data: https:;
    connect-src 'self' https://api.[domain];
    frame-ancestors 'none';
    form-action 'self';
    base-uri 'self';
    upgrade-insecure-requests;
"
```

### 3. Complete Security Headers Suite

```apache
# Security Headers für Hauptdomain
<IfModule mod_headers.c>
    # HSTS
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    
    # X-Frame-Options
    Header always set X-Frame-Options "DENY"
    
    # X-Content-Type-Options
    Header always set X-Content-Type-Options "nosniff"
    
    # X-XSS-Protection
    Header always set X-XSS-Protection "1; mode=block"
    
    # Referrer-Policy
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    
    # Permissions-Policy
    Header always set Permissions-Policy "
        geolocation=(),
        microphone=(),
        camera=(),
        fullscreen=(self),
        payment=()
    "
    
    # Cross-Origin-Embedder-Policy
    Header always set Cross-Origin-Embedder-Policy "require-corp"
    
    # Cross-Origin-Opener-Policy
    Header always set Cross-Origin-Opener-Policy "same-origin"
    
    # Cross-Origin-Resource-Policy
    Header always set Cross-Origin-Resource-Policy "same-origin"
</IfModule>
```

## 🔗 API-Specific CORS Configuration

### FastAPI CORS Settings

```python
# fastapi_app.py - CORS Middleware
from fastapi.middleware.cors import CORSMiddleware

# Produktions-CORS für API
ALLOWED_ORIGINS = [
    "https://[domain]",
    "https://crm.[domain]",
    "https://www.[domain]"  # falls www subdomain
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH"],
    allow_headers=[
        "Accept",
        "Accept-Language", 
        "Content-Language",
        "Content-Type",
        "Authorization",
        "X-Requested-With"
    ],
    expose_headers=["Content-Range", "X-Total-Count"],
    max_age=86400  # 24 hours
)
```

### Apache CORS für API Subdomain

```apache
# Apache CORS für api.[domain]
<IfModule mod_headers.c>
    # CORS preflight
    <If "%{REQUEST_METHOD} == 'OPTIONS'">
        Header always set Access-Control-Allow-Origin "https://[domain]"
        Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, PATCH, OPTIONS"
        Header always set Access-Control-Allow-Headers "Authorization, Content-Type, Accept, X-Requested-With"
        Header always set Access-Control-Allow-Credentials "true"
        Header always set Access-Control-Max-Age "86400"
    </If>
    
    # CORS für alle anderen requests
    <Else>
        Header always set Access-Control-Allow-Origin "https://[domain]"
        Header always set Access-Control-Allow-Credentials "true"
    </Else>
</IfModule>
```

## 🛡️ Rate Limiting & DDoS Protection

### 1. Apache mod_evasive Configuration

```apache
# mod_evasive Installation & Config
<IfModule mod_evasive24.c>
    DOSHashTableSize    2048
    DOSPageCount        10      # Max requests per page per interval
    DOSPageInterval     1       # Interval for page count
    DOSSiteCount        50      # Max requests per site per interval
    DOSSiteInterval     1       # Interval for site count
    DOSBlockingPeriod   600     # Block time in seconds
    DOSLogDir           /var/log/apache2/evasive
    DOSWhitelist        127.0.0.1
    DOSWhitelist        [Admin IP Address]
</IfModule>
```

### 2. Fail2Ban Configuration

```ini
# /etc/fail2ban/jail.local
[apache-auth]
enabled = true
port = http,https
filter = apache-auth
logpath = /var/log/apache2/error.log
maxretry = 3
bantime = 3600
findtime = 600

[apache-overflows]
enabled = true
port = http,https
filter = apache-overflows
logpath = /var/log/apache2/error.log
maxretry = 2
bantime = 3600

[api-bruteforce]
enabled = true
port = http,https
filter = api-bruteforce
logpath = /var/log/apache2/access.log
maxretry = 10
bantime = 1800
findtime = 300
```

### 3. FastAPI Rate Limiting

```python
# requirements.txt
slowapi==0.1.9
redis==4.5.4

# rate_limit.py
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
import redis

# Redis connection für distributed rate limiting
redis_client = redis.Redis(host='localhost', port=6379, db=0)

# Limiter setup
limiter = Limiter(
    key_func=get_remote_address,
    storage_uri="redis://localhost:6379"
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Rate limiting decorators
@app.get("/api/v1/auth/login")
@limiter.limit("5/minute")  # Max 5 login attempts per minute
async def login(request: Request, credentials: UserCredentials):
    pass

@app.get("/api/v1/users")
@limiter.limit("100/hour")  # Max 100 API calls per hour
async def get_users(request: Request):
    pass
```

## 🔍 SSL/TLS Configuration Hardening

### 1. Apache SSL Hardening

```apache
# ssl.conf - Mozilla Modern Configuration
<IfModule mod_ssl.c>
    # SSL Protocol
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    
    # SSL Cipher Suite (Modern)
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
    
    # SSL Options
    SSLHonorCipherOrder off
    SSLCompression off
    SSLUseStapling on
    SSLStaplingCache "shmcb:logs/stapling-cache(150000)"
    
    # Perfect Forward Secrecy
    SSLSessionTickets off
    
    # OCSP Stapling
    SSLStaplingResponderTimeout 5
    SSLStaplingReturnResponderErrors off
</IfModule>
```

### 2. Nginx SSL Hardening (Alternative)

```nginx
# nginx ssl configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1d;
ssl_session_tickets off;

# OCSP stapling
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=60s;
resolver_timeout 2s;
```

## 📊 Security Testing & Validation

### 1. Automated Security Tests

```bash
#!/bin/bash
# security_test.sh

DOMAIN="[domain]"
API_DOMAIN="api.[domain]" 
CRM_DOMAIN="crm.[domain]"

echo "🔍 Starting Security Tests for $DOMAIN"

# SSL Labs Test
echo "📋 SSL Labs Test..."
curl -s "https://api.ssllabs.com/api/v3/analyze?host=$DOMAIN&publish=off&all=done" | jq '.endpoints[0].grade'

# Security Headers Test
echo "📋 Security Headers Test..."
curl -I "https://$DOMAIN" | grep -E "(Strict-Transport-Security|X-Frame-Options|X-Content-Type-Options|X-XSS-Protection|Content-Security-Policy)"

# HSTS Test
echo "📋 HSTS Test..."
curl -I "https://$DOMAIN" | grep "Strict-Transport-Security"

# API CORS Test  
echo "📋 API CORS Test..."
curl -H "Origin: https://$DOMAIN" -H "Access-Control-Request-Method: GET" -X OPTIONS "https://$API_DOMAIN/api/v1/health"

# Rate Limiting Test
echo "📋 Rate Limiting Test..."
for i in {1..15}; do
  curl -w "%{http_code}\n" -s -o /dev/null "https://$API_DOMAIN/api/v1/health"
done

echo "✅ Security Tests Complete"
```

### 2. Continuous Monitoring

```python
# security_monitor.py - Daily Security Checks
import requests
import json
from datetime import datetime

def check_security_headers(domain):
    """Check for required security headers"""
    response = requests.get(f"https://{domain}")
    headers = response.headers
    
    required_headers = [
        'strict-transport-security',
        'x-frame-options', 
        'x-content-type-options',
        'x-xss-protection'
    ]
    
    missing_headers = [h for h in required_headers if h not in headers]
    
    return {
        'domain': domain,
        'timestamp': datetime.now().isoformat(),
        'missing_headers': missing_headers,
        'hsts_max_age': headers.get('strict-transport-security', 'Not Set')
    }

def check_ssl_grade(domain):
    """Check SSL Labs grade"""
    api_url = f"https://api.ssllabs.com/api/v3/analyze?host={domain}&publish=off&all=done"
    response = requests.get(api_url)
    data = response.json()
    
    if 'endpoints' in data and len(data['endpoints']) > 0:
        return data['endpoints'][0].get('grade', 'Unknown')
    return 'Error'

# Daily security report
domains = ['[domain]', 'crm.[domain]', 'api.[domain]']
report = {
    'date': datetime.now().date().isoformat(),
    'checks': []
}

for domain in domains:
    check_result = {
        'domain': domain,
        'headers': check_security_headers(domain),
        'ssl_grade': check_ssl_grade(domain)
    }
    report['checks'].append(check_result)

# Save report
with open(f'security-report-{report["date"]}.json', 'w') as f:
    json.dump(report, f, indent=2)
```

## 📋 Implementation Checklist

### Phase 1: Basic Headers (Tag 1)
- [ ] HSTS Header implementiert (max-age=31536000)
- [ ] X-Frame-Options: DENY
- [ ] X-Content-Type-Options: nosniff  
- [ ] X-XSS-Protection: 1; mode=block
- [ ] HTTP to HTTPS Redirect aktiv
- [ ] SSL Labs Test durchgeführt

### Phase 2: Advanced Headers (Tag 2-3)
- [ ] Content-Security-Policy implementiert
- [ ] Referrer-Policy konfiguriert
- [ ] Permissions-Policy definiert
- [ ] Cross-Origin Policies gesetzt
- [ ] CSP Reports analysiert und Policy angepasst

### Phase 3: Rate Limiting (Tag 3-4)
- [ ] mod_evasive installiert und konfiguriert
- [ ] Fail2Ban Rules implementiert
- [ ] FastAPI Rate Limiting aktiviert
- [ ] Redis für distributed limiting
- [ ] Rate Limit Testing durchgeführt

### Phase 4: API Security (Tag 4-5)
- [ ] CORS Policy für API implementiert
- [ ] API-spezifische Headers gesetzt
- [ ] JWT Token Hardening
- [ ] API Endpoint Rate Limits
- [ ] API Security Testing

### Phase 5: Monitoring (Tag 5-7)
- [ ] Security Header Monitoring
- [ ] SSL Certificate Monitoring
- [ ] Security Test Automation
- [ ] Alert System für Security Events
- [ ] Weekly Security Reports

## 🎯 Success Metrics

### Target Scores
- **SSL Labs**: A+ Rating
- **Mozilla Observatory**: 90+ Score
- **SecurityHeaders.com**: A+ Rating
- **Lighthouse Security**: 100/100

### Performance Impact
- **Page Load**: < 5% increase
- **API Response**: < 10ms overhead
- **SSL Handshake**: < 100ms additional

**Status**: 📋 Security Hardening Plan Complete | 🔄 Ready for Implementation

**Nächster Schritt**: PHP-FPM & Drupal Hardening