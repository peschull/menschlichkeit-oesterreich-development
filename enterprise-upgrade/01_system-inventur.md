# Enterprise Upgrade - System Inventur

## 📋 Aktuelle Systemkonfiguration (Live CRM System)

### 🌐 Domain & SSL Status

#### Domains & Subdomains
- **Hauptdomain**: [Ihre Domain] ✅ Live
- **CRM Subdomain**: `crm.[domain]` ✅ Funktional
- **API Subdomain**: `api.[domain]` ✅ Funktional
- **Staging**: `staging.[domain]` (empfohlen)

#### SSL/TLS Konfiguration
```bash
# SSL Zertifikat Status prüfen
openssl s_client -connect [domain]:443 -servername [domain] 2>/dev/null | openssl x509 -noout -dates -issuer -subject

# Let's Encrypt Ablauf prüfen
certbot certificates

# SSL Labs Test
https://www.ssllabs.com/ssltest/analyze.html?d=[domain]
```

**Erwartetes Ergebnis**:
- ✅ Let's Encrypt Wildcard Zertifikat
- ✅ TLS 1.3 Support
- ✅ A+ Rating (Ziel nach Hardening)
- ✅ Auto-Renewal aktiv

### 🖥️ Server Environment (Plesk)

#### Server Specifications
```bash
# Server Info sammeln
uname -a
cat /etc/os-release
free -h
df -h
lscpu | head -20
```

**Plesk Version & Configuration**:
```bash
# Plesk Version
plesk version

# PHP Versionen verfügbar
plesk bin php --list

# Apache/Nginx Status
systemctl status apache2
systemctl status nginx
```

#### Port Configuration
**Standard Ports (sollten offen sein)**:
- `80` (HTTP → HTTPS Redirect)
- `443` (HTTPS)
- `22` (SSH - nur für Admin)
- `3306` (MySQL - intern only)
- `8443` (Plesk Panel)

**Security Port Check**:
```bash
# Offene Ports prüfen
netstat -tulpn | grep LISTEN
ss -tulpn | grep LISTEN

# Firewall Status
ufw status
iptables -L
```

### 🐘 PHP & Application Stack

#### PHP Configuration
```bash
# Aktuelle PHP Version
php -v

# PHP-FPM Status
systemctl status php*-fpm

# PHP Konfiguration prüfen
php --ini
php -m | head -20
```

**PHP Extensions (Required)**:
- ✅ `curl`
- ✅ `gd`
- ✅ `mbstring`
- ✅ `mysql`/`pdo_mysql`
- ✅ `xml`
- ✅ `zip`
- ✅ `intl`
- ✅ `opcache`

**Performance Settings (zu überprüfen)**:
```ini
; php.ini optimierungen
memory_limit = 512M
max_execution_time = 300
upload_max_filesize = 64M
post_max_size = 64M
opcache.enable = 1
opcache.memory_consumption = 256
opcache.max_accelerated_files = 20000
```

### 🗃️ Database Configuration

#### MySQL/MariaDB Status
```bash
# Database Version
mysql --version
mysqladmin version

# Database Größe prüfen
mysql -e "SELECT table_schema AS 'Database', 
ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' 
FROM information_schema.tables 
GROUP BY table_schema;"

# Performance Schema
mysql -e "SHOW VARIABLES LIKE 'innodb%';"
```

**Database Optimierungen (geplant)**:
- InnoDB Buffer Pool Size
- Query Cache (falls verfügbar)
- Slow Query Log
- Connection Limits

### 🐳 Docker Environment

#### Container Status
```bash
# Docker Version & Status
docker --version
docker-compose --version
docker ps -a
docker images

# Container Logs
docker-compose logs fastapi
docker-compose logs --tail=100 -f
```

**Container Configuration**:
```yaml
# docker-compose.yml aktuelle Konfiguration
version: '3.8'
services:
  fastapi:
    image: python:3.11-slim
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=mysql://...
      - JWT_SECRET_KEY=...
    volumes:
      - ./app:/code/app
    restart: unless-stopped
```

### 📁 File System & Permissions

#### Drupal Installation
```bash
# Drupal Root verzeichnis
ls -la /var/www/vhosts/[domain]/httpdocs/

# Drupal Version
drush status
drush core:requirements

# File Permissions (Security Critical)
find /var/www/vhosts/[domain]/ -type f -name "*.php" -exec ls -l {} \;
find /var/www/vhosts/[domain]/ -type d -name "sites" -exec ls -la {} \;
```

**Sichere Permissions**:
- `644` für PHP Files
- `755` für Directories
- `444` für settings.php
- `www-data` als Owner

#### CiviCRM Configuration
```bash
# CiviCRM Verzeichnis
ls -la /var/www/vhosts/[domain]/httpdocs/sites/default/files/civicrm/

# CiviCRM Status via Drush
drush civicrm:sql:conf
drush civicrm:flush
```

