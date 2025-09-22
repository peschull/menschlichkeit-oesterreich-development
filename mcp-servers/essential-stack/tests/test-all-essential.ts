#!/usr/bin/env node

/**
 * Test script for essential MCP servers
 * Tests Stripe, Mailchimp, and Google Services integration
 */

import { exec } from 'child_process';
import path from 'path';
import { promisify } from 'util';

const execAsync = promisify(exec);

const SERVERS = [
  {
    name: 'Stripe MCP Server',
    path: 'dist/stripe/index.js',
    description: 'Membership payment processing with Austrian compliance'
  },
  {
    name: 'Mailchimp MCP Server', 
    path: 'dist/mailchimp/index.js',
    description: 'Newsletter and member communication management'
  },
  {
    name: 'Google Services MCP Server',
    path: 'dist/google-services/index.js',
    description: 'Google Sheets member management and Gmail integration'
  }
];

async function testServerBuild(serverPath: string, serverName: string) {
  try {
    const fullPath = path.join(process.cwd(), serverPath);
    console.log(`🧪 Testing ${serverName}...`);
    
    // Check if file exists
    const fs = await import('fs');
    if (!fs.existsSync(fullPath)) {
      throw new Error(`Server file not found: ${fullPath}`);
    }
    
    // Try to import the module
    const serverModule = await import(fullPath);
    if (!serverModule.server) {
      throw new Error('Server export not found');
    }
    
    console.log(`✅ ${serverName} - Build erfolgreich`);
    return true;
  } catch (error) {
    console.error(`❌ ${serverName} - Fehler:`, error instanceof Error ? error.message : error);
    return false;
  }
}

async function testEnvironmentVariables() {
  console.log('\n🔧 Environment-Variablen prüfen...');
  
  const requiredVars = [
    'STRIPE_SECRET_KEY',
    'MAILCHIMP_API_KEY',
    'GOOGLE_CREDENTIALS_PATH'
  ];
  
  const missingVars: string[] = [];
  
  for (const varName of requiredVars) {
    if (!process.env[varName]) {
      missingVars.push(varName);
    }
  }
  
  if (missingVars.length > 0) {
    console.log(`⚠️  Fehlende Environment-Variablen (in .env konfigurieren):`);
    missingVars.forEach(v => console.log(`   - ${v}`));
    console.log('\n💡 Kopiere .env.example zu .env und konfiguriere die API-Keys');
  } else {
    console.log('✅ Alle erforderlichen Environment-Variablen gesetzt');
  }
}

async function main() {
  console.log('🚀 Menschlichkeit Österreich - Essential MCP Server Tests\n');
  
  let allPassed = true;
  
  // Test environment setup
  await testEnvironmentVariables();
  
  console.log('\n📦 MCP Server Build-Tests...\n');
  
  // Test each server
  for (const server of SERVERS) {
    const passed = await testServerBuild(server.path, server.name);
    if (!passed) allPassed = false;
    console.log(`   ${server.description}\n`);
  }
  
  // Summary
  console.log('='.repeat(50));
  if (allPassed) {
    console.log('🎉 Alle Essential MCP Server erfolgreich getestet!');
    console.log('\n📋 Nächste Schritte:');
    console.log('1. .env.example zu .env kopieren und API-Keys eintragen');
    console.log('2. VS Code MCP-Konfiguration aktualisieren');
    console.log('3. Server in VS Code testen');
    console.log('\n💡 Bereit für Produktive Nutzung! 🚀');
  } else {
    console.log('❌ Einige Tests sind fehlgeschlagen.');
    console.log('Überprüfe die Build-Errors und Dependencies.');
  }
  
  console.log('='.repeat(50));
}

if (require.main === module) {
  main().catch(console.error);
}

export { testServerBuild };
