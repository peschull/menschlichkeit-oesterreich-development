#!/usr/bin/env node
/**
 * Menschlichkeit Österreich – ChatGPT App MCP Tool Server
 * Tools: register_user, create_membership (+ optional SEPA), request_data_deletion, check_deletion_status, get_profile
 * Security: No PII leakage via model output. Tokens handled server-side via Authorization header.
 */

const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const { ListToolsRequestSchema, CallToolRequestSchema } = require('@modelcontextprotocol/sdk/types.js');

const API_BASE = process.env.MOE_API_BASE || 'http://localhost:8001/api/v1';

async function apiFetch(path, { method = 'GET', body, token, headers = {} } = {}) {
  const url = `${API_BASE}${path}`;
  const isJsonBody = body && !(body instanceof FormData);
  const h = { ...headers };
  if (isJsonBody) h['Content-Type'] = 'application/json';
  if (token) h['Authorization'] = `Bearer ${token}`;
  const res = await fetch(url, { method, headers: h, body: isJsonBody ? JSON.stringify(body) : body });
  let data = null;
  const ct = res.headers.get('content-type') || '';
  if (ct.includes('application/json')) {
    try { data = await res.json(); } catch { data = null; }
  } else {
    data = await res.text().catch(() => null);
  }
  if (!res.ok) {
    const msg = data?.message || data?.error || `${res.status} ${res.statusText}`;
    const err = new Error(msg);
    err.status = res.status;
    err.data = data;
    throw err;
  }
  return data;
}

function getAuthTokenFromContext(ctx) {
  // Prefer explicit bearer from environment (service account) if provided
  if (process.env.MOE_MCP_BEARER) return process.env.MOE_MCP_BEARER;
  // Fallback: extract from ctx?.params?.arguments?.__auth or headers in future SDKs
  const token = ctx?.params?.arguments?.__auth?.bearer;
  return token || null;
}

const server = new Server({ name: 'moe-chatgpt-app-server', version: '1.0.0' }, { capabilities: { tools: {} } });

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: 'register_user',
      description: 'Lege ein neues Nutzerkonto an (Contact in CiviCRM) – gibt Bestätigung zurück',
      inputSchema: {
        type: 'object',
        properties: {
          email: { type: 'string' },
          first_name: { type: 'string' },
          last_name: { type: 'string' },
          password: { type: 'string' },
        },
        required: ['email', 'first_name', 'last_name'],
      },
      _meta: {
        'openai/toolInvocation/invoking': 'Registriere Benutzer…',
        'openai/toolInvocation/invoked': 'Registrierung abgeschlossen',
      },
    },
    {
      name: 'create_membership',
      description: 'Erstellt eine Mitgliedschaft für den aktuellen Nutzer (optional SEPA-Mandat)',
      inputSchema: {
        type: 'object',
        properties: {
          contact_id: { type: 'integer' },
          membership_type: { type: 'string' },
          iban: { type: 'string' },
          bic: { type: 'string' },
        },
        required: ['contact_id', 'membership_type'],
      },
      _meta: {
        'openai/outputTemplate': 'ui://widget/membership-signup.html',
        'openai/toolInvocation/invoking': 'Mitgliedschaft wird erstellt…',
        'openai/toolInvocation/invoked': 'Mitgliedschaft erstellt',
      },
    },
    {
      name: 'request_data_deletion',
      description: 'Stellt einen DSGVO-Löschantrag (Art. 17) mit Begründung',
      inputSchema: { type: 'object', properties: { reason: { type: 'string' } }, required: ['reason'] },
      _meta: {
        'openai/toolInvocation/invoking': 'Löschantrag wird übermittelt…',
        'openai/toolInvocation/invoked': 'Löschantrag eingereicht',
        'openai/outputTemplate': 'ui://card/deletion-status.html',
      },
    },
    {
      name: 'check_deletion_status',
      description: 'Listet eigene Löschanträge und deren Status',
      inputSchema: { type: 'object', properties: {} },
      _meta: { 'openai/outputTemplate': 'ui://card/deletion-status.html' },
    },
    {
      name: 'get_profile',
      description: 'Liest das eigene Profil (Contact) aus',
      inputSchema: { type: 'object', properties: {} },
      _meta: { 'openai/outputTemplate': 'ui://card/profile.html' },
    },
  ],
}));

