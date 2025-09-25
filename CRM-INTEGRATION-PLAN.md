# 🎯 CRM Integration - Clean Setup Plan
**Datum:** 22. September 2025

## 🏗️ **Entwicklungsumgebung (Lokal)**

### **1. CRM Backend (crm.menschlichkeit-oesterreich.at/)**
- **Docker-Compose** Setup mit:
  - Drupal 10 + CiviCRM
  - MariaDB Database
  - Nginx Reverse Proxy
  - Redis Cache
  - MailHog (Development Mail)

### **2. API Service (api.menschlichkeit-oesterreich.at/)**
- **FastAPI + Docker** mit:
  - JWT Authentication
  - CiviCRM APIv4 Integration
  - CORS für Frontend
  - Rate Limiting
  - OpenAPI Documentation

### **3. Frontend Integration (website/)**
- Bestehende **Phase 3** Website erweitern:
  - Mitgliederbereich
  - CRM API Integration
  - JWT Token Management
  - DSGVO-konforme Datenverarbeitung

## 🚀 **Production Deployment**

### **Server Requirements (Ubuntu 22.04)**
- PHP 8.2 + Nginx + MariaDB
- Docker für API Service
- Let's Encrypt SSL (A+ Rating)
- Fail2ban Security
- SEPA Integration

### **Domains**
- `crm.menschlichkeit-oesterreich.at` → Drupal CRM
- `api.menschlichkeit-oesterreich.at` → FastAPI Service
- `menschlichkeit-oesterreich.at` → Frontend (bestehend)

## 📋 **Implementation Plan**

1. **✅ Clean Integration Setup** (aktuell)
2. **🔄 CRM Development Environment** 
3. **⏳ API Development Service**
4. **⏳ Production Deployment Scripts**
5. **⏳ Website CRM Integration** 
6. **⏳ End-to-End Testing**

---

## 🔧 **Nächste Schritte**

1. **CRM Docker Environment** in `crm.menschlichkeit-oesterreich.at/`
2. **API Service** in `api.menschlichkeit-oesterreich.at/`
3. **Frontend Integration** mit bestehender Website
4. **Production Deployment** Vorbereitung

**Status:** 🚀 Bereit für saubere Implementation!