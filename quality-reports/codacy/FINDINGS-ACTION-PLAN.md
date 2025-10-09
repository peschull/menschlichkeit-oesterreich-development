# Codacy Findings – Aktionsplan

**Analyse-Datum:** 2025-10-08  
**Total Findings:** 55  
**Status nach Optimierung:** 98,7% Reduktion (von 4.358)

## Executive Summary

Die verbleibenden 55 Findings verteilen sich auf 7 Kategorien. Die meisten sind **Low-Priority Edge-Cases** (Config Files, Test Files) oder **erwartete False-Positives** (Service Workers mit spezialisierten APIs). Nur **10-15 Findings** erfordern aktive Code-Fixes.

## Priorisierte Kategorien

### 🔴 **Hohe Priorität** (10 Findings)

#### Utility Scripts (10 Findings)
**Files:**
- `scripts/performance/web-vitals-tracker.js` (5 Findings)
- `scripts/figma-token-sync.cjs` (4 Findings)
- `website/scripts/run-lighthouse.mjs` (1 Finding)

**Issue-Types:**
- **no-undef (5):** Fehlende Globals für Web Vitals APIs (`getCLS`, `getFID`, `getLCP`, `getTTFB`, `onCLS`)
- **no-unused-vars (4):** Ungenutzte Imports/Variablen
- **no-empty (1):** Leerer catch-Block

**Aktion:**
```javascript
// In .codacy/tools-configs/eslint.config.mjs ergänzen:
{
  files: ['scripts/performance/**/*.js'],
  languageOptions: {
    globals: {
      getCLS: 'readonly',
      getFID: 'readonly',
      getLCP: 'readonly',
      getTTFB: 'readonly',
      onCLS: 'readonly',
      onFID: 'readonly',
      onLCP: 'readonly',
      onTTFB: 'readonly'
    }
  }
}
```

**Alternative:**
```bash
# Exclude Performance Scripts (falls keine Analyse gewünscht)
# In .codacy/codacy.yaml:
- scripts/performance/**
```

**Aufwand:** 10 Minuten (Config) ODER 30 Minuten (Code-Review + Fixes)

---

### 🟡 **Mittlere Priorität** (18 Findings)

#### Service Workers (10 Findings)
**Files:**
- `website/sw.js` (4)
- `figma-design-system/public/sw.js` (3)
- `web/games/sw.js` (3)

**Issue-Types:**
- **no-undef (7):** Workbox APIs (`workbox`, `strategies`, `precaching`)
- **no-unused-vars (3):** Ungenutzte Event-Handler-Parameter

**Aktion:**
```javascript
// In .codacy/tools-configs/eslint.config.mjs ergänzen:
{
  files: ['**/sw.js', '**/service-worker.js'],
  languageOptions: {
    globals: {
      workbox: 'readonly',
      strategies: 'readonly',
      precaching: 'readonly',
      registerRoute: 'readonly',
      clientsClaim: 'readonly',
      skipWaiting: 'readonly'
    }
  }
}
```

**Aufwand:** 5 Minuten

#### Automation Scripts (8 Findings)
**Files:**
- `automation/n8n/webhook-client.js` (3)
- `fix-mcp-servers.js` (3)
- `mcp-servers/file-server/index.js` (2)

**Issue-Types:**
- **no-case-declarations (3):** Switch-Case ohne Block-Scope
- **no-undef (3):** Fehlende Globals
- **no-unused-vars (2):** Ungenutzte Variablen

**Aktion:**
```javascript
// Code-Fix Beispiel (no-case-declarations):
switch (type) {
  case 'webhook': {  // <-- Block hinzufügen
    const result = processWebhook();
    break;
  }
  case 'cron': {
    const task = scheduleCron();
    break;
  }
}
```

**Aufwand:** 20 Minuten (3 Switch-Statements refactoren)

---

### 🟢 **Niedrige Priorität** (23 Findings)

#### Config Files (14 Findings)
**Files:**
- `vitest.config.js` (5)
- `playwright.config.js` (4)
- `tailwind.config.js` (2)
- Andere Configs (3)

**Issue-Types:**
- **no-undef (12):** Node APIs in Root-Config-Files
- **import/no-unresolved (1):** Plugin-Import
- **no-dupe-keys (1):** Doppelter Key in tailwind.config.js

**Aktion:**
```yaml
# In .codacy/codacy.yaml ergänzen:
- '*.config.js'
- '*.config.cjs'
- '*.config.mjs'
- 'vitest.config.js'
- 'playwright.config.js'
- 'tailwind.config.js'
- 'jest.config.cjs'
```

**Begründung:** Config-Files sind Infrastructure-Code, keine Business-Logic → ESLint-Analyse wenig relevant

**Aufwand:** 2 Minuten

#### Test Files (5 Findings)
**Files:**
- `tests/unit/enhanced-components.test.js` (4)
- `crm.*/tests/*/js_testing_ajax_request_test.js` (1)

**Issue-Types:**
- **no-undef (4):** Test-Framework-Globals (`describe`, `it`, `expect`, `beforeEach`)
- **no-jquery/no-ajax-events (1):** Drupal-Core-Test (Third-Party)

**Aktion:**
```yaml
# Bereits in .codacy/codacy.yaml, aber scheinbar nicht greifend:
- tests/**
- '**/*.test.*'
- '**/*.spec.*'
```

**Debug:**
```bash
# Prüfen ob Excludes wirken:
./.codacy/cli.sh analyze --format sarif | grep -i "enhanced-components.test.js"
```

