# MySQL/MariaDB Installation Anleitung

## Option 1: MariaDB Portable Installation

### Download und Setup

1. **MariaDB herunterladen**: https://mariadb.org/download/?t=mariadb&p=mariadb&r=11.4.4&os=windows&cpu=x86_64&pkg=zip
2. **Entpacken nach**: `C:\mariadb-portable\`
3. **PATH erweitern**: Füge `C:\mariadb-portable\bin` zur Umgebungsvariable hinzu

```powershell
# MariaDB Portable Setup Skript
$mariadbPath = "C:\mariadb-portable"
$downloadUrl = "https://archive.mariadb.org/mariadb-11.4.4/winx64-packages/mariadb-11.4.4-winx64.zip"
$zipFile = "$env:TEMP\mariadb.zip"

# Download MariaDB
Write-Host "Lade MariaDB herunter..." -ForegroundColor Green
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile

# Extract to portable directory
Write-Host "Extrahiere MariaDB..." -ForegroundColor Green
Expand-Archive -Path $zipFile -DestinationPath "C:\" -Force

# Rename to consistent path
if (Test-Path "C:\mariadb-11.4.4-winx64") {
    Rename-Item "C:\mariadb-11.4.4-winx64" $mariadbPath -Force
}

# Add to PATH for current session
$env:PATH += ";$mariadbPath\bin"

# Permanently add to PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
if ($currentPath -notlike "*$mariadbPath\bin*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$mariadbPath\bin", "Machine")
}

Write-Host "MariaDB portable installation complete!" -ForegroundColor Green
Write-Host "Restart PowerShell to use mysql command globally" -ForegroundColor Yellow
```

## Option 2: XAMPP Installation (Empfohlen)

### Automatische XAMPP Installation

```powershell
# XAMPP Download und Installation
$xamppUrl = "https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe/download"
$xamppInstaller = "$env:TEMP\xampp-installer.exe"

# Download XAMPP
Write-Host "Lade XAMPP herunter..." -ForegroundColor Green
Invoke-WebRequest -Uri $xamppUrl -OutFile $xamppInstaller

# Silent installation
Write-Host "Installiere XAMPP..." -ForegroundColor Green
Start-Process -FilePath $xamppInstaller -ArgumentList "--mode", "unattended", "--unattendedmodeui", "none" -Wait

# Add MySQL to PATH
$xamppPath = "C:\xampp\mysql\bin"
$env:PATH += ";$xamppPath"

# Permanently add to PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
if ($currentPath -notlike "*$xamppPath*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$xamppPath", "Machine")
}

# Start MySQL service
Write-Host "Starte MySQL Service..." -ForegroundColor Green
& "C:\xampp\mysql\bin\mysqld.exe" --install-manual MySQL
Start-Service MySQL

Write-Host "XAMPP MySQL installation complete!" -ForegroundColor Green
```

## Option 3: MySQL Community Server

### MySQL 8.0 Community Installation

```powershell
# MySQL Community Server Download
$mysqlUrl = "https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.35-winx64.zip"
$mysqlZip = "$env:TEMP\mysql.zip"
$mysqlPath = "C:\mysql"

# Download and extract
Invoke-WebRequest -Uri $mysqlUrl -OutFile $mysqlZip
Expand-Archive -Path $mysqlZip -DestinationPath "C:\" -Force
Rename-Item "C:\mysql-8.0.35-winx64" $mysqlPath -Force

# Add to PATH
$env:PATH += ";$mysqlPath\bin"
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH", "Machine")

# Initialize MySQL
& "$mysqlPath\bin\mysqld.exe" --initialize-insecure --user=mysql --console
```

## Schnelle Lösung: Docker MySQL

```powershell
# Docker MySQL Container
docker run -d `
  --name mysql-dev `
  -p 3306:3306 `
  -e MYSQL_ROOT_PASSWORD=root123 `
  -e MYSQL_DATABASE=mo_wordpress `
  mysql:8.0

# Warten bis Container bereit ist
Start-Sleep 30

# MySQL Client über Docker
function Invoke-MySQLCommand {
    param([string]$Command)
    docker exec -it mysql-dev mysql -u root -proot123 -e $Command
}
```

## Nach der Installation

### MySQL Service starten

```powershell
# XAMPP Control Panel starten
Start-Process "C:\xampp\xampp-control.exe"

# Oder per Command Line
net start MySQL
# oder
Start-Service MySQL
```

### Verbindung testen

```powershell
# Test MySQL Verbindung
mysql -u root -p -e "SELECT VERSION();"

# Datenbank erstellen (Test)
mysql -u root -p -e "CREATE DATABASE test_db;"
mysql -u root -p -e "SHOW DATABASES;"
```

## Empfehlung

Für Entwicklungszwecke empfehle ich **XAMPP**, da es:

- MySQL/MariaDB enthält
- PHP für WordPress beinhaltet
- Apache Webserver mitliefert
- Einfach zu verwalten ist
- Grafisches Control Panel hat

Nach Installation eine der Optionen neu PowerShell starten und `./scripts/database-setup.ps1` erneut ausführen.
