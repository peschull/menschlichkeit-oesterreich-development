# 🐞 GITHUB CODESPACE - COMPLETE DEBUGGING SETUP

## 📋 DEBUGGING CONFIGURATION ANALYSIS

**Target:** GitHub Codespace Multi-Service Debugging
**Components:** Frontend, API, CRM, n8n, Tests, Quality Gates
**Status:** 🔧 Debug Configuration Required

---

## 🚀 **CODESPACE DEBUG ENHANCEMENT**

### **Current Debug Capabilities:**
```jsonc
// .vscode/launch.json - 6 Individual + 3 Compound Configurations
{
  "configurations": [
    "🚀 Debug: Frontend (Vite)",     // React/TypeScript debugging
    "🐍 Debug: API (FastAPI)",       // Python API debugging
    "🏗️ Debug: Build Pipeline",      // Shell script debugging
    "🔄 Debug: n8n Workflow",        // Automation debugging
    "🧪 Debug: Playwright Tests",    // E2E test debugging
    "🔍 Debug: Quality Gates"        // Quality analysis debugging
  ]
}
```

### **🔧 Missing Codespace-Specific Debug Configurations:**

1. **🐳 Container Debug Support**
2. **🗄️ Database Connection Debugging**
3. **🔐 SSH/Plesk Server Debugging**
4. **📱 CRM (CiviCRM/Drupal) Debugging**
5. **🌐 Multi-Port Service Debugging**

---

## 🛠️ **ENHANCED DEBUG CONFIGURATIONS**

### **1. Codespace Container Debugging**
```json
{
  "name": "🐳 Debug: Codespace Container",
  "type": "node",
  "request": "attach",
  "port": 9229,
  "address": "localhost",
  "localRoot": "${workspaceFolder}",
  "remoteRoot": "/workspaces/menschlichkeit-oesterreich-development",
  "protocol": "inspector",
  "restart": true
}
```

### **2. Database Connection Debugging**
```json
{
  "name": "🗄️ Debug: Database Connections",
  "type": "debugpy",
  "request": "launch",
  "program": "${workspaceFolder}/scripts/debug-database-connections.py",
  "console": "integratedTerminal",
  "env": {
    "DB_HOST": "localhost",
    "LARAVEL_DB_PASS": "${secret:LARAVEL_DB_PASS}",
    "CIVICRM_DB_PASS": "${secret:CIVICRM_DB_PASS}"
  }
}
```

### **3. CRM Debug Configuration**
```json
{
  "name": "🏥 Debug: CRM (CiviCRM)",
  "type": "php",
  "request": "launch",
  "program": "${workspaceFolder}/crm.menschlichkeit-oesterreich.at/httpdocs/index.php",
  "cwd": "${workspaceFolder}/crm.menschlichkeit-oesterreich.at",
  "port": 9003,
  "env": {
    "XDEBUG_MODE": "debug",
    "XDEBUG_SESSION": "vscode"
  }
}
```

### **4. SSH/Server Connection Debug**
```json
{
  "name": "🔐 Debug: SSH/Plesk Connection",
  "type": "bashdb",
  "request": "launch",
  "program": "${workspaceFolder}/.devcontainer/post-start.sh",
  "env": {
    "SSH_PRIVATE_KEY": "${secret:SSH_PRIVATE_KEY}",
    "PLESK_HOST": "${secret:PLESK_HOST}",
    "DEBUG": "true"
  }
}
```

### **5. Multi-Service Health Debug**
```json
{
  "name": "🌐 Debug: Service Health Monitor",
  "type": "node",
  "request": "launch",
  "program": "${workspaceFolder}/scripts/service-health-monitor.js",
  "env": {
    "SERVICES": "frontend:3000,api:8001,crm:8000,n8n:5678",
    "DEBUG": "service:*"
  }
}
```

---

## 🔍 **CODESPACE-SPECIFIC DEBUGGING TOOLS**

### **A. Service Discovery & Health**
```javascript
// scripts/service-health-monitor.js
const services = [
  { name: 'Frontend', port: 3000, path: '/' },
  { name: 'API', port: 8001, path: '/docs' },
  { name: 'CRM', port: 8000, path: '/' },
  { name: 'n8n', port: 5678, path: '/healthz' }
];

async function debugServices() {
  for (const service of services) {
    const url = `https://${process.env.CODESPACE_NAME}-${service.port}.preview.app.github.dev${service.path}`;
    console.log(`🔍 Testing ${service.name}: ${url}`);
    // Health check implementation
  }
}
```

### **B. Database Connection Tester**
```python
# scripts/debug-database-connections.py
import psycopg2
import mysql.connector
import os

