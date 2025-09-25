# SSL/TLS Production Hardening Implementation

## Übersicht

Implementation von SSL/TLS A+ Rating für alle Subdomains mit automatischer Zertifikatserneuerung und Security Headers.

## 1. SSL/TLS Konfiguration für Plesk

### 1.1 Let's Encrypt Automatisierung

```bash
# Plesk CLI für SSL-Zertifikat-Management
plesk bin site --info menschlichkeit-oesterreich.at
plesk bin certificate --list

# Automatische SSL-Erneuerung für alle Subdomains
plesk bin certificate --create "menschlichkeit-oesterreich.at" \
  --subject-name "menschlichkeit-oesterreich.at" \
  --subject-alternative-name "www.menschlichkeit-oesterreich.at,crm.menschlichkeit-oesterreich.at,api.menschlichkeit-oesterreich.at" \
  --key-size 2048 \
  --auto-renew
```

### 1.2 SSL Labs A+ Konfiguration
```nginx
# /etc/nginx/conf.d/ssl_security.conf
# SSL/TLS Configuration für A+ Rating

# Modern SSL Configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;

# SSL Session Settings
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_session_tickets off;

# OCSP Stapling
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;

# Perfect Forward Secrecy
ssl_dhparam /etc/ssl/certs/dhparam.pem;

# SSL Security Headers
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
```

### 1.3 DH Parameters generieren
```bash
# Sichere DH-Parameter für Perfect Forward Secrecy
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
chmod 644 /etc/ssl/certs/dhparam.pem
```

## 2. Content Security Policy Implementation

### 2.1 CSP Header Konfiguration
```nginx
# Content Security Policy für alle Domains
add_header Content-Security-Policy "
  default-src 'self';
  script-src 'self' 'unsafe-inline' 'unsafe-eval' 
    https://js.stripe.com 
    https://www.google-analytics.com 
    https://www.googletagmanager.com;
  style-src 'self' 'unsafe-inline' 
    https://fonts.googleapis.com;
  font-src 'self' 
    https://fonts.gstatic.com;
  img-src 'self' data: 
    https://www.google-analytics.com 
    https://stats.g.doubleclick.net;
  connect-src 'self' 
    https://api.stripe.com 
    https://api.menschlichkeit-oesterreich.at;
  frame-src 'self' 
    https://js.stripe.com;
  object-src 'none';
  base-uri 'self';
  form-action 'self';
  upgrade-insecure-requests;
" always;
```

### 2.2 Domain-spezifische Konfigurationen
```nginx
# Main Domain - menschlichkeit-oesterreich.at
server {
    listen 443 ssl http2;
    server_name menschlichkeit-oesterreich.at www.menschlichkeit-oesterreich.at;
    
    include /etc/nginx/conf.d/ssl_security.conf;
    
    ssl_certificate /opt/psa/var/certificates/scfabcdef12345/cert.pem;
    ssl_certificate_key /opt/psa/var/certificates/scfabcdef12345/privkey.pem;
    
    # HSTS Header
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    
    # Additional Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Force HTTPS Redirect
    if ($scheme = http) {
        return 301 https://$server_name$request_uri;
    }
    
    root /var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs;
    index index.php index.html;
    
    # PHP Configuration
    location ~ \.php$ {
        fastcgi_pass unix:/opt/plesk/php/8.4/var/lib/php/sessions;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        
        # Security Headers für PHP
        fastcgi_hide_header X-Powered-By;
        add_header X-Frame-Options "SAMEORIGIN" always;
    }
}

# CRM Subdomain - crm.menschlichkeit-oesterreich.at
server {
    listen 443 ssl http2;
    server_name crm.menschlichkeit-oesterreich.at;
    
    include /etc/nginx/conf.d/ssl_security.conf;
    
    ssl_certificate /opt/psa/var/certificates/scfabcdef12345/cert.pem;
    ssl_certificate_key /opt/psa/var/certificates/scfabcdef12345/privkey.pem;
    
    root /var/www/vhosts/menschlichkeit-oesterreich.at/crm.menschlichkeit-oesterreich.at;
    
    # Drupal-spezifische Konfiguration
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    # CRM-spezifische Security Headers
    add_header X-Robots-Tag "noindex, nofollow" always;
    add_header Cache-Control "no-store, no-cache, must-revalidate" always;
    
    location ~ \.php$ {
        fastcgi_pass unix:/opt/plesk/php/8.4/var/lib/php/sessions;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}

# API Subdomain - api.menschlichkeit-oesterreich.at  
server {
    listen 443 ssl http2;
    server_name api.menschlichkeit-oesterreich.at;
    
    include /etc/nginx/conf.d/ssl_security.conf;
    
    ssl_certificate /opt/psa/var/certificates/scfabcdef12345/cert.pem;
    ssl_certificate_key /opt/psa/var/certificates/scfabcdef12345/privkey.pem;
    
    # API Rate Limiting
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
    limit_req zone=api_limit burst=20 nodelay;
    
    # CORS für API
    add_header Access-Control-Allow-Origin "https://menschlichkeit-oesterreich.at" always;
    add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
    add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Requested-With" always;
    add_header Access-Control-Max-Age "86400" always;
    
    # FastAPI Proxy
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeout Settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Health Check Endpoint ohne Rate Limiting
    location /status/health {
        proxy_pass http://127.0.0.1:8000/status/health;
        access_log off;
    }
}
```

