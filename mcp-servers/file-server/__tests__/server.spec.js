const fs = require('fs');
const fsp = fs.promises;
const os = require('os');
const path = require('path');
const FileServerMCP = require('..');

describe('FileServerMCP hardening', () => {
  test('redact removes secrets and keys', () => {
    const s = new FileServerMCP();
    const input = `x-api-key: abc123\nSECRET_ACCESS_KEY=shhh\n-----BEGIN PRIVATE KEY-----\nabc\n-----END PRIVATE KEY-----`;
    const out = s.redact(input);
    expect(out).toContain('x-api-key: [REDACTED]');
    expect(out).toContain('SECRET_ACCESS_KEY=[REDACTED]');
    expect(out).toContain('-----BEGIN PRIVATE KEY-----');
    expect(out).toContain('[REDACTED]');
  });

  test('resolveSafePath blocks symlink traversal', async () => {
    const s = new FileServerMCP();
    const tmp = await fsp.mkdtemp(path.join(os.tmpdir(), 'mcp-test-'));
    const base = path.join(tmp, 'base');
    const outside = path.join(tmp, 'outside');
    await fsp.mkdir(base);
    await fsp.mkdir(outside);
    const target = path.join(outside, 'secret.txt');
    await fsp.writeFile(target, 'secret');
    const link = path.join(base, 'link.txt');
    await fsp.symlink(target, link);
    await expect(s.resolveSafePath(base, 'link.txt')).rejects.toThrow(/Symbolic links/);
  });

  test('validators enforce schema', () => {
    const s = new FileServerMCP();
    expect(s.validators.read({ service: 'frontend', filePath: 'README.md' })).toBe(true);
    expect(s.validators.read({ service: 'unknown', filePath: 'x' })).toBe(false);
  });

  test('searchAcrossServices finds matches within limits', async () => {
    const s = new FileServerMCP();
    // Use temp workspace
    const tmp = await fsp.mkdtemp(path.join(os.tmpdir(), 'mcp-search-'));
    const root = tmp;
    const fe = path.join(root, 'frontend');
    await fsp.mkdir(fe, { recursive: true });
    await fsp.writeFile(path.join(fe, 'notes.txt'), 'hello world\nneedle here\nbye');
    s.projectRoot = root;
    const out = await s.searchAcrossServices({ query: 'needle', fileTypes: ['.txt'] });
    const text = out.content[0].text;
    expect(text).toContain('results');
  });
});
