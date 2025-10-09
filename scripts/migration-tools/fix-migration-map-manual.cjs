#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const mapFile = '.github/prompts/MIGRATION_MAP.json';
const map = JSON.parse(fs.readFileSync(mapFile, 'utf8'));

// Manuelle Korrekturen basierend auf tatsächlich vorhandenen Dateien
const manualMappings = {
  // API Design
  'api-design': '.github/chatmodes/general/APIDesign_DE.chatmode.md',
  'apidesign': '.github/chatmodes/general/APIDesign_DE.chatmode.md',
  
  // Security Audit
  'security-audit': '.github/chatmodes/general/SicherheitsAudit_DE.chatmode.md',
  'sicherheitsaudit': '.github/chatmodes/general/SicherheitsAudit_DE.chatmode.md',
  
  // Code Review
  'code-review': '.github/chatmodes/general/CodeReview_DE.chatmode.md',
  'codereview': '.github/chatmodes/general/CodeReview_DE.chatmode.md',
  
  // Bug Report / Fehlerbericht
  'bug-report': '.github/chatmodes/general/FehlerberichtVorlage_DE.chatmode.md',
  'bugreport': '.github/chatmodes/general/FehlerberichtVorlage_DE.chatmode.md',
  'fehlerbericht': '.github/chatmodes/general/FehlerberichtVorlage_DE.chatmode.md',
  
  // Test Generation
  'test-generation': '.github/chatmodes/general/TestGeneration_DE.chatmode.md',
  'testgeneration': '.github/chatmodes/general/TestGeneration_DE.chatmode.md',
  
  // Deployment Operations
  'deployment-operations': '.github/chatmodes/general/DeploymentGuide_DE.chatmode.md',
  'deploymentguide': '.github/chatmodes/general/DeploymentGuide_DE.chatmode.md',
  
  // CI Pipeline
  'ci-pipeline': '.github/chatmodes/general/CIPipeline_DE.chatmode.md',
  'cipipeline': '.github/chatmodes/general/CIPipeline_DE.chatmode.md',
  
  // Architecture Plan / Architekturplan
  'architecture-plan': '.github/chatmodes/general/Architekturplan_DE.chatmode.md',
  'architekturplan': '.github/chatmodes/general/Architekturplan_DE.chatmode.md',
  
  // Database Schema
  'database-schema': '.github/chatmodes/general/DatenbankSchema_DE.chatmode.md',
  'databaseschema': '.github/chatmodes/general/DatenbankSchema_DE.chatmode.md',
  'datenbankschema': '.github/chatmodes/general/DatenbankSchema_DE.chatmode.md',
  
  // Dockerization / Dockerisierung
  'dockerization': '.github/chatmodes/general/Dockerisierung_DE.chatmode.md',
  'dockerisierung': '.github/chatmodes/general/Dockerisierung_DE.chatmode.md',
  
  // Feature Proposal / Vorschlag
  'feature-proposal': '.github/chatmodes/general/FeatureVorschlag_DE.chatmode.md',
  'featurevorschlag': '.github/chatmodes/general/FeatureVorschlag_DE.chatmode.md',
  
  // Localization Plan / Lokalisierungsplan
  'localization-plan': '.github/chatmodes/general/Lokalisierungsplan_DE.chatmode.md',
  'lokalisierungsplan': '.github/chatmodes/general/Lokalisierungsplan_DE.chatmode.md',
  
  // Marketing Content
  'marketing-content': '.github/chatmodes/general/MarketingContent_DE.chatmode.md',
  'marketingcontent': '.github/chatmodes/general/MarketingContent_DE.chatmode.md',
  
  // Performance Optimization / Optimierung
  'performance-optimization': '.github/chatmodes/general/PerformanceOptimierung_DE.chatmode.md',
  'performanceoptimierung': '.github/chatmodes/general/PerformanceOptimierung_DE.chatmode.md',
  
  // Roadmap
  'roadmap': '.github/chatmodes/general/Roadmap_DE.chatmode.md',
  
  // User Documentation / Benutzerdokumentation
  'user-documentation': '.github/chatmodes/general/BenutzerDokumentation_DE.chatmode.md',
  'benutzerdokumentation': '.github/chatmodes/general/BenutzerDokumentation_DE.chatmode.md',
  
  // Accessibility Audit / Barrierefreiheit
  'accessibility-audit': '.github/chatmodes/general/BarrierefreiheitAudit_DE.chatmode.md',
  'barrierefreiheit': '.github/chatmodes/general/BarrierefreiheitAudit_DE.chatmode.md',
  
  // Contribution Guidelines / Beitragsrichtlinien
  'contribution-guidelines': '.github/chatmodes/general/Beitragsrichtlinien_DE.chatmode.md',
  'beitragsrichtlinien': '.github/chatmodes/general/Beitragsrichtlinien_DE.chatmode.md',
  
  // README
  'readme': '.github/chatmodes/general/README_DE.chatmode.md',
  'readme-modernization': '.github/chatmodes/general/README_DE.chatmode.md',
  
  // Onboarding
  'onboarding': '.github/chatmodes/general/Onboarding_DE.chatmode.md',
  
  // DSGVO Compliance
  'dsgvo-compliance-audit': '.github/chatmodes/compliance/MCPSicherheitsAudit_DE.chatmode.md',
  'dsgvo': '.github/chatmodes/compliance/MCPSicherheitsAudit_DE.chatmode.md',
  
  // Quality Gates
  'quality-gates-audit': '.github/chatmodes/operations/MCPQualityGates_DE.chatmode.md',
  
  // Verein
  'verein-mitgliederaufnahme': '.github/chatmodes/general/Verein_Mitgliederaufnahme_DE.chatmode.md',
  'verein-mitgliederversammlung': '.github/chatmodes/general/Verein_Mitgliederversammlung_DE.chatmode.md',
  'verein-rechnungspruefung': '.github/chatmodes/general/Verein_Rechnungspruefung_DE.chatmode.md',
  
  // n8n / N8N
  'n8n-automation': '.github/chatmodes/operations/MCPn8nAutomation_DE.chatmode.md',
  'n8n-workflows': '.github/chatmodes/operations/MCPn8nAutomation_DE.chatmode.md',
  
  // CiviCRM
  'civicrm-n8n-automation': '.github/chatmodes/operations/MCPCiviCRMWorkflows_DE.chatmode.md',
  'civicrm-vereinsbuchhaltung': '.github/chatmodes/general/Beitragsrichtlinien_DE.chatmode.md', // Fallback
  
  // MCP
  'repository-prompt-architect': '.github/chatmodes/development/MCPCodeReview_DE.chatmode.md',
};

