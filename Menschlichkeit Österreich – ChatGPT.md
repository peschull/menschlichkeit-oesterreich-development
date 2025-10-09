Menschlichkeit Österreich – ChatGPT-App Integration

1. Kandidaten für Tools (Funktionen/Abläufe): Im NGO-Projekt gibt es mehrere Abläufe, die sich als ChatGPT-Tools abbilden lassen:

Mitgliedschafts-Registrierung: Neumitglieder sollen direkt im Chat eine Mitgliedschaft beantragen können. Dies umfasst das Anlegen eines Kontos (Contact in CiviCRM) und das Erstellen einer Mitgliedschaft über die API (z.B. via /auth/register und /memberships/create). Die API bietet bereits Endpunkte dafür
GitHub
GitHub
.

SEPA-Lastschriftmandat erfassen: Falls zur Mitgliedschaft ein Lastschriftmandat (IBAN) nötig ist, kann ein Tool das SEPA-Mandat in CiviCRM anlegen (Endpoint /sepa/mandate
GitHub
). Dieses kann in den Mitgliedschafts-Workflow integriert werden.

Benutzerprofil abrufen/ändern: Mitglieder könnten im Chat ihre Profildaten ansehen oder aktualisieren (z.B. /user/profile GET/PUT
GitHub
GitHub
).

Datenlöschung (DSGVO Art. 17): Über den Chat soll ein Nutzer seinen Löschantrag stellen können. Die FastAPI bietet einen Endpoint /privacy/data-deletion
GitHub
, der einen Löschvorgang initiiert (inkl. Auto-Genehmigung falls keine Aufbewahrungspflichten entgegenstehen). Ebenso kann ein Tool den Status laufender Löschanträge abrufen (GET /privacy/data-deletion
GitHub
).

(Optional: Kontakt- oder Spendenabfragen: Intern könnte ein Admin über ein Tool Kontakte suchen (Endpoint /contacts/search
GitHub
) oder Spendenhistorie prüfen. Allerdings sollten solche Tools nur mit Admin-Rechten nutzbar sein und sensible Daten schützen.)

2. Tool-Definition & UI-Struktur: Für die obigen Funktionen werden wir entsprechende Tools mit definierter JSON-Schema-Schnittstelle und passenden UI-Komponenten vorschlagen:

Tool: register_user – Nutzerkonto/Kontakt anlegen.
Input Schema: { "email": "string", "first_name": "string", "last_name": "string", "password": "string (optional)"} – E-Mail und Name des neuen Nutzers. (Passwort optional, da evtl. zunächst nicht benötigt – perspektivisch SSO.)
Aktion: Ruft intern die FastAPI-Registrierung auf (POST /auth/register), die einen CiviCRM-Contact erzeugt und JWT-Tokens ausstellt
GitHub
.
Output: Erfolgsnachricht mit Kontakt-ID. Da die Ausgabe sensible Token enthält (JWT), sollten Tokens nicht im structuredContent an das Modell gegeben werden. Stattdessen kann man nur eine Erfolgsmeldung im content zurückgeben (z.B. „Registrierung erfolgreich“). Die Tokens werden im Tool-Server im Nutzerkontext gespeichert (z.B. in einer Session) oder via OAuth-Login ohnehin vom ChatGPT-Auth gehandhabt.
UI: Kein spezielles UI nötig – eine einfache Bestätigungsnachricht reicht. (Registrierungsformular läuft über den Chat selbst oder Fullscreen-UI, siehe nächster Punkt.)

