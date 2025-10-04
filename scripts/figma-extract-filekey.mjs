#!/usr/bin/env node
import { URL } from 'node:url';

/**
 * Extracts Figma file key from a Figma URL and prints it.
 * Usage: node scripts/figma-extract-filekey.mjs <figma-url>
 */
const [,, rawUrl] = process.argv;
if (!rawUrl) {
  console.error('Usage: node scripts/figma-extract-filekey.mjs <figma-url>');
  process.exit(1);
}

try {
  const u = new URL(rawUrl);
  // URLs can be: https://www.figma.com/file/<key>/... or /design/... or /make/<key>/...
  const parts = u.pathname.split('/').filter(Boolean);
  // find the segment that looks like a file key (letters+digits, usually length >= 10)
  const candidate = parts.find(p => /^[A-Za-z0-9_-]{10,}$/.test(p));
  if (!candidate) {
    throw new Error('No file key segment found in URL');
  }
  console.log(candidate);
} catch (e) {
  console.error(`Error: ${(e && e.message) || e}`);
  process.exit(2);
}
