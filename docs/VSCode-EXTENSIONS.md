# VS Code Extension Playbook

This workspace ships with a curated extension list so every stack (Drupal/PHP, JS games, React, FastAPI, DevOps) can be debugged from the same editor. The summary below shows how to bring each extension to life and which tasks/launch configs pair with it.

## 1. Install the recommended pack

Open the command palette and run `Extensions: Show Recommended Extensions`. Install everything from the **Workspace Recommendations** group or run:

```bash
code \
  --install-extension bmewburn.vscode-intelephense-client \
  --install-extension xdebug.php-debug \
  --install-extension xdebug.php-pack \
  --install-extension dbaeumer.vscode-eslint \
  --install-extension esbenp.prettier-vscode \
  --install-extension bradlc.vscode-tailwindcss \
  --install-extension ms-vscode.vscode-js-profile-table \
  --install-extension Prisma.prisma \
  --install-extension ms-playwright.playwright \
  --install-extension vitest.explorer \
  --install-extension ms-azuretools.vscode-docker \
  --install-extension ms-python.python \
  --install-extension eamodio.gitlens \
  --install-extension gruntfuggly.todo-tree \
  --install-extension ms-vscode.hexeditor \
  --install-extension yzhang.markdown-all-in-one \
  --install-extension streetsidesoftware.code-spell-checker \
  --install-extension stylelint.vscode-stylelint \
  --install-extension ms-python.vscode-pylance
```

> Tip: the Playwright, Vitest and Docker extensions may ask to install helper binaries the first time – accept those prompts so debug sessions work.

## 2. Extension → Workflow map

| Extension | Purpose | First-run checklist |
|-----------|---------|---------------------|
| **Intelephense** | PHP intelligence for Drupal. | Run `Composer: install` task once (Ctrl/Cmd+Shift+P → `Tasks: Run Task`). |
| **PHP Debug / Xdebug** | Debug Drupal via port 9003. | Start the `PHP: Start Server (Debug Mode)` task → launch `PHP: Xdebug Listen (9003)`. |
| **ESLint** | JS/TS linting. | `npm ci` (or `npm install`) at repo root, then `Lint: ESLint` task. |
| **Prettier** | Formatting. | Already the default formatter – toggle Format on Save in Status Bar if needed. |
| **Tailwind CSS IntelliSense** | Utility class hints for `frontend/` components. | Ensure `npm run dev` is running so Tailwind config is picked up. |
| **JS Profile Table** | Flame charts for game loops. | Attach to `Node: Start with Debug` task or Chrome debug session while games are running. |
| **Prisma** | Schema linting + migrations for backend. | Run `Prisma: Generate` task to sync the client. |
| **Vitest & Playwright** | Unit/E2E tests with debug UI. | Use the pre-wired launch configs `Vitest: Unit Tests (Debug)` and `Playwright: E2E Tests (Debug)`. |
| **Docker** | Manage local containers. | Use `Docker: Up (Development)` or attach with the `Docker: Node Attach` configuration. |
| **Python** | FastAPI support. | Create `.venv` (see below) and start `Python: FastAPI (uvicorn)` launch. |
| **GitLens / TODO Tree** | Repo insights & TODO overview. | No extra setup – open the panes from the Activity Bar. |
| **Hex Editor** | Inspect binary game assets. | Use `Command Palette → Reopen With… → Hex Editor` when needed. |
| **Markdown All in One** | Live Vorschau, Inhaltsverzeichnis, Shortcuts für `.md`. | Öffne eine Markdown-Datei und aktiviere Vorschau (`Ctrl/Cmd+Shift+V`). |
| **Code Spell Checker** | Mehrsprachige Rechtschreibprüfung in Markdown/Code. | Sprache via Status-Bar auswählen (`DE`/`EN`) und Workspace-Wörterbuch pflegen (`.vscode/secrets/spell.json`). |
| **Stylelint** | Linting für CSS/Tailwind/PostCSS. | `npm install` ausführen, danach `npx stylelint "**/*.css"` oder Tasks integrieren. |
| **Pylance** | Schnelle Python Language Services (FastAPI). | Interpreter auf `.venv` setzen; ergänzt den Python Extension Pack. |

## 3. Updated launch & task defaults

- **Fixed `NODE_OPTIONS='--inspect'`**: Tasks now set the environment variable directly, so Windows terminals no longer choke on POSIX quoting.
- **FastAPI debugging**: `Python: FastAPI (uvicorn)` launches uvicorn with auto-reload. Requires a virtualenv in `api.menschlichkeit-oesterreich.at/.venv` (run `python -m venv .venv && .venv\Scripts\activate && pip install -r requirements.txt`).
- **Full-stack compounds**: Debug panel includes ready-made combos (Games + Node, Drupal + Chrome, etc.). Pick them from the Run and Debug sidebar.

## 4. Frequently used tasks (⌘/Ctrl+Shift+P → `Tasks: Run Task`)

| Task | When to use |
|------|-------------|
| `Node: Start with Debug` | Spins up the root `npm run dev` with the inspector. Attach with `Node: Attach (9229)`. |
| `Next.js: Dev (Debug Mode)` | Develop the React frontend (inspector auto-enabled). |
| `Games: Serve Local (Port 3000)` | Quick static server for `web/games/`. |
| `PHP: Start Server (Debug Mode)` | Serve Drupal via the PHP built-in dev server with Xdebug. |
| `API: Start FastAPI (Debug)` | Launch uvicorn reloader pointing at `app.main:app`. |
| `Lint: ESLint` / `Format: Prettier` | Quality gates before committing. |
| `Stylelint: Check CSS` | Führt `stylelint` über Game- und Frontend-CSS aus. |

## 5. Troubleshooting quick reference

- **ESLint warnings not appearing** → Verify `node_modules` exists and ESLint extension is enabled for the workspace folder.
- **Xdebug not connecting** → Confirm `XDEBUG_MODE=debug` in the PHP task and port 9003 is open (extension status bar shows a listening state).
- **FastAPI debugger won’t start** → Ensure the Python interpreter is set to the virtualenv (`Ctrl/Cmd+Shift+P → Python: Select Interpreter`).
- **Playwright/Vitest UI empty** → Run `npm run test -- --ui` to let the extension detect your test suite, then refresh the Testing sidebar.
- **Tailwind intellisense missing** → Check that the workspace open folder is the repo root (so `.vscode/settings.json` applies) and the Tailwind extension picked up `tailwind.config.cjs`.

That’s it – once the recommendations are installed and the helper tasks are run once per stack, every language server and debugger lights up automatically the next time you open VS Code.
