# PHP Development Tools - Local Configuration

Aufgrund von SSL/TLS-Konfigurationsproblemen in der aktuellen PHP-Installation verwenden wir lokale Tools ohne externe Dependencies.

## PHPStan (Lokale Installation)

```powershell
# PHPStan als PHAR herunterladen (falls Internet verfügbar)
Invoke-WebRequest -Uri "https://github.com/phpstan/phpstan/releases/latest/download/phpstan.phar" -OutFile "phpstan.phar"

# PHPStan ausführen
php phpstan.phar analyse --level=8 --configuration=phpstan.neon
```

## PHP-CS-Fixer (Lokale Installation)

```powershell
# PHP-CS-Fixer als PHAR herunterladen (falls Internet verfügbar)
Invoke-WebRequest -Uri "https://cs.symfony.com/download/php-cs-fixer-v3.phar" -OutFile "php-cs-fixer.phar"

# PHP-CS-Fixer ausführen
php php-cs-fixer.phar fix --config=.php-cs-fixer.php
```

## Alternative: Node.js-basierte PHP Tools

Da die PHP-Ecosystem-Tools OpenSSL benötigen, können wir Node.js-basierte Alternativen verwenden:

```powershell
# PHP Linting mit Node.js
npm install --save-dev php-parser
```

## Aktuelle Entwicklungstools Status:

✅ JavaScript/TypeScript: ESLint 9.x + Prettier funktional
✅ Python: Black, Flake8, MyPy funktional (Python 3.13.7)
⚠️ PHP: Konfiguriert, aber OpenSSL-Probleme in der PHP-Installation
✅ Markdown: markdownlint-cli funktional
✅ VS Code Integration: Vollständig konfiguriert

## Empfohlene nächste Schritte:

1. **Für PHP-Entwicklung ohne externe Tools:**
   - Verwende VS Code PHP-Extensions für Syntax-Highlighting
   - Manuelles Code-Review nach PSR-12-Standards
2. **Für vollständige PHP-Tools:**
   - PHP mit OpenSSL-Extension neu installieren
   - Oder: PHP über einen anderen Package Manager (Chocolatey) installieren
