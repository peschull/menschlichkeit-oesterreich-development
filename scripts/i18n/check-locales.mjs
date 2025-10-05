#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import process from 'node:process';
import { parse } from '@formatjs/icu-messageformat-parser';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Konfiguration über Umgebungsvariablen
// I18N_DIRS: Kommagetrennte Basisverzeichnisse (Standard: frontend,website,admin.menschlichkeit-oesterreich.at)
// I18N_DIR_NAMES: Kommagetrennte Verzeichnisnamen, die Locale-Dateien enthalten (Standard: locales,i18n,lang)
// I18N_FILE_BASENAMES: Basenamen (z. B. de.json,en.json) zur Referenzbestimmung (Standard: de.json,en.json)
// I18N_REF_LOCALE: erzwinge Referenzsprache (de|en); leer = automatisch
const I18N_DIRS = (process.env.I18N_DIRS || 'frontend,website,admin.menschlichkeit-oesterreich.at')
  .split(',').map(s => s.trim()).filter(Boolean);
const I18N_DIR_NAMES = (process.env.I18N_DIR_NAMES || 'locales,i18n,lang')
  .split(',').map(s => s.trim()).filter(Boolean);
const I18N_FILE_BASENAMES = (process.env.I18N_FILE_BASENAMES || 'de.json,en.json')
  .split(',').map(s => s.trim()).filter(Boolean);
const I18N_REF_LOCALE = (process.env.I18N_REF_LOCALE || '').trim();

function* walk(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const e of entries) {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) yield* walk(full);
    else yield full;
  }
}

function findLocaleRoots() {
  const roots = [];
  for (const base of I18N_DIRS) {
    if (!fs.existsSync(base)) continue;
    const locales = [];
    for (const f of walk(base)) {
      const dirName = path.basename(path.dirname(f));
      if (I18N_DIR_NAMES.includes(dirName) && f.endsWith('.json')) {
        locales.push(f);
      }
    }
    if (locales.length) roots.push({ base, locales });
  }
  return roots;
}

function flattenKeys(obj, prefix = '') {
  const out = {};
  for (const [k, v] of Object.entries(obj)) {
    const key = prefix ? `${prefix}.${k}` : k;
    if (v && typeof v === 'object' && !Array.isArray(v)) Object.assign(out, flattenKeys(v, key));
    else out[key] = v;
  }
  return out;
}

function parseJSON(file) {
  try {
    const raw = fs.readFileSync(file, 'utf8');
    return JSON.parse(raw);
  } catch (e) {
    throw new Error(`Invalid JSON in ${file}: ${e.message}`);
  }
}

function validateICU(map) {
  const errors = [];
  for (const [k, v] of Object.entries(map)) {
    if (typeof v !== 'string') continue;
    try {
      parse(v);
    } catch (e) {
      errors.push({ key: k, message: String(e.message || e) });
    }
  }
  return errors;
}

const roots = findLocaleRoots();
if (!roots.length) {
  console.log('[i18n] Keine Locale-Strukturen gefunden – überspringe Checks.');
  process.exit(0);
}

let failures = 0;
for (const { base, locales } of roots) {
  // Gruppiere pro Ordner, suche Referenzsprache (de oder en)
  const byDir = new Map();
  for (const f of locales) {
    const dir = path.dirname(f);
    if (!byDir.has(dir)) byDir.set(dir, []);
    byDir.get(dir).push(f);
  }

  for (const [dir, files] of byDir.entries()) {
    const baseNames = I18N_FILE_BASENAMES;
    let refFile = null;
    if (I18N_REF_LOCALE) {
      refFile = files.find(f => path.basename(f).startsWith(`${I18N_REF_LOCALE}.`)) ||
                files.find(f => path.basename(f) === `${I18N_REF_LOCALE}.json`);
    }
    if (!refFile) {
      refFile = files.find(f => baseNames.includes(path.basename(f)));
    }
    if (!refFile) continue;
    const ref = flattenKeys(parseJSON(refFile));

    for (const f of files) {
      if (f === refFile) continue;
      const tgt = flattenKeys(parseJSON(f));
      const missing = Object.keys(ref).filter(k => !(k in tgt));
      const icuErrors = validateICU(tgt);
      if (missing.length || icuErrors.length) {
        failures++;
        console.log(`\n[i18n] Probleme in ${f} (Basis: ${path.relative(process.cwd(), refFile)}):`);
        if (missing.length) console.log(`  Fehlende Keys (${missing.length}):`, missing.slice(0, 20).join(', '), missing.length > 20 ? '…' : '');
        for (const err of icuErrors.slice(0, 20)) console.log(`  ICU-Fehler: ${err.key} → ${err.message}`);
      }
    }
  }
}

if (failures) {
  console.error(`\n[i18n] Checks fehlgeschlagen (${failures}).`);
  process.exit(1);
}

console.log('[i18n] Alle Checks erfolgreich.');
