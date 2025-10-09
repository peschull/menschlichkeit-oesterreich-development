#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const mapFile = '.github/prompts/MIGRATION_MAP.json';
const map = JSON.parse(fs.readFileSync(mapFile, 'utf8'));

// Alle vorhandenen Chatmodes scannen
const chatmodesDir = '.github/chatmodes';
const existingChatmodes = new Set();

function scanChatmodes(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      scanChatmodes(fullPath);
    } else if (entry.name.endsWith('.chatmode.md')) {
      existingChatmodes.add(fullPath);
    }
  }
}

scanChatmodes(chatmodesDir);

console.log(`Gefundene Chatmodes: ${existingChatmodes.size}\n`);

// Mapping-Fixes
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
  
  // Wenn das Ziel nicht existiert UND es ein Chatmode sein sollte
  if (!fs.existsSync(fullPath) && target.includes('.github/chatmodes/')) {
    const targetBasename = path.basename(target);
    
    // Normalisiere für Vergleich: entferne .chatmode.md, _DE, PascalCase → lowercase mit -
    const normalizeForMatch = (str) => {
      return str
        .replace(/.chatmode.md$/, '')
        .replace(/_DE$/i, '')
        .replace(/_/g, '-')
        .toLowerCase()
        .trim();
    };
    
    const targetNormalized = normalizeForMatch(targetBasename);
    
    // Suche nach ähnlichen Chatmodes (in allen Unterverzeichnissen)
    let bestMatch = null;
    let bestScore = 0;
    
    for (const chatmode of existingChatmodes) {
      const chatmodeBasename = path.basename(chatmode);
      const chatmodeNormalized = normalizeForMatch(chatmodeBasename);
      
      // Exakter Match?
      if (chatmodeNormalized === targetNormalized) {
        bestMatch = chatmode;
        bestScore = 100;
        break;
      }
      
      // Substring-Match (für Examples/YAML-Varianten)
      const sourceBasename = path.basename(source);
      const sourceNormalized = normalizeForMatch(sourceBasename.replace(/(_examples|\.yaml|\.json)/, ''));
      
      if (chatmodeNormalized === sourceNormalized) {
        const score = 90;
        if (score > bestScore) {
          bestMatch = chatmode;
          bestScore = score;
        }
      }
      
      // Enthält den Source-Namen?
      if (chatmodeNormalized.includes(sourceNormalized) || sourceNormalized.includes(chatmodeNormalized)) {
        const score = 70;
        if (score > bestScore) {
          bestMatch = chatmode;
          bestScore = score;
        }
      }
    }
    
    if (bestMatch) {
      fixes[source] = bestMatch;
      fixedCount++;
      console.log(`✅ FIX (Score ${bestScore}): ${source}`);
      console.log(`   ALT: ${target}`);
      console.log(`   NEU: ${bestMatch}\n`);
    } else {
      console.log(`❌ KEIN MATCH: ${source} → ${target}\n`);
    }
  }
}

console.log(`\n=== Zusammenfassung ===`);
console.log(`Fixes gefunden: ${fixedCount}`);

if (fixedCount > 0) {
  console.log(`\nWende Fixes an auf MIGRATION_MAP.json...`);
  
  // Mappings aktualisieren
  for (const [source, newTarget] of Object.entries(fixes)) {
    map.mappings[source] = newTarget;
  }
  
  // Timestamp aktualisieren
  map.generated = new Date().toISOString();
  
  // Backup erstellen
  const backupFile = mapFile + '.backup-' + Date.now();
  fs.writeFileSync(backupFile, JSON.stringify(JSON.parse(fs.readFileSync(mapFile, 'utf8')), null, 2));
  console.log(`✅ Backup erstellt: ${backupFile}`);
  
  // Neue Version schreiben
  fs.writeFileSync(mapFile, JSON.stringify(map, null, 2));
  console.log(`✅ MIGRATION_MAP.json aktualisiert!\n`);
} else {
  console.log(`\nKeine Fixes notwendig.\n`);
}

process.exit(0);
