#!/usr/bin/env node
/**
 * MCP Debugger: startet alle Server aus .vscode/mcp.json
 * – stdio: npx/command + args
 * – http: prüft Erreichbarkeit
 * Sendet ein JSON‑RPC initialize und wartet auf Antwort
 */

import { spawn } from 'node:child_process';
import fs from 'node:fs/promises';
import path from 'node:path';

const GREEN = '\x1b[32m',
  RED = '\x1b[31m',
  YEL = '\x1b[33m',
  BLUE = '\x1b[34m',
  R = '\x1b[0m';
const ROOT = process.cwd();
const MCP_JSON = path.join(ROOT, '.vscode', 'mcp.json');

const sleep = ms => new Promise(r => setTimeout(r, ms));

async function loadConfig() {
  const raw = await fs.readFile(MCP_JSON, 'utf8');
  const cfg = JSON.parse(raw);
  if (!cfg.servers || typeof cfg.servers !== 'object') throw new Error('mcp.json: servers{} fehlt');
  return cfg;
}

function resolvePlaceholders(value) {
  if (typeof value !== 'string') return value;
  // ${workspaceFolder}
  let v = value.replaceAll('${workspaceFolder}', ROOT);
  // ${env:VAR}
  v = v.replace(/\$\{env:([A-Z0-9_]+)\}/g, (_m, name) => process.env[name] ?? '');
  return v;
}

async function testStdIo(id, cfg) {
  const { command, args = [], env = {} } = cfg;
  if (!command) throw new Error(`${id}: command fehlt`);
  const resolvedArgs = (args || []).map(resolvePlaceholders);
  const resolvedEnvRaw = Object.fromEntries(
    Object.entries(env || {}).map(([k, v]) => [k, resolvePlaceholders(v)])
  );
  // drop empty placeholder results
  const resolvedEnv = Object.fromEntries(
    Object.entries(resolvedEnvRaw).filter(
      ([_, v]) => v !== undefined && v !== null && String(v).length > 0
    )
  );

  console.log(`${BLUE}📦 ${id}${R} → ${command} ${resolvedArgs.join(' ')}`);

  const child = spawn(command, resolvedArgs, {
    env: { ...process.env, ...resolvedEnv },
    stdio: ['pipe', 'pipe', 'pipe'],
  });

  let out = '';
  let err = '';
  const timer = setTimeout(() => {
    try {
      child.kill();
    } catch { /* ignore kill errors */ }
  }, 12000);
  child.stdout.on('data', d => (out += d.toString()));
  child.stderr.on('data', d => (err += d.toString()));

  // initialize handshake
  await sleep(500);
  try {
    const init =
      JSON.stringify({
        jsonrpc: '2.0',
        id: 1,
        method: 'initialize',
        params: {
          protocolVersion: '1.0.0',
          capabilities: {},
          clientInfo: { name: 'mcp-debug', version: '1.0.0' },
        },
      }) + '\n';
    child.stdin.write(init);
  } catch { /* ignore initialize write errors */ }

  const exitCode = await new Promise(res => child.on('close', code => res(code)));
  clearTimeout(timer);

  if (/jsonrpc|tool|resource|prompt/i.test(out)) {
    console.log(`${GREEN}✅ ${id}${R} antwortet (JSON‑RPC erkannt)`);
    return { id, ok: true };
  }
  if (err) {
    console.log(`${YEL}⚠ ${id}${R} stderr: ${err.split('\n')[0].slice(0, 140)}…`);
  }
  console.log(`${RED}❌ ${id}${R} keine valide Antwort (exit ${exitCode})`);
  return { id, ok: false };
}

async function testHttp(id, cfg) {
  const url = cfg.url;
  if (!url) throw new Error(`${id}: url fehlt`);
  console.log(`${BLUE}🌐 ${id}${R} → ${url}`);
  // Lazy check without external deps: use node fetch
  const ctrl = new AbortController();
  const t = setTimeout(() => ctrl.abort(), 4000);
    try {
      const res = await fetch(url, {
        method: 'GET',
        headers: {
          'Accept': 'text/event-stream, application/json',
          'MCP-Protocol-Version': '2025-06-18'
        },
        signal: ctrl.signal
      });
    clearTimeout(t);
    console.log(`${GREEN}✅ ${id}${R} HTTP erreichbar (${res.status})`);
    return { id, ok: true };
  } catch (e) {
    clearTimeout(t);
    console.log(`${RED}❌ ${id}${R} HTTP nicht erreichbar: ${e.message}`);
    return { id, ok: false };
  }
}

async function main() {
  console.log(`${BLUE}🔍 MCP Diagnose aus .vscode/mcp.json${R}\n`);
  const cfg = await loadConfig();
  const entries = Object.entries(cfg.servers);
  const results = [];
  for (const [id, server] of entries) {
    try {
      if (server.type === 'stdio') {
        results.push(await testStdIo(id, server));
      } else if (server.type === 'http') {
        results.push(await testHttp(id, server));
      } else {
        console.log(`${YEL}⚠ ${id}${R} unbekannter type=${server.type}`);
        results.push({ id, ok: false });
      }
    } catch (e) {
      console.log(`${RED}✗ ${id}${R} Fehler: ${e.message}`);
      results.push({ id, ok: false });
    }
    console.log();
  }

  const ok = results.filter(r => r.ok).length;
  console.log(`${BLUE}📊 Ergebnis:${R} ${ok}/${results.length} OK`);
  if (ok !== results.length) process.exitCode = 1;
}

main().catch(e => {
  console.error(e);
  process.exit(2);
});