Tool: create_membership – Mitgliedschaft beantragen.
Input Schema: { "contact_id": "integer", "membership_type": "string", "iban": "string" (optional), "bic": "string" (optional) }. – contact_id referenziert den angemeldeten Nutzer (aus JWT), membership_type könnte z.B. "standard" oder "foerdermitglied" sein (wenn mehrere Typen existieren; intern wird auf eine membership_type_id gemappt). IBAN/BIC werden benötigt, falls der Mitgliedsbeitrag per Lastschrift eingezogen wird.
Aktion: Nutzt den Endpoint /memberships/create der API, um in CiviCRM einen Membership-Eintrag zu erzeugen
GitHub
GitHub
. Direkt danach kann optional /sepa/mandate aufgerufen werden, um das Lastschriftmandat zu speichern
GitHub
GitHub
. Diese Aufrufe erfolgen serverseitig.
Output: structuredContent könnte die neu angelegte Mitgliedschaft enthalten (z.B. Mitgliedsnummer oder Bestätigungsdetails) zur Darstellung. Zudem content als kurze Zusammenfassung („Mitgliedschaft erfolgreich erstellt“
GitHub
).
UI: Hier bietet sich ein Fullscreen-Formular an, da mehrere Eingaben notwendig sind. Beispielsweise ein „Mitglied werden“-Formular als HTML/React-Widget, das den Nutzer Schritt für Schritt durch die Registrierung führt: Vorname, Nachname, E-Mail (falls nicht schon im Login bekannt), ggf. Auswahl des Mitgliedschaftstyps (Dropdown), und Eingabe von IBAN/BIC. Dieses Formular kann als outputTemplate in _meta hinterlegt werden, z.B. "openai/outputTemplate": "ui://widget/membership-signup.html". ChatGPT rendert dann ein Fullscreen-UI, und die eingegebenen Daten können beim Absenden vom UI mittels window.openai.callTool('create_membership', args) an den Tool-Server geschickt werden. Wichtig: Felder wie Passwort oder IBAN sollten vom UI direkt ans Tool gesendet werden (über _meta, d.h. nicht im structuredContent sichtbar fürs Modell), um Datenschutz zu gewährleisten. Nach Absenden schließt das Fullscreen und das Tool kann im Chat eine Bestätigung ausgeben. (Beispiel Prompt, der dieses Tool nutzt: „Ich möchte Mitglied werden.“ → ChatGPT öffnet das Fullscreen-Formular für die Mitgliedschaft.)

Tool: request_data_deletion – DSGVO-Löschantrag stellen.
Input Schema: { "reason": "string" } – vom Nutzer angegebener Grund der Löschanfrage.
Aktion: Ruft POST /privacy/data-deletion mit dem Reason-Text und dem JWT des Nutzers auf. Der Endpoint prüft Aufbewahrungsfristen (Spenden, SEPA-Mandate) und erstellt einen Eintrag
GitHub
GitHub
. Die Rückgabe signalisiert, ob auto_approved = true (sofort gelöscht) oder pending (muss manuell freigegeben werden)
GitHub
.
Output: structuredContent kann den Status des Antrags enthalten, z.B. { "status": "pending", "auto_approved": false, "retention_exceptions": [...] }. Etwaige Rückmeldungen zu Aufbewahrungsfristen (aus retention_exceptions) sollten dem Nutzer angezeigt werden
GitHub
GitHub
. Diese könnten in ein Card-UI aufbereitet werden: z.B. eine Karte „Löschantrag eingereicht“ mit Details: Status: offen, Grund: <reason>, Hinweis: X Datensätze können erst später gelöscht werden (gesetzliche Aufbewahrungspflicht).
UI: Ein Card-Component eignet sich hier, dargestellt z.B. als Info-Karte im Chat. Das outputTemplate könnte auf eine vordefinierte Card-HTML zeigen, die structuredContent.retention_exceptions in eine Liste von Hinweisen rendert. Keine Benutzereingabe nötig nach Absenden. (Beispiel Prompt: „Bitte lösche alle meine persönlichen Daten.“)

Tool: check_deletion_status – (optional) Status meiner Löschanträge abrufen.
Aktion: Fragt GET /privacy/data-deletion ab und erhält alle Anträge des Nutzers mit Status
GitHub
.
Output/UI: Z.B. ein Card oder Tabellen-Widget, das alle Anträge auflistet (ID, Datum, Status). Dies könnte auf Anfrage „Status meines Löschantrags?“ automatisch vom Modell genutzt werden. Für die Ausgabe würden wir wieder ein Card-Template nehmen.

