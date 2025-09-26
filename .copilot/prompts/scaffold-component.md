# name: Scaffold Component

# description: Gerüstet eine neue React/TypeScript UI-Komponente mit Tests und Stories

Erzeuge eine vollständige Komponente **{ComponentName}** mit folgender Struktur:

## Dateien erstellen:

- `src/components/{category}/{ComponentName}.tsx` - Haupt-Komponente
- `src/components/{category}/{ComponentName}.test.tsx` - Unit Tests
- `src/components/{category}/{ComponentName}.stories.tsx` - Storybook Stories
- `src/components/{category}/index.ts` - Export-Barrel

## Komponenten-Standards:

- **TypeScript:** Vollständige Typisierung mit Props-Interface
- **React:** Functional Component mit FC<Props> Typing
- **Styling:** Tailwind Classes mit Design Token Integration
- **Accessibility:** ARIA-Labels, Keyboard Navigation, Screen Reader Support

## Test-Abdeckung:

- **Unit Tests:** Rendering, Props, Events, Edge Cases
- **Accessibility:** axe-core Tests für WCAG Compliance
- **Visual Tests:** Storybook Stories für alle Varianten

## Props-Template (falls nicht spezifiziert):

```typescript
interface {ComponentName}Props {
  children?: React.ReactNode;
  className?: string;
  variant?: 'primary' | 'secondary' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  onClick?: () => void;
}
```

## Vereins-spezifische Integration:

- **DSGVO:** Bei Daten-Components: Privacy-Hinweise und Consent-Management
- **Branding:** Österreichische Farben und Corporate Identity
- **Barrierefreiheit:** WCAG 2.1 AA Compliance für öffentliche Vereinswebsite

**Nach der Erstellung:** Erkläre kurz die Component-API und gib Verwendungsbeispiele.
