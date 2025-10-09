#!/usr/bin/env node
// Auto-annotate fenced code blocks without language to satisfy MD040.
// Heuristics: detect bash (commands starting with $, npm, git), JSON ({, [ and ":), YAML (key: value), otherwise 'text'.
// Usage: node scripts/fix-fenced-code-language.mjs [glob...]

import fs from 'fs';
import path from 'path';

const args = process.argv.slice(2);
const exts = ['.md', '.markdown'];

function isLikelyJSON(snippet) {
  const s = snippet.trim();
  return (/^\{[\s\S]*\}$/.test(s) || /^\[[\s\S]*\]$/.test(s)) && /"\w+"\s*:/.test(s);
}

function isLikelyYAML(snippet) {
  const lines = snippet.trim().split(/\r?\n/).slice(0, 5);
  let kv = 0;
  for (const l of lines) {
    if (/^[A-Za-z0-9_-]+\s*:\s*[^:]+$/.test(l)) kv++;
  }
  return kv >= 2;
}

function isLikelyBash(snippet) {
  const lines = snippet.trim().split(/\r?\n/).slice(0, 5);
  const score = lines.reduce((acc, l) => acc + (/^(#:|# |#!|\$ |npm |yarn |pnpm |git |bash |curl |wget |python |node |cd |ls |echo |export |set -e|sudo )/.test(l) ? 1 : 0), 0);
  return score >= 1;
}

function detectLang(snippet) {
  if (isLikelyJSON(snippet)) return 'json';
  if (isLikelyBash(snippet)) return 'bash';
  if (isLikelyYAML(snippet)) return 'yaml';
  return 'text';
}

function processFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split(/\r?\n/);
  let inFence = false;
  let fenceStart = -1; // kept for potential future diagnostics
  let fenceLang = '';
  const out = [];
  let i = 0;
  while (i < lines.length) {
    const line = lines[i];
    const fenceOpen = line.match(/^```(.*)$/);
    if (fenceOpen) {
      if (!inFence) {
        inFence = true;
        fenceStart = i;
        fenceLang = fenceOpen[1].trim();
        // If no lang provided, collect snippet until closing fence to detect
        if (!fenceLang) {
          let j = i + 1;
          const buf = [];
          while (j < lines.length && !/^```\s*$/.test(lines[j])) { buf.push(lines[j]); j++; }
          const lang = detectLang(buf.join('\n'));
          out.push('```' + lang);
        } else {
          out.push(line);
        }
      } else {
        // Closing fence
        inFence = false;
        fenceStart = -1;
        fenceLang = '';
        out.push('```');
      }
    } else {
      out.push(line);
    }
    i++;
  }
  const newContent = out.join('\n');
  if (newContent !== content) {
    fs.writeFileSync(filePath, newContent, 'utf8');
    return true;
  }
  return false;
}

function walk(dir, changed = []) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const e of entries) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) {
      if (['.git', 'node_modules', 'vendor', 'wp-content'].includes(e.name)) continue;
      walk(p, changed);
    } else if (exts.includes(path.extname(e.name))) {
      const updated = processFile(p);
      if (updated) changed.push(p);
    }
  }
  return changed;
}

const targets = args.length ? args : ['.'];
let changed = [];
for (const t of targets) {
  const stat = fs.statSync(t);
  if (stat.isDirectory()) changed = changed.concat(walk(t));
  else if (exts.includes(path.extname(t))) { if (processFile(t)) changed.push(t); }
}

if (changed.length) {
  console.log(`Updated ${changed.length} file(s):`);
  for (const c of changed) console.log(' - ' + c);
  process.exitCode = 0;
} else {
  console.log('No changes needed.');
}
