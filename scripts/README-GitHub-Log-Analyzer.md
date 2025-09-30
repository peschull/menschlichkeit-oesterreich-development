# 🚀 GitHub Actions Log Analyzer für menschlichkeit-oesterreich-development

## 📋 **Überblick**

Vollständiges PowerShell-Modul zum automatisierten Download und Meta-Analyse aller GitHub Actions Workflow-Logs für das Repository `menschlichkeit-oesterreich-development`.

## ⚡ **Quick Start**

### **1. GitHub Fine-Grained Token erstellen (Empfohlen)**
1. Gehe zu **https://github.com/settings/personal-access-tokens/fine-grained**
2. Klicke auf **"Generate new token"**
3. **Repository access:** Wähle "Selected repositories" → `menschlichkeit-oesterreich-development`
4. **Repository permissions:**
   - ✅ **Actions: Read** (Workflow logs lesen)
   - ✅ **Contents: Read** (Repository-Inhalte lesen)
   - ✅ **Metadata: Read** (Repository-Metadaten)
5. **Token sofort kopieren** – wird nur einmal angezeigt!
6. Token beginnt mit `github_pat_...`

### **2. PowerShell-Modul importieren**
```powershell
# Modul aus dem scripts-Verzeichnis laden
Import-Module "D:\Arbeitsverzeichniss\scripts\Download-GitHubWorkflowLogs.psm1"
```

### **3. Sicheres Token-Management**

#### **Option A: Direkt als Parameter (Empfohlen)**
```powershell
Download-GitHubWorkflowLogs `
  -GitHubToken "ghp_ABC123xyz456DEIN_TOKEN" `
  -RepoOwner "peschull" `
  -RepoName "menschlichkeit-oesterreich-development" `
  -Branch "main"
```

#### **Option B: Sicherheitsdatei (Beste Praxis)**
```powershell
# 1. Token in separater Datei speichern (secrets/github-token.ps1)
$env:GITHUB_TOKEN = "github_pat_ABC123..."

# 2. Sicherheitsdatei laden
. .\secrets\github-token.ps1

# 3. Modul ohne Token-Parameter ausführen  
Download-GitHubWorkflowLogs
```

#### **Option C: Umgebungsvariable (Session-basiert)**
```powershell
# Token in Umgebungsvariable speichern (nur für diese Session)
$env:GITHUB_TOKEN = "github_pat_ABC123xyz456DEIN_TOKEN"

# Modul ohne Token-Parameter ausführen
Download-GitHubWorkflowLogs -RepoOwner "peschull" -RepoName "menschlichkeit-oesterreich-development"
```

#### **Option C: Benutzerfreundliches Interface**
```powershell
# Interaktives Script (fragt nach Token)
.\scripts\run-log-analysis.ps1
```

---

## 🛠️ **Funktionen**

### **Download-GitHubWorkflowLogs**
Hauptfunktion zum Download aller Workflow-Logs mit erweiterten Features.

```powershell
Download-GitHubWorkflowLogs -GitHubToken "token" -ExtractLogs -MetaAnalysis
```

**Parameter:**
- `GitHubToken` (Required*): Dein GitHub Personal Access Token (oder via $env:GITHUB_TOKEN)
- `RepoOwner`: Repository Owner (Standard: "peschull")
- `RepoName`: Repository Name (Standard: "menschlichkeit-oesterreich-development")
- `Branch`: Branch (Standard: "main")
- `OutputPath`: Ausgabepfad (Standard: `%USERPROFILE%\GitHubLogs\menschlichkeit-oesterreich`)
- `MaxRuns`: Maximale Anzahl Runs (Standard: 50)
- `WorkflowNames`: Spezifische Workflows (Optional)
- `ExtractLogs`: ZIP-Dateien extrahieren
- `MetaAnalysis`: Meta-Analyse durchführen
- `CleanupZips`: ZIP-Dateien nach Extraktion löschen

*Token kann als Parameter oder Umgebungsvariable übergeben werden

### **Invoke-MetaAnalysis**
Erweiterte Analyse der extrahierten Log-Dateien.

**Analysiert:**
- 🚨 Error Patterns (npm ERR!, SyntaxError, etc.)
- ⚠️ Warning Patterns (deprecated, vulnerabilities)
- 🛡️ Security Findings (CVE-*, high severity)
- 📊 Quality Tool Usage (ESLint, PHPStan, pytest)
- 🔄 Workflow Performance & Success Rates

### **Get-WorkflowSummary**
Zeigt alle verfügbaren Workflows im Repository.

```powershell
Get-WorkflowSummary -GitHubToken "token"
```

---

## 📁 **Output-Struktur**

```
%USERPROFILE%\GitHubLogs\menschlichkeit-oesterreich\
├── logs/                              # ZIP-Dateien der Logs
│   ├── CI-CD-Pipeline-a1b2c3d-123456-2025-09-30_15-30-00-success.zip
│   └── Quality-x7y8z9w-789012-2025-09-30_14-20-00-failure.zip
├── extracted/                         # Extrahierte Log-Dateien
│   ├── CI-CD-Pipeline-a1b2c3d-123456/
│   └── Quality-x7y8z9w-789012/
├── analysis/                          # Meta-Analyse Berichte
│   ├── meta-analysis-2025-09-30_16-00-00.json
│   └── meta-analysis-summary-2025-09-30_16-00-00.md
└── download-summary-2025-09-30_16-00-00.json
```

**Datei-Naming-Convention:**
```
{WorkflowName}-{Commit}-{RunID}-{Timestamp}-{Status}.zip
```

---

## 🎯 **Anwendungsbeispiele**