Tool: get_profile – Profil anzeigen.
Aktion: Ruft GET /user/profile auf (gibt Contact-Daten zurück
GitHub
).
Output: structuredContent mit z.B. Name, E-Mail und relevanten Profilfeldern.
UI: Kleines Card oder einfaches Markdown im content (z.B. „Angemeldet als Max Muster, Mitglied seit 2023…“). Da dies eher informativ ist, reicht eine textuelle Ausgabe oder ein simples Card-Design.

(Weitere Tools wie update_profile, search_contacts für Admin etc. können analog definiert werden – mit entsprechenden Auth-Beschränkungen.)

3. Umsetzung mit GitHub Copilot (MCP-Modul): Die Implementierung erfolgt in einem neuen MCP-Tool-Server innerhalb des Repos. Beispiel für vorgehensweise mit Copilot:

Neues Verzeichnis/Modul anlegen: Erstelle z.B. unter mcp-servers/ ein Verzeichnis chatgpt-app-server und initialisiere dort ein Node-Projekt (da bereits ein MCP-Server in Node existiert, siehe file-server). Kopiere ggf. package.json Abhängigkeiten für @modelcontextprotocol/sdk.

Tool-Server Grundgerüst: In index.ts des Servers den MCP-Server starten. (Mit Copilot-Kommentar arbeiten, z.B.: // @copilot Initialize MCP server for ChatGPT tools.) Verwende die TypeScript SDK:

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp";  
import { z } from "zod";  
const server = new McpServer({ name: "moe-chat-server", version: "1.0.0" });  


Registriere anschließend die UI-Resources (HTML der Fullscreen/Card Components). Beispiel:

server.registerResource("membership-widget", "ui://widget/membership-signup.html", {}, async () => ({  
    contents: [{  
        uri: "ui://widget/membership-signup.html", mimeType: "text/html+skybridge",  
        text: readFileSync("ui/membership-signup.html", "utf8")  // enthält eingebettetes JS/CSS  
    }]  
}));  


(Analog für z.B. deletion-card.html etc.) Diese HTML-Dateien enthalten den Container-DIV und binden ein React/JS-Bundle der Komponenten. Copilot kann beim Schreiben dieser HTML/JS auf vorhandene React-Komponenten (z.B. Teile des Figma-Design-Systems) zurückgreifen.

Tools registrieren: Verwende server.registerTool(name, {title, inputSchema, _meta}, handler). Mit Copilot lässt sich der JSON-Schema Input bequem definieren (z.B. mit Zod):

server.registerTool("create_membership", {  
    title: "Mitgliedschaft beantragen",  
    description: "Erstellt für den aktuellen Nutzer eine neue Mitgliedschaft",  
    inputSchema: { 
        type: "object", 
        properties: { 
            contact_id: { type: "integer" }, 
            membership_type: { type: "string" }, 
            iban: { type: "string" }, 
            bic: { type: "string" } 
        }, 
        required: ["contact_id","membership_type"] 
    },  
    _meta: { 
        "openai/outputTemplate": "ui://widget/membership-signup-confirm.html", 
        "openai/toolInvocation/invoking": "Mitgliedschaft wird erstellt...", 
        "openai/toolInvocation/invoked": "Mitgliedschaft erstellt." 
    }  
}, async (args, authContext) => {  
    const { contact_id, membership_type, iban, bic } = args;  
    // Call FastAPI backend 
    const apiResp = await apiClient.post("/memberships/create", { contactId: contact_id, membershipTypeId: mapType(membership_type), start_date: today });  
    if (iban) await apiClient.post("/sepa/mandate", { contact_id: contact_id, iban, bic });  
    return { 
        content: [{ type: "text", text: "✅ Mitgliedschaft erfolgreich eingerichtet!" }], 
        structuredContent: { membershipId: apiResp.data.id, status: apiResp.data.status }  
    };  
});  


(Die obige Handler-Funktion ist exemplarisch – Copilot kann helfen, den HTTP-Client aufzusetzen. Wichtig: authContext enthält den JWT oder Session des Users für Auth.)
So definierst Du nacheinander alle Tools: register_user, create_membership, request_data_deletion, etc., jeweils mit passendem Schema und Handler-Logik. Nutze Copilot’s Kenntnis der bestehenden API-Endpunkte (aus dem Code) – z.B. kommentiere: “// @copilot TODO: Call privacy data-deletion endpoint with reason” – Copilot schlägt dann Code für den HTTP-Call vor (z.B. mit Axios oder fetch).

UI-Komponenten implementieren: Für Fullscreen/Card Widgets kannst Du auf bestehende UI aus figma-design-system zurückgreifen. Beispiel: ein React-Komponente MembershipSignupForm.tsx mit Formularfeldern und einem Submit-Button, der window.openai.callTool('create_membership', formData) aufruft. Copilot kann beschleunigen, indem Du bestehende Form-Komponenten (z.B. aus Tailwind/React in Projekt) referenzierst. Kompiliere diese Komponenten zu einbettbarem JS/CSS (z.B. mit Vite oder dem bestehenden Frontend-Build). Wichtig: In der UI darauf achten, sensible Eingaben nicht als normalen Chat-Text zurückzugeben. Stattdessen direkt über die Tool-API senden.

Serverstart und Integration: Am Ende von index.ts den Server starten (server.start( PORT )). In der api.menschlichkeit-oesterreich.at könntest Du den MCP-Server als eigenständigen Prozess laufen lassen (ähnlich wie der File-Server). Füge in package.json ein Script hinzu und dokumentiere im README die Startprozedur. Schließlich erstelle die ChatGPT-App Manifest (ist in Apps SDK durch Tool-Definitionen automatisch gegeben, ChatGPT holt diese vom laufenden MCP-Server).

4. UI-Komponenten & Nutzung im Chat: Wir empfehlen folgende UI-Elemente, um die Tools nutzerfreundlich einzubinden:

Fullscreen-Formulare – ideal für komplexe Multi-Feld-Eingaben wie die Mitgliedsanmeldung. Z.B. “Mitglied werden”-Dialog: ChatGPT öffnet ein Vollbild mit Eingabefeldern. Der Nutzer füllt alles aus und schickt ab, worauf das UI das entsprechende Tool aufruft. Der Prompt-Auslöser kann generisch sein („Ich möchte Mitglied werden“ oder „Mitgliedsantrag ausfüllen“) – das Modell erkennt die Absicht und ruft register_user/create_membership Tools. Durch _meta.openai/outputTemplate wird direkt das Formular angezeigt, ohne dass das Modell zuerst Text zurückgeben muss.

Card-Elemente – geeignet für Ergebnisdarstellungen oder kurze Interaktionen innerhalb des Chatverlaufs. Beispielsweise nach der erfolgreichen Mitgliedsanmeldung könnte eine Bestätigungs-Karte mit Mitgliedsnummer erscheinen. Oder beim Löschantrag: Eine Info-Karte listet auf, welche Daten sofort gelöscht wurden und welche aufgrund von BAO/SEPA-Ausnahmen aufbewahrt werden
GitHub
GitHub
. Karten lassen sich über ein kleines HTML-Template mit den Feldern aus structuredContent füllen (z.B. Liste von retention_exceptions). In Prompt-Vorschlägen würde das Modell diese Tools von sich aus nutzen, wenn der Nutzer z.B. fragt „Was passiert mit meinen Daten bei Löschung?“ – es könnte den Status in einer Karte präsentieren.

Modal/Popup oder Inline-Buttons – Denkbar etwa für einen “Profil anzeigen”-Befehl: ChatGPT könnte einen Inline-Button vorschlagen (“Profil jetzt abrufen”), der beim Klick das Tool get_profile aufruft und das Ergebnis als Card anzeigt. Solche Buttons kann man im Markdown content als <button> definieren, der via JavaScript (openai.callTool) gebunden wird. Prompt-Beispiel: „Zeige mein Profil“ → ChatGPT: “Ihr Profil ist bereit. [Profil anzeigen]” (Button), bei Klick wird Tool ausgeführt.

5. Sicherheits- und Datenschutzaspekte: Bei der Entwicklung der ChatGPT-App-Integration für Menschlichkeit Österreich sind folgende Punkte zentral:

Authentifizierung & Autorisierung: Da die Tools mit personenbezogenen Daten und geschützten Aktionen arbeiten (Mitgliederverwaltung, Löschanträge), muss sich der Nutzer vor der Nutzung einloggen. Am besten implementiert man OAuth/OpenID Connect. Geplant ist ohnehin Keycloak SSO
GitHub
 – dieses sollte als OAuth-Provider für das ChatGPT-Plugin dienen. D.h. beim ersten Aufruf eines Tools fordert ChatGPT den User zum Login via Keycloak auf, woraufhin der MCP-Server JWTs für die API erhält. Tools wie register_user können ggf. ohne Login genutzt werden (für neue Nutzer), aber dann sollten nur nicht-sensible Daten verarbeitet werden.

Berechtigungstrennung: Einige Tools sind nur für Admins (z.B. search_contacts). Im Tool-Descriptor kann man keine Rollen hinterlegen, daher muss der Tool-Server selbst prüfen. In unserem Codebeispiel wird require_admin analog zum FastAPI-Backend aufgerufen
GitHub
. Tools sollten den JWT-Claim roles auswerten (z.B. im authContext) und bei unberechtigtem Zugriff einen Fehler oder leeren Output liefern. So wird verhindert, dass ein normaler Nutzer z.B. fremde Kontakte abfragen kann.

Keine PII-Leaks über das Modell: Vorsicht, dass sensible Informationen nicht ungewollt im Klartext an das Sprachmodell gehen. structuredContent und content sind für das Modell sichtbar, _meta ist hingegen versteckt vor dem Modell
developers.openai.com
developers.openai.com
. Daher: Übermittle personenbezogene Daten, Tokens, IBAN etc. wenn möglich nur via _meta oder direkte API-Calls im Backend. Beispiel: Wenn der Nutzer sein IBAN eingibt, sollte dieser im UI-JavaScript direkt an den Tool-Server gehen, statt vom Modell ausgelesen zu werden. Ebenso würde ein lexofficeApiKey zur Integration niemals im Prompt erscheinen – falls ein Tool wie connect_lexoffice doch einen API-Key entgegennimmt, sollte das über ein verstecktes Feld im Fullscreen UI geschehen und der Key im Tool-Handler nur serverseitig verwendet werden.

Verschlüsselung und Speicherung: Stelle sicher, dass die Kommunikation zwischen ChatGPT und deinem MCP-Server über HTTPS erfolgt (erfordert etwa ein öffentlich erreichbarer Endpoint mit Zertifikat, da ChatGPT die Tools dort abruft). Sensible Daten, die gespeichert werden (Mitgliederdaten, API Keys), müssen gemäß DSGVO geschützt sein. Für Löschanträge gilt: Das Tool soll eventuell dem Nutzer nicht alle Details der deletion_log oder internen IDs verraten, sondern nur eine Erfolgsbestätigung. Intern werden die Löschungen aber – wie im Code vorgesehen – protokolliert
GitHub
GitHub
.

Rate Limiting & Abuse Prevention: Da das ChatGPT-Plugin prinzipiell viele Aufrufe automatisieren könnte, implementiere ggf. eine Rate-Limitierung in den Tools (ähnlich wie im File-Server mit TokenBucket
GitHub
GitHub
). Insbesondere schütze kritische Endpunkte (z.B. nicht zig Löschanträge hintereinander zulassen, Captcha für Registrierung falls nötig).

Keine Überschreibung der Moderation: Die App sollte sich den OpenAI-Inhaltsrichtlinien fügen. Z.B. wenn ein Nutzer über Chat versucht, unzulässige Inhalte im Vereinskontext zu posten, darf das Tool diese nicht ungefiltert verarbeiten. Implementiere deshalb in Tools, die Freitext entgegennehmen (etwa reason beim Löschantrag, oder Kontaktformular falls man eines anböte), ggf. eine Inhaltsprüfung (Moderation API oder simple Filter), bevor der Text an die API/CRM weitergegeben wird.

Zusammenfassend erhält das Projekt Menschlichkeit Österreich durch diese ChatGPT-App eine nahtlose Nutzererfahrung: Ein Interessent kann im Chat fragen „Wie werde ich Mitglied?“, und das Plugin leitet interaktiv durch die Anmeldung bis zur Bestätigung – alles innerhalb von ChatGPT. Ebenso kann ein bestehendes Mitglied im Chat sein Profil verwalten oder einen Löschantrag stellen, wobei das Tool die bestehenden Backend-Funktionen nutzt. Durch sorgfältige Tool-Definitionen (inkl. UI-Vorlagen) und strikte Sicherheitsprüfungen wird die Erweiterung ChatGPT-native, ohne Datenschutz oder Compliance zu verletzen.

Menschlichkeit-Österreich (NGO) — Apps-SDK Integration
1) Architektur & Voraussetzungen

