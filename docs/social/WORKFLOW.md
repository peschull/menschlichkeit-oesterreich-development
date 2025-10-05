Social Media – Automatisierte Beiträge
=====================================

Variante A: n8n Workflow (Approval)
-----------------------------------
- Datei: automation/n8n/workflows/social-auto-post.json
- Setup in n8n:
  - Importiere Workflow → setze Credentials (LinkedIn OAuth2, Twitter/X OAuth2, Facebook Graph)
  - Ersetze Platzhalter (ORG URN, Page ID)
  - Optional: Trigger (Cron) aktivieren, Approval über „Wait for Approval“ lösen
- Content-Quelle: im Stub per Function Node; tausche gegen GitHub/API Fetch Node aus

Environment (docker-compose override)
------------------------------------
- Beispiel‑Env: config-templates/n8n.env.example
- Override‑Datei: automation/n8n/docker-compose.override.yml.example
- Schritte:
  1) cp config-templates/n8n.env.example automation/n8n/.env.n8n
  2) Tokens/IDs eintragen (s. Liste unten)
  3) cp automation/n8n/docker-compose.override.yml.example automation/n8n/docker-compose.override.yml
  4) docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d

n8n: Content direkt aus dem Repo laden
-------------------------------------
- Optional kannst du Beiträge aus `content/social/` via GitHub API laden.
- Setze in `.env.n8n`:
  - `GITHUB_REPO=owner/repo`
  - `GITHUB_TOKEN=<PAT oder GITHUB_TOKEN>` (für private Repos)
  - `GITHUB_REF=main` (Branch)
- Im Workflow ist ein HTTP Request Node vorbereitet, der `/contents/content/social` listet und pro Datei den JSON‑Inhalt lädt.

Bild‑Checkliste pro Plattform
----------------------------
- Instagram: 1080×1080 oder 1080×1350; JPEG/PNG; max ~8–10 MB; `imageUrl` erforderlich.
- Facebook: 1200×630 (OG) oder quadratisch 1080×1080; JPEG/PNG; Alt‑Text im Text erwähnen.
- LinkedIn: 1200×627 (Empfehlung), quadratisch möglich; Alt‑Text optional.
- X (Twitter): 1200×675; ≤5 MB (API Limits variieren); bei reinem Text keine Bildanforderung.
- Pinterest: 1000×1500 (2:3) bevorzugt; `imageUrl` erforderlich; Board ID nötig.
- Mastodon: flexibel (API/Instanz‑Limits beachten); Alt‑Text empfohlen.
- Slack/Discord: Vorschaubilder per Link Card; direkte Uploads per Webhook eingeschränkt; Text inkl. Link verwenden.


Variante B: GitHub Actions + Script
-----------------------------------
- Workflow: .github/workflows/social-posts.yml
- Script: scripts/social/publish.mjs (JSON-Content aus content/social)
- Secrets (Repo Settings → Secrets and variables → Actions):
  - LINKEDIN_ORG_URN, LINKEDIN_ACCESS_TOKEN
  - X_BEARER_TOKEN
  - FB_PAGE_ID, FB_PAGE_TOKEN
  - IG_USER_ID (Instagram Graph; Business Account mit FB Page verknüpft)
  - MASTODON_BASE_URL, MASTODON_ACCESS_TOKEN
  - TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID
  - BSKY_SERVICE_URL (optional, default https://bsky.social), BSKY_HANDLE, BSKY_APP_PASSWORD
  - REDDIT_ACCESS_TOKEN, REDDIT_SUBREDDIT
  - SLACK_WEBHOOK_URL, DISCORD_WEBHOOK_URL
  - PINTEREST_ACCESS_TOKEN, PINTEREST_BOARD_ID
- DRY_RUN: Default true (ohne Publikation). Bei manuellem Trigger abschalten.

Content-Format
--------------
- JSON: content/social/*.json
  - title, summary, url, tags[], platforms[], scheduled_at (optional)
  - Für Instagram: imageUrl erforderlich (direkte Bild‑URL)
  - Für Mastodon/Telegram/Bluesky keine Zusatzfelder nötig (alle Secrets via ENV)
  - Für Pinterest: imageUrl erforderlich; optional pinterestBoardId pro Beitrag (falls nicht via ENV gesetzt)

Governance & Compliance
-----------------------
- PR-Review (Variante B) bzw. Approval-Node (Variante A)
- UTM-Parameter werden automatisch angehängt
- Keine PII posten; Bildrechte klären; Alt-Texte bei Assets pflegen
