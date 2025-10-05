#!/usr/bin/env node
// Minimal social publisher (dry-run by default). Reads JSON posts from a folder.
// Usage: node scripts/social/publish.mjs --dir content/social --due-now [--dry-run]

import fs from 'node:fs';
import path from 'node:path';

function parseArgs() {
  const args = process.argv.slice(2);
  const opts = { dir: 'content/social', dueNow: false, dryRun: (process.env.DRY_RUN || 'true').toLowerCase() === 'true' };
  for (let i = 0; i < args.length; i++) {
    const a = args[i];
    if (a === '--dir') opts.dir = args[++i];
    else if (a === '--due-now') opts.dueNow = true;
    else if (a === '--dry-run') opts.dryRun = true;
  }
  return opts;
}

function loadPosts(dir) {
  if (!fs.existsSync(dir)) return [];
  const files = fs.readdirSync(dir).filter(f => f.endsWith('.json'));
  const items = [];
  for (const f of files) {
    try {
      const json = JSON.parse(fs.readFileSync(path.join(dir, f), 'utf8'));
      items.push({ file: f, ...json });
    } catch (e) {
      console.error('Failed to parse', f, e.message);
    }
  }
  return items;
}

function trimTo(str, n) { return (str || '').length > n ? str.slice(0, n - 1) + '…' : str; }
function utm(url, platform, slug) {
  const u = new URL(url);
  u.searchParams.set('utm_source', platform);
  u.searchParams.set('utm_medium', 'social');
  u.searchParams.set('utm_campaign', slug || 'ngo');
  return u.toString();
}

function render(post) {
  const slug = (post.title || 'post').toLowerCase().replace(/\s+/g, '-');
  const tagStr = (post.tags || []).map(t => '#' + t.replace(/\s+/g, '')).join(' ');
  const link = utm(post.url, 'all', slug);
  return {
    linkedin: `${post.title} – ${post.summary}\n\n${tagStr}\n${link}`.trim(),
    x: trimTo(`${post.title} – ${post.summary} ${tagStr} ${utm(post.url, 'x', slug)}`, 280),
    facebook: `${post.title}\n\n${post.summary}\n\n${tagStr}\n${utm(post.url, 'facebook', slug)}`,
    instagram: `${post.title}\n\n${post.summary}\n\n${tagStr}`,
    link
  };
}

async function httpJson(url, method, body, headers = {}) {
  const res = await fetch(url, { method, headers: { 'content-type': 'application/json', ...headers }, body: JSON.stringify(body) });
  const text = await res.text();
  let data;
  try { data = JSON.parse(text); } catch { data = text; }
  return { status: res.status, data };
}

async function publishLinkedIn(text) {
  const ACCESS_TOKEN = process.env.LINKEDIN_ACCESS_TOKEN; const ORG_URN = process.env.LINKEDIN_ORG_URN;
  if (!ACCESS_TOKEN || !ORG_URN) throw new Error('Missing LinkedIn credentials');
  const body = {
    author: ORG_URN,
    lifecycleState: 'PUBLISHED',
    specificContent: { 'com.linkedin.ugc.ShareContent': { shareCommentary: { text }, shareMediaCategory: 'NONE' } },
    visibility: { 'com.linkedin.ugc.MemberNetworkVisibility': 'PUBLIC' }
  };
  return httpJson('https://api.linkedin.com/v2/ugcPosts', 'POST', body, { Authorization: `Bearer ${ACCESS_TOKEN}` });
}

async function publishX(text) {
  const TOKEN = process.env.X_BEARER_TOKEN; if (!TOKEN) throw new Error('Missing X_BEARER_TOKEN');
  const body = { text };
  return httpJson('https://api.twitter.com/2/tweets', 'POST', body, { Authorization: `Bearer ${TOKEN}` });
}

async function publishFacebook(text) {
  const PAGE_ID = process.env.FB_PAGE_ID; const PAGE_TOKEN = process.env.FB_PAGE_TOKEN;
  if (!PAGE_ID || !PAGE_TOKEN) throw new Error('Missing FB_PAGE_ID/FB_PAGE_TOKEN');
  const url = `https://graph.facebook.com/v18.0/${PAGE_ID}/feed?message=${encodeURIComponent(text)}&access_token=${encodeURIComponent(PAGE_TOKEN)}`;
  const res = await fetch(url, { method: 'POST' });
  return { status: res.status, data: await res.text() };
}