## 3. Plesk Panel Konfiguration

### 3.1 SSL/TLS Einstellungen über Plesk GUI
```php
<?php
// Plesk Extension für SSL-Management
// /usr/local/psa/admin/plib/modules/ssl-it-up/ssl-manager.php

class SSLManager {
    public function enableSSLForDomain($domain) {
        $cmd = "plesk bin site --update-ssl $domain -ssl-certificates-location default";
        exec($cmd, $output, $return_var);
        
        if ($return_var === 0) {
            $this->enableHSTS($domain);
            $this->configureSecurityHeaders($domain);
            return true;
        }
        return false;
    }
    
    public function enableHSTS($domain) {
        $nginxConfig = "
        add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains; preload\" always;
        ";
        
        file_put_contents("/var/www/vhosts/$domain/conf/nginx.conf", $nginxConfig, FILE_APPEND);
    }
    
    public function configureSecurityHeaders($domain) {
        $headers = [
            'X-Frame-Options: SAMEORIGIN',
            'X-Content-Type-Options: nosniff', 
            'X-XSS-Protection: 1; mode=block',
            'Referrer-Policy: strict-origin-when-cross-origin'
        ];
        
        foreach ($headers as $header) {
            $cmd = "plesk bin site --update $domain -nginx-directives \"add_header $header always;\"";
            exec($cmd);
        }
    }
}
?>
```

### 3.2 Automatisiertes SSL-Monitoring
```bash
#!/bin/bash
# /opt/psa/admin/bin/ssl-monitor.sh

# SSL Certificate Monitoring Script
check_ssl_expiry() {
    local domain=$1
    local cert_file="/opt/psa/var/certificates/$(plesk bin certificate --list | grep $domain | awk '{print $1}')/cert.pem"
    
    if [ -f "$cert_file" ]; then
        local expiry_date=$(openssl x509 -in "$cert_file" -noout -enddate | cut -d= -f2)
        local expiry_epoch=$(date -d "$expiry_date" +%s)
        local current_epoch=$(date +%s)
        local days_until_expiry=$(( ($expiry_epoch - $current_epoch) / 86400 ))
        
        if [ $days_until_expiry -lt 30 ]; then
            echo "WARNING: SSL certificate for $domain expires in $days_until_expiry days"
            # Send alert email
            echo "SSL Certificate for $domain expires soon" | mail -s "SSL Alert" admin@menschlichkeit-oesterreich.at
        fi
    fi
}

# Check alle Domains
domains=("menschlichkeit-oesterreich.at" "crm.menschlichkeit-oesterreich.at" "api.menschlichkeit-oesterreich.at")

for domain in "${domains[@]}"; do
    check_ssl_expiry $domain
done

# SSL Labs API Check
check_ssl_rating() {
    local domain=$1
    local api_url="https://api.ssllabs.com/api/v3/analyze?host=$domain"
    
    local rating=$(curl -s "$api_url" | jq -r '.endpoints[0].grade')
    
    if [ "$rating" != "A+" ] && [ "$rating" != "A" ]; then
        echo "WARNING: SSL rating for $domain is $rating (expected A+)"
        echo "SSL Rating issue for $domain: $rating" | mail -s "SSL Rating Alert" admin@menschlichkeit-oesterreich.at
    fi
}

# Cronjob: Täglich um 6:00 Uhr prüfen
# 0 6 * * * /opt/psa/admin/bin/ssl-monitor.sh
```

