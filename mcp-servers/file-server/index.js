#!/usr/bin/env node

/**
 * MCP File Server für Menschlichkeit Österreich
 * Bietet Dateizugriff für alle Services im Multi-Service Setup
 */

const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} = require('@modelcontextprotocol/sdk/types.js');
const fs = require('fs').promises;
const fssync = require('fs');
const path = require('path');
const { spawn } = require('child_process');
const Ajv = require('ajv');
const crypto = require('crypto');
const { trace, SpanStatusCode } = require('@opentelemetry/api');

class FileServerMCP {
  constructor() {
    this.server = new Server(
      {
        name: 'menschlichkeit-file-server',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.projectRoot = process.env.PROJECT_ROOT || process.cwd();
    this.maxFileBytes = Number(process.env.MCP_FS_MAX_FILE_BYTES || 262144); // 256 KiB default
    this.allowedServices = new Set(['api', 'crm', 'frontend', 'games', 'website', 'n8n', 'root']);
    this.opaPolicyPath = process.env.MCP_OPA_POLICY || path.join(__dirname, '..', 'policies', 'opa', 'tool-io.rego');
    this._opaAvailable = undefined;
    this.opaRequired = String(process.env.MCP_OPA_REQUIRED || 'false').toLowerCase() === 'true';
    this.allowDotfiles = String(process.env.MCP_ALLOW_DOTFILES || 'false').toLowerCase() === 'true';
    this.maxListEntries = Number(process.env.MCP_MAX_LIST_ENTRIES || 500);
    this.maxConcurrent = Number(process.env.MCP_MAX_CONCURRENCY || 4);
    this.blockedExts = new Set((process.env.MCP_BLOCKED_EXTS || '.key,.pem,.der,.p12,.crt,.kdbx').split(',').map(s => s.trim()).filter(Boolean));
    this.blockedPathPatterns = (process.env.MCP_BLOCKED_PATH_PATTERNS || 'id_rsa,/secrets/,/private/,/keys/').split(',').map(s => s.trim()).filter(Boolean);
    // Simple token bucket: limit N requests per interval
    const rateLimit = Number(process.env.MCP_RATE_LIMIT || 30); // ops per interval
    const intervalMs = Number(process.env.MCP_RATE_INTERVAL_MS || 10000); // 10s
    this.rateLimiter = new TokenBucket(rateLimit, intervalMs);
    // Circuit breakers per operation
    this.cbRead = new CircuitBreaker({ threshold: 5, cooldownMs: 60000, halfOpenPass: 2 });
    this.cbList = new CircuitBreaker({ threshold: 5, cooldownMs: 60000, halfOpenPass: 2 });
    // Concurrency limiter
    this._current = 0;
    this._queue = [];
    // Request ID generator for logging
    this._rid = () => this.randomId(10);
    // Ajv validators
    this.ajv = new Ajv({ allErrors: true, strict: false });
    this.validators = this.compileValidators();
    this.tracer = trace.getTracer('mcp-file-server');
    this.otelEnabled = String(process.env.MCP_OTEL_ENABLED || 'true').toLowerCase() !== 'false';
    this.setupHandlers();
  }

  compileValidators() {
    const serviceEnum = Array.from(this.allowedServices);
     // const commonPathPattern = '^(?!/)(?!.*\\\.\\.)(?!.*\\\\\\\.\\\\\.)(?!.*\\\\\\\\\\\\)';
    const readSchema = {
      type: 'object',
      properties: {
        service: { type: 'string', enum: serviceEnum },
        filePath: { type: 'string', minLength: 1 },
      },
      required: ['service', 'filePath'],
      additionalProperties: false,
    };
    const listSchema = {
      type: 'object',
      properties: {
        service: { type: 'string', enum: serviceEnum },
        directory: { type: 'string' },
      },
      required: ['service'],
      additionalProperties: false,
    };
    const searchSchema = {
      type: 'object',
      properties: {
        query: { type: 'string', minLength: 1, maxLength: 256 },
        fileTypes: {
          type: 'array',
          items: { type: 'string', pattern: '^\\.\\w{1,10}$' },
          minItems: 0,
          maxItems: 10,
          uniqueItems: true,
        },
      },
      required: ['query'],
      additionalProperties: false,
    };
    return {
      read: this.ajv.compile(readSchema),
      list: this.ajv.compile(listSchema),
      search: this.ajv.compile(searchSchema),
    };
  }

  randomId(len = 10) {
    const alphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    const buf = crypto.randomBytes(len);
    let out = '';
    for (let i = 0; i < len; i++) out += alphabet[buf[i] % alphabet.length];
    return out;
  }

  setupHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'read_multi_service_file',
            description: 'Read files from any service directory (API, CRM, Frontend, Games, n8n)',
            inputSchema: {
              type: 'object',
              properties: {
                service: {
                  type: 'string',
                  enum: ['api', 'crm', 'frontend', 'games', 'website', 'n8n', 'root'],
                  description: 'Service directory to read from',
                },
                filePath: {
                  type: 'string',
                  description: 'Relative path within the service directory',
                },
              },
              required: ['service', 'filePath'],
            },
          },
          {
            name: 'list_service_files',
            description: 'List files and directories in a service',
            inputSchema: {
              type: 'object',
              properties: {
                service: {
                  type: 'string',
                  enum: ['api', 'crm', 'frontend', 'games', 'website', 'n8n', 'root'],
                },
                directory: {
                  type: 'string',
                  description: 'Directory path within service (optional)',
                  default: '.',
                },
              },
              required: ['service'],
            },
          },
          {
            name: 'get_project_structure',
            description: 'Get overview of multi-service project structure',
            inputSchema: {
              type: 'object',
              properties: {},
            },
          },
          {
            name: 'search_across_services',
            description: 'Search for text across all services',
            inputSchema: {
              type: 'object',
              properties: {
                query: {
                  type: 'string',
                  description: 'Text to search for',
                },
                fileTypes: {
                  type: 'array',
                  items: { type: 'string' },
                  description: 'File extensions to include (e.g., [".js", ".php", ".py"])',
                },
              },
              required: ['query'],
            },
          },
        ],
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async request => {
      const rid = this._rid();
      const start = Date.now();
      if (!this.rateLimiter.tryRemoveToken()) {
        return {
          content: [
            { type: 'text', text: 'Rate limit exceeded. Please retry later.' },
          ],
          isError: true,
        };
      }
      const spanRunner = async () => this.withConcurrency(async () => {
        switch (request.params.name) {
          case 'read_multi_service_file':
            return await this.withTimeout(
              this.readMultiServiceFile(request.params.arguments, { rid }),
              5000,
              'Read timed out'
            );
          case 'list_service_files':
            return await this.withTimeout(
              this.listServiceFiles(request.params.arguments, { rid }),
              5000,
              'List timed out'
            );
          case 'get_project_structure':
            return await this.getProjectStructure({ rid });
          case 'search_across_services':
            return await this.withTimeout(
              this.searchAcrossServices(request.params.arguments, { rid }),
              8000,
              'Search timed out'
            );
          default:
            throw new Error(`Unknown tool: ${request.params.name}`);
        }
      });

      if (!this.otelEnabled) {
        try {
          return await spanRunner();
        } finally {
          const dur = Date.now() - start;
          console.log(JSON.stringify({ type: 'mcp', rid, tool: request.params.name, duration_ms: dur }));
        }
      }

      return await this.tracer.startActiveSpan('mcp.tool', async span => {
  span.setAttribute('tool.name', request.params.name);
  span.setAttribute('mcp.rid', rid);
        try {
          const res = await spanRunner();
          span.setStatus({ code: SpanStatusCode.OK });
          return res;
        } catch (err) {
          span.recordException(err);
          span.setStatus({ code: SpanStatusCode.ERROR, message: String(err && err.message) });
          return {
            content: [{ type: 'text', text: `Error: ${err.message}` }],
            isError: true,
          };
        } finally {
          span.end();
          const dur = Date.now() - start;
          console.log(JSON.stringify({ type: 'mcp', rid, tool: request.params.name, duration_ms: dur }));
        }
      });
    });
  }

  getServicePath(service) {
    const serviceMap = {
      api: 'api.menschlichkeit-oesterreich.at',
      crm: 'crm.menschlichkeit-oesterreich.at',
      frontend: 'frontend',
      games: 'web',
      website: 'website',
      n8n: 'automation/n8n',
      root: '.',
    };

    // Strict allowlist: reject unknown services
    if (!this.allowedServices.has(service)) {
      throw new Error(`Unknown or disallowed service: ${service}`);
    }
    return path.join(this.projectRoot, serviceMap[service]);
  }

  // Resolve a relative path safely under a base directory.
  // Throws if the resolved path escapes the base or via symlink.
  async resolveSafePath(baseDir, relPath) {
    if (typeof relPath !== 'string' || relPath.trim().length === 0) {
      throw new Error('Invalid file path');
    }
    if (relPath.length > 4096) {
      throw new Error('Path too long');
    }
    if (!this.allowDotfiles) {
      const parts = relPath.split(/[\\/]+/);
      if (parts.some(p => p.startsWith('.') && p !== '.')) {
        throw new Error('Dotfiles/hidden paths are not allowed');
      }
    }
    const base = path.resolve(baseDir);
    const target = path.resolve(base, relPath);
    const relative = path.relative(base, target);
    if (relative.startsWith('..') || path.isAbsolute(relative)) {
      throw new Error('Path traversal detected');
    }
    // Block common sensitive patterns
    const lower = target.toLowerCase();
    for (const pat of this.blockedPathPatterns) {
      if (lower.includes(pat.toLowerCase())) {
        throw new Error('Access to this path is blocked by policy');
      }
    }
    const ext = path.extname(target).toLowerCase();
    if (ext && this.blockedExts.has(ext)) {
      throw new Error(`Files with extension ${ext} are blocked`);
    }
    // Symlink and realpath confinement
    const lst = await fs.lstat(target);
    if (lst.isSymbolicLink()) {
      throw new Error('Symbolic links are not allowed');
    }
    const real = await fs.realpath(target);
    const relReal = path.relative(base, real);
    if (relReal.startsWith('..') || path.isAbsolute(relReal)) {
      throw new Error('Real path escapes base directory');
    }
    return target;
  }

  async opaAvailable() {
    if (this._opaAvailable !== undefined) return this._opaAvailable;
    try {
      // Require policy file to exist and opa in PATH
      if (!fssync.existsSync(this.opaPolicyPath)) {
        this._opaAvailable = false;
        return false;
      }
      await new Promise((resolve, reject) => {
        const p = spawn('opa', ['version']);
        p.on('error', reject);
        p.on('exit', code => (code === 0 ? resolve() : reject(new Error('opa exit'))));
      });
      this._opaAvailable = true;
    } catch {
      this._opaAvailable = false;
    }
    return this._opaAvailable;
  }

  async opaAllow(query, inputObj) {
    const ok = await this.opaAvailable();
    if (!ok) return this.opaRequired ? false : null; // enforce if required
    const runner = async () => new Promise(resolve => {
      try {
        const args = ['eval', '-f', 'pretty', '-I', '-d', this.opaPolicyPath, query, '-i', '-'];
        const p = spawn('opa', args, { stdio: ['pipe', 'pipe', 'pipe'] });
        let out = '';
        p.stdout.on('data', d => (out += d.toString()));
        p.stdin.write(JSON.stringify(inputObj));
        p.stdin.end();
        p.on('error', () => resolve(null));
        p.on('close', () => {
          const decision = out.trim();
          resolve(decision === 'true');
        });
      } catch {
        resolve(null);
      }
    });
    if (!this.otelEnabled) return await runner();
    return await this.tracer.startActiveSpan('mcp.opa.eval', async span => {
      span.setAttribute('opa.query', query);
      try {
        const v = await runner();
        span.setStatus({ code: SpanStatusCode.OK });
        return v;
      } catch (err) {
        span.recordException(err);
        span.setStatus({ code: SpanStatusCode.ERROR, message: String(err && err.message) });
        return null;
      } finally {
        span.end();
      }
    });
  }

  async readMultiServiceFile(args, { _rid } = {}) {
    try {
      if (!this.cbRead.allow()) {
        throw new Error('Circuit open for read operation');
      }
      if (!this.validators.read(args)) {
        throw new Error('Invalid arguments: ' + this.ajv.errorsText(this.validators.read.errors));
      }
      const { service, filePath } = args;
      const opaIn = await this.opaAllow('data.mcp.policy.toolio.allow_input', { service, filePath });
      if (opaIn === false) {
        throw new Error('OPA policy denied input');
      }
      const servicePath = this.getServicePath(service);
      const fullPath = await this.resolveSafePath(servicePath, filePath);
      const st = await fs.stat(fullPath);
      if (!st.isFile()) {
        throw new Error('Requested path is not a file');
      }
      if (st.size > this.maxFileBytes) {
        throw new Error(`File too large (${st.size} bytes), limit is ${this.maxFileBytes}`);
      }
      const contentRaw = await fs.readFile(fullPath, 'utf8');
      const content = this.redact(contentRaw);
      const opaOut = await this.opaAllow('data.mcp.policy.toolio.allow_output', { content });
      if (opaOut === false) {
        throw new Error('OPA policy denied output');
      }

      this.cbRead.success();
      return {
        content: [
          {
            type: 'text',
            text: `File: ${service}/${filePath}\n\n${content}`,
          },
        ],
      };
    } catch (error) {
      this.cbRead.failure();
      return {
        content: [
          {
            type: 'text',
            text: `Error reading file: ${error.message}`,
          },
        ],
        isError: true,
      };
    }
  }

  async listServiceFiles(args, { _rid } = {}) {
    try {
      if (!this.cbList.allow()) {
        throw new Error('Circuit open for list operation');
      }
      if (!this.validators.list(args)) {
        throw new Error('Invalid arguments: ' + this.ajv.errorsText(this.validators.list.errors));
      }
      const { service, directory = '.' } = args;
      // Input-Validierung: directory darf nicht zu lang/leer sein und keine Traversals enthalten
      if (typeof directory !== 'string' || directory.length === 0 || directory.length > 4096 || directory.includes('..') || directory.startsWith('/')) {
        throw new Error('Invalid directory argument');
      }
      const opaIn = await this.opaAllow('data.mcp.policy.toolio.allow_input', { service, filePath: directory });
      if (opaIn === false) {
        throw new Error('OPA policy denied input');
      }
      const servicePath = this.getServicePath(service);
      const fullPath = await this.resolveSafePath(servicePath, directory);
      const items = await fs.readdir(fullPath, { withFileTypes: true });

      if (items.length > this.maxListEntries) {
        throw new Error(`Directory listing too large (${items.length} entries), limit is ${this.maxListEntries}`);
      }

      // Filterung der blockierten Extensions und Patterns
      const filteredList = items
        .filter(item => {
          const ext = path.extname(item.name).toLowerCase();
          if (item.isFile() && this.blockedExts.has(ext)) return false;
          const lower = item.name.toLowerCase();
          for (const pat of this.blockedPathPatterns) {
            if (lower.includes(pat.toLowerCase())) return false;
          }
          if (!this.allowDotfiles && item.name.startsWith('.') && item.name !== '.') return false;
          return true;
        })
        .map(item => ({
          name: item.name,
          type: item.isDirectory() ? 'directory' : 'file',
          path: path.join(directory, item.name),
        }));

      this.cbList.success();
      return {
        content: [
          {
            type: 'text',
            text: `Files in ${service}/${directory}:\n\n${JSON.stringify(filteredList, null, 2)}`,
          },
        ],
      };
    } catch (error) {
      this.cbList.failure();
      return {
        content: [
          {
            type: 'text',
            text: `Error listing files: ${error.message}`,
          },
        ],
        isError: true,
      };
    }
  }

  async getProjectStructure() {
    const structure = {
      services: [
        {
          name: 'API Service',
          path: 'api.menschlichkeit-oesterreich.at/',
          technology: 'FastAPI/Python',
          purpose: 'Backend API für Frontend und CRM Integration',
        },
        {
          name: 'CRM System',
          path: 'crm.menschlichkeit-oesterreich.at/',
          technology: 'Drupal 10 + CiviCRM',
          purpose: 'Mitgliederverwaltung und Spendenverwaltung',
        },
        {
          name: 'Frontend',
          path: 'frontend/',
          technology: 'React/TypeScript + TailwindCSS',
          purpose: 'Hauptwebsite mit Design System Integration',
        },
        {
          name: 'Gaming Platform',
          path: 'web/',
          technology: 'Web Games + Prisma/PostgreSQL',
          purpose: 'Educational democracy games',
        },
        {
          name: 'Website',
          path: 'website/',
          technology: 'WordPress/HTML',
          purpose: 'Statische Website-Inhalte',
        },
        {
          name: 'Automation',
          path: 'automation/n8n/',
          technology: 'n8n Workflows',
          purpose: 'Automatisierte Workflows und Integrationen',
        },
      ],
      keyFiles: [
        'schema.prisma - Database schema für Gaming Platform',
        'package.json - Monorepo workspace configuration',
        'composer.json - PHP dependencies für CRM/API',
        'build-pipeline.sh - Multi-service build automation',
        'scripts/plesk-sync.sh - Deployment synchronization',
        'figma-design-system/ - Design tokens und Branding',
      ],
    };

    return {
      content: [
        {
          type: 'text',
          text: `Multi-Service Project Structure:\n\n${JSON.stringify(structure, null, 2)}`,
        },
      ],
    };
  }

  async searchAcrossServices(args, { _rid } = {}) {
    if (!this.validators.search(args)) {
      return {
        content: [{ type: 'text', text: 'Invalid arguments: ' + this.ajv.errorsText(this.validators.search.errors) }],
        isError: true,
      };
    }
    const { query, fileTypes = ['.js', '.php', '.py', '.ts', '.jsx', '.tsx'] } = args;
    const cfg = {
      maxFiles: Number(process.env.MCP_SEARCH_MAX_FILES || 100),
      maxMatches: Number(process.env.MCP_SEARCH_MAX_MATCHES || 200),
      maxBytes: Number(process.env.MCP_SEARCH_MAX_BYTES || 65536),
      maxDepth: Number(process.env.MCP_SEARCH_MAX_DEPTH || 6),
    };
    const ignoreDirs = new Set((process.env.MCP_SEARCH_IGNORE_DIRS || 'node_modules,.git,dist,build,coverage,vendor').split(',').map(s => s.trim()));
    const results = [];
    let filesScanned = 0;
    let matchesFound = 0;
    const services = ['api', 'crm', 'frontend', 'games', 'website', 'n8n'];
    const lowerQuery = query.toLowerCase();

    const scanDir = async (service, baseDir, rel, depth) => {
      if (depth > cfg.maxDepth) return;
      let entries;
      try {
        entries = await fs.readdir(path.join(baseDir, rel), { withFileTypes: true });
      } catch {
        return;
      }
      for (const ent of entries) {
        if (matchesFound >= cfg.maxMatches || filesScanned >= cfg.maxFiles) return;
        const name = ent.name;
        if (name.startsWith('.') && !this.allowDotfiles) continue;
        if (ent.isDirectory()) {
          if (ignoreDirs.has(name)) continue;
          await scanDir(service, baseDir, path.join(rel, name), depth + 1);
          continue;
        }
        const ext = path.extname(name).toLowerCase();
        if (!fileTypes.includes(ext)) continue;
        const relFile = path.join(rel, name);
        try {
          // OPA input gate per file
          const opaIn = await this.opaAllow('data.mcp.policy.toolio.allow_input', { service, filePath: relFile });
          if (opaIn === false) continue;
          const fullPath = await this.resolveSafePath(this.getServicePath(service), relFile);
          const st = await fs.stat(fullPath);
          if (st.size > cfg.maxBytes) continue;
          filesScanned += 1;
          const raw = await fs.readFile(fullPath, 'utf8');
          const text = raw.slice(0, cfg.maxBytes);
          if (!text.toLowerCase().includes(lowerQuery)) continue;
          const lines = text.split(/\r?\n/);
          for (let i = 0; i < lines.length && matchesFound < cfg.maxMatches; i++) {
            if (lines[i].toLowerCase().includes(lowerQuery)) {
              const snippet = this.redact(lines[i]).slice(0, 200);
              results.push({ service, path: relFile, line: i + 1, snippet });
              matchesFound += 1;
            }
          }
        } catch {
          // ignore errors per-file
          continue;
        }
      }
    };

    const runner = async () => {
      for (const service of services) {
        const base = this.getServicePath(service);
        await scanDir(service, base, '.', 0);
        if (matchesFound >= cfg.maxMatches || filesScanned >= cfg.maxFiles) break;
      }
      // OPA output gate over aggregated output
      const contentForPolicy = JSON.stringify(results);
      const opaOut = await this.opaAllow('data.mcp.policy.toolio.allow_output', { content: contentForPolicy });
      if (opaOut === false) {
        return {
          content: [{ type: 'text', text: 'OPA policy denied output' }],
          isError: true,
        };
      }
      return {
        content: [{ type: 'text', text: `Search results for "${query}":\n\n${JSON.stringify({ results, filesScanned, matchesFound }, null, 2)}` }],
      };
    };

    if (!this.otelEnabled) return await runner();
    return await this.tracer.startActiveSpan('mcp.search', async span => {
      span.setAttribute('search.query.length', query.length);
      span.setAttribute('search.fileTypes', fileTypes.join(','));
      try {
        const out = await runner();
        span.setAttribute('search.filesScanned', filesScanned);
        span.setAttribute('search.matchesFound', matchesFound);
        span.setStatus({ code: SpanStatusCode.OK });
        return out;
      } catch (err) {
        span.recordException(err);
        span.setStatus({ code: SpanStatusCode.ERROR, message: String(err && err.message) });
        return {
          content: [{ type: 'text', text: `Error searching: ${err.message}` }],
          isError: true,
        };
      } finally {
        span.end();
      }
    });
  }

  async start() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
  }

  // Concurrency limiter
  async withConcurrency(fn) {
    if (this._current >= this.maxConcurrent) {
      await new Promise(resolve => this._queue.push(resolve));
    }
    this._current += 1;
    try {
      return await fn();
    } finally {
      this._current -= 1;
      const next = this._queue.shift();
      if (next) next();
    }
  }

  // Simple timeout wrapper
  async withTimeout(promise, ms, msg = 'Operation timed out') {
    let to;
    const timeout = new Promise((_, rej) => {
      to = setTimeout(() => rej(new Error(msg)), ms);
    });
    try {
      const res = await Promise.race([promise, timeout]);
      return res;
    } finally {
      clearTimeout(to);
    }
  }

  // Redact secrets and sensitive markers
  redact(text) {
    if (typeof text !== 'string') return text;
    const patterns = [
      { re: /-----BEGIN [A-Z ]*PRIVATE KEY-----[\s\S]*?-----END [A-Z ]*PRIVATE KEY-----/g, repl: '-----BEGIN PRIVATE KEY-----\n[REDACTED]\n-----END PRIVATE KEY-----' },
      { re: /(AWS_)?SECRET_ACCESS_KEY\s*[:=]\s*[^\n\r]+/gi, repl: 'SECRET_ACCESS_KEY=[REDACTED]' },
      { re: /(x-api-key\s*[:=]\s*)[^\n\r]+/gi, repl: '$1[REDACTED]' },
      { re: /(api[_-]?key\s*[:=]\s*)[^\n\r]+/gi, repl: '$1[REDACTED]' },
      { re: /(authorization:\s*Bearer\s+)[A-Za-z0-9\-_.~+/=]+/gi, repl: '$1[REDACTED]' },
    ];
    let out = text;
    for (const { re, repl } of patterns) out = out.replace(re, repl);
    return out;
  }
}