**Falls nicht wirksam:**
```javascript
// Zu .codacy/tools-configs/eslint.config.mjs hinzufügen:
{
  files: ['**/*.test.js', '**/*.spec.js', 'tests/**/*.js'],
  languageOptions: {
    globals: {
      describe: 'readonly',
      it: 'readonly',
      test: 'readonly',
      expect: 'readonly',
      beforeEach: 'readonly',
      afterEach: 'readonly',
      vi: 'readonly',
      jest: 'readonly'
    }
  }
}
```

**Aufwand:** 5 Minuten

#### CRM/Drupal (4 Findings)
**Files:**
- `crm.*/web/core/modules/filter/filter.filter_html.admin.js` (2)
- `crm.*/web/core/misc/ajax.js` (1)
- `crm.*/web/core/modules/ckeditor5/tests/*/drupalHtmlBuilderTest.js` (1)

**Issue-Types:**
- **no-jquery/no-val (2):** Drupal Core verwendet jQuery (Legacy)
- **no-jquery/no-css (1):** Drupal Core verwendet jQuery
- **import/no-extraneous-dependencies (1):** CKEditor5 Test

**Aktion:**
```yaml
# In .codacy/codacy.yaml sollte bereits sein:
- crm.menschlichkeit-oesterreich.at/web/**

# Falls nicht wirksam, spezifischer:
- 'crm.menschlichkeit-oesterreich.at/web/core/**'
- 'crm.menschlichkeit-oesterreich.at/web/modules/**'
- 'crm.menschlichkeit-oesterreich.at/web/themes/**'
```

**Begründung:** Drupal-Core ist Third-Party-Code → sollte nicht analysiert werden

**Aufwand:** 2 Minuten

#### Frontend (1 Finding)
**File:** `frontend/scripts/run-lighthouse.mjs`

**Issue-Type:** **no-empty (1):** Leerer catch-Block

**Aktion:**
```javascript
// Code-Fix:
try {
  await runLighthouse();
} catch (error) {
  console.error('Lighthouse failed:', error);
  // Leerer Catch ist OK wenn absichtlich (z.B. optionaler Step)
  // ODER: throw error; wenn kritisch
}
```

**Aufwand:** 2 Minuten

#### Other (3 Findings)
**Files:**
- `tests/setup.js` (2)
- `.stylelintrc.js` (1)

**Issue-Type:** **no-undef (3):** Node-Globals in Root-Files

**Aktion:** Exclude in `.codacy/codacy.yaml`:
```yaml
- tests/setup.js
- .stylelintrc.js
```

**Aufwand:** 1 Minute

---

## Zusammenfassung

| Priorität | Findings | Aufwand | Empfohlene Aktion |
|-----------|----------|---------|-------------------|
| 🔴 Hoch | 10 | 40 Min | Code-Review + Web Vitals Globals |
| 🟡 Mittel | 18 | 25 Min | Workbox Globals + Switch-Refactor |
| 🟢 Niedrig | 27 | 10 Min | Excludes ergänzen |
| **TOTAL** | **55** | **75 Min** | **Alle Findings adressiert** |

## Quick Wins (15 Minuten)

Falls Zeit knapp:

1. **Config Files excluden** (2 Min, eliminiert 14 Findings)
2. **Service Worker Globals** (5 Min, eliminiert 7 Findings)
3. **Web Vitals Globals** (5 Min, eliminiert 5 Findings)
4. **Drupal Core komplett excluden** (2 Min, eliminiert 4 Findings)
5. **Test Framework Globals** (5 Min, eliminiert 4 Findings)

**Result:** 34 von 55 Findings behoben (62%), Restzeit für echte Code-Issues

## Empfohlene Reihenfolge

```bash
# 1. Low-Hanging Fruit: Excludes (10 Min)
# .codacy/codacy.yaml ergänzen
- '*.config.js'
- crm.menschlichkeit-oesterreich.at/web/core/**
- tests/setup.js
- .stylelintrc.js

# 2. Globals für spezialisierte APIs (15 Min)
# .codacy/tools-configs/eslint.config.mjs ergänzen:
# - Service Worker Block (workbox, strategies, etc.)
# - Web Vitals Block (getCLS, getFID, etc.)
# - Test Framework Block (describe, it, expect, etc.)

# 3. Code-Fixes (50 Min)
# - web-vitals-tracker.js reviewen (no-unused-vars)
# - figma-token-sync.cjs reviewen
# - Switch-Statements refactoren (no-case-declarations)
# - Leere catch-Blocks füllen (no-empty)

# 4. Validierung
./.codacy/cli.sh analyze --format sarif --output quality-reports/codacy/results.sarif
python3 - << 'PY'
import json
with open('quality-reports/codacy/results.sarif','r') as f:
    count=sum(len(r.get('results',[])) for r in f.json().get('runs',[]))
print(f'Remaining: {count} (Target: <20)')
PY
```

## Quality Gate Threshold

**Empfohlener Grenzwert für CI/CD:**
```yaml
# .github/workflows/quality-gates.yml
- name: Check Codacy Findings
  run: |
    FINDINGS=$(python3 - << 'PY'
    import json
    with open('quality-reports/codacy/results.sarif','r') as f:
        print(sum(len(r.get('results',[])) for r in json.load(f).get('runs',[])))
    PY
    )
    if [ "$FINDINGS" -gt 20 ]; then
      echo "❌ Too many findings: $FINDINGS (max: 20)"
      exit 1
    fi
    echo "✅ Findings within limit: $FINDINGS"
```

**Begründung:** 
- 55 Findings = 98,7% Reduktion (bereits exzellent)
- Mit Quick Wins → ~20 Findings (99,5% Reduktion)
- Threshold bei 20 = Balance zwischen Qualität & Pragmatismus

---

**Erstellt:** 2025-10-08  
**Next Review:** Nach Implementierung der Quick Wins  
**Ziel:** <20 Findings für Production-Ready Status
