#!/usr/bin/env node
// Exportiert unsere Design Tokens in ein Tokens-Studio-kompatibles JSON
import { promises as fs } from 'fs';
import path from 'path';

const ROOT = process.cwd();
const SOURCE = path.join(ROOT, 'figma-design-system', '00_design-tokens.json');
const OUT_DIR = path.join(ROOT, 'figma-design-system', 'exports');
const OUT_FILE = path.join(OUT_DIR, 'tokens-studio.json');

function toKebab(input) {
  return String(input)
    .replace(/_/g, '-')
    .replace(/([a-z])([A-Z])/g, '$1-$2')
    .toLowerCase();
}

function flattenColors(colors) {
  const result = {};
  for (const [name, value] of Object.entries(colors || {})) {
    if (value && typeof value === 'object') {
      for (const [shade, hex] of Object.entries(value)) {
        const key = `${toKebab(name)}.${toKebab(shade)}`;
        result[key] = { value: hex, type: 'color' };
      }
    } else if (typeof value === 'string') {
      const key = toKebab(name);
      result[key] = { value, type: 'color' };
    }
  }
  return result;
}

function mapTypography(typo = {}) {
  const out = {};
  if (typo.fontFamily) {
    const families = Object.entries(typo.fontFamily).reduce((acc, [k, v]) => {
      acc[toKebab(k)] = { value: Array.isArray(v) ? v.join(', ') : String(v), type: 'fontFamilies' };
      return acc;
    }, {});
    out.fontFamilies = families;
  }
  if (typo.fontSize) {
    const sizes = Object.entries(typo.fontSize).reduce((acc, [k, v]) => {
      acc[toKebab(k)] = { value: v, type: 'fontSizes' };
      return acc;
    }, {});
    out.fontSizes = sizes;
  }
  if (typo.fontWeight) {
    const weights = Object.entries(typo.fontWeight).reduce((acc, [k, v]) => {
      acc[toKebab(k)] = { value: String(v), type: 'fontWeights' };
      return acc;
    }, {});
    out.fontWeights = weights;
  }
  if (typo.lineHeight) {
    const lineHeights = Object.entries(typo.lineHeight).reduce((acc, [k, v]) => {
      acc[toKebab(k)] = { value: v, type: 'lineHeights' };
      return acc;
    }, {});
    out.lineHeights = lineHeights;
  }
  if (typo.letterSpacing) {
    const letterSpacings = Object.entries(typo.letterSpacing).reduce((acc, [k, v]) => {
      acc[toKebab(k)] = { value: v, type: 'letterSpacing' };
      return acc;
    }, {});
    out.letterSpacing = letterSpacings;
  }
  return out;
}

function mapSimple(category, typeName) {
  return Object.entries(category || {}).reduce((acc, [k, v]) => {
    acc[toKebab(k)] = { value: v, type: typeName };
    return acc;
  }, {});
}

async function main() {
  const raw = JSON.parse(await fs.readFile(SOURCE, 'utf-8'));
  const tokens = raw.designTokens || raw;

  const out = {
    $metadata: {
      exporter: 'export-tokens-tokensstudio.mjs',
      source: path.relative(ROOT, SOURCE),
      generatedAt: new Date().toISOString(),
    },
    // Tokens Studio Standard-Gruppen
    color: flattenColors(tokens.colors),
    fontFamilies: mapTypography(tokens.typography).fontFamilies || {},
    fontSizes: mapTypography(tokens.typography).fontSizes || {},
    fontWeights: mapTypography(tokens.typography).fontWeights || {},
    lineHeights: mapTypography(tokens.typography).lineHeights || {},
    letterSpacing: mapTypography(tokens.typography).letterSpacing || {},
    spacing: mapSimple(tokens.spacing, 'spacing'),
    borderRadius: mapSimple(tokens.borderRadius, 'borderRadius'),
    boxShadow: mapSimple(tokens.shadows, 'boxShadow'),
    // Optional / custom
    // breakpoints, animation, zIndex werden als generische Tokens abgelegt
    other: {
      breakpoints: mapSimple(tokens.breakpoints, 'dimension'),
      animationDuration: mapSimple(tokens.animation?.duration, 'duration'),
      animationEasing: mapSimple(tokens.animation?.easing, 'cubicBezier'),
      zIndex: mapSimple(tokens.zIndex, 'number'),
      semantic: mapSimple(tokens.colors?.semantic || {}, 'color'),
    },
  };

  await fs.mkdir(OUT_DIR, { recursive: true });
  await fs.writeFile(OUT_FILE, JSON.stringify(out, null, 2));
  console.log('✅ Tokens Studio Export geschrieben nach:', path.relative(ROOT, OUT_FILE));
}

main().catch((err) => {
  console.error('❌ Export fehlgeschlagen:', err.message);
  process.exit(1);
});
