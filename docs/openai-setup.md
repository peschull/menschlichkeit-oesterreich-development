**OpenAI & Secrets Setup**

This document describes secure, repeatable steps to configure OpenAI credentials for local development, CI, and VS Code integration using SOPS (age) encryption. Follow the sections in order.

1. Prerequisites

- Install `sops` (https://github.com/mozilla/sops) and `age` on your development machine.
- Have a valid OpenAI API key (`sk-...`) with an active billing/account status.
- PowerShell (pwsh) is the recommended shell for scripts in this repository on Windows.

2. Create / verify age keypair

- Generate an age keypair (if you don't have one):

```pwsh
# create directory for age keys
mkdir $HOME\.config\sops\age -Force
age-keygen -o $HOME\.config\sops\age\keys.txt
```

- Copy the public recipient (the line starting with `age1...`) into the repository `.sops.yaml` recipients list or export it to CI as needed.

3. Add OpenAI key to encrypted secrets

- Recommended secret path: `secrets/production/api-keys.yaml` or a dedicated `secrets/production/openai.json`.
- Example plaintext file before encrypting (do NOT commit plaintext):

```yaml
openai:
  api_key: "sk-REPLACE_WITH_OPENAI_API_KEY"
  org_id: "org-..." # optional
```

- Encrypt the file with sops:

```pwsh
sops --encrypt --in-place secrets/production/api-keys.yaml
```

4. Decrypt and set environment for local testing

- To decrypt to stdout and set a process environment variable for a single session (safe):

```pwsh
$openai = sops --decrypt secrets/production/api-keys.yaml | ConvertFrom-Yaml
$env:OPENAI_API_KEY = $openai.openai.api_key
```

- Or use the provided helper script (if present):

```pwsh
.\n+\scripts\secrets-decrypt.ps1
```

5. Test OpenAI connectivity

- Run a simple connectivity test (PowerShell):

```pwsh
if (-not $env:OPENAI_API_KEY) { Write-Error 'OPENAI_API_KEY not set'; exit 1 }
$headers = @{ Authorization = "Bearer $($env:OPENAI_API_KEY)" }
Invoke-RestMethod -Uri "https://api.openai.com/v1/models" -Headers $headers -Method GET
```

- Expected: JSON listing available models. If you receive 401/403, the key is invalid or revoked. If you receive network errors, check firewall/proxy.

6. VS Code hardening

- Do NOT store `openai.apiKey` or `chatgpt.apiKey` in workspace settings or checked-in settings files.
- Set the following in user-level settings only (not committed):

```json
"chat.tools.global.autoApprove": false,
"chat.tools.terminal.autoApprove": false
```

- If the workspace has `.vscode/settings.json` with OpenAI keys, remove them and use SOPS + environment variables instead.

7. CI / GitHub Actions

- Add `OPENAI_API_KEY` as a repository secret in GitHub (Settings → Secrets). Prefer a dedicated CI account for auditing.
- For pipelines that need runtime secrets, either:
  - Decrypt `secrets/production/api-keys.yaml` in a protected runner using `SOPS_AGE_KEY` (recommended), or
  - Mount secrets from your secrets manager (Vault, Azure Key Vault, GitHub Secrets) at runtime.

Example GitHub Actions step to decrypt using `SOPS_AGE_KEY` (repository secret):

```yaml
- name: Install sops
  run: sudo apt-get update && sudo apt-get install -y sops

- name: Decrypt secrets
  env:
    SOPS_AGE_KEY: ${{ secrets.SOPS_AGE_KEY }}
  run: |
    echo "$SOPS_AGE_KEY" > sops-age-key.txt
    export SOPS_AGE_KEY_FILE=$(pwd)/sops-age-key.txt
    sops --decrypt --in-place secrets/production/api-keys.yaml
```

### VS Code Codex / ChatGPT-login note

If you're using the VS Code Codex or ChatGPT extension which authenticates via your ChatGPT login session, a local `OPENAI_API_KEY` is not strictly required for the editor plugin: the extension uses your interactive ChatGPT session to authenticate against OpenAI and will accept minimal local model configuration such as `model = "gpt-5-codex"` for editor features.

Caveats:

- **Not for automation:** Editor/extension authentication is interactive and cannot be used by CI, servers, or background MCP repair scripts. For non-interactive automation, always provide an explicit `OPENAI_API_KEY` via encrypted secrets or CI secrets.
- **Auditing & scope:** The ChatGPT-login is tied to a personal account; prefer org-owned API keys for shared or production workflows.
- **Local quick tests:** For quick manual testing you may export `OPENAI_API_KEY` into your shell for the session instead of encrypting the file.

Editor plugin = ChatGPT-login is fine. Automation = explicit API key in encrypted secrets or CI.

1. MCP autostart guidance

- Avoid workspace `.vscode/mcp.json` entries that call `npx -y @openai/mcp-server` or similar unpublished packages. Options:
  - Use the local `servers/src/mcp-stub.js` for development (already added to this repo), or
  - Use official Docker images for the MCP servers when available, or
  - Document manual `npm`/`pip` install steps for team members.

1. Troubleshooting checklist

- 401/403: invalid key, revoked, or org mismatch — reissue key in OpenAI dashboard.
- Network errors: verify outbound HTTPS to `api.openai.com:443` (curl/wget/TCP check).
- Rate limits / billing: check OpenAI dashboard usage & billing status.
- VS Code extensions failing: ensure `chat.tools.global.autoApprove` disabled and no workspace-stored keys.

1. Safety & Audit

- Rotate keys periodically. Keep old keys archived and revoked after rotation.
- Use scoped service accounts if possible and limit privileges.

If you want, I can now run the local connectivity test (step 5) here — tell me whether I should (I will only run it if `OPENAI_API_KEY` is present in the environment or you provide a test key).