def test_databases():
    # Laravel API Database
    try:
        conn = psycopg2.connect(
            host="localhost",
            database="mo_laravel_api_dev",
            user="laravel_dev",
            password=os.getenv("LARAVEL_DB_PASS")
        )
        print("✅ Laravel DB: Connected")
    except Exception as e:
        print(f"❌ Laravel DB: {e}")

    # CiviCRM Database
    try:
        conn = mysql.connector.connect(
            host="localhost",
            database="mo_civicrm_dev",
            user="civicrm_dev",
            password=os.getenv("CIVICRM_DB_PASS")
        )
        print("✅ CiviCRM DB: Connected")
    except Exception as e:
        print(f"❌ CiviCRM DB: {e}")
```

### **C. Codespace Environment Inspector**
```bash
#!/bin/bash
# scripts/debug-codespace-env.sh

echo "🔍 CODESPACE ENVIRONMENT DEBUG"
echo "=============================="

echo "📍 Location Info:"
echo "  CODESPACE_NAME: $CODESPACE_NAME"
echo "  GITHUB_USER: $GITHUB_USER"
echo "  WORKSPACE: $PWD"

echo "🌐 Network Info:"
for port in 3000 3001 5678 8000 8001 8080; do
    url="https://$CODESPACE_NAME-$port.preview.app.github.dev"
    echo "  Port $port → $url"
done

echo "🔐 Secrets Status:"
secrets=("SSH_PRIVATE_KEY" "PLESK_HOST" "LARAVEL_DB_PASS" "CIVICRM_DB_PASS" "CODACY_API_TOKEN")
for secret in "${secrets[@]}"; do
    if [ -n "${!secret}" ]; then
        echo "  ✅ $secret: Available"
    else
        echo "  ❌ $secret: Missing"
    fi
done
```

---

## 🧪 **DEBUG COMPOUND CONFIGURATIONS**

### **🚀 Complete Codespace Debug Suite**
```json
{
  "name": "🐳 Debug: Complete Codespace",
  "configurations": [
    "🐳 Debug: Codespace Container",
    "🗄️ Debug: Database Connections",
    "🌐 Debug: Service Health Monitor",
    "🚀 Debug: Frontend (Vite)",
    "🐍 Debug: API (FastAPI)",
    "🏥 Debug: CRM (CiviCRM)"
  ],
  "stopAll": true
}
```

### **🔧 Infrastructure Debug**
```json
{
  "name": "🔧 Debug: Infrastructure",
  "configurations": [
    "🗄️ Debug: Database Connections",
    "🔐 Debug: SSH/Plesk Connection",
    "🌐 Debug: Service Health Monitor"
  ]
}
```

---

## 🎯 **CODESPACE DEBUG WORKFLOW**

### **1. Environment Setup Debug**
```bash
# In Codespace Terminal:
npm run codespace:debug-setup
```

### **2. Service-by-Service Debug**
```bash
# Debug individual services:
npm run debug:frontend    # Port 3000
npm run debug:api        # Port 8001
npm run debug:crm        # Port 8000
npm run debug:n8n        # Port 5678
```

### **3. Full Stack Debug Session**
```bash
# VS Code Command Palette:
> Debug: Select and Start Debugging
> "🐳 Debug: Complete Codespace"
```

### **4. Health Check Debug**
```bash
# Monitor all services:
npm run debug:health-monitor
```

---

## 📊 **DEBUG MONITORING DASHBOARD**

### **Real-time Service Status:**
```
🟢 Frontend (3000): https://CODESPACE-3000-xxx.preview.app.github.dev
🟢 API (8001):      https://CODESPACE-8001-xxx.preview.app.github.dev
🟢 CRM (8000):      https://CODESPACE-8000-xxx.preview.app.github.dev
🟢 n8n (5678):      https://CODESPACE-5678-xxx.preview.app.github.dev
🟡 Database:        Local connections checking...
🔐 SSH Access:      Plesk server connectivity test
```

---

## 🔗 **DEBUG INTEGRATION POINTS**

### **A. VS Code Integration**
- **Breakpoints:** Multi-language support (JS/TS, Python, PHP)
- **Watch Variables:** Environment variables, service states
- **Debug Console:** Multi-service log aggregation
- **Terminal Integration:** Service-specific debugging

### **B. Codespace Integration**
- **Port Forwarding:** Automatic HTTPS URLs
- **GitHub Secrets:** Secure credential access
- **Container Access:** Direct container debugging
- **Multi-Service:** Parallel debugging sessions

### **C. Quality Integration**
- **Real-time Linting:** ESLint, PHPStan, Pylint
- **Debug Logging:** Structured debug output
- **Performance Monitoring:** Service response times
- **Error Tracking:** Centralized error collection

---

## 🚀 **NEXT STEPS: COMPLETE DEBUG SETUP**

1. **Enhanced launch.json** - Add Codespace-specific configurations
2. **Debug Scripts** - Create health monitoring and connection testing
3. **NPM Scripts** - Add debug commands for each service
4. **Documentation** - Team debugging guidelines
5. **Testing** - Validate debug setup in actual Codespace

**🎯 GOAL:** Complete debugging ecosystem for Austrian NGO multi-service platform in GitHub Codespace environment.