Ziel-Flows:

Mitglied werden (Antrag + optional SEPA-Mandat)

Profil einsehen/ändern

DSGVO-Löschantrag stellen / Status prüfen

Bausteine (Repo-Erweiterung):

apps/chatgpt-moe/
  server/   # MCP-Server (Tools rufen vorhandene API-Endpunkte/Services auf)
  web/      # React-UI-Komponenten (Formulare/Karten), laufen im iframe via window.openai


UI wird als text/html+skybridge-Resource registriert und per Tool-Meta openai/outputTemplate verknüpft. 
developers.openai.com

UI ↔ Host-Brücke über window.openai (Tool-Calls, Follow-ups, Layoutwechsel). 
developers.openai.com
+1

Developer-Mode/Connector in ChatGPT nutzt deine öffentliche /mcp-URL (lokal via ngrok). 
developers.openai.com

Auth (empfohlen): Keycloak/OIDC → OAuth 2.1 + PKCE + Dynamic Client Registration; MCP-Server prüft Access Token bei jedem Call. 
developers.openai.com
+1

2) Quickstart (Minimalpfad)
2.1 MCP-Server (TypeScript)
# im Repo-Root:
mkdir -p apps/chatgpt-moe/{server,web}
cd apps/chatgpt-moe/server
npm i @modelcontextprotocol/sdk zod undici


