# MCP Configuration Cleanup - Pull Request

## 📋 Summary
Consolidated fragmented MCP (Model Context Protocol) server configurations into a single, validated `.mcp.json` file. Removed 8 non-approved servers with strict double-confirmation protocol and configured 6 approved servers.

## 🎯 Objectives
- ✅ Single source of truth for MCP configuration
- ✅ Only approved servers active
- ✅ Safe removal process with double-confirmation
- ✅ Automated validation and health checks
- ✅ Complete audit trail and rollback capability

## 📊 Changes

### Created Files
- `.mcp.json` - Canonical MCP configuration (6 approved servers)
- `scripts/mcp/validate.cjs` - Configuration validator
- `scripts/mcp/health-check.sh` - Server health checks
- `docs/mcp/CHANGELOG.md` - Complete audit trail

### Modified Files
- `package.json` - Added `mcp:validate` and `mcp:health` scripts

### Preserved Files
- `.vscode/mcp-backup-20251010_071510.json` - Historical reference
- `mcp.json` - Legacy config (to be deprecated after validation)

## 🔐 Removed Servers (Double-Confirmed)

Each server received explicit double-confirmation before removal:

| Server | Reason | Confirmation Status |
|--------|--------|---------------------|
| **filesystem** | Not on approved list | ✅✅ Double-confirmed |
| **memory** | Not on approved list | ✅✅ Double-confirmed |
| **notion** | Not on approved list | ✅✅ Double-confirmed |
| **postgres** | Not on approved list | ✅✅ Double-confirmed |
| **upstash-context7** | Not on approved list | ✅✅ Double-confirmed |
| **moe-chat** | Not on approved list | ✅✅ Double-confirmed |
| **playwright-mcp** | Not on approved list | ✅✅ Double-confirmed |
| **microsoft-docs** | Not on approved list | ✅✅ Double-confirmed |

## ✅ Active Servers (Approved)

| Server | Package | Auth Required |
|--------|---------|---------------|
| **GitHub** | `@modelcontextprotocol/server-github` | `GITHUB_PERSONAL_ACCESS_TOKEN` |
| **Codacy** | `@codacy/codacy-mcp-server` | `CODACY_API_TOKEN` |
| **Figma** | `@modelcontextprotocol/server-figma` | `FIGMA_PERSONAL_ACCESS_TOKEN` |
| **Sentry** | `@sentry/mcp-server` | `SENTRY_AUTH_TOKEN`, `SENTRY_ORG` |
| **Hugging Face** | `@huggingface/mcp-server` | `HUGGING_FACE_API_TOKEN` |
| **Markitdown** | `@microsoft/markitdown-mcp-server` | None |

**Note:** DeepWiki and GitHub Copilot MCP servers were approved but package names need verification.

## 🧪 Testing

### Validation
```bash
npm run mcp:validate
```

**Expected Output:**
```
✅ Valid JSON syntax
✅ Found 6 configured MCP server(s)
✅ Documented 8 removed server(s)
✅ Configuration is valid!
```

### Health Checks
```bash
npm run mcp:health
```

**Note:** Some servers will be skipped if environment variables are not set. This is expected.

## 📝 Checklist

- [x] `.mcp.json` exists and validates successfully
- [x] Only approved servers configured
- [x] Non-approved servers documented in `removedServers`
- [x] Double-confirmation protocol followed for all removals
- [x] Validation script created (`npm run mcp:validate`)
- [x] Health check script created (`npm run mcp:health`)
- [x] Complete audit trail in `docs/mcp/CHANGELOG.md`
- [x] Secrets use placeholders (no real tokens)
- [x] Conventional Commit message
- [ ] Environment variables set (post-merge task)
- [ ] All health checks pass with credentials (post-merge task)

## 🔄 Rollback Instructions

If issues arise, restore previous configuration:

```bash
# Restore from backup
cp .vscode/mcp-backup-20251010_071510.json .vscode/mcp.json

# Or restore old mcp.json
mv mcp.json .mcp.json
```

## 📖 Documentation

See `docs/mcp/CHANGELOG.md` for:
- Complete inventory of all configs found
- Detailed confirmation logs for each removal
- Server descriptions and requirements
- Next steps and recommendations

## 🚀 Next Steps (Post-Merge)

1. Set required environment variables in `.env`:
   ```bash
   GITHUB_PERSONAL_ACCESS_TOKEN=...
   CODACY_API_TOKEN=...
   FIGMA_PERSONAL_ACCESS_TOKEN=...
   SENTRY_AUTH_TOKEN=...
   SENTRY_ORG=...
   HUGGING_FACE_API_TOKEN=...
   ```

2. Run health checks:
   ```bash
   npm run mcp:health
   ```

3. Test each MCP server integration

4. Consider adding DeepWiki/GitHub Copilot once package names verified

5. Deprecate old `mcp.json` after validation period

## 🏷️ Labels
- `chore` - Maintenance task
- `configuration` - Config changes
- `mcp` - MCP-specific
- `breaking-change` - Removes existing servers

## ⚠️ Breaking Changes

**BREAKING CHANGE:** This PR removes 8 MCP servers. If you depend on any of these servers, you MUST:
1. Review `docs/mcp/CHANGELOG.md` for details
2. Use rollback instructions if needed
3. Request re-addition through proper approval process

---

**Branch:** `chore/mcp-prune-20251015`  
**Commit:** `bc2bc375`  
**Files Changed:** 5 files (+458 lines)
