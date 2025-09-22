const { spawn } = require('child_process');
const WebSocket = require('ws');

const PORT = Number(process.env.PORT || 8765);
const ALLOW = (process.env.ALLOW || 'D:\\Arbeitsverzeichniss').split(';').filter(Boolean);

// Befehlszeile für npx als EIN String (shell:true löst das unter Windows)
const allowArgs = ALLOW.map(p => `"${p}"`).join(' ');
const cmdLine = `npx -y @modelcontextprotocol/server-filesystem ${allowArgs}`;

console.log('[bridge] starting filesystem server via shell:');
console.log('[bridge] ', cmdLine);

const child = spawn(cmdLine, {
  stdio: ['pipe', 'pipe', 'inherit'],
  shell: true, // <<— WICHTIG für Windows
});

child.on('error', e => {
  console.error('[bridge] failed to start filesystem server:', e);
});
child.on('exit', code => {
  console.error(`[bridge] filesystem server exited with code ${code}`);
  process.exit(code ?? 1);
});

// WS-Server
const wss = new WebSocket.Server({ port: PORT }, () => {
  console.log(`[bridge] WS listening on ws://127.0.0.1:${PORT}`);
  console.log(`[bridge] Allowed paths: ${ALLOW.join(' | ')}`);
});

// 1 JSON-Message pro Zeile (STDIO <-> WS)
const clients = new Set();

wss.on('connection', ws => {
  clients.add(ws);
  ws.on('close', () => clients.delete(ws));
  ws.on('message', data => {
    child.stdin.write(data.toString().trim() + '\n');
  });
});

const rl = require('readline').createInterface({ input: child.stdout });
rl.on('line', line => {
  for (const ws of clients) {
    if (ws.readyState === ws.OPEN) ws.send(line);
  }
});
