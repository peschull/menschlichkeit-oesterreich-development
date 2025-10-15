# MCP Configuration Changelog

## 2025-10-15 - Major Cleanup (chore/mcp-prune-20251015)

### Overview
Consolidated multiple fragmented MCP configurations into a single `.mcp.json` at repository root.
Implemented strict approval process with double-confirmation for all server removals.

### Inventory
**Found configurations:**
- `mcp.json` (root) - 18 local utility servers
- `.vscode/mcp.json` - empty placeholder
- `.vscode/mcp-backup-20251010_071510.json` - 12 MCP servers (backup from previous config)
- `config-templates/mcp-hosts.json` - SSH host config (not MCP-related, preserved)

### Approved MCP Servers (Active)
These servers are now configured in `.mcp.json`:

1. **github** - `@modelcontextprotocol/server-github`
   - Requires: `GITHUB_PERSONAL_ACCESS_TOKEN`
   
2. **codacy** - `@codacy/codacy-mcp-server`
   - Requires: `CODACY_API_TOKEN`
   
3. **figma** - `@modelcontextprotocol/server-figma`
   - Requires: `FIGMA_PERSONAL_ACCESS_TOKEN`
   
4. **sentry** - `@sentry/mcp-server`
   - Requires: `SENTRY_AUTH_TOKEN`, `SENTRY_ORG`
   
5. **huggingface** - `@huggingface/mcp-server`
   - Requires: `HUGGING_FACE_API_TOKEN`
   
6. **markitdown** - `@microsoft/markitdown-mcp-server`
   - No auth required

**Note:** DeepWiki and GitHub Copilot MCP servers were approved but package names need verification before adding.

### Removed Servers (Double-Confirmed)

Each server below received explicit double-confirmation before removal:

1. **filesystem** 
   - **Confirmation 1:** "CONFIRM REMOVE filesystem" ✅
   - **Confirmation 2:** "CONFIRM REMOVE filesystem AGAIN" ✅
   - **Previous:** `@modelcontextprotocol/server-filesystem`
   - **Reason:** Not on approved list

2. **memory**
   - **Confirmation 1:** "CONFIRM REMOVE memory" ✅
   - **Confirmation 2:** "CONFIRM REMOVE memory AGAIN" ✅
   - **Previous:** `@modelcontextprotocol/server-memory`
   - **Reason:** Not on approved list

3. **notion**
   - **Confirmation 1:** "CONFIRM REMOVE notion" ✅
   - **Confirmation 2:** "CONFIRM REMOVE notion AGAIN" ✅
   - **Previous:** `@notionhq/notion-mcp-server`
   - **Reason:** Not on approved list
   - **Required:** NOTION_API_KEY

4. **postgres**
   - **Confirmation 1:** "CONFIRM REMOVE postgres" ✅
   - **Confirmation 2:** "CONFIRM REMOVE postgres AGAIN" ✅
   - **Previous:** Custom script `scripts/run-postgres-mcp.sh`
   - **Reason:** Not on approved list
   - **Required:** DATABASE_URL

5. **upstash-context7**
   - **Confirmation 1:** "CONFIRM REMOVE upstash-context7" ✅
   - **Confirmation 2:** "CONFIRM REMOVE upstash-context7 AGAIN" ✅
   - **Previous:** `@upstash/context7-mcp`
   - **Reason:** Not on approved list

6. **moe-chat**
   - **Confirmation 1:** "CONFIRM REMOVE moe-chat" ✅
   - **Confirmation 2:** "CONFIRM REMOVE moe-chat AGAIN" ✅
   - **Previous:** Custom script `mcp-servers/chatgpt-app-server/index.js`
   - **Reason:** Not on approved list
   - **Required:** MOE_API_BASE

7. **playwright-mcp**
   - **Confirmation 1:** "CONFIRM REMOVE playwright-mcp" ✅
   - **Confirmation 2:** "CONFIRM REMOVE playwright-mcp AGAIN" ✅
   - **Previous:** `@playwright/mcp@latest`
   - **Reason:** Not on approved list

8. **microsoft-docs**
   - **Confirmation 1:** "CONFIRM REMOVE microsoft-docs" ✅
   - **Confirmation 2:** "CONFIRM REMOVE microsoft-docs AGAIN" ✅
   - **Previous:** HTTP endpoint `https://learn.microsoft.com/api/mcp`
   - **Reason:** Not on approved list

### Files Modified
- ✅ Created `.mcp.json` (new canonical config)
- ✅ Preserved `.vscode/mcp-backup-20251010_071510.json` (historical reference)
- ✅ Kept old `mcp.json` for now (to be deprecated after validation)

### Next Steps
1. Set environment variables for approved servers (see `.env.example` updates)
2. Run `npm run mcp:health` to verify all servers are accessible
3. Test each MCP server integration
4. Remove old `mcp.json` after confirming `.mcp.json` works
5. Consider re-adding DeepWiki/GitHub Copilot once package names verified

### Rollback Instructions
If needed, restore previous config:
```bash
cp .vscode/mcp-backup-20251010_071510.json .vscode/mcp.json
```

---
**Maintainer:** Automated via MCP Config Maintainer AI Agent  
**Branch:** chore/mcp-prune-20251015  
**Date:** 2025-10-15