## 4. Deployment und Testing

### 4.1 SSL Configuration Deployment Script
```bash
#!/bin/bash
# deploy-ssl-config.sh

set -e

echo "🔒 Deploying SSL/TLS Configuration..."

# 1. Backup existing configurations
echo "📋 Creating configuration backup..."
cp -r /etc/nginx/conf.d /etc/nginx/conf.d.backup.$(date +%Y%m%d_%H%M%S)

# 2. Deploy SSL security configuration
echo "🔧 Installing SSL security configuration..."
cat > /etc/nginx/conf.d/ssl_security.conf << 'EOF'
# Modern SSL Configuration for A+ Rating
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
ssl_dhparam /etc/ssl/certs/dhparam.pem;
EOF

# 3. Generate DH parameters if not exists
if [ ! -f /etc/ssl/certs/dhparam.pem ]; then
    echo "🔑 Generating DH parameters..."
    openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
    chmod 644 /etc/ssl/certs/dhparam.pem
fi

# 4. Test nginx configuration
echo "✅ Testing nginx configuration..."
nginx -t

if [ $? -eq 0 ]; then
    echo "🔄 Reloading nginx..."
    systemctl reload nginx
    echo "✅ SSL configuration deployed successfully!"
else
    echo "❌ nginx configuration test failed. Rolling back..."
    rm -f /etc/nginx/conf.d/ssl_security.conf
    exit 1
fi

# 5. Install SSL monitoring script
echo "📊 Installing SSL monitoring..."
cp ssl-monitor.sh /opt/psa/admin/bin/ssl-monitor.sh
chmod +x /opt/psa/admin/bin/ssl-monitor.sh

# Add to crontab if not exists
if ! crontab -l | grep -q "ssl-monitor.sh"; then
    (crontab -l 2>/dev/null; echo "0 6 * * * /opt/psa/admin/bin/ssl-monitor.sh") | crontab -
    echo "✅ SSL monitoring cron job installed"
fi

echo "🎉 SSL/TLS hardening deployment completed!"
echo ""
echo "Next steps:"
echo "1. Test SSL configuration: https://www.ssllabs.com/ssltest/"
echo "2. Verify HSTS preload eligibility: https://hstspreload.org/"
echo "3. Check security headers: https://securityheaders.com/"
```

### 4.2 SSL Testing Script
```bash
#!/bin/bash
# test-ssl-config.sh

echo "🧪 Testing SSL/TLS Configuration..."

domains=("menschlichkeit-oesterreich.at" "crm.menschlichkeit-oesterreich.at" "api.menschlichkeit-oesterreich.at")

test_ssl_connection() {
    local domain=$1
    echo "Testing SSL connection to $domain..."
    
    # Test SSL certificate
    echo | openssl s_client -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -noout -dates
    
    # Test TLS version
    local tls_version=$(echo | openssl s_client -servername $domain -connect $domain:443 -tls1_2 2>/dev/null | grep "Protocol" | awk '{print $3}')
    echo "TLS Version: $tls_version"
    
    # Test HSTS header
    local hsts_header=$(curl -s -I https://$domain | grep -i "strict-transport-security")
    if [ -n "$hsts_header" ]; then
        echo "✅ HSTS Header: $hsts_header"
    else
        echo "❌ HSTS Header missing"
    fi
    
    # Test security headers
    echo "Security Headers Check:"
    curl -s -I https://$domain | grep -E "(X-Frame-Options|X-Content-Type-Options|Content-Security-Policy|Referrer-Policy)"
    
    echo "---"
}

# Test all domains
for domain in "${domains[@]}"; do
    test_ssl_connection $domain
done

# SSL Labs API Check (rate limited - use sparingly)
echo "🔍 Checking SSL Labs ratings (this may take a few minutes)..."
for domain in "${domains[@]}"; do
    echo "Checking SSL Labs rating for $domain..."
    curl -s "https://api.ssllabs.com/api/v3/analyze?host=$domain&publish=off&startNew=on&all=done" | jq '.endpoints[0].grade // "Pending"'
done

echo "✅ SSL testing completed!"
```

