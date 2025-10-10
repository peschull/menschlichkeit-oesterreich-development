#!/usr/bin/env node
/**
 * MCP Server Debug & Test Script
 * Testet alle verfügbaren MCP-Server systematisch
 */

import { spawn } from 'child_process';

const GREEN = '\x1b[32m';
const RED = '\x1b[31m';
const YELLOW = '\x1b[33m';
const BLUE = '\x1b[34m';
const RESET = '\x1b[0m';

console.log(`${BLUE}🔍 MCP Server Diagnose & Test${RESET}`);
console.log('================================\n');

// Verfügbare MCP-Server zum Testen
const mcpServers = [
    {
        name: 'Filesystem MCP',
        package: '@modelcontextprotocol/server-filesystem',
        args: ['.'],
        env: {}
    },
    {
        name: 'Memory MCP',
        package: '@modelcontextprotocol/server-memory',
        args: [],
        env: {}
    },
    {
        name: 'Figma MCP',
        package: 'figma-mcp',
        args: [],
        env: { FIGMA_API_TOKEN: 'test' }
    },
    {
        name: 'PostgreSQL MCP',
        package: 'enhanced-postgres-mcp-server',
        args: [],
        env: { DATABASE_URL: 'postgresql://test:test@localhost:5432/test' }
    },
    {
        name: 'Puppeteer MCP',
        package: 'puppeteer-mcp-server',
        args: [],
        env: {}
    },
    {
        name: 'Sequential Thinking MCP',
        package: '@modelcontextprotocol/server-sequential-thinking',
        args: [],
        env: {}
    }
];

async function testMcpServer(server) {
    return new Promise((resolve) => {
        console.log(`${YELLOW}📦 Teste ${server.name}...${RESET}`);
        
        const child = spawn('npx', ['-y', server.package, ...server.args], {
            env: { ...process.env, ...server.env },
            stdio: ['pipe', 'pipe', 'pipe']
        });

        let stdout = '';
        let stderr = '';
        let timeout;

        // Timeout nach 10 Sekunden
        timeout = setTimeout(() => {
            child.kill();
            console.log(`${RED}❌ ${server.name} - Timeout nach 10s${RESET}`);
            resolve({ name: server.name, status: 'timeout', package: server.package });
        }, 10000);

        child.stdout.on('data', (data) => {
            stdout += data.toString();
        });

        child.stderr.on('data', (data) => {
            stderr += data.toString();
        });

        child.on('close', (code) => {
            clearTimeout(timeout);
            
            // MCP-Server laufen normalerweile endlos, daher ist ein schneller Exit oft ein Fehler
            if (code === 0 && stdout.length === 0) {
                console.log(`${RED}❌ ${server.name} - Kein Output${RESET}`);
                resolve({ name: server.name, status: 'no_output', package: server.package });
            } else if (stderr.includes('Error') || stderr.includes('SyntaxError')) {
                console.log(`${RED}❌ ${server.name} - Fehler: ${stderr.slice(0, 100)}...${RESET}`);
                resolve({ name: server.name, status: 'error', package: server.package, error: stderr });
            } else if (stdout.includes('MCP') || stdout.includes('server') || code === null) {
                console.log(`${GREEN}✅ ${server.name} - Erfolgreich gestartet${RESET}`);
                resolve({ name: server.name, status: 'success', package: server.package });
            } else {
                console.log(`${YELLOW}⚠️ ${server.name} - Unbekannter Status (Code: ${code})${RESET}`);
                resolve({ name: server.name, status: 'unknown', package: server.package, code });
            }
        });

        child.on('error', (error) => {
            clearTimeout(timeout);
            console.log(`${RED}❌ ${server.name} - Start-Fehler: ${error.message}${RESET}`);
            resolve({ name: server.name, status: 'start_error', package: server.package, error: error.message });
        });

        // Sende ein einfaches MCP-Init-Message
        setTimeout(() => {
            try {
                const initMessage = JSON.stringify({
                    jsonrpc: "2.0",
                    id: 1,
                    method: "initialize",
                    params: {
                        protocolVersion: "1.0.0",
                        capabilities: {},
                        clientInfo: { name: "test-client", version: "1.0.0" }
                    }
                }) + '\n';
                
                child.stdin.write(initMessage);
            } catch {
                // Ignore write errors
            }
        }, 1000);
    });
}

async function main() {
    const results = [];
    
    for (const server of mcpServers) {
        const result = await testMcpServer(server);
        results.push(result);
        console.log(''); // Leerzeile
    }

    // Zusammenfassung
    console.log(`${BLUE}📊 Zusammenfassung:${RESET}`);
    console.log('==================');
    
    const successful = results.filter(r => r.status === 'success');
    const failed = results.filter(r => r.status !== 'success');

    console.log(`${GREEN}✅ Erfolgreich: ${successful.length}/${results.length}${RESET}`);
    successful.forEach(r => console.log(`   - ${r.name} (${r.package})`));
    
    if (failed.length > 0) {
        console.log(`${RED}❌ Fehlgeschlagen: ${failed.length}/${results.length}${RESET}`);
        failed.forEach(r => console.log(`   - ${r.name}: ${r.status} (${r.package})`));
    }

    // Empfehlungen
    console.log(`\n${BLUE}💡 Empfehlungen:${RESET}`);
    failed.forEach(r => {
        if (r.status === 'start_error') {
            console.log(`${YELLOW}📦 ${r.name}: npm install -g ${r.package}${RESET}`);
        } else if (r.status === 'error') {
            console.log(`${YELLOW}🔧 ${r.name}: Konfiguration prüfen${RESET}`);
        }
    });
}

main().catch(console.error);