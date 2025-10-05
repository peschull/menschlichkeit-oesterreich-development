#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

function inflate(str) {
  // Simpler Pseudo-Lokalisierung: Zeichen duplizieren/akzentuieren, Länge ~150%
  const map = { a: 'á', e: 'é', i: 'í', o: 'ó', u: 'ú', A: 'Á', E: 'É', I: 'Í', O: 'Ó', U: 'Ú' };
  let out = '';
  for (const ch of str) {
    const m = map[ch] || ch;
    out += m + (/[A-Za-z]/.test(ch) ? m : '');
  }
  return `[!! ${out} !!]`;
}

function generatePseudo(obj) {
  if (typeof obj === 'string') return inflate(obj);
  if (Array.isArray(obj)) return obj.map(generatePseudo);
  if (obj && typeof obj === 'object') {
    const out = {};
    for (const [k, v] of Object.entries(obj)) out[k] = generatePseudo(v);
    return out;
  }
  return obj;
}

const candidates = [
  'frontend/src/locales/de.json',
  'frontend/locales/de.json',
  'website/locales/de.json',
];

const base = candidates.find(f => fs.existsSync(f));
if (!base) {
  console.log('[i18n] Keine Basis-Locale (de.json) gefunden – Pseudo-Locale übersprungen.');
  process.exit(0);
}

const raw = JSON.parse(fs.readFileSync(base, 'utf8'));
const pseudo = generatePseudo(raw);
const outDir = path.join('frontend', '.i18n', 'pseudo');
fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(path.join(outDir, 'en-XX.json'), JSON.stringify(pseudo, null, 2));
console.log(`[i18n] Pseudo-Locale erzeugt: ${path.join(outDir, 'en-XX.json')}`);
