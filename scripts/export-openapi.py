#!/usr/bin/env python3
"""
Exportiert das OpenAPI‑Schema der FastAPI‑App als JSON‑Datei.

Beispiel:
  python3 scripts/export-openapi.py \
    --module api.menschlichkeit-oesterreich.at.app.main \
    --app app \
    --out api.menschlichkeit-oesterreich.at/openapi.generated.json
"""
import argparse
import importlib
import json
import sys


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--module', required=False, default=None, help='Python Modulpfad (optional)')
    p.add_argument('--file', required=False, default='api.menschlichkeit-oesterreich.at/app/main.py', help='Pfad zur Python-Datei mit der App')
    p.add_argument('--app', required=False, default='app', help='Name der FastAPI App Variable im Modul')
    p.add_argument('--out', required=False, default='api.menschlichkeit-oesterreich.at/openapi.generated.json', help='Zieldatei')
    args = p.parse_args()

    try:
        if args.module:
            mod = importlib.import_module(args.module)
        else:
            # Versuche, das Modul über sys.path als Paket zu importieren
            import os
            pkg_dir = os.path.dirname(args.file)          # .../app
            proj_root = os.path.dirname(pkg_dir)          # .../api.menschlichkeit-oesterreich.at
            pkg_name = os.path.basename(pkg_dir)          # app
            module_name = os.path.splitext(os.path.basename(args.file))[0]  # main
            sys.path.insert(0, proj_root)
            mod = importlib.import_module(f"{pkg_name}.{module_name}")
        app = getattr(mod, args.app)
        schema = app.openapi()
    except Exception as e:
        print(f"Fehler beim Laden der App oder Generieren des Schemas: {e}", file=sys.stderr)
        return 1

    with open(args.out, 'w', encoding='utf-8') as f:
        json.dump(schema, f, ensure_ascii=False, indent=2)
    print(f"OpenAPI Schema exportiert: {args.out}")
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
