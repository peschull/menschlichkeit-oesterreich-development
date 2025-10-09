#!/bin/bash
#####################################################################
# DKIM Key Rotation Script
# Generiert neue DKIM Keypairs und bereitet DNS-Updates vor
# Ausführen: Alle 6 Monate (Q1/Q3)
#####################################################################

set -euo pipefail

QUARTER=$1  # z.B. "2025q1", "2025q3"
SECRETS_DIR="secrets/email-dkim"
DOMAIN="menschlichkeit-oesterreich.at"
SUBDOMAIN="newsletter.menschlichkeit-oesterreich.at"

if [[ -z "${QUARTER:-}" ]]; then
  echo "❌ Fehler: Quarter-Parameter fehlt"
  echo "Usage: $0 <quarter>"
  echo "Beispiel: $0 2025q1"
  exit 1
fi

# Validierung: Quarter-Format
if ! [[ "${QUARTER}" =~ ^20[0-9]{2}q[1-4]$ ]]; then
  echo "❌ Fehler: Ungültiges Quarter-Format"
  echo "Format: YYYYq[1-4] (z.B. 2025q1)"
  exit 1
fi

echo "🔄 DKIM Key Rotation gestartet für Quarter: ${QUARTER}"
echo "Domain: ${DOMAIN}"
echo "Subdomain: ${SUBDOMAIN}"
echo ""

mkdir -p "${SECRETS_DIR}"
mkdir -p "${SECRETS_DIR}/archive"

#####################################################################
# 1. Transactional DKIM (Hauptdomain)
#####################################################################
echo "🔑 Generiere Transactional DKIM Key (Selector: tx${QUARTER})..."

PRIVATE_KEY_TX="${SECRETS_DIR}/tx${QUARTER}_private.pem"
PUBLIC_KEY_TX="${SECRETS_DIR}/tx${QUARTER}_public.txt"

# Keypair generieren
openssl genrsa -out "${PRIVATE_KEY_TX}" 2048
openssl rsa -in "${PRIVATE_KEY_TX}" -pubout -outform der | base64 -w0 > "${PUBLIC_KEY_TX}"

echo "✅ Transactional DKIM Keys generiert:"
echo "   Private Key: ${PRIVATE_KEY_TX}"
echo "   Public Key:  ${PUBLIC_KEY_TX}"
echo ""

#####################################################################
# 2. Newsletter DKIM (Subdomain)
#####################################################################
echo "📧 Generiere Newsletter DKIM Key (Selector: news${QUARTER})..."

PRIVATE_KEY_NEWS="${SECRETS_DIR}/news${QUARTER}_private.pem"
PUBLIC_KEY_NEWS="${SECRETS_DIR}/news${QUARTER}_public.txt"

# Keypair generieren
openssl genrsa -out "${PRIVATE_KEY_NEWS}" 2048
openssl rsa -in "${PRIVATE_KEY_NEWS}" -pubout -outform der | base64 -w0 > "${PUBLIC_KEY_NEWS}"

echo "✅ Newsletter DKIM Keys generiert:"
echo "   Private Key: ${PRIVATE_KEY_NEWS}"
echo "   Public Key:  ${PUBLIC_KEY_NEWS}"
echo ""

#####################################################################
# 3. DNS Records vorbereiten
#####################################################################
echo "🌐 DNS Records vorbereiten..."

DNS_FILE="${SECRETS_DIR}/dns-records-${QUARTER}.txt"

cat > "${DNS_FILE}" <<EOF
#####################################################################
# DKIM DNS Records für Quarter ${QUARTER}
# Generiert: $(date -Iseconds)
#####################################################################

## Transactional DKIM (Hauptdomain: ${DOMAIN})
tx${QUARTER}._domainkey.${DOMAIN}   IN TXT "v=DKIM1; k=rsa; p=$(cat ${PUBLIC_KEY_TX})"

## Newsletter DKIM (Subdomain: ${SUBDOMAIN})
news${QUARTER}._domainkey.${SUBDOMAIN}   IN TXT "v=DKIM1; k=rsa; p=$(cat ${PUBLIC_KEY_NEWS})"

#####################################################################
# Deployment Steps:
#####################################################################

1. Plesk → DNS → ${DOMAIN} → Add TXT Record:
   Name: tx${QUARTER}._domainkey
   Value: v=DKIM1; k=rsa; p=$(cat ${PUBLIC_KEY_TX})