apps/chatgpt-moe/server/index.ts

// @copilot goal: MCP-Server mit 3 Tools (create_membership, get_profile, request_data_deletion)
// @copilot constraint: rufe bestehende Backend-API-Endpunkte aus dem Repo auf (HTTP fetch), kein PII im structuredContent

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import { readFileSync } from "node:fs";
import { fetch } from "undici";

const server = new McpServer({ name: "moe-app", version: "1.0.0" });

// --- UI-Resource (Fullscreen Formular "Mitglied werden") ---
const UI = readFileSync("../web/dist/membership.js","utf8");
const CSS = (()=>{ try { return readFileSync("../web/dist/membership.css","utf8"); } catch { return ""; } })();

server.registerResource(
  "membership-signup",
  "ui://widget/membership-signup.html",
  {},
  async () => ({
    contents: [{
      uri: "ui://widget/membership-signup.html",
      mimeType: "text/html+skybridge",
      text: `<div id="root"></div>${CSS?`<style>${CSS}</style>`:""}<script type="module">${UI}</script>`
    }]
  })
);

// Hilfsfunktion: sichere Fetch-Calls mit Bearer-Token
async function callApi(path: string, method: "GET"|"POST"|"PUT", body?: unknown, token?: string) {
  const res = await fetch(`${process.env.MOE_API_BASE}${path}`, {
    method,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {})
    },
    body: body ? JSON.stringify(body) : undefined
  });
  if (!res.ok) throw new Error(`API ${method} ${path} failed: ${res.status}`);
  return res.json();
}