console.log(`=== Intelligente MIGRATION_MAP.json Korrektur ===\n`);

const fixes = {};
let fixedCount = 0;

for (const [source, target] of Object.entries(map.mappings)) {
  let fullPath;
  if (target.startsWith('./')) {
    fullPath = path.join(process.cwd(), target.slice(2));
  } else if (target.startsWith('.')) {
    fullPath = path.join(process.cwd(), target);
  } else {
    fullPath = path.join(process.cwd(), target);
  }
  
  // Nur fehlende Chatmode-Mappings korrigieren
  if (!fs.existsSync(fullPath) && target.includes('.github/chatmodes/')) {
    const sourceBasename = path.basename(source, path.extname(source));
    const normalized = sourceBasename
      .replace(/_examples$/, '')
      .replace(/\.yaml$/, '')
      .replace(/\.json$/, '')
      .toLowerCase()
      .replace(/_/g, '-');
    
    if (manualMappings[normalized]) {
      fixes[source] = manualMappings[normalized];
      fixedCount++;
      console.log(`✅ FIX: ${source}`);
      console.log(`   ALT: ${target}`);
      console.log(`   NEU: ${manualMappings[normalized]}\n`);
    } else {
      console.log(`❌ KEIN MAPPING: ${source} (${normalized})`);
      console.log(`   → ${target}\n`);
    }
  }
}

console.log(`\n=== Zusammenfassung ===`);
console.log(`Fixes gefunden: ${fixedCount}`);

if (fixedCount > 0) {
  console.log(`\nWende Fixes an...`);
  
  for (const [source, newTarget] of Object.entries(fixes)) {
    map.mappings[source] = newTarget;
  }
  
  map.generated = new Date().toISOString();
  
  const backupFile = mapFile + '.backup-' + Date.now();
  fs.writeFileSync(backupFile, JSON.stringify(JSON.parse(fs.readFileSync(mapFile, 'utf8')), null, 2));
  console.log(`✅ Backup: ${backupFile}`);
  
  fs.writeFileSync(mapFile, JSON.stringify(map, null, 2));
  console.log(`✅ MIGRATION_MAP.json aktualisiert!\n`);
  
  process.exit(0);
} else {
  console.log(`\nKeine Fixes notwendig.\n`);
  process.exit(0);
}
