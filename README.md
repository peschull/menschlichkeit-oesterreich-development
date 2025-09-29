# Enterprise Development Workspace - Menschlichkeit Österreich

## 🎯 Overview

This is an **Enterprise-grade multi-service development workspace** for Menschlichkeit Österreich, featuring automated quality gates, security scanning, DSGVO compliance, and comprehensive CI/CD integration.

## 🏗️ Architecture

### Service Boundaries
- **Main Website**: `website/` → menschlichkeit-oesterreich.at (WordPress/HTML)
- **API Service**: `api.menschlichkeit-oesterreich.at/` → FastAPI/Python backend
- **CRM System**: `crm.menschlichkeit-oesterreich.at/` → Drupal 10 + CiviCRM
- **Gaming Platform**: `web/` → Educational web games (Prisma + PostgreSQL)
- **Frontend**: `frontend/` → React/TypeScript with design tokens
- **Automation**: `automation/n8n/` → Docker-based workflow automation

### Quality Gates (PR-Blocking)
- ✅ **Security**: 0 open CVE issues (Trivy, Snyk, Codacy)
- ✅ **Maintainability**: ≥85 score; ≤2% duplication per service
- ✅ **Performance**: Lighthouse P≥90, A11y≥90, BP≥95, SEO≥90
- ✅ **DSGVO**: 0 PII in logs; documented consent/retention
- ✅ **Supply Chain**: SBOM generated & verified; SLSA-compliant builds

## 🚀 Quick Start

### Prerequisites
- Node.js ≥18.0.0
- Python ≥3.9
- PHP ≥8.1
- Docker & Docker Compose
- Git

### Setup
```powershell
# Clone and setup workspace
git clone <repository-url>
cd menschlichkeit-oesterreich-development

# Run enterprise setup
./scripts/setup-workspace.ps1

# Start all development services
npm run dev:all
```

## 🔧 Development Commands

```powershell
# Development
npm run dev:all              # Start all services (CRM:8000, API:8001, Frontend:3000, Games:3000)
npm run dev:crm              # Start CRM only
npm run dev:api              # Start API only
npm run dev:frontend         # Start Frontend only

# Quality & Security (MANDATORY before commits)
npm run quality:gates        # Run all quality gates
npm run security:scan        # Security vulnerability scan
npm run compliance:dsgvo     # DSGVO compliance check
npm run performance:lighthouse # Performance audit

# Build & Deploy
./build-pipeline.sh production    # Production build with quality gates
./scripts/safe-deploy.sh --dry-run # Simulate Plesk deployment
npm run deploy:all           # Deploy to Plesk (after dry-run)

# Database & Sync
npx prisma generate          # Generate Prisma client
./scripts/plesk-sync.sh pull # Sync from production (dry-run first!)

# Automation
npm run n8n:start           # Start n8n workflow automation
npm run n8n:webhook         # Test webhook integration
```

## 📊 Quality Reports

All quality metrics are automatically generated in `quality-reports/`:

- `complete-analysis.json` - Comprehensive quality overview
- `codacy-analysis.sarif` - Code quality issues
- `trivy-security.sarif` - Security vulnerabilities
- `dsgvo-check.json` - DSGVO compliance status
- `lighthouse/` - Performance & accessibility reports

## 🛡️ Enterprise Pipeline

The 15-step enterprise pipeline ensures production readiness:

1. **Workspace Sanity** → 2. **Build & Lint** → 3. **Security Layer** → 4. **GDPR/Compliance** → 5. **Testing & Performance** → 6. **UX/UI Audits** → 7. **Observability** → 8. **Backup/Recovery** → 9. **Developer Experience** → 10. **Deployment Simulation** → 11. **Data Synchronization** → 12. **Production Readiness** → 13. **Extended Checks** → 14. **Codacy Finalization** → 15. **Complete Report**

## 🔌 VS Code Integration

### Recommended Extensions
- **GitHub Copilot** + **Copilot Chat** - AI development assistance
- **Codacy** - Real-time code quality
- **SonarLint** - Security & quality linting
- **Trunk.io** - Universal formatter & linter
- **PHP Intelephense** - PHP language support
- **Python** + **Pylance** - Python development
- **Playwright** - E2E testing
- **Docker** - Container management

### Quality Gates in IDE
- **Real-time linting** with Trunk.io integration
- **Security scanning** with Snyk & SonarLint
- **Accessibility checking** with axe DevTools
- **Performance budgets** with Lighthouse integration

## 🔄 CiviCRM & n8n Integration

### Critical Integration Metrics
- **Success Rate**: ≥99% (7-day rolling)
- **Median Latency**: <60s
- **Event Backlog**: <100 items
- **Double Opt-In**: Enforced for DSGVO compliance

### Webhook Security
- **HMAC Signatures** for n8n webhooks
- **IP Allowlisting** with rate limiting
- **JWT Validation** for API bridge
- **Token + Timestamp** for CiviCRM webhooks

## 🏢 Plesk Deployment

### Safe Deployment Process
```powershell
# 1. Dry-run deployment simulation
./scripts/safe-deploy.sh --dry-run

# 2. Review deployment plan
# Check quality-reports/deploy-simulation.md

# 3. Execute deployment (if dry-run passed)
./deployment-scripts/deploy-api-plesk.sh
./deployment-scripts/deploy-crm-plesk.sh
```

### Multi-Subdomain Architecture
- `menschlichkeit-oesterreich.at` - Main website
- `api.menschlichkeit-oesterreich.at` - FastAPI backend
- `crm.menschlichkeit-oesterreich.at` - CiviCRM system

## 📋 Compliance & Governance

### DSGVO Requirements
- ✅ **Data Minimization**: Prisma models use minimal required fields
- ✅ **Consent Management**: CiviCRM handles newsletter subscriptions
- ✅ **Right to Deletion**: Cascade delete patterns implemented
- ✅ **Audit Logging**: PII scrubbing and retention policies

### Security Standards
- ✅ **Zero CVE Policy**: No unpatched vulnerabilities
- ✅ **Secret Management**: No secrets in repository
- ✅ **Transport Security**: TLS ≥1.2, HSTS headers
- ✅ **Content Security**: Strict CSP, XSS protection

## 🔧 Troubleshooting

### Common Issues

**Build Pipeline Fails**
```powershell
# Check individual quality gates
npm run quality:codacy
npm run security:scan
npm run compliance:dsgvo
```

**CiviCRM Integration Issues**
```powershell
# Test n8n webhook
npm run n8n:webhook

# Check integration health
# Review quality-reports/civicrm-integration.md
```

**Performance Issues**
```powershell
# Run Lighthouse audit
npm run performance:lighthouse

# Check resource budgets in lighthouse.config.cjs
```

## 📚 Documentation

- `.github/copilot-instructions.md` - AI agent configuration
- `deployment-scripts/README.md` - Plesk deployment guide
- `automation/n8n/README.md` - Workflow automation setup
- `quality-reports/` - Automated quality analysis

## 🤝 Contributing

1. **Quality Gates**: All PRs must pass quality gates
2. **Security First**: Zero tolerance for CVE issues
3. **DSGVO Compliance**: Privacy by design required
4. **Testing Required**: E2E tests for critical paths
5. **Documentation**: Update relevant docs with changes

## 📞 Support

For enterprise support and configuration assistance, contact the DevOps team or review the comprehensive AI agent instructions in `.github/copilot-instructions.md`.

---

**🚀 Enterprise-ready development with automated quality assurance! 🚀**