# 🌐 SUBDOMAIN-ARCHITEKTUR für menschlichkeit-oesterreich.at

## 🎯 **EMPFEHLUNG: Subdomänen BEIBEHALTEN + ERWEITERN**

Basierend auf Ihrer aktuellen Projektstruktur ist eine **saubere Subdomain-Trennung** die beste Lösung!

---

## ✅ **EMPFOHLENE SUBDOMAIN-STRUKTUR:**

### **🏠 Hauptdomain:**

```
menschlichkeit-oesterreich.at
├── Next.js Frontend (Hauptwebsite)
├── Statische Inhalte
└── Public Landing Page
```

### **🔗 API-Subdomain (BEIBEHALTEN):**

```
api.menschlichkeit-oesterreich.at
├── FastAPI Backend (Python)
├── REST/GraphQL Endpoints
├── Datenbank: mo_laravel_api
└── Port: 8001 (intern)
```

### **👥 CRM-Subdomain (BEIBEHALTEN):**

```
crm.menschlichkeit-oosterreich.at
├── CiviCRM + Drupal
├── Mitgliederverwaltung
├── Datenbank: mo_civicrm_data
└── Admin Interface
```

### **🎮 Gaming-Subdomain (NEU ANLEGEN):**

```
games.menschlichkeit-oesterreich.at
├── Educational Web Games
├── Prisma ORM Integration
├── Datenbank: mo_gaming_platform
└── Port: 3000 (intern)
```

---

## 🔧 **PLESK-KONFIGURATION:**

### **1. Bestehende Subdomänen prüfen:**

In Plesk unter **"Websites & Domains"**:

- ✅ `api.menschlichkeit-oesterreich.at` (sollte existieren)
- ✅ `crm.menschlichkeit-oesterreich.at` (sollte existieren)
- ❓ `games.menschlichkeit-oesterreich.at` (neu anlegen)

### **2. Neue Gaming-Subdomain anlegen:**

```
Plesk → Websites & Domains → Add Subdomain
├── Subdomain: games
├── Document root: /httpdocs/web
├── SSL Certificate: ✅ (Let's Encrypt)
└── PHP Version: 8.4.x
```

### **3. Datenbank-Zuordnung pro Subdomain:**

| Subdomain                             | System           | Datenbank            | User           |
| ------------------------------------- | ---------------- | -------------------- | -------------- |
| `menschlichkeit-oesterreich.at`       | Next.js Frontend | -                    | -              |
| `api.menschlichkeit-oesterreich.at`   | FastAPI/Laravel  | `mo_laravel_api`     | `laravel_user` |
| `crm.menschlichkeit-oesterreich.at`   | CiviCRM+Drupal   | `mo_civicrm_data`    | `civicrm_user` |
| `games.menschlichkeit-oesterreich.at` | Web Games        | `mo_gaming_platform` | `gaming_user`  |

---

## 💡 **WARUM Subdomänen verwenden?**

### **✅ VORTEILE:**

- 🔒 **Sicherheit**: Getrennte SSL-Zertifikate
- 🎯 **Klarheit**: Jedes System hat eigene URL
- 🔧 **Wartung**: Separate Updates möglich
- 🚀 **Performance**: Individuelle Caching-Strategien
- 📊 **Analytics**: Getrennte Tracking-Domains
- 🛡️ **Isolation**: Ein Hack betrifft nicht alle Systeme

### **❌ Alternative "Alles auf Hauptdomain":**

```
menschlichkeit-oesterreich.at/api/     → ❌ Komplexere Routing
menschlichkeit-oesterreich.at/crm/     → ❌ SSL-Konflikte möglich
menschlichkeit-oesterreich.at/games/   → ❌ Port-Probleme
```

---

## 🚀 **NÄCHSTE SCHRITTE:**

### **1. In Plesk prüfen welche Subdomänen existieren:**

```
Plesk → Websites & Domains → Übersicht
```

### **2. Fehlende Subdomains anlegen:**

Falls `games.menschlichkeit-oesterreich.at` nicht existiert:

```
Add Subdomain → games → /httpdocs/web → SSL ✅
```

### **3. Datenbanken den Subdomains zuordnen:**

Jede Datenbank wird ihrer entsprechenden Subdomain zugewiesen.

### **4. .env-Files pro Subdomain konfigurieren:**

Nach Datenbank-Setup die Environment-Variablen setzen.

---

## 🎯 **MEINE EMPFEHLUNG:**

**✅ SUBDOMÄNEN BEIBEHALTEN UND ERWEITERN**

Das gibt Ihnen:

- Professionelle Architektur
- Einfache Wartung
- Maximale Flexibilität
- Beste Sicherheit

**Soll ich Ihnen beim Setup der fehlenden `games.menschlichkeit-oesterreich.at` Subdomain helfen?** 🚀