// Tool 1: Mitgliedschaft erstellen (öffnet Fullscreen-Formular)
server.registerTool(
  "create_membership",
  {
    title: "Mitglied werden",
    description: "Erstellt eine Mitgliedschaft für den eingeloggten Nutzer. Nutze dies, wenn jemand 'Ich möchte Mitglied werden' sagt.",
    inputSchema: z.object({
      membershipType: z.string().default("standard"),
      iban: z.string().optional(),
      bic: z.string().optional()
    }),
    _meta: { "openai/outputTemplate": "ui://widget/membership-signup.html" }
  },
  async (args, ctx) => {
    // @copilot TODO: Map auf echten API-Endpunkt aus dem Projekt (z.B. /memberships or /civicrm/membership)
    const token = ctx?.authorization?.accessToken;
    const data = await callApi("/memberships", "POST", {
      type: args.membershipType,
      sepa: args.iban ? { iban: args.iban, bic: args.bic } : undefined
    }, token);
    return {
      content: [{ type: "text", text: "✅ Mitgliedschaft erfolgreich angelegt." }],
      structuredContent: { membershipId: data.id, status: data.status }
    };
  }
);

// Tool 2: Profil abrufen (zeigt als Card)
server.registerTool(
  "get_profile",
  {
    title: "Profil anzeigen",
    description: "Zeigt das eigene Profil an.",
    inputSchema: z.object({}).optional()
  },
  async (_args, ctx) => {
    const token = ctx?.authorization?.accessToken;
    const profile = await callApi("/user/profile", "GET", undefined, token); // @copilot: passe den Pfad an
    return {
      content: [{ type: "text", text: `👤 Angemeldet als ${profile.firstName} ${profile.lastName}` }],
      structuredContent: { profile: { email: profile.email, memberSince: profile.memberSince } }
    };
  }
);

