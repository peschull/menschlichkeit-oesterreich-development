#!/usr/bin/env node
/**
 * MCP Debugger: startet alle Server aus .vscode/mcp.json
 * – stdio: via command+args oder automatisch via npx <package> + args
 * – http: prüft Erreichbarkeit (GET)
 * Sendet ein JSON-RPC initialize und prüft Antwort/Protokollhinweise
 */

import { spawn } from 'node:child_process';
import fs from 'node:fs/promises';
import path from 'node:path';

const GREEN = '\x1b[32m';
const RED   = '\x1b[31m';
const YEL   = '\x1b[33m';
const BLUE  = '\x1b[34m';
const R     = '\x1b[0m';

const ROOT = process.cwd();
const MCP_JSON = path.join(ROOT, '.vscode', 'mcp.json');

const sleep = ms => new Promise(r => setTimeout(r, ms));

async function loadConfig() {
  const raw = await fs.readFile(MCP_JSON, 'utf8');
  const cfg = JSON.parse(raw);
  if (!cfg.servers || typeof cfg.servers !== 'object') {
    throw new Error('mcp.json: servers{} fehlt oder ist ungültig');
  }
  return cfg;
}

function resolvePlaceholders(value) {
  if (typeof value !== 'string') return value;
  let v = value.replaceAll('${workspaceFolder}', ROOT);
  v = v.replace(/\$\{env:([A-Z0-9_]+)\}/gi, (_m, name) => process.env[name] ?? '');
  return v;
}

function resolveArgs(args = []) {
  return args.map(resolvePlaceholders);
}

function resolveEnv(env = {}) {
  const mapped = Object.fromEntries(
    Object.entries(env).map(([k, v]) => [k, resolvePlaceholders(v)])
  );
  // Leere nach Placeholder-Auflösung entfernen
  return Object.fromEntries(
    Object.entries(mapped).filter(([, v]) => v !== undefined && v !== null && String(v).length > 0)
  );
}

/**
 * Ermittelt Startkommando für STDIO:
 *  - wenn server.package vorhanden → npx -y <package> ...args
 *  - sonst server.command ...args
 */
function stdioSpawnConfig(id, server) {
  const args = resolveArgs(server.args || []);
  const env = resolveEnv(server.env || {});
  if (server.package) {
    const npxCmd = process.platform === 'win32' ? 'npx.cmd' : 'npx';
    return { cmd: npxCmd, args: ['-y', server.package, ...args], env };
  }
  if (!server.command) throw new Error(`${id}: command oder package fehlt`);
  return { cmd: resolvePlaceholders(server.command), args, env };
}

async function testStdIo(id, server) {
  const { cmd, args, env } = stdioSpawnConfig(id, server);

  console.log(`${BLUE}📦 ${id}${R} → ${cmd} ${args.join(' ')}`);
  const child = spawn(cmd, args, {
    env: { ...process.env, ...env },
    stdio: ['pipe', 'pipe', 'pipe']
  });

  let out = '';
  let err = '';
  let resolved = false;

  const killAfter = setTimeout(() => {
    try { child.kill(); } catch { /* ignore */ }
  }, server.timeoutMs ?? 12000);

  child.stdout.on('data', d => (out += d.toString()));
  child.stderr.on('data', d => (err += d.toString()));

  // JSON-RPC initialize senden
  await sleep(500);
  try {
    const init = JSON.stringify({
      jsonrpc: '2.0',
      id: 1,
      method: 'initialize',
      params: {
        protocolVersion: '1.0.0',
        capabilities: {},
        clientInfo: { name: 'mcp-debug', version: '1.0.0' }
      }
    }) + '\n';
    child.stdin.write(init);
  } catch { /* ignore write errors */ }

  // Frühzeitige Heuristik: sobald JSON-RPC ähnliche Tokens auftauchen → OK
  const earlyCheck = setInterval(() => {
    if (resolved) return;
    if (/"jsonrpc"\s*:\s*"2\.0"|tool|resource|prompt|capabilit/i.test(out)) {
      resolved = true;
      clearInterval(earlyCheck);
      clearTimeout(killAfter);
      try { child.kill(); } catch {}
      console.log(`${GREEN}✅ ${id}${R} antwortet (JSON-RPC/Capabilities erkannt)`);
    }
  }, 200);

  const exitCode = await new Promise(res => child.on('close', code => res(code)));
  clearInterval(earlyCheck);
  clearTimeout(killAfter);

  if (resolved) return { id, ok: true };

  if (err) {
    const first = err.split('\n').find(Boolean) ?? err;
    console.log(`${YEL}⚠ ${id}${R} stderr: ${first.slice(0, 200)}…`);
  }

  // Wenn Prozess schnell ohne Output beendet → wahrscheinlich Fehlstart
  if (!out.trim() && (exitCode === 0 || exitCode === 1 || exitCode === null)) {
    console.log(`${RED}❌ ${id}${R} keine valide Antwort (exit ${exitCode})`);
    return { id, ok: false };
  }

  // Letzter Versuch: JSON-RPC-Fragmente prüfen
  if (/"jsonrpc"\s*:\s*"2\.0"/i.test(out)) {
    console.log(`${GREEN}✅ ${id}${R} antwortet (JSON-RPC erkannt)`);
    return { id, ok: true };
  }

  console.log(`${RED}❌ ${id}${R} keine valide Antwort (exit ${exitCode})`);
  return { id, ok: false };
}

async function testHttp(id, server) {
  const url = resolvePlaceholders(server.url);
  if (!url) throw new Error(`${id}: url fehlt`);
  console.log(`${BLUE}🌐 ${id}${R} → ${url}`);

  const ctrl = new AbortController();
  const t = setTimeout(() => ctrl.abort(), server.timeoutMs ?? 4000);

  try {
    const res = await fetch(url, {
      method: 'GET',
      headers: {
        Accept: 'text/event-stream, application/json',
        'MCP-Protocol-Version': '2025-06-18' // Header ist optional; nur als Hinweis
      },
      signal: ctrl.signal
    });
    clearTimeout(t);
    console.log(`${GREEN}✅ ${id}${R} HTTP erreichbar (Status ${res.status})`);
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
        console.log(`${YEL}⚠ ${id}${R} unbekannter type="${server.type}"`);
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