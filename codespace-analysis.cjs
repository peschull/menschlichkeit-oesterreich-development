const fs = require('fs');

// Codespace Configuration Deep Analysis
console.log('🔍 GITHUB CODESPACE - TIEFGRÜNDIGE ANALYSE');
console.log('==========================================');
console.log();

try {
    // Load and parse devcontainer.json
    const config = JSON.parse(fs.readFileSync('.devcontainer/devcontainer.json', 'utf8'));
    
    console.log('📋 CONFIGURATION OVERVIEW:');
    console.log('Name:', config.name);
    console.log('Base Image:', config.image);
    console.log('Features:', Object.keys(config.features || {}).length);
    console.log('Forwarded Ports:', config.forwardPorts?.length || 0);
    console.log('VS Code Extensions:', config.customizations?.vscode?.extensions?.length || 0);
    console.log('Secrets:', Object.keys(config.secrets || {}).length);
    console.log();

    // Feature Analysis
    console.log('🔧 FEATURES ANALYSIS:');
    Object.entries(config.features || {}).forEach(([feature, featureConfig]) => {
        console.log(`- ${feature}: ${JSON.stringify(featureConfig)}`);
    });
    console.log();

    // Port Configuration Analysis
    console.log('🌐 PORT CONFIGURATION ANALYSIS:');
    const portIssues = [];
    config.forwardPorts?.forEach(port => {
        const attr = config.portsAttributes?.[port];
        console.log(`- Port ${port}: ${attr?.label || 'No label'} (${attr?.protocol || 'http'})`);
        
        // Check for common port conflicts
        if (port === 3000 && !attr?.label?.includes('Frontend')) {
            portIssues.push(`Port 3000 should be labeled for Frontend`);
        }
        if (port === 8000 && !attr?.label?.includes('CRM')) {
            portIssues.push(`Port 8000 should be labeled for CRM`);
        }
    });
    
    if (portIssues.length > 0) {
        console.log('⚠️ PORT ISSUES:');
        portIssues.forEach(issue => console.log(`  - ${issue}`));
    }
    console.log();

    // Security Analysis
    console.log('🔐 SECURITY ANALYSIS:');
    console.log('Secrets configured:', Object.keys(config.secrets || {}).length);
    Object.entries(config.secrets || {}).forEach(([secret, secretConfig]) => {
        console.log(`- ${secret}: ${secretConfig.description}`);
    });
    
    // Check for missing essential secrets
    const requiredSecrets = ['SSH_PRIVATE_KEY', 'PLESK_HOST', 'LARAVEL_DB_PASS', 'CIVICRM_DB_PASS'];
    const missingSecrets = requiredSecrets.filter(secret => !config.secrets?.[secret]);
    if (missingSecrets.length > 0) {
        console.log('❌ MISSING ESSENTIAL SECRETS:');
        missingSecrets.forEach(secret => console.log(`  - ${secret}`));
    }
    console.log();

    // Command Analysis
    console.log('⚙️ COMMAND ANALYSIS:');
    console.log('onCreateCommand:', config.onCreateCommand ? '✅ Set' : '❌ Missing');
    console.log('postCreateCommand:', config.postCreateCommand ? '✅ Set' : '❌ Missing');
    console.log('postStartCommand:', config.postStartCommand ? '✅ Set' : '❌ Missing');
    
    // Analyze command structure
    if (config.onCreateCommand) {
        console.log(`  onCreateCommand: ${config.onCreateCommand}`);
    }
    if (config.postCreateCommand) {
        console.log(`  postCreateCommand: ${config.postCreateCommand}`);
    }
    if (config.postStartCommand) {
        console.log(`  postStartCommand: ${config.postStartCommand}`);
    }
    console.log();

    // VS Code Extensions Analysis
    console.log('🧩 VS CODE EXTENSIONS ANALYSIS:');
    const essentialExtensions = [
        'ms-vscode.vscode-typescript-next',
        'bradlc.vscode-tailwindcss', 
        'ms-python.python',
        'bmewburn.vscode-intelephense-client',
        'GitHubCopilot.github-copilot'
    ];
    
    config.customizations?.vscode?.extensions?.forEach(ext => {
        console.log(`- ${ext}`);
    });
    
    const missingExtensions = essentialExtensions.filter(ext => 
        !config.customizations?.vscode?.extensions?.includes(ext)
    );
    if (missingExtensions.length > 0) {
        console.log('⚠️ POTENTIALLY MISSING EXTENSIONS:');
        missingExtensions.forEach(ext => console.log(`  - ${ext}`));
    }
    console.log();

    // Container Environment Analysis  
    console.log('🐳 CONTAINER ENVIRONMENT:');
    Object.entries(config.containerEnv || {}).forEach(([key, value]) => {
        console.log(`- ${key}: ${value}`);
    });
    console.log();

    // Mounts Analysis
    console.log('💾 MOUNTS ANALYSIS:');
    if (config.mounts?.length > 0) {
        config.mounts.forEach(mount => {
            console.log(`- ${mount}`);
        });
    } else {
        console.log('No custom mounts configured');
    }
    console.log();

    // Quality Score Calculation
    let qualityScore = 100;
    let issues = [];

    // Deduct points for missing configurations
    if (portIssues.length > 0) {
        qualityScore -= portIssues.length * 5;
        issues.push(`Port configuration issues: ${portIssues.length}`);
    }
    if (missingSecrets.length > 0) {
        qualityScore -= missingSecrets.length * 10;
        issues.push(`Missing essential secrets: ${missingSecrets.length}`);
    }
    if (missingExtensions.length > 0) {
        qualityScore -= missingExtensions.length * 3;
        issues.push(`Missing recommended extensions: ${missingExtensions.length}`);
    }
    if (!config.onCreateCommand || !config.postCreateCommand || !config.postStartCommand) {
        qualityScore -= 15;
        issues.push('Missing lifecycle commands');
    }

    console.log('🏆 QUALITY ASSESSMENT:');
    console.log(`Overall Score: ${qualityScore}/100`);
    if (issues.length > 0) {
        console.log('Issues found:');
        issues.forEach(issue => console.log(`  - ${issue}`));
    }
    
    // Recommendations
    console.log();
    console.log('💡 RECOMMENDATIONS:');
    if (qualityScore >= 90) {
        console.log('✅ Excellent configuration - ready for production use');
    } else if (qualityScore >= 75) {
        console.log('⚠️ Good configuration with minor improvements needed');
    } else {
        console.log('❌ Configuration needs significant improvements');
    }

} catch (error) {
    console.error('❌ Error analyzing devcontainer.json:', error.message);
}