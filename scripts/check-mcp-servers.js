#!/usr/bin/env node
/**
 * MCP Server Health Check Script
 * Prüft ob alle konfigurierten MCP Server verfügbar sind
 */

import { readFileSync } from 'fs';
import { exec } from 'child_process';
import { promisify } from 'util';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const execAsync = promisify(exec);
const __dirname = dirname(fileURLToPath(import.meta.url));
const rootDir = join(__dirname, '..');

// Farben für Console Output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  cyan: '\x1b[36m'
};

async function checkMCPServers() {
  console.log(`${colors.cyan}🔍 MCP Server Health Check${colors.reset}\n`);
  
  try {
    // Lade MCP-Konfiguration
    const mcpConfigPath = join(rootDir, '.vscode', 'mcp.json');
    const mcpConfig = JSON.parse(readFileSync(mcpConfigPath, 'utf8'));
    
    if (!mcpConfig.servers) {
      console.error(`${colors.red}❌ Keine MCP Server in der Konfiguration gefunden${colors.reset}`);
      process.exit(1);
    }
    
    const servers = Object.entries(mcpConfig.servers);
    console.log(`📊 Gefundene MCP Server: ${servers.length}\n`);
    
    const results = [];
    
    for (const [name, config] of servers) {
      console.log(`${colors.cyan}Prüfe ${name}...${colors.reset}`);
      
      const result = {
        name,
        command: config.command,
        args: config.args,
        env: config.env || {},
        status: 'unknown',
        message: ''
      };
      
      try {
        // Prüfe ob der Command verfügbar ist
        if (config.command === 'npx') {
          const packageName = config.args.find(arg => arg.startsWith('@') || !arg.startsWith('-'));
          
          // Versuche Package Info zu holen
          try {
            await execAsync(`npm view ${packageName} version`, { timeout: 5000 });
            result.status = 'available';
            result.message = `✅ Package ${packageName} ist verfügbar`;
          } catch {
            result.status = 'unavailable';
            result.message = `⚠️  Package ${packageName} nicht gefunden (wird bei Bedarf installiert via npx -y)`;
          }
        } else {
          // Prüfe ob Command existiert
          try {
            await execAsync(`which ${config.command}`, { timeout: 5000 });
            result.status = 'available';
            result.message = `✅ Command ${config.command} ist verfügbar`;
          } catch {
            result.status = 'unavailable';
            result.message = `❌ Command ${config.command} nicht gefunden`;
          }
        }
        
        // Prüfe Umgebungsvariablen
        if (config.env) {
          const missingEnvVars = [];
          
          for (const [envVar, value] of Object.entries(config.env)) {
            // Skip VS Code Variablen wie ${workspaceFolder}
            if (value.includes('${')) continue;
            
            if (!process.env[envVar.replace('${', '').replace('}', '')]) {
              missingEnvVars.push(envVar);
            }
          }
          
          if (missingEnvVars.length > 0) {
            result.status = 'warning';
            result.message += `\n   ⚠️  Fehlende Umgebungsvariablen: ${missingEnvVars.join(', ')}`;
          }
        }
        
      } catch (error) {
        result.status = 'error';
        result.message = `❌ Fehler: ${error.message}`;
      }
      
      results.push(result);
      console.log(`   ${result.message}\n`);
    }
    
    // Zusammenfassung
    console.log(`\n${colors.cyan}📊 Zusammenfassung${colors.reset}`);
    console.log('='.repeat(50));
    
    const available = results.filter(r => r.status === 'available').length;
    const warnings = results.filter(r => r.status === 'warning').length;
    const unavailable = results.filter(r => r.status === 'unavailable').length;
    const errors = results.filter(r => r.status === 'error').length;
    
    console.log(`${colors.green}✅ Verfügbar: ${available}${colors.reset}`);
    if (warnings > 0) console.log(`${colors.yellow}⚠️  Warnungen: ${warnings}${colors.reset}`);
    if (unavailable > 0) console.log(`${colors.yellow}⚠️  Nicht installiert (wird bei Bedarf geladen): ${unavailable}${colors.reset}`);
    if (errors > 0) console.log(`${colors.red}❌ Fehler: ${errors}${colors.reset}`);
    
    console.log('\n💡 Hinweis: MCP Server mit npx -y werden automatisch bei Bedarf installiert.');
    console.log('   Führen Sie "npm run mcp:setup" aus, um alle Server manuell zu installieren.\n');
    
    // Exit Code basierend auf Ergebnissen
    if (errors > 0) {
      process.exit(1);
    } else if (warnings > 0 || unavailable > 0) {
      process.exit(0); // Warnings sind OK, Server werden bei Bedarf installiert
    } else {
      process.exit(0);
    }
    
  } catch (error) {
    console.error(`${colors.red}❌ Fehler beim Laden der MCP-Konfiguration:${colors.reset}`, error.message);
    process.exit(1);
  }
}

// Hauptausführung
checkMCPServers().catch(error => {
  console.error(`${colors.red}❌ Unerwarteter Fehler:${colors.reset}`, error);
  process.exit(1);
});
