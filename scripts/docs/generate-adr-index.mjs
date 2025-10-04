#!/usr/bin/env node
import { promises as fs } from 'node:fs';
import path from 'node:path';

const ADR_DIR = path.resolve('docs/architecture/ADRs');
const INDEX_FILE = path.join(ADR_DIR, 'ADR-INDEX.md');

function parseFrontmatter(content) {
  const m = content.match(/^---\n([\s\S]*?)\n---/);
  if (!m) return {};
  const lines = m[1].split(/\r?\n/);
  const data = {};
  for (const line of lines) {
    const idx = line.indexOf(':');
    if (idx > -1) {
      const k = line.slice(0, idx).trim();
      const v = line.slice(idx + 1).trim();
      data[k] = v.replace(/^"|"$/g, '');
    }
  }
  return data;
}

async function main() {
  const files = await fs.readdir(ADR_DIR);
  const adrs = [];
  for (const f of files) {
    if (!/^ADR-\d{3}-.*\.md$/.test(f)) continue;
    const p = path.join(ADR_DIR, f);
    const c = await fs.readFile(p, 'utf8');
    const fm = parseFrontmatter(c);
    const num = f.match(/^ADR-(\d{3})-/)?.[1] ?? '000';
    const title = fm.title || f.replace(/^ADR-\d{3}-/, '').replace(/-/g, ' ').replace(/\.md$/, '');
    const status = (fm.status || '').trim() || 'Proposed';
    adrs.push({ num, title, status, file: f });
  }
  adrs.sort((a, b) => a.num.localeCompare(b.num));

  const lines = [];
  lines.push('# ADR Index');
  lines.push('');
  lines.push('| Nr. | Titel | Status | Datei |');
  lines.push('| --- | ----- | ------ | ----- |');
  for (const a of adrs) {
    lines.push(`| ${a.num} | ${a.title} | ${a.status} | [${a.file}](./${a.file}) |`);
  }
  const out = lines.join('\n') + '\n';
  await fs.writeFile(INDEX_FILE, out, 'utf8');
  console.log(`ADR Index aktualisiert: ${INDEX_FILE}`);
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});

