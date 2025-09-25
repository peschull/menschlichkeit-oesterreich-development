# 🧪 Production Testing Guide

**End-to-End Testing für Menschlichkeit Österreich CRM + API System**

## 📋 **Testing Checklist**

### **Phase 1: Pre-Deployment Validation**

#### **1.1 Local Development Test**
```bash
# Test Docker Environment
cd /d/Arbeitsverzeichniss
docker-compose up -d
curl http://localhost:8080  # Test Drupal
curl http://localhost:8000/health  # Test FastAPI
```

#### **1.2 Scripts Validation**
```bash
# Check deployment scripts syntax
bash -n deployment-scripts/deploy-crm-plesk.sh
bash -n deployment-scripts/deploy-api-plesk.sh
bash -n deployment-scripts/setup-cron-jobs.sh
```

#### **1.3 Configuration Files Check**
- ✅ Environment variables (.env files)
- ✅ Database connection strings
- ✅ JWT secret keys
- ✅ SEPA creditor information
- ✅ Email SMTP settings

---

### **Phase 2: Plesk Deployment Testing**

#### **2.1 Infrastructure Preparation**
```bash
# 1. Create Plesk Subdomains
# - crm.menschlichkeit-oesterreich.at
# - api.menschlichkeit-oesterreich.at

# 2. SSH Access Test
ssh user@menschlichkeit-oesterreich.at
cd httpdocs/
ls -la

# 3. PHP Version Check
php -v  # Should be 8.2+

# 4. Composer Installation Check
composer --version

# 5. Python Environment Check
python3 --version
pip3 --version
```

#### **2.2 CRM Deployment Test**
```bash
# Run CRM deployment script
chmod +x deployment-scripts/deploy-crm-plesk.sh
./deployment-scripts/deploy-crm-plesk.sh

# Expected Output:
# ✅ Database connection established
# ✅ Composer dependencies installed
# ✅ Drupal 10 installed
# ✅ CiviCRM installed and configured
# ✅ Admin user created
# ✅ SSL certificate validated
```

#### **2.3 API Deployment Test**
```bash
# Run API deployment script
chmod +x deployment-scripts/deploy-api-plesk.sh
./deployment-scripts/deploy-api-plesk.sh

# Expected Output:
# ✅ Python virtual environment created
# ✅ FastAPI dependencies installed
# ✅ PHP bridge configured
# ✅ Systemd service created and started
# ✅ SSL certificate validated
```

#### **2.4 Cron Jobs Setup Test**
```bash
# Run cron setup script
chmod +x deployment-scripts/setup-cron-jobs.sh
./deployment-scripts/setup-cron-jobs.sh

# Expected Output:
# ✅ CiviCRM scheduled jobs configured
# ✅ SEPA processing scheduled
# ✅ Log rotation setup
# ✅ Health monitoring activated
```

---

### **Phase 3: API Functionality Testing**

#### **3.1 Health Check Tests**
```bash
# Test API Health
curl -X GET https://api.menschlichkeit-oesterreich.at/health
# Expected: {"status":"healthy","timestamp":"2025-09-22T..."}

# Test CRM Health
curl -I https://crm.menschlichkeit-oesterreich.at
# Expected: HTTP/2 200 OK
```

#### **3.2 Authentication Testing**
```bash
# Test User Registration
curl -X POST https://api.menschlichkeit-oesterreich.at/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Test",
    "last_name": "User", 
    "email": "test@example.com",
    "password": "TestPass123!"
  }'
# Expected: {"access_token":"jwt_token","refresh_token":"refresh_token"}

# Test User Login
curl -X POST https://api.menschlichkeit-oesterreich.at/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPass123!"
  }'
# Expected: {"access_token":"jwt_token","refresh_token":"refresh_token"}
```

#### **3.3 Contact Management Testing**
```bash
# Save JWT token from login response
export JWT_TOKEN="your_jwt_token_here"

# Test Contact Creation
curl -X POST https://api.menschlichkeit-oesterreich.at/contacts/create \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Max",
    "last_name": "Mustermann",
    "email": "max@example.com"
  }'
# Expected: {"contact_id":123,"status":"success"}

# Test Contact Retrieval
curl -X GET https://api.menschlichkeit-oesterreich.at/contacts/123 \
  -H "Authorization: Bearer $JWT_TOKEN"
# Expected: Contact data JSON
```

#### **3.4 Membership Management Testing**
```bash
# Test Membership Creation
curl -X POST https://api.menschlichkeit-oesterreich.at/memberships/create \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "contact_id": 123,
    "membership_type": "Standard",
    "amount": 36.00
  }'
# Expected: {"membership_id":456,"status":"success"}

# Test Membership Retrieval
curl -X GET https://api.menschlichkeit-oesterreich.at/memberships/contact/123 \
  -H "Authorization: Bearer $JWT_TOKEN"
# Expected: Membership data JSON
```

---

### **Phase 4: Website Integration Testing**

#### **4.1 Frontend Authentication Test**
1. **Open**: https://menschlichkeit-oesterreich.at/login.html
2. **Register**: New test account
   - ✅ Form validation works
   - ✅ Password strength indicator
   - ✅ DSGVO consent required
   - ✅ API call successful
3. **Login**: With test account
   - ✅ JWT token stored
   - ✅ Redirect to member-area.html

#### **4.2 Member Area Functionality Test**
1. **Dashboard Access**: https://menschlichkeit-oesterreich.at/member-area.html
   - ✅ Authentication required
   - ✅ User data loaded from API
   - ✅ Statistics displayed
   - ✅ Quick actions work

