#!/bin/bash
#####################################################################
# E-Mail Infrastructure Monitoring Script
# Prüft SPF/DKIM/DMARC/TLSRPT Records und generiert Reports
#####################################################################

set -euo pipefail

DOMAIN="menschlichkeit-oesterreich.at"
SUBDOMAIN="newsletter.menschlichkeit-oesterreich.at"
REPORT_DIR="quality-reports/email-infrastructure"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="${REPORT_DIR}/email-monitoring-${TIMESTAMP}.json"

# Farben für Output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

mkdir -p "${REPORT_DIR}"

echo "🔍 E-Mail Infrastructure Monitoring gestartet..."
echo "Domain: ${DOMAIN}"
echo "Subdomain: ${SUBDOMAIN}"
echo ""

# JSON Report initialisieren
cat > "${REPORT_FILE}" <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "domain": "${DOMAIN}",
  "subdomain": "${SUBDOMAIN}",
  "checks": {}
}
EOF

#####################################################################
# 1. SPF Record Check
#####################################################################
echo "📋 Prüfe SPF Records..."

check_spf() {
  local domain=$1
  local spf_record=$(dig +short TXT "${domain}" | grep "v=spf1" || echo "NOT_FOUND")
  
  if [[ "${spf_record}" == "NOT_FOUND" ]]; then
    echo -e "${RED}❌ SPF Record nicht gefunden für ${domain}${NC}"
    jq --arg domain "${domain}" --arg status "FAILED" --arg record "" \
       '.checks.spf['\"${domain}\"'] = {"status": $status, "record": $record}' \
       "${REPORT_FILE}" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "${REPORT_FILE}"
    return 1
  else
    echo -e "${GREEN}✅ SPF Record gefunden: ${spf_record}${NC}"
    jq --arg domain "${domain}" --arg status "PASSED" --arg record "${spf_record}" \
       '.checks.spf['\"${domain}\"'] = {"status": $status, "record": $record}' \
       "${REPORT_FILE}" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "${REPORT_FILE}"
    return 0
  fi
}

check_spf "${DOMAIN}"
check_spf "${SUBDOMAIN}"

#####################################################################
# 2. DKIM Record Check
#####################################################################
echo ""
echo "🔑 Prüfe DKIM Records..."

check_dkim() {
  local selector=$1
  local domain=$2
  local dkim_record=$(dig +short TXT "${selector}._domainkey.${domain}" | grep "v=DKIM1" || echo "NOT_FOUND")
  
  if [[ "${dkim_record}" == "NOT_FOUND" ]]; then
    echo -e "${RED}❌ DKIM Record nicht gefunden: ${selector}._domainkey.${domain}${NC}"
    jq --arg selector "${selector}" --arg domain "${domain}" --arg status "FAILED" \
       '.checks.dkim['\"${selector}.${domain}\"'] = {"status": $status}' \
       "${REPORT_FILE}" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "${REPORT_FILE}"
    return 1
  else
    echo -e "${GREEN}✅ DKIM Record gefunden: ${selector}._domainkey.${domain}${NC}"
    echo "   ${dkim_record:0:50}..."
    jq --arg selector "${selector}" --arg domain "${domain}" --arg status "PASSED" --arg record "${dkim_record:0:100}" \
       '.checks.dkim['\"${selector}.${domain}\"'] = {"status": $status, "record": $record}' \
       "${REPORT_FILE}" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "${REPORT_FILE}"
    return 0
  fi
}

check_dkim "tx2025q4" "${DOMAIN}"
check_dkim "news2025q4" "${SUBDOMAIN}"

#####################################################################
# 3. DMARC Record Check
#####################################################################
echo ""
echo "🛡️ Prüfe DMARC Records..."