class TokenBucket {
  constructor(capacity, intervalMs) {
    this.capacity = Math.max(1, capacity);
    this.tokens = this.capacity;
    this.intervalMs = intervalMs;
    this.lastRefill = Date.now();
  }
  tryRemoveToken() {
    const now = Date.now();
    const elapsed = now - this.lastRefill;
    if (elapsed >= this.intervalMs) {
      const periods = Math.floor(elapsed / this.intervalMs);
      this.tokens = Math.min(this.capacity, this.tokens + periods * this.capacity);
      this.lastRefill += periods * this.intervalMs;
    }
    if (this.tokens > 0) {
      this.tokens -= 1;
      return true;
    }
    return false;
  }
}

class CircuitBreaker {
  constructor({ threshold = 5, cooldownMs = 60000, halfOpenPass = 1 } = {}) {
    this.threshold = threshold;
    this.cooldownMs = cooldownMs;
    this.halfOpenPass = halfOpenPass;
    this.state = 'closed';
    this.failures = 0;
    this.successes = 0;
    this.openedAt = 0;
  }
  allow() {
    if (this.state === 'open') {
      if (Date.now() - this.openedAt >= this.cooldownMs) {
        this.state = 'halfopen';
        this.successes = 0;
        this.failures = 0;
        return true;
      }
      return false;
    }
    return true;
  }
  failure() {
    if (this.state === 'halfopen') {
      this.trip();
      return;
    }
    this.failures += 1;
    if (this.failures >= this.threshold) {
      this.trip();
    }
  }
  success() {
    if (this.state === 'halfopen') {
      this.successes += 1;
      if (this.successes >= this.halfOpenPass) {
        this.reset();
      }
      return;
    }
    // closed: reset failure count on success
    this.failures = 0;
  }
  trip() {
    this.state = 'open';
    this.openedAt = Date.now();
    this.failures = 0;
    this.successes = 0;
  }
  reset() {
    this.state = 'closed';
    this.failures = 0;
    this.successes = 0;
    this.openedAt = 0;
  }
}

// Start server if run directly
if (require.main === module) {
  const server = new FileServerMCP();
  server.start().catch(console.error);
}

module.exports = FileServerMCP;