2. **Profile Management**:
   - ✅ Load profile data from API
   - ✅ Update profile information
   - ✅ DSGVO consent management

3. **Membership Management**:
   - ✅ Display membership status
   - ✅ Upgrade options available
   - ✅ Payment method changes

#### **4.3 SEPA Integration Test**
1. **SEPA Modal**: Click "Upgrade" button
   - ✅ Modal opens with correct data
   - ✅ IBAN validation works
   - ✅ BIC auto-lookup (Austrian banks)
   - ✅ Form validation complete

2. **SEPA Submission**:
   - ✅ API call to create mandate
   - ✅ Mandate data stored in CiviCRM
   - ✅ Success message displayed

---

### **Phase 5: CiviCRM Backend Testing**

#### **5.1 CiviCRM Admin Access**
1. **Access**: https://crm.menschlichkeit-oesterreich.at/civicrm
2. **Login**: Admin credentials from deployment
3. **Verify**:
   - ✅ Dashboard accessible
   - ✅ Contact records created via API
   - ✅ Membership records visible
   - ✅ SEPA mandates stored

#### **5.2 CiviCRM API Testing**
```bash
# Test CiviCRM API directly
curl -X POST https://crm.menschlichkeit-oesterreich.at/civicrm/rest \
  -H "Content-Type: application/json" \
  -d '{
    "action": "get",
    "entity": "Contact",
    "api_key": "your_api_key",
    "key": "your_site_key"
  }'
# Expected: Contact data from CiviCRM
```

#### **5.3 SEPA Extension Testing**
1. **SEPA Settings**: Configure creditor information
2. **Test Mandate**: Create test SEPA mandate
3. **Export**: Test SEPA export functionality
4. **Processing**: Test payment processing

---

### **Phase 6: Cron Jobs & Maintenance Testing**

#### **6.1 Cron Jobs Validation**
```bash
# Check crontab installation
crontab -l
# Expected: 5 CiviCRM cron jobs

# Test manual cron execution
/path/to/crm/private/cron/civicrm-scheduled-jobs.sh
# Expected: Successful execution logged

# Check log files
tail -f /path/to/crm/private/logs/civicrm-cron.log
# Expected: Recent cron execution entries
```

#### **6.2 Health Monitoring Test**
```bash
# Test health check script
/path/to/crm/private/cron/check-cron-health.sh
# Expected: Health status report

# Test email notifications
# Check if cron failure emails are sent correctly
```

---

### **Phase 7: Performance & Security Testing**

#### **7.1 Performance Tests**
```bash
# Load Testing with Apache Bench
ab -n 100 -c 10 https://api.menschlichkeit-oesterreich.at/health

# Response Time Testing
curl -w "@curl-format.txt" -o /dev/null -s https://api.menschlichkeit-oesterreich.at/health

# Database Performance
# Monitor MySQL slow query log during testing
```

#### **7.2 Security Tests**
1. **SSL Certificate Validation**:
   - ✅ Let's Encrypt certificates active
   - ✅ A+ SSL rating
   - ✅ HSTS headers present

2. **API Security**:
   - ✅ JWT token validation
   - ✅ Rate limiting active
   - ✅ CORS properly configured
   - ✅ Input validation working

3. **DSGVO Compliance**:
   - ✅ Data encryption at rest
   - ✅ Secure data transmission
   - ✅ Consent management working
   - ✅ Data export functionality

---

## 🚨 **Troubleshooting Guide**

### **Common Issues & Solutions**

#### **Database Connection Errors**
```bash
# Check MySQL service
systemctl status mysql

# Test database connection
mysql -u username -p -e "SELECT 1"

# Check CiviCRM database
mysql -u username -p civicrm -e "SHOW TABLES"
```

#### **API Service Issues**
```bash
# Check FastAPI service status
systemctl status fastapi-menschlichkeit

# Check service logs
journalctl -u fastapi-menschlichkeit -f

# Test direct Python execution
cd /path/to/api/private
source venv/bin/activate
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

#### **Cron Job Failures**
```bash
# Check cron service
systemctl status cron

# Test cron script manually
bash -x /path/to/crm/private/cron/civicrm-scheduled-jobs.sh

# Check file permissions
ls -la /path/to/crm/private/cron/
```

---

## ✅ **Success Criteria**

### **Minimum Requirements for Production Release**
- [ ] All deployment scripts execute successfully
- [ ] CRM accessible with admin login
- [ ] API health checks pass
- [ ] Website authentication works
- [ ] Member area fully functional
- [ ] SEPA integration operational
- [ ] Cron jobs running without errors
- [ ] SSL certificates valid
- [ ] Performance acceptable (<2s response time)
- [ ] Security tests pass

### **Optional Advanced Testing**
- [ ] Load testing with 100+ concurrent users
- [ ] Backup/restore procedures tested
- [ ] Disaster recovery plan validated
- [ ] Multi-device responsive testing
- [ ] Email notification system tested

---

## 📊 **Test Report Template**

```markdown
# Test Execution Report
Date: 2025-09-22
Environment: Production Plesk Server

## Test Results Summary
- ✅ Deployment: PASSED
- ✅ API Testing: PASSED  
- ✅ Website Integration: PASSED
- ✅ CiviCRM Backend: PASSED
- ✅ Security: PASSED
- ✅ Performance: PASSED

## Issues Found
- None / List issues here

## Recommendations
- Monitor system for 48 hours
- Set up automated health checks
- Schedule regular backups

## Sign-off
Tested by: [Name]
Approved by: [Name]
Production Release: APPROVED
```

---

**🎯 Status: READY FOR PRODUCTION TESTING**