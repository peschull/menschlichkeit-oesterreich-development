#!/usr/bin/env node
/**
 * ADR Index Generator
 * Generates an index of Architecture Decision Records (ADRs)
 * for the Menschlichkeit Österreich project
 */

import { readdir, readFile, writeFile } from 'fs/promises';
import { join, basename } from 'path';
import { fileURLToPath } from 'url';

const __dirname = fileURLToPath(new URL('.', import.meta.url));
const ADR_DIR = join(__dirname, '../../docs/architecture/ADRs');
const INDEX_FILE = join(ADR_DIR, 'ADR-INDEX.md');

async function generateADRIndex() {
  try {
    // Read all ADR files
    const files = await readdir(ADR_DIR);
    const adrFiles = files
      .filter(f => f.match(/^ADR-\d{4}-.*\.md$/) && f !== 'ADR-INDEX.md')
      .sort();

    if (adrFiles.length === 0) {
      console.log('ℹ️ No ADR files found - creating placeholder index');
      await createPlaceholderIndex();
      return;
    }

    // Parse ADR metadata
    const adrs = await Promise.all(
      adrFiles.map(async (file) => {
        const content = await readFile(join(ADR_DIR, file), 'utf-8');
        const match = content.match(/^#\s+(.+)/m);
        const title = match ? match[1] : basename(file, '.md');
        const number = file.match(/ADR-(\d{4})/)[1];
        
        return { file, title, number };
      })
    );

    // Generate index content
    const indexContent = `# Architecture Decision Records (ADR) Index

> Auto-generated index of all ADRs in this project

## What are ADRs?

Architecture Decision Records (ADRs) document important architectural decisions made during the development of this project.

## ADR List

${adrs.map(adr => `- [ADR-${adr.number}](./${adr.file}) - ${adr.title}`).join('\n')}

---

**Total ADRs:** ${adrs.length}  
**Last Updated:** ${new Date().toISOString().split('T')[0]}

## ADR Template

New ADRs should follow the structure:

\`\`\`markdown
# ADR-XXXX: [Title]

**Status:** Proposed | Accepted | Deprecated | Superseded  
**Date:** YYYY-MM-DD  
**Decision Makers:** [Names]

## Context

[Describe the problem and context]

## Decision

[Describe the decision made]

## Consequences

[Describe positive and negative consequences]

## References

[Links to related resources]
\`\`\`
`;

    await writeFile(INDEX_FILE, indexContent, 'utf-8');
    console.log(`✅ ADR Index generated: ${adrFiles.length} records indexed`);
  } catch (error) {
    if (error.code === 'ENOENT') {
      console.log('ℹ️ ADR directory not found - creating structure');
      await createPlaceholderIndex();
    } else {
      console.error('❌ Error generating ADR index:', error.message);
      process.exit(1);
    }
  }
}

async function createPlaceholderIndex() {
  const placeholderContent = `# Architecture Decision Records (ADR) Index

> This project will document architectural decisions as they are made

## What are ADRs?

Architecture Decision Records (ADRs) document important architectural decisions made during the development of this project.

## Getting Started

No ADRs have been created yet. When architectural decisions are made, they will be documented here following the ADR format.

## ADR Template

New ADRs should be named \`ADR-XXXX-short-title.md\` and follow this structure:

\`\`\`markdown
# ADR-0001: [Title]

**Status:** Proposed | Accepted | Deprecated | Superseded  
**Date:** YYYY-MM-DD  
**Decision Makers:** [Names]

## Context

[Describe the problem and context]

## Decision

[Describe the decision made]

## Consequences

[Describe positive and negative consequences]

## References

[Links to related resources]
\`\`\`

---

**Last Updated:** ${new Date().toISOString().split('T')[0]}
`;

  await writeFile(INDEX_FILE, placeholderContent, 'utf-8');
  console.log('✅ Placeholder ADR index created');
}

// Run the generator
generateADRIndex();
