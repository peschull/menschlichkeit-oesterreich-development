#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const mapFile = '.github/prompts/MIGRATION_MAP.json';
const map = JSON.parse(fs.readFileSync(mapFile, 'utf8'));

let missing = [];
let found = [];

for (const [source, target] of Object.entries(map.mappings)) {
  // Wenn der Pfad mit ./ oder . startet, root-relativ behandeln, sonst direkt
  let fullPath;
  if (target.startsWith('./')) {
    fullPath = path.join(process.cwd(), target.slice(2));
  } else if (target.startsWith('.')) {
    fullPath = path.join(process.cwd(), target); // .github bleibt .github
  } else {
    fullPath = path.join(process.cwd(), target);
  }
  
  if (!fs.existsSync(fullPath)) {
    missing.push({ source, target });
  } else {
    found.push({ source, target });
  }
}

console.log('=== MIGRATION_MAP.json Validierung ===\n');
console.log(`Generiert: ${map.generated}`);
console.log(`Deprecated Count: ${map.deprecated_count}`);
console.log(`Total Mappings: ${Object.keys(map.mappings).length}\n`);

console.log(`✅ Gefunden: ${found.length}`);
console.log(`❌ Fehlend: ${missing.length}\n`);

if (missing.length > 0) {
  console.log('Fehlende Zieldateien:\n');
  missing.forEach(({ source, target }) => {
    console.log(`  ❌ ${source}`);
    console.log(`     → ${target}\n`);
  });
  process.exit(1);
} else {
  console.log('🎉 Alle Zieldateien existieren!\n');
  
  // Zeige Beispiel-Mappings
  console.log('Beispiel-Mappings (erste 10):');
  found.slice(0, 10).forEach(({ source, target }) => {
    console.log(`  ✅ ${source}`);
    console.log(`     → ${target}`);
  });
  
  process.exit(0);
}
