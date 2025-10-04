#!/usr/bin/env node
// Simple helper to extract and normalize Figma node-id from a Figma URL
// Usage: node scripts/figma-extract-nodeid.mjs <figma-url>

function exitWith(msg, code = 1) {
  console.error(msg);
  process.exit(code);
}

const urlArg = process.argv.slice(2).find((a) => !a.startsWith('-'));
if (!urlArg) {
  exitWith('Usage: figma:nodeid -- <figma-url>');
}

let parsed;
try {
  parsed = new URL(urlArg);
} catch {
  exitWith(`Invalid URL: ${urlArg}`);
}

// Get node-id from query, supporting encoded forms like 1%3A2
const rawNodeId = parsed.searchParams.get('node-id');
if (!rawNodeId) {
  exitWith('No node-id parameter found in URL.');
}

// Normalize: Figma remote often uses dash `-` for `:` in some share links, ensure colon
const decoded = decodeURIComponent(rawNodeId);
const normalized = decoded.replace(/-/g, ':');

if (!/^[0-9]+:[0-9]+(?:;[0-9]+:[0-9]+)*$/.test(normalized)) {
  // Accept compound node ids separated by ';' as well, else warn
  console.warn(`Warning: Unexpected node-id format: ${decoded}`);
}

console.log(normalized);
