#!/usr/bin/env node
import { writeFileSync, readFileSync } from 'fs';
import { join } from 'path';

console.log('🔧 MCP Server Configuration Cleanup');
console.log('====================================');

// Lade aktuelle Konfiguration
const mcpConfigPath = join(process.cwd(), '.vscode', 'mcp.json');
const currentConfig = JSON.parse(readFileSync(mcpConfigPath, 'utf8'));

console.log('📊 Aktuelle Server:', Object.keys(currentConfig.mcpServers).length);

// Bekannte problematische Server entfernen
const problematicServers = [
    'oraios/serena',
    'microsoft/markitdown',
    'markitdown'
];

// Bekannte funktionierende Server (aus vorherigen Tests)
const workingServers = {
    "memory": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "sequential-thinking": {
        "command": "npx", 
        "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "figma": {
        "command": "npx",
        "args": ["-y", "figma-mcp"],
        "env": {
            "FIGMA_ACCESS_TOKEN": "${FIGMA_ACCESS_TOKEN}"
        }
    },
    "github": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-github"]
    },
    "upstash-context7": {
        "command": "npx",
        "args": ["-y", "@upstash/context7-mcp"]
    },
    "filesystem": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-filesystem", "${workspaceFolder}"]
    }
};

// Backup der aktuellen Konfiguration
const backupPath = join(process.cwd(), '.vscode', `mcp-backup-${Date.now()}.json`);
writeFileSync(backupPath, JSON.stringify(currentConfig, null, 2));
console.log('💾 Backup erstellt:', backupPath);

// Erstelle bereinigte Konfiguration (nur funktionierende Server)
const cleanConfig = {
    mcpServers: workingServers
};

// Speichere bereinigte Konfiguration
writeFileSync(mcpConfigPath, JSON.stringify(cleanConfig, null, 2));

console.log('✅ Bereinigte Konfiguration gespeichert');
console.log('📦 Funktionierende Server:', Object.keys(workingServers).length);
console.log('🔧 Server-Liste:', Object.keys(workingServers).join(', '));

// Erstelle Reparatur-Report
const report = {
    timestamp: new Date().toISOString(),
    action: 'MCP Server Cleanup',
    problematicServersRemoved: problematicServers,
    workingServersKept: Object.keys(workingServers),
    totalServers: Object.keys(workingServers).length,
    backupFile: backupPath,
    recommendation: 'VS Code neustarten für Aktivierung der bereinigten Konfiguration'
};

const reportPath = join(process.cwd(), 'quality-reports', 'mcp-server-cleanup-report.json');
writeFileSync(reportPath, JSON.stringify(report, null, 2));

console.log('\n📋 Cleanup-Report:', reportPath);
console.log('\n🔄 Nächste Schritte:');
console.log('1. VS Code neustarten (Cmd/Ctrl + Shift + P → "Developer: Reload Window")');
console.log('2. MCP Server-Status in Copilot prüfen');
console.log('3. Funktionalität testen');