### **Scenario 1: Vollständige Analyse**
```powershell
# Download + Extract + Meta-Analysis + Cleanup
Download-GitHubWorkflowLogs `
    -GitHubToken $env:GITHUB_TOKEN `
    -MaxRuns 30 `
    -ExtractLogs `
    -MetaAnalysis `
    -CleanupZips
```

### **Scenario 2: Spezifischer Workflow**
```powershell
# Nur CI/CD Pipeline Logs
Download-GitHubWorkflowLogs `
    -GitHubToken $env:GITHUB_TOKEN `
    -WorkflowNames @("CI/CD Pipeline - Multi-Technology Stack") `
    -ExtractLogs
```

### **Scenario 3: Quick Check**
```powershell
# Letzten 10 Runs für schnelle Analyse
Download-GitHubWorkflowLogs `
    -GitHubToken $env:GITHUB_TOKEN `
    -MaxRuns 10 `
    -MetaAnalysis
```

### **Scenario 4: Bulk Download ohne Analyse**
```powershell
# Alle Logs der letzten 100 Runs nur downloaden
Download-GitHubWorkflowLogs `
    -GitHubToken $env:GITHUB_TOKEN `
    -MaxRuns 100
```

---

## 📊 **Meta-Analyse Features**

### **Error Pattern Recognition**
- **npm ERR!**: Node.js package installation failures
- **SyntaxError**: Code syntax issues
- **ModuleNotFoundError**: Python import issues  
- **FAILED**: General test/build failures

### **Security Scanning**
- **CVE-*** pattern detection
- **vulnerability** mentions
- **high/critical severity** alerts
- **security audit** results

### **Quality Metrics**
- **ESLint** usage and results
- **PHPStan** static analysis
- **pytest** test coverage
- **Codacy** quality reports

### **Performance Tracking**
- Build times extraction
- Test execution times
- Workflow success rates
- Trend analysis over time

---

## 🔧 **Troubleshooting**

### **🔐 Security Best Practices:**

#### **Token-Sicherheit:**
- ✅ **Fine-grained Tokens verwenden** (repository-spezifisch)
- ✅ **Token in separater Sicherheitsdatei** (secrets/github-token.ps1)
- ✅ **Sicherheitsdatei zu .gitignore hinzufügen**
- ✅ **Minimale Berechtigungen** (nur Actions:Read, Contents:Read, Metadata:Read)
- ✅ **Token regelmäßig erneuern** (alle 90 Tage)
- ✅ **Niemals Token in Code committen**
- ✅ **Token nach Nutzung aus Zwischenablage löschen**

#### **Sichere Token-Verwendung:**
```powershell
# ✅ GUT: Token als Parameter
Download-GitHubWorkflowLogs -GitHubToken "ghp_xxx"

# ✅ BESSER: Umgebungsvariable (Session-basiert)
$env:GITHUB_TOKEN = "ghp_xxx"
Download-GitHubWorkflowLogs

# ❌ SCHLECHT: Token in Script hardcoded
# $token = "ghp_xxx" # Niemals so!
```

### **Common Issues:**

**❌ "401 Unauthorized"**
- Token fehlt oder ungültig
- Lösung: Neuen Token mit `repo` + `workflow` Berechtigungen erstellen

**❌ "403 Rate Limited"**  
- GitHub API Rate Limit erreicht
- Lösung: Warten oder `MaxRuns` reduzieren

**❌ "Could not extract ZIP"**
- Logs sind leer oder beschädigt
- Lösung: `ExtractLogs` Skip und manuell prüfen

**❌ "Access Denied auf Output Path"**
- Keine Schreibberechtigung
- Lösung: `OutputPath` auf writeable Verzeichnis setzen

### **Debug Mode:**
```powershell
# Verbose Output für Debugging
$VerbosePreference = "Continue"
Download-GitHubWorkflowLogs -GitHubToken $env:GITHUB_TOKEN -Verbose
```

---

## 🎊 **Advanced Usage**

### **Batch Processing für Multiple Repositories**
```powershell
$repos = @("repo1", "repo2", "repo3")
foreach ($repo in $repos) {
    Download-GitHubWorkflowLogs -RepoName $repo -GitHubToken $env:GITHUB_TOKEN
}
```

### **Scheduled Analysis mit Windows Task Scheduler**
```powershell
# Täglich um 6:00 Uhr
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\Path\To\run-log-analysis.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At "06:00"
Register-ScheduledTask -TaskName "GitHubLogAnalysis" -Action $action -Trigger $trigger
```

### **Integration mit CI/CD Pipeline**
```yaml
# .github/workflows/log-analysis.yml
- name: Download and Analyze Logs
  run: |
    pwsh -File scripts/run-log-analysis.ps1
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 📈 **Nutzen für menschlichkeit-oesterreich-development**

### **Entwicklungsverbesserung:**
- ✅ **Proaktive Fehlererkennung** durch Pattern Analysis
- ✅ **Performance Monitoring** von Build-Zeiten
- ✅ **Security Alert Tracking** für Dependencies
- ✅ **Quality Trend Analysis** über Zeit

### **DevOps Optimierung:**
- ✅ **CI/CD Pipeline Health** Monitoring
- ✅ **Automated Error Categorization** 
- ✅ **Resource Usage Analytics**
- ✅ **Historical Comparison** für Improvements

### **Compliance & Governance:**
- ✅ **Audit Trail** aller Build-Aktivitäten
- ✅ **Security Compliance** Tracking
- ✅ **Quality Gate** Enforcement
- ✅ **Documentation** für Stakeholders

---

**🚀 Ready für Enterprise-Grade GitHub Actions Log-Analyse bei menschlichkeit-oesterreich-development!**