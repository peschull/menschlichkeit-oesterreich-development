# AI Sandbox

## Zweck

Sicherer Experimentierbereich für AI-gestützte Code-Generierung und Testing ohne Auswirkungen auf Production-Code.

## Verwendung

### MCP Server Tests
```bash
# Figma MCP: Design Token Experimente
npm run figma:sync -- --output .ai-sandbox/tokens-test.json

# PostgreSQL MCP: Query-Optimierung testen
# Queries in .ai-sandbox/queries/ entwickeln

# GitHub MCP: PR-Template-Experimente
# Drafts in .ai-sandbox/github-templates/
```

### Code-Generierung Workflows

1. **Prototyping**: Neue Features erst in `.ai-sandbox/prototypes/` entwickeln
2. **Validation**: Quality Gates auf Sandbox-Code ausführen
3. **Migration**: Nach erfolgreicher Validierung in Target-Service verschieben

### Struktur

```
.ai-sandbox/
├── prototypes/          # Feature-Prototypen
├── queries/             # DB Query Experimente
├── tokens-test/         # Design Token Tests
├── github-templates/    # PR/Issue Template Drafts
└── reports/            # Quality Gate Test-Reports
```

## Regeln

- ✅ **DO**: Experimentiere frei, teste neue Patterns
- ✅ **DO**: Führe `npm run quality:gates` vor Migration aus
- ❌ **DON'T**: Production Credentials verwenden
- ❌ **DON'T**: PII-Daten in Sandbox speichern

## Cleanup

Automatische Bereinigung nach 30 Tagen:
```bash
npm run sandbox:cleanup
```

## DSGVO Compliance

- Keine echten User-Daten in Sandbox
- Anonymisierte Test-Daten verwenden
- Bei PII-Tests: `api/app/lib/pii_sanitizer.py` nutzen
```
