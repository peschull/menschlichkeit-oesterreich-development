#!/usr/bin/env node

/**
 * Pseudo-Locale Generator (en-XX)
 * Generiert eine Pseudo-Locale für i18n-Testing
 * 
 * Transformiert Texte um sicherzustellen:
 * - Texte sind nicht hardcodiert (werden sichtbar verändert)
 * - Platzhalter funktionieren ({variable}, %s, etc.)
 * - Längere Texte (simuliert andere Sprachen wie Deutsch)
 * 
 * Env Variables:
 * - I18N_DIRS: Comma-separated Pfade zu i18n-Ordnern
 * - I18N_DIR_NAMES: Comma-separated Namen der i18n-Unterordner
 * - I18N_REF_LOCALE: Referenz-Locale (default: "en")
 */

import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'fs';
import { join, resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Konfiguration
const I18N_DIRS = (process.env.I18N_DIRS || 'frontend').split(',').map(s => s.trim());
const I18N_DIR_NAMES = (process.env.I18N_DIR_NAMES || '.i18n').split(',').map(s => s.trim());
const I18N_REF_LOCALE = process.env.I18N_REF_LOCALE || 'en';
const PSEUDO_LOCALE = 'en-XX';

const ROOT_DIR = resolve(__dirname, '../..');

/**
 * Character-Mapping für Pseudo-Locale (Unicode-Zeichen mit Diakritika)
 */
const CHAR_MAP = {
  'a': 'ȧ', 'b': 'ƀ', 'c': 'ƈ', 'd': 'ḓ', 'e': 'ḗ', 'f': 'ƒ', 'g': 'ɠ',
  'h': 'ħ', 'i': 'ī', 'j': 'ĵ', 'k': 'ķ', 'l': 'ŀ', 'm': 'ḿ', 'n': 'ƞ',
  'o': 'ǿ', 'p': 'ƥ', 'q': 'ɋ', 'r': 'ř', 's': 'ş', 't': 'ŧ', 'u': 'ŭ',
  'v': 'ṽ', 'w': 'ẇ', 'x': 'ẋ', 'y': 'ẏ', 'z': 'ẑ',
  'A': 'Ȧ', 'B': 'Ɓ', 'C': 'Ƈ', 'D': 'Ḓ', 'E': 'Ḗ', 'F': 'Ƒ', 'G': 'Ɠ',
  'H': 'Ħ', 'I': 'Ī', 'J': 'Ĵ', 'K': 'Ķ', 'L': 'Ŀ', 'M': 'Ḿ', 'N': 'Ƞ',
  'O': 'Ǿ', 'P': 'Ƥ', 'Q': 'Ɋ', 'R': 'Ř', 'S': 'Ş', 'T': 'Ŧ', 'U': 'Ŭ',
  'V': 'Ṽ', 'W': 'Ẇ', 'X': 'Ẋ', 'Y': 'Ẏ', 'Z': 'Ẑ'
};

/**
 * Pseudo-Transformation für einzelnen String
 * - Ersetzt Buchstaben durch Unicode-Varianten
 * - Behält Platzhalter ({var}, %s, etc.)
 * - Verlängert Text um ~30% (simuliert längere Sprachen)
 */
function pseudoTransform(text) {
  if (typeof text !== 'string') return text;
  
  // Platzhalter schützen: {variable}, {{variable}}, %s, %d, etc.
  const placeholders = [];
  let protectedText = text.replace(/(\{\{?[^}]+\}?}|%[sd]|%\([^)]+\)[sd])/g, (match) => {
    placeholders.push(match);
    return `__PLACEHOLDER_${placeholders.length - 1}__`;
  });

  // Buchstaben transformieren
  let transformed = '';
  for (const char of protectedText) {
    transformed += CHAR_MAP[char] || char;
  }

  // Platzhalter wiederherstellen
  transformed = transformed.replace(/__PLACEHOLDER_(\d+)__/g, (_, idx) => {
    return placeholders[parseInt(idx)];
  });

  // Text verlängern (~30% länger)
  const extension = '·'.repeat(Math.ceil(text.length * 0.15));
  return `[${transformed}${extension}]`;
}

/**
 * Rekursiv alle Werte in einem Objekt transformieren
 */
function transformObject(obj) {
  if (typeof obj === 'string') {
    return pseudoTransform(obj);
  }
  if (Array.isArray(obj)) {
    return obj.map(transformObject);
  }
  if (typeof obj === 'object' && obj !== null) {
    const result = {};
    for (const [key, value] of Object.entries(obj)) {
      result[key] = transformObject(value);
    }
    return result;
  }
  return obj;
}

/**
 * Generiert Pseudo-Locale für einen i18n-Ordner
 */
function generatePseudoLocale(dirPath) {
  const refFileName = `${I18N_REF_LOCALE}.json`;
  const refPath = join(dirPath, refFileName);

  if (!existsSync(refPath)) {
    console.log(`  ⚠️  Referenz-Datei nicht gefunden: ${refPath}`);
    return null;
  }

  let refData;
  try {
    refData = JSON.parse(readFileSync(refPath, 'utf-8'));
  } catch (err) {
    console.log(`  ❌ Fehler beim Lesen von ${refPath}: ${err.message}`);
    return null;
  }

  // Transformation
  const pseudoData = transformObject(refData);

  // Ausgabepfad
  const pseudoDir = join(dirPath, 'pseudo');
  mkdirSync(pseudoDir, { recursive: true });
  
  const outputPath = join(pseudoDir, `${PSEUDO_LOCALE}.json`);
  writeFileSync(outputPath, JSON.stringify(pseudoData, null, 2), 'utf-8');

  console.log(`  ✅ Generiert: ${outputPath}`);
  return outputPath;
}

/**
 * Main
 */
function main() {
  console.log('🌐 Pseudo-Locale Generator (en-XX)\n');
  console.log(`Referenz-Locale: ${I18N_REF_LOCALE}`);
  console.log(`Ziel-Locale: ${PSEUDO_LOCALE}\n`);

  let generatedCount = 0;

  // Durchsuche alle i18n-Ordner
  for (const baseDir of I18N_DIRS) {
    for (const dirName of I18N_DIR_NAMES) {
      const fullPath = join(ROOT_DIR, baseDir, dirName);
      
      if (!existsSync(fullPath)) {
        continue;
      }

      console.log(`📂 ${fullPath}`);
      const result = generatePseudoLocale(fullPath);
      if (result) {
        generatedCount++;
      }
    }
  }

  console.log('\n' + '='.repeat(60));
  if (generatedCount > 0) {
    console.log(`✅ ${generatedCount} Pseudo-Locale(s) generiert`);
    process.exit(0);
  } else {
    console.log('⚠️  Keine Pseudo-Locales generiert (keine Referenz-Dateien gefunden)');
    process.exit(0); // Kein Fehler, nur Warning
  }
}

main();
