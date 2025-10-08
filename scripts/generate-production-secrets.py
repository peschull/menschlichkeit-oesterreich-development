#!/usr/bin/env python3
"""
generate-production-secrets.py
Secure Password & Key Generator für Menschlichkeit Österreich
Generiert starke, kryptographisch sichere Credentials für alle Services
"""

import secrets
import string
import hashlib
import json
import os
from datetime import datetime
from typing import Dict, List, Tuple

class SecureCredentialGenerator:
    """Generiert sichere Credentials für alle Services"""
    
    def __init__(self):
        self.generated_credentials = {}
        self.generation_timestamp = datetime.now().isoformat()
    
    def generate_password(self, length: int = 24, 
                         include_special: bool = True,
                         exclude_ambiguous: bool = True) -> str:
        """Generiert ein sicheres Passwort"""
        
        # Basis-Zeichen
        chars = string.ascii_letters + string.digits
        
        if include_special:
            # Sichere Sonderzeichen (vermeidet Shell-Probleme)
            safe_special = "!@#$%^&*+=_-"
            chars += safe_special
        
        if exclude_ambiguous:
            # Entferne mehrdeutige Zeichen
            ambiguous = "0O1lI|"
            chars = ''.join(c for c in chars if c not in ambiguous)
        
        # Stelle sicher, dass alle Zeichentypen vertreten sind
        password = []
        
        # Mindestens ein Zeichen aus jeder Kategorie
        password.append(secrets.choice(string.ascii_lowercase))
        password.append(secrets.choice(string.ascii_uppercase))
        password.append(secrets.choice(string.digits))
        
        if include_special:
            password.append(secrets.choice("!@#$%^&*"))
        
        # Fülle auf gewünschte Länge auf
        for _ in range(length - len(password)):
            password.append(secrets.choice(chars))
        
        # Mische die Zeichen
        secrets.SystemRandom().shuffle(password)
        
        return ''.join(password)
    
    def generate_hex_key(self, byte_length: int = 32) -> str:
        """Generiert einen Hex-Key (für JWT, Encryption Keys)"""
        return secrets.token_hex(byte_length)
    
    def generate_api_key(self, length: int = 32) -> str:
        """Generiert einen alphanumerischen API-Key"""
        chars = string.ascii_letters + string.digits
        return ''.join(secrets.choice(chars) for _ in range(length))
    
    def generate_uuid_style(self) -> str:
        """Generiert eine UUID-ähnliche ID"""
        return secrets.token_hex(16)
    
    def generate_database_credentials(self) -> Dict[str, Dict[str, str]]:
        """Generiert alle Datenbank-Credentials"""
        
        databases = {
            # Plesk MariaDB (5 DBs - localhost)
            "plesk_mariadb": {
                "crm": {
                    "user": "svc_crm",
                    "password": self.generate_password(28),
                    "database": "mo_crm",
                    "host": "localhost",
                    "port": "3306"
                },
                "website": {
                    "user": "svc_website", 
                    "password": self.generate_password(28),
                    "database": "mo_website",
                    "host": "localhost",
                    "port": "3306"
                },
                "n8n_local": {
                    "user": "svc_n8n_local",
                    "password": self.generate_password(28),
                    "database": "mo_n8n_local", 
                    "host": "localhost",
                    "port": "3306"
                },
                "analytics": {
                    "user": "svc_analytics",
                    "password": self.generate_password(28),
                    "database": "mo_analytics",
                    "host": "localhost", 
                    "port": "3306"
                },
                "backups": {
                    "user": "svc_backups",
                    "password": self.generate_password(28),
                    "database": "mo_backups",
                    "host": "localhost",
                    "port": "3306"
                }
            },
            
            # External MariaDB (9 DBs)  
            "external_mariadb": {
                "crm_staging": {
                    "user": "svc_crm_staging",
                    "password": self.generate_password(28),
                    "database": "mo_crm_staging",
                    "host": "external-db1.hosting-provider.at",
                    "port": "3306"
                },
                "web_staging": {
                    "user": "svc_web_staging", 
                    "password": self.generate_password(28),
                    "database": "mo_web_staging",
                    "host": "external-db1.hosting-provider.at",
                    "port": "3306"
                },
                "cache": {
                    "user": "svc_cache",
                    "password": self.generate_password(28),
                    "database": "mo_cache",
                    "host": "external-db1.hosting-provider.at",
                    "port": "3306"
                },
                "sessions": {
                    "user": "svc_sessions",
                    "password": self.generate_password(28),
                    "database": "mo_sessions", 
                    "host": "external-db1.hosting-provider.at",
                    "port": "3306"
                },
                "logs": {
                    "user": "svc_logs",
                    "password": self.generate_password(28),
                    "database": "mo_logs",
                    "host": "external-db1.hosting-provider.at", 
                    "port": "3306"
                },
                "queue": {
                    "user": "svc_queue",
                    "password": self.generate_password(28),
                    "database": "mo_queue",
                    "host": "external-db1.hosting-provider.at",
                    "port": "3306"
                },
                "search": {
                    "user": "svc_search",
                    "password": self.generate_password(28),
                    "database": "mo_search",
                    "host": "external-db1.hosting-provider.at",
                    "port": "3306"
                },
                "reports": {
                    "user": "svc_reports", 
                    "password": self.generate_password(28),
                    "database": "mo_reports",
                    "host": "external-db1.hosting-provider.at",
                    "port": "3306"
                },
                "monitoring": {
                    "user": "svc_monitoring",
                    "password": self.generate_password(28),
                    "database": "mo_monitoring",
                    "host": "external-db1.hosting-provider.at",
                    "port": "3306"
                }
            },
            
            # PostgreSQL (3 DBs)
            "postgresql": {
                "games": {
                    "user": "svc_games",
                    "password": self.generate_password(32),
                    "database": "mo_games",
                    "host": "pg-cluster.hosting-provider.at",
                    "port": "5432"
                },
                "analytics_pg": {
                    "user": "svc_analytics_pg",
                    "password": self.generate_password(32),
                    "database": "mo_analytics_pg", 
                    "host": "pg-cluster.hosting-provider.at",
                    "port": "5432"
                },
                "api_data": {
                    "user": "svc_api_data",
                    "password": self.generate_password(32), 
                    "database": "mo_api_data",
                    "host": "pg-cluster.hosting-provider.at",
                    "port": "5432"
                }
            }
        }
        
        return databases
    
    def generate_application_secrets(self) -> Dict[str, str]:
        """Generiert Application-spezifische Secrets"""
        
        return {
            # API & Authentication
            "JWT_SECRET": self.generate_hex_key(32),  # 64 Zeichen
            "API_ENCRYPTION_KEY": self.generate_hex_key(24),  # 48 Zeichen
            "SESSION_SECRET": self.generate_hex_key(16),  # 32 Zeichen
            
            # CiviCRM 
            "CIVICRM_SITE_KEY": self.generate_hex_key(32),  # 64 Zeichen
            "CIVICRM_API_KEY": self.generate_api_key(32),
            
            # n8n
            "N8N_ENCRYPTION_KEY": self.generate_hex_key(20),  # 40 Zeichen
            "N8N_USER_MANAGEMENT_JWT_SECRET": self.generate_hex_key(20),
            "N8N_WEBHOOK_SECRET": self.generate_api_key(48),
            
            # Webhooks
            "WEBHOOK_SECRET_GITHUB": self.generate_hex_key(16),
            "WEBHOOK_SECRET_FIGMA": self.generate_hex_key(16), 
            "WEBHOOK_SECRET_STRIPE": self.generate_hex_key(16),
            
            # Admin Accounts
            "CRM_ADMIN_PASS": self.generate_password(16, include_special=True),
            "N8N_PASSWORD": self.generate_password(24, include_special=True),
            "GRAFANA_ADMIN_PASSWORD": self.generate_password(24, include_special=True),
            
            # Email/SMTP
            "SMTP_SYSTEM_PASS": self.generate_password(16, include_special=False),
            "SMTP_CIVICRM_PASS": self.generate_password(16, include_special=False),
            "SMTP_NOTIFICATIONS_PASS": self.generate_password(16, include_special=False),
            
            # Redis (optional)
            "REDIS_PASSWORD": self.generate_password(32, include_special=False)
        }
    
    def generate_external_service_tokens(self) -> Dict[str, str]:
        """Generiert Tokens für externe Services (Templates/Platzhalter)"""
        
        return {
            # Quality & Security Tools
            "CODACY_TOKEN": f"codacy-{self.generate_uuid_style()}",
            "CODACY_PROJECT_TOKEN": self.generate_api_key(40),
            "SNYK_TOKEN": f"{self.generate_uuid_style()[:8]}-{self.generate_uuid_style()[:4]}-{self.generate_uuid_style()[:4]}-{self.generate_uuid_style()[:4]}-{self.generate_uuid_style()[:12]}",
            "SONAR_TOKEN": f"squ_{self.generate_api_key(40)}",
            
            # Social Media APIs (Platzhalter - müssen manuell konfiguriert werden)
            "LINKEDIN_ACCESS_TOKEN": "AQV8_PLACEHOLDER_MANUAL_SETUP_REQUIRED",
            "X_BEARER_TOKEN": "AAAA_PLACEHOLDER_MANUAL_SETUP_REQUIRED", 
            "FB_PAGE_TOKEN": "EAA_PLACEHOLDER_MANUAL_SETUP_REQUIRED",
            "MASTODON_ACCESS_TOKEN": "PLACEHOLDER_MANUAL_SETUP_REQUIRED",
            
            # Monitoring & Alerts (Platzhalter)
            "SLACK_WEBHOOK": "https://hooks.slack.com/services/PLACEHOLDER/MANUAL/SETUP",
            "DISCORD_WEBHOOK": "https://discord.com/api/webhooks/PLACEHOLDER_MANUAL_SETUP"
        }
    
    def generate_github_secrets_format(self) -> Dict[str, str]:
        """Generiert alle Secrets im GitHub Actions Format"""
        
        secrets = {}
        
        # Database Credentials
        databases = self.generate_database_credentials()
        
        # Plesk MariaDB
        for service, config in databases["plesk_mariadb"].items():
            prefix = f"MO_{service.upper()}_DB"
            secrets[f"{prefix}_HOST"] = config["host"]
            secrets[f"{prefix}_USER"] = config["user"]
            secrets[f"{prefix}_PASS"] = config["password"]
            secrets[f"{prefix}_NAME"] = config["database"]
            secrets[f"{prefix}_PORT"] = config["port"]
        
        # External MariaDB
        secrets["EXTERNAL_DB_HOST"] = "external-db1.hosting-provider.at"
        for service, config in databases["external_mariadb"].items():
            prefix = f"MO_{service.upper()}_DB"
            secrets[f"{prefix}_USER"] = config["user"]
            secrets[f"{prefix}_PASS"] = config["password"]
            secrets[f"{prefix}_NAME"] = config["database"]
        
        # PostgreSQL
        secrets["PG_HOST"] = "pg-cluster.hosting-provider.at"
        secrets["PG_PORT"] = "5432"
        for service, config in databases["postgresql"].items():
            prefix = f"MO_{service.upper()}_DB"
            secrets[f"{prefix}_USER"] = config["user"]
            secrets[f"{prefix}_PASS"] = config["password"]
            secrets[f"{prefix}_NAME"] = config["database"]
        
        # Application Secrets
        app_secrets = self.generate_application_secrets()
        secrets.update(app_secrets)
        
        # External Service Tokens
        external_tokens = self.generate_external_service_tokens()
        secrets.update(external_tokens)
        
        # Infrastructure
        secrets.update({
            "SSH_HOST": "dmpl20230054.digitaloceanspaces.com",
            "SSH_USER": "dmpl20230054", 
            "SSH_PORT": "22",
            
            # Domain & URLs
            "CRM_BASE_URL": "https://crm.menschlichkeit-oesterreich.at",
            "API_BASE_URL": "https://api.menschlichkeit-oesterreich.at",
            "FRONTEND_ORIGINS": "https://menschlichkeit-oesterreich.at,https://games.menschlichkeit-oesterreich.at",
            
            # Email Configuration
            "SMTP_HOST": "mail.menschlichkeit-oesterreich.at",
            "SMTP_PORT": "587",
            "NOTIFICATION_EMAIL": "notifications@menschlichkeit-oesterreich.at",
            "ADMIN_EMAIL": "admin@menschlichkeit-oesterreich.at",
            "SUPPORT_EMAIL": "support@menschlichkeit-oesterreich.at"
        })
        
        return secrets
    
    def export_to_env_file(self, filepath: str = ".env.production.generated"):
        """Exportiert alle Secrets als .env-Datei"""
        
        secrets = self.generate_github_secrets_format()
        
        with open(filepath, 'w') as f:
            f.write(f"# Auto-generated Production Secrets\n")
            f.write(f"# Generated: {self.generation_timestamp}\n")
            f.write(f"# Total Secrets: {len(secrets)}\n\n")
            
            # Kategorisierte Ausgabe
            categories = {
                "Infrastructure & SSH": ["SSH_", "HOST", "PORT", "URL"],
                "Database Credentials": ["_DB_", "PG_", "EXTERNAL_"],
                "Application Secrets": ["JWT_", "API_", "SESSION_", "ENCRYPTION"],
                "CRM & CiviCRM": ["CRM_", "CIVICRM_"],
                "n8n & Automation": ["N8N_"],
                "Webhooks & Communication": ["WEBHOOK_", "SMTP_", "EMAIL"],
                "External Services": ["CODACY_", "SNYK_", "SONAR_", "SLACK_", "LINKEDIN_"]
            }
            
            for category, patterns in categories.items():
                f.write(f"# {category}\n")
                
                category_secrets = {k: v for k, v in secrets.items() 
                                  if any(pattern in k for pattern in patterns)}
                
                for key, value in sorted(category_secrets.items()):
                    f.write(f"{key}={value}\n")
                
                f.write("\n")
        
        print(f"✅ Secrets exported to: {filepath}")
        print(f"📊 Total secrets: {len(secrets)}")
    
    def export_to_json(self, filepath: str = "secrets.production.json"):
        """Exportiert strukturierte Secrets als JSON"""
        
        data = {
            "metadata": {
                "generated_at": self.generation_timestamp,
                "generator_version": "1.0.0",
                "total_secrets": 0
            },
            "databases": self.generate_database_credentials(),
            "application_secrets": self.generate_application_secrets(),
            "external_tokens": self.generate_external_service_tokens(),
            "github_secrets": self.generate_github_secrets_format()
        }
        
        data["metadata"]["total_secrets"] = len(data["github_secrets"])
        
        with open(filepath, 'w') as f:
            json.dump(data, f, indent=2, sort_keys=True)
        
        print(f"✅ Structured secrets exported to: {filepath}")
    
    def print_summary(self):
        """Druckt eine Zusammenfassung der generierten Secrets"""
        
        secrets = self.generate_github_secrets_format()
        databases = self.generate_database_credentials()
        
        print("\n🔐 Generated Secrets Summary")
        print("=" * 50)
        print(f"📅 Generated: {self.generation_timestamp}")
        print(f"📊 Total GitHub Secrets: {len(secrets)}")
        print(f"🗄️ Total Databases: {sum(len(db_group) for db_group in databases.values())}")
        print("\n📂 Database Breakdown:")
        print(f"   • Plesk MariaDB: {len(databases['plesk_mariadb'])} DBs")
        print(f"   • External MariaDB: {len(databases['external_mariadb'])} DBs") 
        print(f"   • PostgreSQL: {len(databases['postgresql'])} DBs")
        
        print("\n🔑 Secret Categories:")
        categories = {
            "Database": len([k for k in secrets.keys() if "_DB_" in k]),
            "Application": len([k for k in secrets.keys() if any(x in k for x in ["JWT_", "API_", "SESSION_"])]),
            "CiviCRM": len([k for k in secrets.keys() if "CIVICRM_" in k or "CRM_" in k]),
            "Infrastructure": len([k for k in secrets.keys() if any(x in k for x in ["SSH_", "HOST", "PORT"])]),
            "External Tools": len([k for k in secrets.keys() if any(x in k for x in ["CODACY_", "SNYK_", "SLACK_"])])
        }
        
        for category, count in categories.items():
            print(f"   • {category}: {count} secrets")

def main():
    """Hauptfunktion"""
    
    print("🔐 Secure Credential Generator für Menschlichkeit Österreich")
    print("=" * 60)
    
    generator = SecureCredentialGenerator()
    
    # Exportiere in verschiedene Formate 
    generator.export_to_env_file()
    generator.export_to_json()
    generator.print_summary()
    
    print("\n⚠️  SECURITY WARNINGS:")
    print("1. Die generierten Dateien enthalten ECHTE Produktions-Secrets")
    print("2. Niemals in Git committen - .gitignore prüfen!")
    print("3. Nach dem Upload in GitHub Secrets lokale Dateien löschen")
    print("4. Externe Service-Token müssen manuell konfiguriert werden")
    
    print("\n📝 Next Steps:")
    print("1. Prüfe .env.production.generated und secrets.production.json")
    print("2. Lade Secrets in GitHub: ./setup-github-secrets.ps1")
    print("3. Konfiguriere externe Services (Codacy, Slack, etc.)")
    print("4. Lösche lokale Secret-Dateien sicher")

if __name__ == "__main__":
    main()