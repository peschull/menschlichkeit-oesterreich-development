// GitHub Codespace Service Health Monitor & Debug Tool
const http = require('http');
const https = require('https');

class CodespaceDebugger {
  constructor() {
    this.codespace = process.env.CODESPACE_NAME;
    this.services = [
      { name: 'Frontend (React)', port: 3000, path: '/', type: 'web' },
      { name: 'Games Platform', port: 3001, path: '/', type: 'web' },
      { name: 'API (FastAPI)', port: 8001, path: '/docs', type: 'api' },
      { name: 'CRM (CiviCRM)', port: 8000, path: '/', type: 'web' },
      { name: 'n8n Automation', port: 5678, path: '/healthz', type: 'service' },
      { name: 'Website', port: 8080, path: '/', type: 'web' }
    ];

    this.secrets = [
      'SSH_PRIVATE_KEY',
      'PLESK_HOST',
      'LARAVEL_DB_PASS',
      'CIVICRM_DB_PASS',
      'MAIL_INFO_PASSWORD',
      'CODACY_API_TOKEN',
      'SNYK_TOKEN'
    ];
  }

  log(level, service, message) {
    const timestamp = new Date().toISOString();
    const emoji = {
      'info': 'ℹ️',
      'success': '✅',
      'warning': '⚠️',
      'error': '❌',
      'debug': '🔍'
    }[level] || 'ℹ️';

    console.log(`${timestamp} ${emoji} [${service}] ${message}`);
  }

  async checkService(service) {
    const baseUrl = this.codespace
      ? `https://${this.codespace}-${service.port}.preview.app.github.dev`
      : `http://localhost:${service.port}`;

    const url = `${baseUrl}${service.path}`;

    return new Promise((resolve) => {
      const startTime = Date.now();
      const client = url.startsWith('https') ? https : http;

      const req = client.get(url, { timeout: 5000 }, (res) => {
        const responseTime = Date.now() - startTime;
        const status = res.statusCode;

        if (status >= 200 && status < 400) {
          this.log('success', service.name, `${status} - ${responseTime}ms - ${url}`);
          resolve({ success: true, status, responseTime, url });
        } else {
          this.log('warning', service.name, `${status} - ${responseTime}ms - ${url}`);
          resolve({ success: false, status, responseTime, url });
        }
      });

      req.on('timeout', () => {
        req.destroy();
        this.log('error', service.name, `Timeout - ${url}`);
        resolve({ success: false, error: 'timeout', url });
      });

      req.on('error', (err) => {
        this.log('error', service.name, `${err.message} - ${url}`);
        resolve({ success: false, error: err.message, url });
      });
    });
  }

  checkSecrets() {
    this.log('info', 'SECRETS', 'Checking GitHub Secrets availability...');

    const available = [];
    const missing = [];

    for (const secret of this.secrets) {
      if (process.env[secret]) {
        available.push(secret);
        const masked = `***${process.env[secret].slice(-4)}`;
        this.log('success', 'SECRET', `${secret}: ${masked}`);
      } else {
        missing.push(secret);
        this.log('error', 'SECRET', `${secret}: Missing`);
      }
    }

    return { available, missing };
  }

  checkEnvironment() {
    this.log('info', 'ENVIRONMENT', 'Checking Codespace environment...');

    const env = {
      codespace: this.codespace || 'Not in Codespace',
      user: process.env.GITHUB_USER || 'Unknown',
      workspace: process.env.PWD || process.cwd(),
      nodeVersion: process.version,
      platform: process.platform,
      arch: process.arch
    };

    for (const [key, value] of Object.entries(env)) {
      this.log('info', 'ENV', `${key}: ${value}`);
    }

    return env;
  }

  async runHealthCheck() {
    console.log('🔍 GITHUB CODESPACE - COMPLETE DEBUG ANALYSIS');
    console.log('==============================================');
    console.log();

    // 1. Environment Check
    const env = this.checkEnvironment();
    console.log();

    // 2. Secrets Check
    const secrets = this.checkSecrets();
    console.log();

    // 3. Service Health Check
    this.log('info', 'SERVICES', 'Testing all service endpoints...');
    const results = [];

    for (const service of this.services) {
      const result = await this.checkService(service);
      results.push({ ...service, ...result });

      // Small delay between requests
      await new Promise(resolve => setTimeout(resolve, 500));
    }

    console.log();
    this.generateSummary(env, secrets, results);

    return {
      environment: env,
      secrets: secrets,
      services: results,
      timestamp: new Date().toISOString()
    };
  }

  generateSummary(env, secrets, services) {
    console.log('📊 DEBUG SUMMARY');
    console.log('================');
    console.log();

    // Environment Summary
    console.log('🌐 Environment:');
    console.log(`  Codespace: ${env.codespace !== 'Not in Codespace' ? '✅' : '❌'} ${env.codespace}`);
    console.log(`  User: ${env.user}`);
    console.log(`  Node.js: ${env.nodeVersion}`);
    console.log();

    // Secrets Summary
    console.log('🔐 Secrets:');
    console.log(`  Available: ${secrets.available.length}/${this.secrets.length}`);
    console.log(`  Missing: ${secrets.missing.join(', ') || 'None'}`);
    console.log();

    // Services Summary
    const healthy = services.filter(s => s.success).length;
    const total = services.length;

    console.log('🚀 Services:');
    console.log(`  Healthy: ${healthy}/${total}`);
    console.log();

    services.forEach(service => {
      const status = service.success ? '✅' : '❌';
      const time = service.responseTime ? `${service.responseTime}ms` : 'N/A';
      console.log(`  ${status} ${service.name} (${service.port}) - ${time}`);
    });

    console.log();

    // Overall Health
    const envScore = env.codespace !== 'Not in Codespace' ? 1 : 0;
    const secretsScore = secrets.available.length / this.secrets.length;
    const servicesScore = healthy / total;
    const overallScore = ((envScore + secretsScore + servicesScore) / 3) * 100;

    let grade = 'D';
    let color = '🔴';

    if (overallScore >= 90) {
      grade = 'A';
      color = '🟢';
    } else if (overallScore >= 80) {
      grade = 'B';
      color = '🟡';
    } else if (overallScore >= 70) {
      grade = 'C';
      color = '🟡';
    }

    console.log(`${color} Overall Health: ${overallScore.toFixed(1)}% (Grade: ${grade})`);

    if (overallScore >= 90) {
      console.log('🎊 Codespace is fully operational!');
    } else if (overallScore >= 70) {
      console.log('⚠️ Codespace needs attention - check missing secrets or services');
    } else {
      console.log('🚨 Codespace has significant issues - review configuration');
    }
  }
}

// Export for use as module or run directly
if (require.main === module) {
  const codespaceDebugger = new CodespaceDebugger();
  codespaceDebugger.runHealthCheck().catch(console.error);
}

module.exports = CodespaceDebugger;