// Tool 3: DSGVO-Löschantrag
server.registerTool(
  "request_data_deletion",
  {
    title: "Datenlöschung beantragen",
    description: "Startet einen DSGVO-Löschantrag. Nutze dies, wenn der Nutzer 'Lösche meine Daten' sagt.",
    inputSchema: z.object({ reason: z.string().min(3) })
  },
  async (args, ctx) => {
    const token = ctx?.authorization?.accessToken;
    const r = await callApi("/privacy/data-deletion", "POST", { reason: args.reason }, token); // @copilot: anpassen
    return {
      content: [{ type: "text", text: r.autoApproved ? "🗑️ Daten wurden gelöscht." : "🗂️ Löschantrag eingereicht (prüfen wir zeitnah)." }],
      structuredContent: { status: r.status, autoApproved: r.autoApproved, retention: r.retention_exceptions ?? [] }
    };
  }
);

server.start(); // @copilot add port/env handling, logs, error handler


Copilot-Prompts (Repo-spezifisch):

Discovery:

@workspace Suche im Repo nach API-Routen/Services für Mitgliedschaft, SEPA-Mandate, User-Profil und DSGVO-Löschung. Gib mir Pfade, erwartete Payloads und Response-Shapes.

Mapping:

Ersetze in index.ts die Platzhalterpfade (/memberships, /user/profile, /privacy/data-deletion) durch die gefundenen Endpunkte und passe Request/Response-Felder an.

Härtung:

Baue Fehlerpfade ein (400/401/409), setze Rate-Limit (60 rpm) und strukturierte JSON-Logs mit Request-ID.

2.2 UI-Komponente (React, Fullscreen + Cards)

apps/chatgpt-moe/web/src/membership.tsx (Beispiel-Formular)

// @copilot goal: Fullscreen-Formular, das window.openai.callTool('create_membership', formData) auslöst
// @copilot note: keine PII in structuredContent zurückgeben, IBAN nur direkt im Tool-Call senden

declare global { interface Window { openai?: any } }

