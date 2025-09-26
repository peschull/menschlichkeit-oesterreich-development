# 🚀 SSH-KEY SETUP für SICHERE PLESK-VERBINDUNG

## 🔐 **SSH-Schlüssel erstellen (EMPFOHLEN)**

### **1. SSH-Key generieren (falls noch nicht vorhanden):**

```powershell
# Windows PowerShell (oder Git Bash)
ssh-keygen -t rsa -b 4096 -C "peter@menschlichkeit-oesterreich.at" -f ~/.ssh/plesk_key
```

### **2. Öffentlichen Schlüssel zu Plesk hinzufügen:**

```powershell
# Öffentlichen Schlüssel anzeigen
Get-Content ~/.ssh/plesk_key.pub
```

**In Plesk Panel:**

1. `Websites & Domains` → `Web Hosting Access`
2. `SSH Access` → `SSH Keys`
3. `Add SSH Key` → Öffentlichen Schlüssel einfügen

### **3. SFTP-Config mit SSH-Key erweitern:**

```json
{
  "protocol": "sftp",
  "host": "digimagical.com",
  "port": 22,
  "username": "dmpl20230054",
  "privateKeyPath": "C:\\Users\\YourUser\\.ssh\\plesk_key",
  "passphrase": "your-key-passphrase-if-set",
  "remotePath": "/var/www/vhosts/menschlichkeit-oesterreich.at"
}
```

---

## 🛠️ **AUTOMATISCHES DEPLOYMENT-SCRIPT**

### **PowerShell Deployment Automation:**

```powershell
# deployment-sync.ps1
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("api", "crm", "games", "main", "all")]
    [string]$Target = "all",

    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $false
)

$Targets = @{
    "api" = @{
        Local = "api.menschlichkeit-oesterreich.at"
        Remote = "/var/www/vhosts/menschlichkeit-oesterreich.at/subdomains/api/httpdocs"
        Description = "FastAPI Backend"
    }
    "crm" = @{
        Local = "crm.menschlichkeit-oesterreich.at"
        Remote = "/var/www/vhosts/menschlichkeit-oesterreich.at/subdomains/crm/httpdocs"
        Description = "CiviCRM + Drupal"
    }
    "games" = @{
        Local = "web"
        Remote = "/var/www/vhosts/menschlichkeit-oesterreich.at/subdomains/games/httpdocs"
        Description = "Web Games Platform"
    }
    "main" = @{
        Local = "frontend/dist"
        Remote = "/var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs"
        Description = "Next.js Frontend"
    }
}

function Deploy-Target {
    param($TargetName, $Config)

    Write-Host "🚀 Deploying $($Config.Description)..." -ForegroundColor Cyan
    Write-Host "   📁 $($Config.Local) → $($Config.Remote)" -ForegroundColor Gray

    if ($DryRun) {
        Write-Host "   🔍 DRY RUN - Würde synchronisieren:" -ForegroundColor Yellow
        # rsync --dry-run simulation
        return
    }

    # Actual SFTP sync command (using VS Code SFTP or custom tool)
    code --command "sftp.sync.localToRemote" --args $Config.Local

    Write-Host "   ✅ $TargetName deployment completed!" -ForegroundColor Green
}

# Main execution
if ($Target -eq "all") {
    foreach ($t in $Targets.Keys) {
        Deploy-Target $t $Targets[$t]
    }
} else {
    Deploy-Target $Target $Targets[$Target]
}
```

---

## 🔧 **ERWEITERTE VS CODE SFTP BEFEHLE**

### **Command Palette Shortcuts:**

```
Ctrl+Shift+P → "SFTP: Sync Local → Remote"
Ctrl+Shift+P → "SFTP: Upload Folder"
Ctrl+Shift+P → "SFTP: Download Folder"
Ctrl+Shift+P → "SFTP: Diff with Remote"
```

### **Workspace-spezifische Tasks (.vscode/tasks.json):**

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Deploy API",
      "type": "shell",
      "command": "code",
      "args": ["--command", "sftp.sync.localToRemote"],
      "group": "build",
      "options": {
        "cwd": "${workspaceFolder}/api.menschlichkeit-oesterreich.at"
      }
    },
    {
      "label": "Deploy CRM",
      "type": "shell",
      "command": "code",
      "args": ["--command", "sftp.sync.localToRemote"],
      "group": "build",
      "options": {
        "cwd": "${workspaceFolder}/crm.menschlichkeit-oesterreich.at"
      }
    },
    {
      "label": "Deploy Games",
      "type": "shell",
      "command": "code",
      "args": ["--command", "sftp.sync.localToRemote"],
      "group": "build",
      "options": {
        "cwd": "${workspaceFolder}/web"
      }
    }
  ]
}
```

---

## 🎯 **DEPLOYMENT WORKFLOW**

### **Empfohlener Workflow:**

1. **Entwicklung lokal**
2. **Git commit & push**
3. **VS Code SFTP sync** für sofortiges Testing
4. **GitHub Actions** für Production Deployment

### **Sicherheitshinweise:**

- ✅ SSH-Keys statt Passwörter verwenden
- ✅ `.env` Dateien nie mit echten Credentials committen
- ✅ Separate Deployment-Keys für CI/CD
- ✅ Backup vor größeren Deployments

---

**Soll ich Ihnen beim SSH-Key Setup oder beim Erstellen der automatischen Deployment-Scripts helfen?** 🔐🚀