async function main() {
  const { dir, dueNow, dryRun } = parseArgs();
  const posts = loadPosts(dir).filter(p => !dueNow || !p.scheduled_at || new Date(p.scheduled_at) <= new Date());
  if (!posts.length) { console.log('No posts due.'); return; }
  for (const p of posts) {
    const content = render(p);
    console.log(`\n=== ${p.file} ===`);
    console.log(content);
    let platforms = p.platforms || ['linkedin','x','facebook','instagram','mastodon','telegram','bluesky','reddit','slack','discord','pinterest'];
    // Env‑basierte Filter (Allowlist/Excludelist)
    const parseList = (s) => (s || '').split(',').map(x => x.trim().toLowerCase()).filter(Boolean);
    const allow = parseList(process.env.SOCIAL_ONLY_PLATFORMS);
    const exclude = parseList(process.env.SOCIAL_EXCLUDE_PLATFORMS);
    platforms = Array.from(new Set(platforms.map(x => x.toLowerCase())));
    if (allow.length) platforms = platforms.filter(pf => allow.includes(pf));
    if (exclude.length) platforms = platforms.filter(pf => !exclude.includes(pf));
    if (dryRun) { console.log('DRY RUN – not publishing'); continue; }
    for (const platform of platforms) {
      try {
        let out;
        if (platform === 'linkedin') out = await publishLinkedIn(content.linkedin);
        else if (platform === 'x') out = await publishX(content.x);
        else if (platform === 'facebook') out = await publishFacebook(content.facebook);
        else if (platform === 'instagram') {
          if (!p.imageUrl) { console.warn('Instagram requires imageUrl; skipping'); continue; }
          out = await publishInstagram(content.instagram, p.imageUrl);
        }
        else if (platform === 'mastodon') {
          out = await publishMastodon(`${content.linkedin}`);
        }
        else if (platform === 'telegram') {
          out = await publishTelegram(`${content.linkedin}`);
        }
        else if (platform === 'bluesky') {
          out = await publishBluesky(`${content.x}`);
        }
        else if (platform === 'reddit') {
          out = await publishReddit(p.title || 'Beitrag', content.link, `${content.linkedin}`);
        }
        else if (platform === 'slack') {
          out = await publishSlack(`${content.linkedin}`);
        }
        else if (platform === 'discord') {
          out = await publishDiscord(`${content.linkedin}`);
        }
        else if (platform === 'pinterest') {
          if (!p.imageUrl) { console.warn('Pinterest requires imageUrl; skipping'); continue; }
          out = await publishPinterest(p.imageUrl, content.link, p.title || 'Beitrag', p.summary || '');
        }
        else { console.log('Skip unsupported platform:', platform); continue; }
        console.log(platform, out.status, typeof out.data === 'string' ? out.data : JSON.stringify(out.data));
      } catch (e) {
        console.error('Publish failed', platform, e.message);
      }
    }
  }
}

async function publishInstagram(caption, imageUrl) {
  // Instagram Graph API (Business/Creator) – requires IG User ID and Page Token.
  const IG_USER_ID = process.env.IG_USER_ID; const PAGE_TOKEN = process.env.FB_PAGE_TOKEN;
  if (!IG_USER_ID || !PAGE_TOKEN) throw new Error('Missing IG_USER_ID/FB_PAGE_TOKEN');
  // Step 1: Create media container
  const createUrl = `https://graph.facebook.com/v18.0/${IG_USER_ID}/media` +
    `?image_url=${encodeURIComponent(imageUrl)}` +
    `&caption=${encodeURIComponent(caption)}` +
    `&access_token=${encodeURIComponent(PAGE_TOKEN)}`;
  let res = await fetch(createUrl, { method: 'POST' });
  const created = await res.json().catch(() => ({}));
  if (!res.ok) return { status: res.status, data: created };
  const creationId = created.id || created.creation_id;
  if (!creationId) return { status: 500, data: { error: 'No creation_id returned' } };
  // Step 2: Publish
  const publishUrl = `https://graph.facebook.com/v18.0/${IG_USER_ID}/media_publish` +
    `?creation_id=${encodeURIComponent(creationId)}` +
    `&access_token=${encodeURIComponent(PAGE_TOKEN)}`;
  res = await fetch(publishUrl, { method: 'POST' });
  return { status: res.status, data: await res.text() };
}