## 5. Performance Optimierung

### 5.1 HTTP/2 und Compression
```nginx
# HTTP/2 und Gzip Konfiguration
server {
    listen 443 ssl http2;
    
    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;
    
    # Brotli Compression (wenn verfügbar)
    brotli on;
    brotli_comp_level 6;
    brotli_types
        text/plain
        text/css
        application/json
        application/javascript
        text/xml
        application/xml
        application/xml+rss
        text/javascript;
}
```

### 5.2 Cache Headers
```nginx
# Browser Caching
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    add_header Vary "Accept-Encoding";
}

# API Responses - no cache
location /api/ {
    add_header Cache-Control "no-store, no-cache, must-revalidate";
    add_header Pragma "no-cache";
}
```

## 6. Monitoring und Alerting

### 6.1 SSL Certificate Monitoring
```python
#!/usr/bin/env python3
# ssl_certificate_monitor.py

import ssl
import socket
import datetime
import smtplib
from email.mime.text import MIMEText
import requests
import json

class SSLMonitor:
    def __init__(self):
        self.domains = [
            'menschlichkeit-oesterreich.at',
            'crm.menschlichkeit-oesterreich.at', 
            'api.menschlichkeit-oesterreich.at'
        ]
        self.alert_threshold_days = 30
        
    def check_certificate_expiry(self, hostname, port=443):
        """Check SSL certificate expiry date"""
        try:
            context = ssl.create_default_context()
            with socket.create_connection((hostname, port), timeout=10) as sock:
                with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                    cert = ssock.getpeercert()
                    
            # Parse expiry date
            expiry_date = datetime.datetime.strptime(cert['notAfter'], '%b %d %H:%M:%S %Y %Z')
            days_until_expiry = (expiry_date - datetime.datetime.now()).days
            
            return {
                'domain': hostname,
                'expiry_date': expiry_date,
                'days_until_expiry': days_until_expiry,
                'status': 'OK' if days_until_expiry > self.alert_threshold_days else 'WARNING'
            }
            
        except Exception as e:
            return {
                'domain': hostname,
                'error': str(e),
                'status': 'ERROR'
            }
    
    def check_ssl_labs_rating(self, hostname):
        """Check SSL Labs rating"""
        try:
            # Start new assessment
            start_url = f"https://api.ssllabs.com/api/v3/analyze?host={hostname}&startNew=on"
            requests.get(start_url)
            
            # Poll for results
            result_url = f"https://api.ssllabs.com/api/v3/analyze?host={hostname}"
            response = requests.get(result_url)
            data = response.json()
            
            if data.get('status') == 'READY' and data.get('endpoints'):
                grade = data['endpoints'][0].get('grade', 'Unknown')
                return {
                    'domain': hostname,
                    'grade': grade,
                    'status': 'OK' if grade in ['A+', 'A'] else 'WARNING'
                }
            else:
                return {
                    'domain': hostname,
                    'status': 'PENDING'
                }
                
        except Exception as e:
            return {
                'domain': hostname,
                'error': str(e),
                'status': 'ERROR'
            }
    
    def send_alert(self, message):
        """Send email alert"""
        try:
            msg = MIMEText(message)
            msg['Subject'] = 'SSL Certificate Alert - Menschlichkeit Österreich'
            msg['From'] = 'alerts@menschlichkeit-oesterreich.at'
            msg['To'] = 'admin@menschlichkeit-oesterreich.at'
            
            # Configure SMTP settings
            with smtplib.SMTP('localhost') as server:
                server.send_message(msg)
                
        except Exception as e:
            print(f"Failed to send alert: {e}")
    
    def run_monitoring(self):
        """Run complete SSL monitoring"""
        results = []
        alerts = []
        
        for domain in self.domains:
            # Check certificate expiry
            cert_result = self.check_certificate_expiry(domain)
            results.append(cert_result)
            
            if cert_result.get('status') == 'WARNING':
                alerts.append(f"Certificate for {domain} expires in {cert_result['days_until_expiry']} days")
            elif cert_result.get('status') == 'ERROR':
                alerts.append(f"Error checking certificate for {domain}: {cert_result.get('error')}")
        
        # Send alerts if any issues found
        if alerts:
            alert_message = "SSL Certificate Issues Detected:\n\n" + "\n".join(alerts)
            self.send_alert(alert_message)
        
        # Generate status report
        print("SSL Monitoring Report:")
        print("=" * 50)
        for result in results:
            domain = result['domain']
            if 'days_until_expiry' in result:
                print(f"{domain}: Expires in {result['days_until_expiry']} days ({result['status']})")
            else:
                print(f"{domain}: {result.get('error', 'Unknown error')} ({result['status']})")
        
        return results

if __name__ == "__main__":
    monitor = SSLMonitor()
    monitor.run_monitoring()
```