2. Plesk → DNS → ${SUBDOMAIN} → Add TXT Record:
   Name: news${QUARTER}._domainkey
   Value: v=DKIM1; k=rsa; p=$(cat ${PUBLIC_KEY_NEWS})

3. Warten auf DNS-Propagation (48 Stunden):
   dig +short TXT tx${QUARTER}._domainkey.${DOMAIN}
   dig +short TXT news${QUARTER}._domainkey.${SUBDOMAIN}

4. DKIM-Signierung aktivieren:
   - CiviCRM: DKIM Selector auf "tx${QUARTER}" umstellen
   - CiviMail: DKIM Selector auf "news${QUARTER}" umstellen

5. Tests durchführen:
   - mail-tester.com (Score ≥ 9/10)
   - Authentication-Results Header prüfen

6. Alte DKIM Records deaktivieren (nach 90 Tagen):
   - Alte Private Keys archivieren
   - Alte DNS Records entfernen

#####################################################################
# GitHub Secrets Update:
#####################################################################

# Via GitHub CLI:
gh secret set DKIM_TX_PRIVATE_KEY < ${PRIVATE_KEY_TX}
gh secret set DKIM_NEWS_PRIVATE_KEY < ${PRIVATE_KEY_NEWS}

# Via GitHub MCP:
"Create repository secret DKIM_TX_PRIVATE_KEY with value from ${PRIVATE_KEY_TX}"
"Create repository secret DKIM_NEWS_PRIVATE_KEY with value from ${PRIVATE_KEY_NEWS}"

EOF

echo "✅ DNS Records vorbereitet: ${DNS_FILE}"
echo ""

#####################################################################
# 4. Alte Keys archivieren (falls vorhanden)
#####################################################################
echo "📦 Archiviere alte DKIM Keys..."

ARCHIVE_DIR="${SECRETS_DIR}/archive/rotation-$(date +%Y%m%d_%H%M%S)"
mkdir -p "${ARCHIVE_DIR}"

# Alle .pem Files außer die neuen archivieren
find "${SECRETS_DIR}" -maxdepth 1 -name "*.pem" ! -name "tx${QUARTER}_private.pem" ! -name "news${QUARTER}_private.pem" -exec mv {} "${ARCHIVE_DIR}/" \;
find "${SECRETS_DIR}" -maxdepth 1 -name "*.txt" ! -name "tx${QUARTER}_public.txt" ! -name "news${QUARTER}_public.txt" ! -name "dns-records-${QUARTER}.txt" -exec mv {} "${ARCHIVE_DIR}/" \;

if [ "$(ls -A ${ARCHIVE_DIR} 2>/dev/null)" ]; then
  echo "✅ Alte Keys archiviert in: ${ARCHIVE_DIR}"
else
  rmdir "${ARCHIVE_DIR}"
  echo "ℹ️  Keine alten Keys zum Archivieren gefunden (erste Rotation)"
fi

echo ""

#####################################################################
# 5. Summary & Next Steps
#####################################################################
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ DKIM Key Rotation abgeschlossen für ${QUARTER}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Nächste Schritte:"
echo ""
echo "1. DNS Records publizieren:"
echo "   cat ${DNS_FILE}"
echo "   → Kopiere TXT Records in Plesk DNS"
echo ""
echo "2. DNS-Propagation abwarten (48 Stunden):"
echo "   dig +short TXT tx${QUARTER}._domainkey.${DOMAIN}"
echo "   dig +short TXT news${QUARTER}._domainkey.${SUBDOMAIN}"
echo ""
echo "3. CiviCRM/CiviMail DKIM Selectors aktualisieren:"
echo "   - Transactional: tx${QUARTER}"
echo "   - Newsletter: news${QUARTER}"
echo ""
echo "4. Tests durchführen:"
echo "   - Mail an mail-tester.com senden"
echo "   - Authentication-Results Header prüfen"
echo ""
echo "5. Nach erfolgreichen Tests (7 Tage):"
echo "   - Alte DKIM DNS Records entfernen"
echo ""
echo "6. Nach 90 Tagen:"
echo "   - Archivierte Keys löschen: rm -rf ${ARCHIVE_DIR}"
echo ""
echo "🔗 GitHub Secrets Update:"
echo "   gh secret set DKIM_TX_PRIVATE_KEY < ${PRIVATE_KEY_TX}"
echo "   gh secret set DKIM_NEWS_PRIVATE_KEY < ${PRIVATE_KEY_NEWS}"
echo ""
echo "📅 Nächste Rotation: $(date -d '+6 months' +%Y-q%q)"
echo ""

exit 0
