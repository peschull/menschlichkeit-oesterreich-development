# JS/JSX Style - Menschlichkeit Österreich

## Modern JavaScript Standards

- **ES Modules:** Verwende `import/export` statt CommonJS
- **Variables:** `const` > `let` > nie `var`
- **Functions:** Arrow functions für Callbacks, normale functions für Methoden
- **Optional Chaining:** Nutze `?.` und `??` für sicheren Zugriff
- **Destructuring:** Bevorzuge Destructuring für Objekt/Array-Zugriffe

## React/JSX Patterns

- **Components:** Functional Components mit Hooks statt Klassen
- **Props:** Destructuring in Parametern, TypeScript Interfaces
- **State:** `useState` für lokalen State, Context für geteilten State
- **Effects:** `useEffect` sparsam, Dependencies-Array immer angeben
- **Event Handler:** Arrow functions in JSX vermeiden (Performance)

## Testing Standards

- **Framework:** Vitest > Jest für neue Tests
- **Pattern:** AAA (Arrange, Act, Assert)
- **Coverage:** Minimum 80% für Kernlogik, 60% für UI-Components
- **Mock:** Sparsam mocken, echte Integration bevorzugen wo möglich

## Error Handling

- **Error Boundaries:** Für React Components
- **Try-Catch:** Fehlerpfade zuerst behandeln (Early Return Pattern)
- **Async:** Immer .catch() oder try-catch bei Promises
- **Logging:** console.error für Development, strukturierte Logs für Production

## Performance

- **Bundle Size:** Code Splitting für große Components
- **Re-Renders:** `useMemo`/`useCallback` nur bei bewiesenen Performance-Problemen
- **Images:** WebP Format, lazy loading für Listen
- **Networks:** Debouncing für Search, Caching für API Calls

## Code Organization

- **Files:** Eine Component pro Datei, Co-Location für Tests/Stories
- **Functions:** Kleine, pure Funktionen bevorzugen (max 20 Zeilen)
- **Imports:** Absolute Imports für `src/`, relative für lokale Dateien
- **Exports:** Named Exports bevorzugen, Default nur für Haupt-Component

## Vereins-spezifische Patterns

```javascript
// ✅ Gut: Strukturierte Mitgliederdaten
const member = {
  id: string,
  personalData: { firstName, lastName, email },
  membership: { status, joinDate, membershipType },
  privacy: { consentGiven, lastUpdated },
};

// ✅ Gut: SEPA-Daten kapseln
const sepaMandate = {
  id: string,
  mandate: { reference, creditorId, status },
  bankDetails: { iban, bic }, // verschlüsselt speichern
  validation: { isValid, validatedAt },
};

// ✅ Gut: Fehlerbehandlung für Finanzdaten
try {
  const result = await processSepaPayment(mandate);
  logAuditEvent('sepa_payment_processed', { mandateId, amount });
} catch (error) {
  logSecurityEvent('sepa_payment_failed', { error, mandateId });
  throw new PaymentError('SEPA-Zahlung fehlgeschlagen', { cause: error });
}
```

## DSGVO-konforme Implementierung

```javascript
// ✅ Datenminimierung im Frontend
const displayMember = {
  initials: `${member.firstName[0]}${member.lastName[0]}`,
  memberSince: member.joinDate.getFullYear(),
  // Keine vollständigen personenbezogenen Daten für Listen-Ansichten
};

// ✅ Consent-Management
const trackingConsent = useConsent('analytics');
if (trackingConsent.isGiven) {
  analytics.track('page_view', { page: 'membership' });
}
```