check_dmarc() {
  local domain=$1
  local dmarc_record=$(dig +short TXT "_dmarc.${domain}" | grep "v=DMARC1" || echo "NOT_FOUND")
  
  if [[ "${dmarc_record}" == "NOT_FOUND" ]]; then
    echo -e "${RED}❌ DMARC Record nicht gefunden für ${domain}${NC}"
    jq --arg domain "${domain}" --arg status "FAILED" \
       '.checks.dmarc['\"${domain}\"'] = {"status": $status}' \
       "${REPORT_FILE}" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "${REPORT_FILE}"
    return 1
  else
    echo -e "${GREEN}✅ DMARC Record gefunden: ${dmarc_record}${NC}"
    
    # Policy prüfen
    if echo "${dmarc_record}" | grep -q "p=reject"; then
      policy="reject"
      echo -e "   ${GREEN}Policy: reject (optimal)${NC}"
    elif echo "${dmarc_record}" | grep -q "p=quarantine"; then
      policy="quarantine"
      echo -e "   ${YELLOW}Policy: quarantine (empfohlen: reject nach 30 Tagen)${NC}"
    else
      policy="none"
      echo -e "   ${RED}Policy: none (WARNUNG: keine Enforcement!)${NC}"
    fi
    
    jq --arg domain "${domain}" --arg status "PASSED" --arg record "${dmarc_record}" --arg policy "${policy}" \
       '.checks.dmarc['\"${domain}\"'] = {"status": $status, "record": $record, "policy": $policy}' \
       "${REPORT_FILE}" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "${REPORT_FILE}"
    return 0
  fi
}

check_dmarc "${DOMAIN}"
check_dmarc "${SUBDOMAIN}"

#####################################################################
# 4. TLS Reporting Check
#####################################################################
echo ""
echo "🔒 Prüfe TLS Reporting Records..."

check_tlsrpt() {
  local domain=$1
  local tlsrpt_record=$(dig +short TXT "_smtp._tls.${domain}" | grep "v=TLSRPTv1" || echo "NOT_FOUND")
  
  if [[ "${tlsrpt_record}" == "NOT_FOUND" ]]; then
    echo -e "${YELLOW}⚠️  TLS Reporting Record nicht gefunden (optional)${NC}"
    jq --arg domain "${domain}" --arg status "NOT_CONFIGURED" \
       '.checks.tlsrpt['\"${domain}\"'] = {"status": $status}' \
       "${REPORT_FILE}" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "${REPORT_FILE}"
    return 0
  else
    echo -e "${GREEN}✅ TLS Reporting Record gefunden: ${tlsrpt_record}${NC}"
    jq --arg domain "${domain}" --arg status "PASSED" --arg record "${tlsrpt_record}" \
       '.checks.tlsrpt['\"${domain}\"'] = {"status": $status, "record": $record}' \
       "${REPORT_FILE}" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "${REPORT_FILE}"
    return 0
  fi
}

check_tlsrpt "${DOMAIN}"

#####################################################################
# 5. MX Record Check
#####################################################################
echo ""
echo "📬 Prüfe MX Records..."

check_mx() {
  local domain=$1
  local mx_records=$(dig +short MX "${domain}" || echo "NOT_FOUND")
  
  if [[ "${mx_records}" == "NOT_FOUND" || -z "${mx_records}" ]]; then
    echo -e "${RED}❌ MX Records nicht gefunden für ${domain}${NC}"
    jq --arg domain "${domain}" --arg status "FAILED" \
       '.checks.mx['\"${domain}\"'] = {"status": $status}' \
       "${REPORT_FILE}" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "${REPORT_FILE}"
    return 1
  else
    echo -e "${GREEN}✅ MX Records gefunden:${NC}"
    echo "${mx_records}" | while read -r line; do
      echo "   ${line}"
    done
    jq --arg domain "${domain}" --arg status "PASSED" --arg records "${mx_records}" \
       '.checks.mx['\"${domain}\"'] = {"status": $status, "records": $records}' \
       "${REPORT_FILE}" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "${REPORT_FILE}"
    return 0
  fi
}

check_mx "${DOMAIN}"

#####################################################################
# 6. BIMI Record Check (Optional)
#####################################################################
echo ""
echo "🎨 Prüfe BIMI Records (optional)..."

check_bimi() {
  local domain=$1
  local bimi_record=$(dig +short TXT "default._bimi.${domain}" | grep "v=BIMI1" || echo "NOT_FOUND")
  
  if [[ "${bimi_record}" == "NOT_FOUND" ]]; then
    echo -e "${YELLOW}⚠️  BIMI Record nicht gefunden (optional, aktiviere nach DMARC p=reject)${NC}"
    jq --arg domain "${domain}" --arg status "NOT_CONFIGURED" \
       '.checks.bimi['\"${domain}\"'] = {"status": $status}' \
       "${REPORT_FILE}" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "${REPORT_FILE}"
    return 0
  else
    echo -e "${GREEN}✅ BIMI Record gefunden: ${bimi_record}${NC}"
    jq --arg domain "${domain}" --arg status "PASSED" --arg record "${bimi_record}" \
       '.checks.bimi['\"${domain}\"'] = {"status": $status, "record": $record}' \
       "${REPORT_FILE}" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "${REPORT_FILE}"
    return 0
  fi
}

