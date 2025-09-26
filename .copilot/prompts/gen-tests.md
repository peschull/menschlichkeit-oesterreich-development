# name: Generate Tests

# description: Erzeugt fokussierte Unit Tests im AAA-Stil für React/TypeScript Code

Schreibe **prägnante Unit Tests** für den markierten Code mit folgenden Anforderungen:

## Test-Framework & Setup

- **Vitest** + **@testing-library/react** für React Components
- **@testing-library/jest-dom** für erweiterte Matchers
- **@testing-library/user-event** für Benutzerinteraktionen
- **MSW (Mock Service Worker)** für API-Mocking falls erforderlich

## Test-Struktur (AAA Pattern)

```typescript
describe('ComponentName', () => {
  // Arrange - Setup
  const defaultProps = { ... };

  it('should render correctly with default props', () => {
    // Arrange
    render(<ComponentName {...defaultProps} />);

    // Act
    const element = screen.getByRole('...');

    // Assert
    expect(element).toBeInTheDocument();
  });
});
```

## Test-Kategorien abdecken

### 1. **Rendering Tests**

- Komponente rendert ohne Fehler
- Props werden korrekt angezeigt
- Conditional Rendering funktioniert

### 2. **User Interaction Tests**

- Button Clicks, Form Submissions
- Keyboard Navigation (Tab, Enter, Escape)
- Mouse Events (hover, focus, blur)

### 3. **Edge Cases & Error States**

- Leere/undefined Props
- Fehlerhafte API Responses (bei Data-Components)
- Loading States, Error Boundaries

### 4. **Accessibility Tests**

- Screen Reader Support (ARIA)
- Keyboard Navigation
- Focus Management
- Color Contrast (programmatisch testbar)

### 5. **DSGVO/Privacy Tests** (bei relevanten Components)

- Consent-Dialoge funktionieren
- Datenschutz-Einstellungen werden gespeichert
- PII-Daten werden nicht in DOM/Console geleaked

## Vereins-spezifische Tests

```typescript
// Beispiel: SEPA-Component Tests
describe('SepaManagement', () => {
  it('should validate Austrian IBAN correctly', () => {
    // Test für österreichische IBAN-Validierung
  });

  it('should not expose sensitive bank data in DOM', () => {
    // DSGVO: Keine IBAN in innerHTML/textContent
  });

  it('should require consent for SEPA processing', () => {
    // Privacy: Consent-Management testen
  });
});

// Beispiel: Member Component Tests
describe('MemberCard', () => {
  it('should display member initials instead of full name', () => {
    // Datenminimierung: Nur Initialen anzeigen
  });

  it('should hide sensitive data from non-admin users', () => {
    // Authorization: Rollentests
  });
});
```

## Mock-Patterns

```typescript
// Auth Context Mocking
const mockAuthContext = {
  user: { id: '1', role: 'admin' },
  isAuthenticated: true,
  login: vi.fn(),
  logout: vi.fn(),
};

// API Response Mocking
const server = setupServer(
  rest.get('/api/members', (req, res, ctx) => {
    return res(ctx.json({ members: mockMembers }));
  })
);
```

## Output-Anforderung

- **Vollständige Testdatei** mit Imports und Setup
- **Mindestens 80% Code Coverage** für kritische Funktionen
- **Kommentare** zu komplexen Test-Szenarien
- **Performance:** Tests sollen unter 100ms pro Test laufen

**Priorisierung:** Kritische Business-Logik > UI-Interaktionen > Edge Cases
