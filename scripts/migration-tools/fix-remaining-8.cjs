const fs = require('fs');

const MIGRATION_MAP_PATH = '.github/prompts/MIGRATION_MAP.json';

// Hotfix für die letzten 8 fehlenden Mappings
const hotfixMappings = {
  '.github/chatmodes/operations/MCPn8nAutomation_DE.chatmode.md': '.github/chatmodes/general/MCPDeploymentOps_DE.chatmode.md',
  '.github/chatmodes/operations/MCPCiviCRMWorkflows_DE.chatmode.md': '.github/chatmodes/general/MCPDeploymentOps_DE.chatmode.md',
  '.github/chatmodes/operations/MCPQualityGates_DE.chatmode.md': '.github/chatmodes/general/CIPipeline_DE.chatmode.md',
};

console.log('=== Hotfix für 8 fehlende operations/ Chatmodes ===\n');

// Lese MIGRATION_MAP.json
const migrationMap = JSON.parse(fs.readFileSync(MIGRATION_MAP_PATH, 'utf8'));

// Backup
const backupPath = `${MIGRATION_MAP_PATH}.backup-${Date.now()}`;
fs.writeFileSync(backupPath, JSON.stringify(migrationMap, null, 2));
console.log(`✅ Backup: ${backupPath}\n`);

let fixCount = 0;

// Durchlaufe alle Mappings und ersetze nicht-existierende Targets
Object.keys(migrationMap.mappings).forEach(source => {
  const target = migrationMap.mappings[source];
  
  if (hotfixMappings[target]) {
    const newTarget = hotfixMappings[target];
    
    // Prüfe ob neue Datei existiert
    if (fs.existsSync(newTarget)) {
      console.log(`✅ FIX: ${source}`);
      console.log(`   ALT: ${target}`);
      console.log(`   NEU: ${newTarget}\n`);
      
      migrationMap.mappings[source] = newTarget;
      fixCount++;
    } else {
      console.log(`❌ FEHLER: ${newTarget} existiert nicht!`);
    }
  }
});

// Update timestamp
migrationMap.generated = new Date().toISOString();

// Schreibe aktualisierte Map
fs.writeFileSync(MIGRATION_MAP_PATH, JSON.stringify(migrationMap, null, 2));

console.log(`\n=== Zusammenfassung ===`);
console.log(`Fixes angewendet: ${fixCount}`);
console.log(`✅ MIGRATION_MAP.json aktualisiert!`);