## 7. Implementation Checklist

### 7.1 Pre-Deployment
- [ ] Backup existing nginx configurations
- [ ] Verify Let's Encrypt certificates are active
- [ ] Test SSL configurations in staging environment
- [ ] Prepare rollback procedures

### 7.2 Deployment
- [ ] Deploy SSL security configuration
- [ ] Generate DH parameters
- [ ] Configure domain-specific SSL settings
- [ ] Implement security headers
- [ ] Set up HSTS preload

### 7.3 Post-Deployment
- [ ] Test SSL connections for all domains
- [ ] Verify SSL Labs A+ rating
- [ ] Check security headers with securityheaders.com
- [ ] Install SSL monitoring scripts
- [ ] Configure alerting and notifications

### 7.4 Monitoring
- [ ] Daily SSL certificate expiry checks
- [ ] Weekly SSL Labs rating verification
- [ ] Monthly security header audits
- [ ] Quarterly SSL configuration reviews

## 8. Success Metrics

### 8.1 Technical Metrics
- **SSL Labs Rating:** A+ für alle Domains
- **Certificate Renewal:** Automatisch 30 Tage vor Ablauf
- **HSTS Preload:** Erfolgreich bei hstspreload.org eingereicht
- **Security Headers:** Alle Headers korrekt implementiert
- **Performance:** Keine Verschlechterung der Ladezeiten

### 8.2 Security Metrics  
- **TLS Version:** Nur TLSv1.2 und TLSv1.3 erlaubt
- **Cipher Suites:** Nur sichere Ciphers aktiviert
- **Perfect Forward Secrecy:** Aktiviert mit 2048-bit DH
- **OCSP Stapling:** Funktional für alle Zertifikate
- **HTTP → HTTPS Redirect:** 100% der Requests

### 8.3 Compliance Metrics
- **HSTS Policy:** Max-age ≥ 31536000 (1 Jahr)
- **CSP Policy:** Restriktiv ohne unsafe-eval (wo möglich)
- **Certificate Transparency:** Alle Zertifikate in CT Logs
- **Security Audit:** Keine kritischen Findings

---

**Geschätzter Aufwand:** 2-3 Tage für vollständige Implementation
**Abhängigkeiten:** Plesk Admin-Zugang, DNS-Konfiguration, Let's Encrypt Setup
**Kritischer Pfad:** SSL-Zertifikate → Nginx-Konfiguration → Security Headers → Testing