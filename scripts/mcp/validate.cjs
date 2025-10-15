const fs = require('fs');
const path = require('path');

/**
 * MCP Configuration Validator
 * Validates .mcp.json against schema and best practices
 */

const CONFIG_PATH = path.join(__dirname, '../../.mcp.json');

function validateMcpConfig() {
  console.log('🔍 Validating MCP Configuration...\n');

  // Check if config file exists
  if (!fs.existsSync(CONFIG_PATH)) {
    console.error('❌ Error: .mcp.json not found at:', CONFIG_PATH);
    process.exit(1);
  }

  // Read and parse config
  let config;
  try {
    const content = fs.readFileSync(CONFIG_PATH, 'utf8');
    config = JSON.parse(content);
    console.log('✅ Valid JSON syntax');
  } catch (err) {
    console.error('❌ JSON parsing error:', err.message);
    process.exit(1);
  }

  // Validate required fields
  const errors = [];
  const warnings = [];

  if (!config.version) {
    errors.push('Missing required field: version');
  }

  if (!config.mcpServers || typeof config.mcpServers !== 'object') {
    errors.push('Missing or invalid field: mcpServers (must be an object)');
  } else {
    const serverCount = Object.keys(config.mcpServers).length;
    console.log(`✅ Found ${serverCount} configured MCP server(s)`);

    // Validate each server
    Object.entries(config.mcpServers).forEach(([name, serverConfig]) => {
      if (!serverConfig.command) {
        errors.push(`Server "${name}": missing required field "command"`);
      }

      if (!serverConfig.args || !Array.isArray(serverConfig.args)) {
        errors.push(`Server "${name}": missing or invalid "args" (must be an array)`);
      }

      // Check for placeholder env vars
      if (serverConfig.env) {
        Object.entries(serverConfig.env).forEach(([envKey, envValue]) => {
          if (envValue.includes('${') && envValue.includes('}')) {
            warnings.push(`Server "${name}": env var "${envKey}" uses placeholder "${envValue}" - ensure it's set in your environment`);
          }
        });
      }
    });
  }

  // Validate removedServers documentation
  if (config.removedServers && Array.isArray(config.removedServers)) {
    console.log(`✅ Documented ${config.removedServers.length} removed server(s)`);
    
    config.removedServers.forEach((removed) => {
      if (!removed.name) {
        warnings.push('Removed server entry missing "name" field');
      }
      if (!removed.reason) {
        warnings.push(`Removed server "${removed.name || 'unknown'}": missing "reason" field`);
      }
    });
  }

  // Print results
  console.log('\n' + '='.repeat(50));
  
  if (errors.length > 0) {
    console.log('\n❌ Validation Errors:');
    errors.forEach(err => console.log(`  - ${err}`));
  }

  if (warnings.length > 0) {
    console.log('\n⚠️  Warnings:');
    warnings.forEach(warn => console.log(`  - ${warn}`));
  }

  if (errors.length === 0) {
    console.log('\n✅ Configuration is valid!');
    
    if (warnings.length === 0) {
      console.log('✅ No warnings');
    }
    
    process.exit(0);
  } else {
    console.log(`\n❌ Validation failed with ${errors.length} error(s)`);
    process.exit(1);
  }
}

// Run validation
validateMcpConfig();
