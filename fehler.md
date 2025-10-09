Fehlerursache (klar & kurz):
In `api.menschlichkeit-oesterreich.at/app/main.py` wird `app.include_router(privacy_router)` aufgerufen, aber `privacy_router` ist nirgends definiert/importiert → `NameError`.

## Schnellfix (empfohlen)

1. **Router importieren** (falls es bereits eine `privacy.py` gibt):

   ```python
   # app/main.py (am Kopfbereich)
   from app.routers.privacy import router as privacy_router
   ```

   Danach bleibt die bestehende Zeile bestehen:

   ```python
   app.include_router(privacy_router)
   ```

2. **Falls es den Router noch nicht gibt, minimalen Stub anlegen:**

   ```python
   # app/routers/privacy.py
   from fastapi import APIRouter

   router = APIRouter(prefix="/privacy", tags=["privacy"])

   @router.get("", summary="Privacy policy")
   def get_privacy():
       return {"status": "ok"}
   ```

3. **Sicherstellen, dass Python-Pakete erkennbar sind:**

   * `app/__init__.py` **und** `app/routers/__init__.py` anlegen (leere Datei genügt), falls nicht vorhanden.

4. **Neu starten:**

   * `npm run dev:all` erneut ausführen (der API-Teil startet dann wieder mit Uvicorn).

## Alternativen / typische Stolpersteine

* Wenn der Router in einem anderen Pfad liegt, Importpfad anpassen, z. B.:

  ```python
  from app.api.v1.routers.privacy import router as privacy_router
  ```
* Wenn die Variable im Modul **`router`** heißt (üblich), unbedingt mit Alias importieren wie oben gezeigt.
* Wenn ihr die Einbindung temporär überspringen wollt (bis die Privacy-Seite fertig ist), Zeile auskommentieren:

  ```python
  # app.include_router(privacy_router)
  ```

## Kurzer Sanity-Check

Nach dem Fix sollte `GET http://localhost:8001/privacy` `{"status":"ok"}` liefern (oder eure implementierte Policy).
Frontend (Vite) läuft weiter auf `5173`, CRM auf `8000`, Games auf `3000`.
