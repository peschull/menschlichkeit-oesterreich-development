#!/usr/bin/env node

/**
 * i18n Locale Completeness Check
 * Prüft ob alle i18n-Keys in allen Sprachen vorhanden sind
 * 
 * Env Variables (aus GitHub Actions Workflow):
 * - I18N_DIRS: Comma-separated Pfade zu i18n-Ordnern
 * - I18N_DIR_NAMES: Comma-separated Namen der i18n-Unterordner (z.B. ".i18n,locales")
 * - I18N_FILE_BASENAMES: Comma-separated Dateinamen (z.B. "de.json,en.json")
 * - I18N_REF_LOCALE: Referenz-Locale (default: "de")
 */

import { readFileSync, existsSync } from 'fs';
import { join, resolve } from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Konfiguration aus Environment Variables
const I18N_DIRS = (process.env.I18N_DIRS || 'frontend,web').split(',').map(s => s.trim());
const I18N_DIR_NAMES = (process.env.I18N_DIR_NAMES || '.i18n,locales,i18n').split(',').map(s => s.trim());
const I18N_FILE_BASENAMES = (process.env.I18N_FILE_BASENAMES || 'de.json,en.json').split(',').map(s => s.trim());
const I18N_REF_LOCALE = process.env.I18N_REF_LOCALE || 'de';

const ROOT_DIR = resolve(__dirname, '../..');

/**
 * Sammelt alle Keys aus einem i18n JSON-File (flache oder verschachtelte Struktur)
 */
function collectKeys(obj, prefix = '') {
  const keys = [];
  for (const [key, value] of Object.entries(obj)) {
    const fullKey = prefix ? `${prefix}.${key}` : key;
    if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
      keys.push(...collectKeys(value, fullKey));
    } else {
      keys.push(fullKey);
    }
  }
  return keys;
}

/**
 * Prüft einen i18n-Ordner auf fehlende Keys
 */
function checkLocaleDir(dirPath) {
  const results = {
    path: dirPath,
    files: {},
    errors: [],
    warnings: []
  };

  if (!existsSync(dirPath)) {
    results.warnings.push(`Ordner existiert nicht: ${dirPath}`);
    return results;
  }

  // Referenz-Locale laden
  const refFile = I18N_FILE_BASENAMES.find(basename => 
    basename.startsWith(I18N_REF_LOCALE) && existsSync(join(dirPath, basename))
  );

  if (!refFile) {
    results.warnings.push(`Referenz-Locale ${I18N_REF_LOCALE} nicht gefunden in ${dirPath}`);
    return results;
  }

  const refPath = join(dirPath, refFile);
  let refData;
  try {
    refData = JSON.parse(readFileSync(refPath, 'utf-8'));
  } catch (err) {
    results.errors.push(`Fehler beim Parsen von ${refPath}: ${err.message}`);
    return results;
  }

  const refKeys = collectKeys(refData);
  results.files[refFile] = { keys: refKeys.length, missing: [] };

  // Alle anderen Locales prüfen
  for (const basename of I18N_FILE_BASENAMES) {
    if (basename === refFile) continue;
    
    const targetPath = join(dirPath, basename);
    if (!existsSync(targetPath)) {
      results.warnings.push(`Locale-Datei fehlt: ${basename} in ${dirPath}`);
      continue;
    }

    let targetData;
    try {
      targetData = JSON.parse(readFileSync(targetPath, 'utf-8'));
    } catch (err) {
      results.errors.push(`Fehler beim Parsen von ${targetPath}: ${err.message}`);
      continue;
    }

    const targetKeys = collectKeys(targetData);
    const missingKeys = refKeys.filter(key => !targetKeys.includes(key));

    results.files[basename] = {
      keys: targetKeys.length,
      missing: missingKeys
    };

    if (missingKeys.length > 0) {
      results.errors.push(`${basename}: ${missingKeys.length} fehlende Keys`);
    }
  }

  return results;
}

/**
 * Main
 */
function main() {
  console.log('🌍 i18n Locale Completeness Check\n');
  console.log(`Referenz-Locale: ${I18N_REF_LOCALE}`);
  console.log(`Prüfe Dateien: ${I18N_FILE_BASENAMES.join(', ')}\n`);

  const allResults = [];
  let totalErrors = 0;

  // Durchsuche alle möglichen i18n-Ordner
  for (const baseDir of I18N_DIRS) {
    for (const dirName of I18N_DIR_NAMES) {
      const fullPath = join(ROOT_DIR, baseDir, dirName);
      const result = checkLocaleDir(fullPath);
      
      if (result.warnings.length === 0 || result.errors.length > 0) {
        // Nur ausgeben wenn Ordner existiert oder Fehler gefunden
        allResults.push(result);
        totalErrors += result.errors.length;
      }
    }
  }

  // Ausgabe
  for (const result of allResults) {
    console.log(`\n📂 ${result.path}`);
    
    if (result.warnings.length > 0) {
      result.warnings.forEach(w => console.log(`  ⚠️  ${w}`));
    }

    if (Object.keys(result.files).length > 0) {
      for (const [file, data] of Object.entries(result.files)) {
        const status = data.missing.length === 0 ? '✅' : '❌';
        console.log(`  ${status} ${file}: ${data.keys} Keys`);
        
        if (data.missing.length > 0) {
          console.log(`     Fehlend (${data.missing.length}): ${data.missing.slice(0, 5).join(', ')}${data.missing.length > 5 ? '...' : ''}`);
        }
      }
    }

    if (result.errors.length > 0) {
      result.errors.forEach(e => console.log(`  ❌ ${e}`));
    }
  }

  // Zusammenfassung
  console.log('\n' + '='.repeat(60));
  if (totalErrors === 0) {
    console.log('✅ Alle i18n-Locales sind vollständig!');
    process.exit(0);
  } else {
    console.log(`❌ ${totalErrors} Fehler gefunden in i18n-Locales`);
    process.exit(1);
  }
}

main();