server.setRequestHandler(CallToolRequestSchema, async req => {
  const name = req.params.name;
  try {
    switch (name) {
      case 'register_user':
        return await handleRegisterUser(req.params.arguments || {});
      case 'create_membership':
        return await handleCreateMembership(req.params.arguments || {}, req);
      case 'request_data_deletion':
        return await handleRequestDeletion(req.params.arguments || {}, req);
      case 'check_deletion_status':
        return await handleCheckDeletionStatus(req);
      case 'get_profile':
        return await handleGetProfile(req);
      default:
        return { content: [{ type: 'text', text: `Unknown tool: ${name}` }], isError: true };
    }
  } catch (e) {
    const msg = e?.message || 'Unbekannter Fehler';
    return { content: [{ type: 'text', text: `❌ Fehler: ${msg}` }], isError: true };
  }
});

// Tool handlers
async function handleRegisterUser(args) {
  const { email, first_name, last_name, password } = args;
  const payload = { email, first_name, last_name, password };
  const data = await apiFetch('/auth/register', { method: 'POST', body: payload });
  // Do not leak tokens; return only confirmation
  return {
    content: [{ type: 'text', text: '✅ Registrierung erfolgreich. Willkommen im Verein!' }],
    structuredContent: { contact_id: data?.data?.contact_id ?? null },
  };
}

function mapMembershipType(t) {
  // Basic mapping; adjust to real IDs as needed
  const map = { standard: 1, foerdermitglied: 2, reduced: 3 };
  return map[t] || 1;
}

async function handleCreateMembership(args, req) {
  const token = getAuthTokenFromContext(req);
  if (!token) throw new Error('Nicht authentifiziert');
  const { contact_id, membership_type, iban, bic } = args;
  const payload = { contact_id, membership_type_id: mapMembershipType(membership_type), start_date: new Date().toISOString().slice(0, 10) };
  const created = await apiFetch('/memberships/create', { method: 'POST', body: payload, token });
  if (iban) {
    try {
      await apiFetch('/sepa/mandate', { method: 'POST', body: { contact_id, iban, bic }, token });
    } catch {
      // Best effort; don’t fail membership creation if mandate fails
    }
  }
  return {
    content: [{ type: 'text', text: '✅ Mitgliedschaft erfolgreich erstellt.' }],
    structuredContent: { membership_id: created?.data?.id ?? null, status: created?.data?.status ?? 'created' },
  };
}

async function handleRequestDeletion(args, req) {
  const token = getAuthTokenFromContext(req);
  if (!token) throw new Error('Nicht authentifiziert');
  const { reason } = args;
  const resp = await apiFetch('/privacy/data-deletion', { method: 'POST', body: { reason }, token });
  const status = resp?.data?.status || resp?.status || 'pending';
  return {
    content: [{ type: 'text', text: '🗑️ Löschantrag übermittelt.' }],
    structuredContent: resp?.data || { status },
  };
}

async function handleCheckDeletionStatus(req) {
  const token = getAuthTokenFromContext(req);
  if (!token) throw new Error('Nicht authentifiziert');
  const resp = await apiFetch('/privacy/data-deletion', { method: 'GET', token });
  return { content: [{ type: 'text', text: 'ℹ️ Löschanträge geladen.' }], structuredContent: resp?.data || {} };
}

async function handleGetProfile(req) {
  const token = getAuthTokenFromContext(req);
  if (!token) throw new Error('Nicht authentifiziert');
  const prof = await apiFetch('/user/profile', { method: 'GET', token });
  // Return only non-sensitive summary
  const summary = prof?.data ? { email: prof.data.email, first_name: prof.data.first_name, last_name: prof.data.last_name, member_since: prof.data.member_since } : {};
  return { content: [{ type: 'text', text: '👤 Profil geladen.' }], structuredContent: summary };
}

// Minimal UI resource protocol via SDK content (placeholder URIs)
server.addResource?.('ui://widget/membership-signup.html', async () => ({
  contents: [
    { uri: 'ui://widget/membership-signup.html', mimeType: 'text/html+skybridge', text: '<!doctype html><meta charset="utf-8"/><title>Mitglied werden</title><div id="app"></div><script>/* UI powered externally; submit calls window.openai.callTool("create_membership", formData) */</script>' },
  ],
}));

server.addResource?.('ui://card/deletion-status.html', async () => ({
  contents: [
    { uri: 'ui://card/deletion-status.html', mimeType: 'text/html+skybridge', text: '<!doctype html><meta charset="utf-8"/><div id="card">Löschstatus wird angezeigt…</div>' },
  ],
}));

server.addResource?.('ui://card/profile.html', async () => ({
  contents: [
    { uri: 'ui://card/profile.html', mimeType: 'text/html+skybridge', text: '<!doctype html><meta charset="utf-8"/><div id="card">Profilübersicht</div>' },
  ],
}));

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  // Keep process alive
}

main().catch(err => {
  console.error('Failed to start moe-chatgpt-app-server:', err);
  process.exit(1);
});
