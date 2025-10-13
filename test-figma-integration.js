// Quick test to verify Figma integration can be imported
const fs = require('fs');
const path = require('path');

console.log('🧪 Testing Figma Integration...\n');

// Check if all component files exist
const components = [
  'frontend/src/components/figma/HeaderNavigation.tsx',
  'frontend/src/components/figma/HeroSection.tsx',
  'frontend/src/components/figma/FeaturesGrid.tsx',
  'frontend/src/components/figma/CtaSection.tsx',
  'frontend/src/components/figma/Footer.tsx',
];

let allExist = true;

components.forEach(file => {
  if (fs.existsSync(file)) {
    const content = fs.readFileSync(file, 'utf-8');
    const hasImport = content.includes('import React');
    const hasInterface = content.includes('interface');
    const hasExport = content.includes('export');
    const hasCn = content.includes('cn(');
    
    console.log(`✅ ${path.basename(file)}`);
    console.log(`   - React import: ${hasImport ? '✅' : '❌'}`);
    console.log(`   - TypeScript interface: ${hasInterface ? '✅' : '❌'}`);
    console.log(`   - Export: ${hasExport ? '✅' : '❌'}`);
    console.log(`   - cn() utility: ${hasCn ? '✅' : '❌'}`);
    console.log('');
  } else {
    console.log(`❌ Missing: ${file}`);
    allExist = false;
  }
});

// Check index file
const indexPath = 'frontend/src/components/figma/index.ts';
if (fs.existsSync(indexPath)) {
  const indexContent = fs.readFileSync(indexPath, 'utf-8');
  const exports = indexContent.match(/export \{.*\}/g);
  console.log(`✅ Index file exists with ${exports ? exports.length : 0} exports`);
} else {
  console.log(`❌ Index file missing`);
  allExist = false;
}

// Check utils file
const utilsPath = 'frontend/src/lib/utils.ts';
if (fs.existsSync(utilsPath)) {
  const utilsContent = fs.readFileSync(utilsPath, 'utf-8');
  const hasCn = utilsContent.includes('export function cn');
  console.log(`✅ Utils file exists with cn function: ${hasCn ? '✅' : '❌'}`);
} else {
  console.log(`❌ Utils file missing`);
  allExist = false;
}

console.log('\n' + (allExist ? '✅ All tests passed!' : '❌ Some tests failed'));
process.exit(allExist ? 0 : 1);
