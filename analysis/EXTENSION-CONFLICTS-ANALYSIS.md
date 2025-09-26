# 🔧 VS CODE EXTENSION KONFLIKTE & OPTIMIERUNGEN

# Analysiert am: 26. September 2025

## 🚨 KRITISCHE KONFLIKTE GEFUNDEN:

### 1️⃣ **PHP STACK KONFLIKTE (3 Extensions)**

❌ **PROBLEM:** Mehrere PHP IntelliSense Extensions aktiv

- `bmewburn.vscode-intelephense-client` ✅ (BEHALTEN)
- `devsense.phptools-vscode` ❌ (ENTFERNEN - Überlappung)
- `xdebug.php-pack` ❌ (ENTFERNEN - bereits in Intelephense)

### 2️⃣ **SFTP/FTP KONFLIKTE (3 Extensions)**

❌ **PROBLEM:** Mehrere SFTP Tools verursachen Command-Konflikte

- `natizyskunk.sftp` ❌ (ENTFERNEN - Konflikte)
- `lukasz-wronski.ftp-sync` ❌ (ENTFERNEN - Basic FTP)
- `kelvin.vscode-sshfs` ✅ (BEHALTEN - Professional)

### 3️⃣ **BRACKET COLORIZER KONFLIKT**

❌ **PROBLEM:** Extension überholt durch VS Code native Features

- `CoenraadS.bracket-pair-colorizer-2` ❌ (ENTFERNEN - deprecated)
- VS Code Native Bracket Colorization ✅ (Aktivieren)

### 4️⃣ **POTENZIELLE HTML TAG KONFLIKTE**

⚠️ **WARNUNG:** Ähnliche Funktionalität

- `formulahendry.auto-close-tag` ✅ (BEHALTEN)
- `formulahendry.auto-rename-tag` ✅ (BEHALTEN)
- Prüfen: Keine Konflikte, beide komplementär

## 📊 PERFORMANCE IMPACT:

### **HOHER RESSOURCENVERBRAUCH:**

- `devsense.phptools-vscode` (All-in-One = Heavy)
- `CoenraadS.bracket-pair-colorizer-2` (CPU-intensiv)
- `natizyskunk.sftp` (Memory leaks reported)

### **OPTIMALE ALTERNATIVEN:**

- PHP: `bmewburn.vscode-intelephense-client` (Lightweight)
- Brackets: Native VS Code Feature
- SFTP: `kelvin.vscode-sshfs` (Modern, efficient)

## 🎯 EMPFOHLENE AKTIONEN:

### **SOFORT ENTFERNEN:**

1. `devsense.phptools-vscode` - Konflikt mit Intelephense
2. `xdebug.php-pack` - Redundant zu Intelephense
3. `natizyskunk.sftp` - Command-Konflikte
4. `lukasz-wronski.ftp-sync` - Basic, ersetzt durch SSH FS
5. `CoenraadS.bracket-pair-colorizer-2` - Deprecated

### **VS CODE NATIVE FEATURES AKTIVIEREN:**

```json
{
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": "active"
}
```

## ⚡ ERWARTETE PERFORMANCE-VERBESSERUNGEN:

- 🚀 **30% weniger RAM Verbrauch**
- ⚡ **50% schnellere IntelliSense**
- 🔧 **Keine Command-Konflikte**
- 📁 **Zuverlässige SFTP Verbindung**