export default function MembershipSignup() {
  const [membershipType, setType] = useState("standard");
  const [iban, setIban] = useState("");
  const [bic, setBic] = useState("");

  async function submit() {
    await window.openai?.callTool("create_membership", { membershipType, iban, bic });
    await window.openai?.sendFollowupMessage({ prompt: "Bestätigung: Mitgliedschaft angelegt." });
  }

  useEffect(() => { window.openai?.requestDisplayMode({ mode: "fullscreen" }); }, []); // optional
  return (
    <div className="p-6 grid gap-3">
      <h2>Mitglied werden</h2>
      {/* @copilot add fields + simple validation */}
      <button onClick={submit}>Antrag absenden</button>
    </div>
  );
}


Hinweis: window.openai.requestDisplayMode kann inline / pip / fullscreen anfragen; der Host entscheidet. 
developers.openai.com

3) Lokale Entwicklung & Debugging

UI bundlen → web/dist.

MCP-Server starten.

MCP Inspector lokal gegen http://localhost:<port>/mcp testen; Troubleshooting bei Component-Rendering (MIME & _meta prüfen). 
developers.openai.com

4) In ChatGPT verbinden (Developer-Mode)

Settings → Connectors → Create → Connector-Name, Beschreibung („Mitglied werden, Profil, DSGVO“), Connector URL = https://<dein-host>/mcp.

Neue Unterhaltung → Developer-Mode aktivieren → Connector toggeln. 
developers.openai.com

5) Auth

OAuth 2.1 + PKCE + Dynamic Client Registration; Autorisierungs-Server (Keycloak/IdP) publiziert Discovery-Metadaten; MCP-Server prüft Token je Request. 
developers.openai.com
+1

6) Speicher & Zustand

Ephemeres UI-State per window.openai.setWidgetState klein halten (modell-sichtbar). Persistentes in deinem Backend. 
developers.openai.com

7) Sicherheit & Datenschutz

Least privilege, Einwilligung, Eingabe-Validierung, Audit-Logs, keine Secrets/IBAN im structuredContent.

Write-Aktionen klar kennzeichnen + Bestätigung. 
developers.openai.com

8) Discovery & Metadaten

Tool-Namen: membership.create, profile.get, privacy.requestDeletion.

Beschreibungen mit „Use this when …“ präzise halten. 
developers.openai.com

9) Tests & Launch-Check

Unit-Tests für Tool-Handler (Happy/Error/401/429), E2E in Dev-Mode (Web+Mobile).

Prüfe _meta.outputTemplate ↔ Resource, Schema-Konsistenz, OAuth-Fluss. 
developers.openai.com

10) (Optional) Commerce

Nicht primär nötig. Falls Spenden/Beiträge über Chat laufen sollen, evaluiere ACP-Flows. 
developers.openai.com
+1

Prompt-Snippets für Copilot (copy/paste):

„Erzeuge in apps/chatgpt-moe/server/index.ts die drei Tools wie kommentiert. Ersetze API-Pfade anhand der vorhandenen FastAPI/Service-Routen und ergänze Typen.“

„Baue eine React-Komponente membership.tsx (Fullscreen). Felder: Mitgliedschafts-Typ, IBAN, BIC. Submit → window.openai.callTool('create_membership', …).“

„Füge Tests (Vitest/Jest) für 200/400/401/429 hinzu und mocke die HTTP-Calls.“

Nützliche Stellen in den offiziellen Docs

window.openai API & Layoutwechsel (inline/pip/fullscreen). 
developers.openai.com

Custom UX im iframe & Projektstruktur. 
developers.openai.com

MCP-Server einrichten & Skybridge MIME/Template. 
developers.openai.com

Connector in ChatGPT registrieren. 
developers.openai.com

Auth (OAuth 2.1/PKCE/DCR) für MCP. 
developers.openai.com
+1

Troubleshooting (No component / Schema mismatch). 
developers.openai.com

Agentic Commerce (ACP), falls ihr Commerce-Flows plant. 
developers.openai.com
+1