### 🔐 Security Current State

#### User & Access Management
```bash
# System Users
cat /etc/passwd | grep -E "(plesk|psaadm|www-data)"

# SSH Key Management
ls -la ~/.ssh/
cat ~/.ssh/authorized_keys

# Sudo Access
sudo -l
```

#### Network Security
```bash
# Fail2Ban Status
systemctl status fail2ban
fail2ban-client status

# SELinux/AppArmor
sestatus 2>/dev/null || aa-status 2>/dev/null || echo "Kein MAC System aktiv"

# Cronjobs prüfen
crontab -l
cat /etc/crontab
ls -la /etc/cron.*/*
```

## 📊 Performance Baseline

### 🚀 Current Performance Metrics

#### Website Performance (zu messen)
```bash
# PageSpeed Insights
https://pagespeed.web.dev/analysis?url=https://[domain]

# GTMetrix
https://gtmetrix.com/

# Lighthouse CLI (wenn installiert)
lighthouse https://[domain] --output=json --output-path=baseline-report.json
```

**Baseline Targets**:
- **First Contentful Paint**: < 1.8s
- **Largest Contentful Paint**: < 2.5s
- **Cumulative Layout Shift**: < 0.1
- **Performance Score**: > 90

#### API Performance
```bash
# FastAPI Health Check
curl -w "@curl-format.txt" -s -o /dev/null https://api.[domain]/health

# Response Times
for i in {1..10}; do
  curl -w "%{time_total}\n" -s -o /dev/null https://api.[domain]/api/v1/users/me
  sleep 1
done
```

### 💾 Backup Current State

#### Database Backup
```bash
# Vollständiges DB Backup
mysqldump -u [user] -p[pass] --all-databases > baseline-backup-$(date +%Y%m%d).sql

# CiviCRM spezifisch
mysqldump -u [user] -p[pass] [civicrm_db] > civicrm-backup-$(date +%Y%m%d).sql
```

#### File System Backup
```bash
# Website Files
tar -czf website-backup-$(date +%Y%m%d).tar.gz /var/www/vhosts/[domain]/

# Konfiguration
tar -czf config-backup-$(date +%Y%m%d).tar.gz \
  /etc/apache2/ \
  /etc/nginx/ \
  /etc/php/ \
  /opt/psa/ \
  ~/.bashrc \
  /etc/crontab
```

## 🎯 Upgrade Priorities Matrix

### High Priority (Sofort)
1. **Security Headers**: HSTS, CSP, CSRF Protection
2. **SSL/TLS Hardening**: Perfect Forward Secrecy, OCSP
3. **Database Backup Automation**: Täglich + Offsite
4. **Monitoring Setup**: Uptime, Error Tracking

### Medium Priority (Woche 1-2)
1. **PHP-FPM Optimization**: Memory, Processes, Cache
2. **API Security**: Rate Limiting, JWT Hardening
3. **File Permissions Audit**: Drupal + CiviCRM
4. **CI/CD Pipeline**: Automated Deployments

### Low Priority (Woche 3-4)
1. **Performance Optimization**: Caching, CDN Setup
2. **Log Management**: Centralized Logging, Rotation
3. **Documentation**: Runbooks, Recovery Procedures
4. **Advanced Monitoring**: APM, Custom Metrics

## 📋 System Inventory Checklist

### Server Level
- [ ] OS Version & Updates geprüft
- [ ] Plesk Version & Lizenz validiert  
- [ ] Server Resources (CPU/RAM/Disk) dokumentiert
- [ ] Network Configuration geprüft
- [ ] Firewall Rules dokumentiert
- [ ] SSH Access & Keys validiert

### Application Level
- [ ] PHP Version & Extensions geprüft
- [ ] Drupal Version & Module Status
- [ ] CiviCRM Installation validiert
- [ ] FastAPI Container Status geprüft
- [ ] Database Configuration dokumentiert
- [ ] File Permissions auditiert

### Security Level
- [ ] SSL Zertifikat & Konfiguration geprüft
- [ ] User Access & Sudo Rechte auditiert
- [ ] Fail2Ban & Intrusion Detection Status
- [ ] Backup Procedures getestet
- [ ] Log Files & Rotation geprüft
- [ ] Vulnerability Scan durchgeführt

### Performance Level
- [ ] Website Performance Baseline
- [ ] API Response Times gemessen
- [ ] Database Performance geprüft
- [ ] Server Load & Resources gemessen
- [ ] CDN/Caching Status evaluiert
- [ ] Mobile Performance getestet

**Status**: 📊 System Inventory Template bereit | 🔄 Bereit für Live-System Ausführung

**Nächste Schritte**:
1. Commands auf Live-System ausführen
2. Ergebnisse dokumentieren
3. Prioritäten basierend auf Findings anpassen
4. Upgrade Roadmap finalisieren