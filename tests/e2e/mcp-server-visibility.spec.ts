import { expect, test } from '@playwright/test';
import fs from 'node:fs';
import path from 'node:path';

// Dieser Test validiert die MCP-Server-Konfiguration aus .vscode/mcp.json
// und nutzt optional das Health-Check-Skript für eine Quick-Prüfung.

// In ESM-Umgebungen ist __dirname nicht verfügbar; Playwright startet im Repo-Root
const WORKSPACE = process.cwd();
const MCP_JSON = path.join(WORKSPACE, '.vscode', 'mcp.json');
const HEALTH_SCRIPT = path.join(WORKSPACE, 'scripts', 'mcp-health-check.sh');

test.describe('MCP-Server-Integration', () => {
  test('Konfiguration enthält alle erwarteten Server', async () => {
    expect(fs.existsSync(MCP_JSON)).toBeTruthy();
    const raw = fs.readFileSync(MCP_JSON, 'utf8');
    // mcp.json ist JSONC-fähig; entferne Kommentare falls vorhanden
    type MCPConfig = { servers?: Record<string, unknown> };
    const json = JSON.parse(
      raw.replace(/\/\*.*?\*\//gs, '').replace(/^\s*\/\/.*$/gm, '')
    ) as MCPConfig;
    const servers = Object.keys(json.servers ?? {});

    const expected = [
      'filesystem',
      'memory',
      'notion',
      'figma',
      'postgres',
      'upstash-context7',
      'codacy-mcp-server',
      'moe-chat',
      'markitdown',
      'github-mcp',
      'playwright-mcp',
      'microsoft-docs',
    ];

    for (const name of expected) {
      expect(servers).toContain(name);
    }
  });

  test('Health-Check Quick JSON liefert ok|warn', async () => {
    test.skip(!fs.existsSync(HEALTH_SCRIPT), 'Health-Check-Skript nicht vorhanden');
    const { spawnSync } = await import('node:child_process');
    const res = spawnSync('bash', [HEALTH_SCRIPT, '--mode=quick', '--format=json'], {
      cwd: WORKSPACE,
      env: process.env,
      encoding: 'utf8',
      timeout: 30000,
    });
    test.info().attach('mcp-health-output', {
      body: res.stdout || res.stderr || '',
      contentType: 'application/json',
    });
    expect(res.status === 0 || res.status === 1).toBeTruthy();
    const outUnknown = (() => {
      const text = (res.stdout || '').trim();
      const start = text.indexOf('{');
      const end = text.lastIndexOf('}');
      if (start === -1 || end === -1 || end <= start) return null;
      const slice = text.slice(start, end + 1);
      try {
        return JSON.parse(slice);
      } catch {
        return null;
      }
    })();
    expect(outUnknown).toBeTruthy();
    type HealthOut = { status: 'ok' | 'warn' | 'error'; summary?: unknown };
    const isHealthOut = (o: unknown): o is HealthOut =>
      !!o && typeof (o as { status?: unknown }).status === 'string';
    expect(isHealthOut(outUnknown)).toBeTruthy();
    const out = outUnknown as HealthOut;
    expect(['ok', 'warn']).toContain(out.status);
    expect(out.summary).toBeTruthy();
  });
});
