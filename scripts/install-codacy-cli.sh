#!/usr/bin/env bash
set -euo pipefail

# Installiert Java (headless) und die Codacy Analysis CLI (JAR) in ~/.codacy
# Getestet auf Ubuntu 20.04 (Codespace-Container)

CODACY_DIR="$HOME/.codacy"
CODACY_JAR="$CODACY_DIR/codacy-analysis-cli-assembly.jar"
JAR_URL="https://github.com/codacy/codacy-analysis-cli/releases/latest/download/codacy-analysis-cli-assembly.jar"

echo "[1/4] Prüfe Java Runtime..."
if ! command -v java >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y default-jre-headless
fi
java -version || true

echo "[2/4] Erzeuge Verzeichnis: $CODACY_DIR"
mkdir -p "$CODACY_DIR"

echo "[3/4] Lade Codacy Analysis CLI (JAR) herunter..."
# -L: Follow redirects, -f: fail on server errors, -o: output path
curl -fL "$JAR_URL" -o "$CODACY_JAR"

# Minimalprüfung: Dateigröße > 1MB
MIN_SIZE=$((1 * 1024 * 1024))
ACT_SIZE=$(stat -c%s "$CODACY_JAR")
if [ "$ACT_SIZE" -lt "$MIN_SIZE" ]; then
  echo "Fehler: heruntergeladene JAR ist zu klein ($ACT_SIZE Bytes). Abbruch." >&2
  exit 1
fi

chmod 0644 "$CODACY_JAR"
echo "[4/4] Validierung: Ausgabe der CLI-Version (falls unterstützt)"
set +e
java -jar "$CODACY_JAR" --version || java -jar "$CODACY_JAR" version || true
set -e

echo "✅ Codacy CLI Installation abgeschlossen: $CODACY_JAR"
echo "Tipp: Wrapper nutzen: scripts/codacy-cli.sh analyze --directory ."