async function publishMastodon(text) {
  const BASE = (process.env.MASTODON_BASE_URL || '').replace(/\/$/, '');
  const TOKEN = process.env.MASTODON_ACCESS_TOKEN;
  if (!BASE || !TOKEN) throw new Error('Missing MASTODON_BASE_URL/MASTODON_ACCESS_TOKEN');
  return httpJson(`${BASE}/api/v1/statuses`, 'POST', { status: text }, { Authorization: `Bearer ${TOKEN}` });
}

async function publishTelegram(text) {
  const BOT = process.env.TELEGRAM_BOT_TOKEN; const CHAT = process.env.TELEGRAM_CHAT_ID;
  if (!BOT || !CHAT) throw new Error('Missing TELEGRAM_BOT_TOKEN/TELEGRAM_CHAT_ID');
  const url = `https://api.telegram.org/bot${encodeURIComponent(BOT)}/sendMessage`;
  return httpJson(url, 'POST', { chat_id: CHAT, text, disable_web_page_preview: false });
}

async function publishBluesky(text) {
  const SERVICE = (process.env.BSKY_SERVICE_URL || 'https://bsky.social').replace(/\/$/, '');
  const IDENT = process.env.BSKY_HANDLE; const PASSWORD = process.env.BSKY_APP_PASSWORD;
  if (!IDENT || !PASSWORD) throw new Error('Missing BSKY_HANDLE/BSKY_APP_PASSWORD');
  let res = await fetch(`${SERVICE}/xrpc/com.atproto.server.createSession`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ identifier: IDENT, password: PASSWORD }) });
  const session = await res.json().catch(() => ({}));
  if (!res.ok) return { status: res.status, data: session };
  const { accessJwt, did } = session;
  if (!accessJwt || !did) return { status: 500, data: { error: 'No accessJwt/did' } };
  const body = { repo: did, collection: 'app.bsky.feed.post', record: { $type: 'app.bsky.feed.post', text, createdAt: new Date().toISOString() } };
  res = await fetch(`${SERVICE}/xrpc/com.atproto.repo.createRecord`, { method: 'POST', headers: { 'content-type': 'application/json', Authorization: `Bearer ${accessJwt}` }, body: JSON.stringify(body) });
  const data = await res.json().catch(() => ({}));
  return { status: res.status, data };
}

async function publishReddit(title, url, fallbackText) {
  const TOKEN = process.env.REDDIT_ACCESS_TOKEN; const SUB = process.env.REDDIT_SUBREDDIT;
  if (!TOKEN || !SUB) throw new Error('Missing REDDIT_ACCESS_TOKEN/REDDIT_SUBREDDIT');
  // Submit as link post; if no URL, submit as self post
  const form = new URLSearchParams();
  form.set('sr', SUB);
  if (url) { form.set('kind', 'link'); form.set('url', url); }
  else { form.set('kind', 'self'); form.set('text', fallbackText); }
  form.set('title', title);
  const res = await fetch('https://oauth.reddit.com/api/submit', {
    method: 'POST',
    headers: { Authorization: `Bearer ${TOKEN}`, 'User-Agent': 'moe-social-publisher/1.0', 'content-type': 'application/x-www-form-urlencoded' },
    body: form.toString()
  });
  const data = await res.json().catch(() => ({}));
  return { status: res.status, data };
}

async function publishSlack(text) {
  const HOOK = process.env.SLACK_WEBHOOK_URL;
  if (!HOOK) throw new Error('Missing SLACK_WEBHOOK_URL');
  return httpJson(HOOK, 'POST', { text });
}

async function publishDiscord(text) {
  const HOOK = process.env.DISCORD_WEBHOOK_URL;
  if (!HOOK) throw new Error('Missing DISCORD_WEBHOOK_URL');
  return httpJson(HOOK, 'POST', { content: text });
}

async function publishPinterest(imageUrl, link, title, description) {
  const TOKEN = process.env.PINTEREST_ACCESS_TOKEN;
  const BOARD_ID = process.env.PINTEREST_BOARD_ID;
  const boardId = (globalThis.currentPost && globalThis.currentPost.pinterestBoardId) || BOARD_ID; // optional per-post override
  if (!TOKEN || !boardId) throw new Error('Missing PINTEREST_ACCESS_TOKEN/PINTEREST_BOARD_ID');
  const body = {
    board_id: boardId,
    title,
    description,
    link,
    media_source: { source_type: 'image_url', url: imageUrl }
  };
  return httpJson('https://api.pinterest.com/v5/pins', 'POST', body, { Authorization: `Bearer ${TOKEN}` });
}

main().catch(err => { console.error(err); process.exit(1); });
