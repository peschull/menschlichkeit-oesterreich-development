// Shared utilities for the monorepo
// Keep browser/node compatibility in mind; avoid heavy deps

function redactSecrets(text) {
  if (typeof text !== 'string') return text;
  const patterns = [
    { re: /-----BEGIN [A-Z ]*PRIVATE KEY-----[\s\S]*?-----END [A-Z ]*PRIVATE KEY-----/g, repl: '-----BEGIN PRIVATE KEY-----\n[REDACTED]\n-----END PRIVATE KEY-----' },
    { re: /(AWS_)?SECRET_ACCESS_KEY\s*[:=]\s*[^\n\r]+/gi, repl: 'SECRET_ACCESS_KEY=[REDACTED]' },
    { re: /(x-api-key\s*[:=]\s*)[^\n\r]+/gi, repl: '$1[REDACTED]' },
    { re: /(api[_-]?key\s*[:=]\s*)[^\n\r]+/gi, repl: '$1[REDACTED]' },
    { re: /(authorization:\s*Bearer\s+)[A-Za-z0-9\-_.~+/=]+/gi, repl: '$1[REDACTED]' },
    { re: /("|')?password("|')?\s*[:=]\s*("|')[^"']+("|')/gi, repl: 'password: "[REDACTED]"' },
    { re: /(jwt|id_token|access_token)\s*[:=]\s*[A-Za-z0-9\-_.~+/=]+/gi, repl: '$1=[REDACTED]' }
  ];
  let out = text;
  for (const { re, repl } of patterns) out = out.replace(re, repl);
  return out;
}

function isBlockedPath(name, { blockedExts = new Set(), blockedPatterns = [], allowDotfiles = false } = {}) {
  const lower = name.toLowerCase();
  for (const pat of blockedPatterns) {
    if (lower.includes(String(pat).toLowerCase())) return true;
  }
  if (!allowDotfiles && name.startsWith('.') && name !== '.') return true;
  const ext = require('path').extname(name).toLowerCase();
  if (ext && blockedExts.has(ext)) return true;
  return false;
}

module.exports = { redactSecrets, isBlockedPath };