check_bimi "${DOMAIN}"

#####################################################################
# 7. Summary & Recommendations
#####################################################################
echo ""
echo "📊 Monitoring Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Zähle Passed/Failed
total_checks=$(jq '[.checks | to_entries[] | .value | to_entries[] | .value.status] | length' "${REPORT_FILE}")
passed_checks=$(jq '[.checks | to_entries[] | .value | to_entries[] | .value.status] | map(select(. == "PASSED")) | length' "${REPORT_FILE}")
failed_checks=$(jq '[.checks | to_entries[] | .value | to_entries[] | .value.status] | map(select(. == "FAILED")) | length' "${REPORT_FILE}")

echo "Gesamt Checks: ${total_checks}"
echo -e "Bestanden: ${GREEN}${passed_checks}${NC}"
echo -e "Fehlgeschlagen: ${RED}${failed_checks}${NC}"

# Recommendations
echo ""
echo "💡 Empfehlungen:"

# DMARC Policy Check
dmarc_policy=$(jq -r '.checks.dmarc["menschlichkeit-oesterreich.at"].policy // "unknown"' "${REPORT_FILE}")
if [[ "${dmarc_policy}" == "quarantine" ]]; then
  echo -e "${YELLOW}⚠️  DMARC Policy ist 'quarantine' - nach 30 Tagen auf 'reject' umstellen${NC}"
  jq '.recommendations += ["Upgrade DMARC policy to p=reject after 30 days of quarantine"]' \
     "${REPORT_FILE}" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "${REPORT_FILE}"
elif [[ "${dmarc_policy}" == "none" ]]; then
  echo -e "${RED}❌ DMARC Policy ist 'none' - SOFORT auf 'quarantine' umstellen!${NC}"
  jq '.recommendations += ["CRITICAL: Change DMARC policy from none to quarantine immediately"]' \
     "${REPORT_FILE}" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "${REPORT_FILE}"
fi

# BIMI Check
bimi_status=$(jq -r '.checks.bimi["menschlichkeit-oesterreich.at"].status // "unknown"' "${REPORT_FILE}")
if [[ "${bimi_status}" == "NOT_CONFIGURED" && "${dmarc_policy}" == "reject" ]]; then
  echo -e "${YELLOW}⚠️  BIMI kann aktiviert werden (DMARC p=reject vorhanden)${NC}"
  jq '.recommendations += ["Consider enabling BIMI for brand logo display in email clients"]' \
     "${REPORT_FILE}" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "${REPORT_FILE}"
fi

# TLS Reporting Check
tlsrpt_status=$(jq -r '.checks.tlsrpt["menschlichkeit-oesterreich.at"].status // "unknown"' "${REPORT_FILE}")
if [[ "${tlsrpt_status}" == "NOT_CONFIGURED" ]]; then
  jq '.recommendations += ["Consider enabling TLS Reporting for enhanced security monitoring"]' \
     "${REPORT_FILE}" > "${REPORT_FILE}.tmp" && mv "${REPORT_FILE}.tmp" "${REPORT_FILE}"
fi

echo ""
echo "✅ Monitoring abgeschlossen"
echo "Report gespeichert: ${REPORT_FILE}"
echo ""
echo "Nächste Schritte:"
echo "  1. DMARC Reports bei dmarc@${DOMAIN} prüfen"
echo "  2. TLS Reports bei tlsrpt@${DOMAIN} prüfen (falls konfiguriert)"
echo "  3. Nach 30 Tagen: DMARC Policy auf 'reject' erhöhen"
echo "  4. Nach 60 Tagen: BIMI aktivieren (optional)"
echo ""
echo "Automatisches Monitoring einrichten:"
echo "  crontab -e"
echo "  0 6 * * * /workspaces/menschlichkeit-oesterreich-development/scripts/email-monitoring.sh"

exit 0
