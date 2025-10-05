# @menschlichkeit/shared

Zentrale Utilities für das Monorepo.

## API

- `redactSecrets(text: string): string`
  - Reduziert Risiko, sensible Daten in Logs/Outputs preiszugeben (Keys, JWT, Passwörter). 
- `isBlockedPath(name: string, options): boolean`
  - Nutzt Extension-/Pattern-/Dotfile-Filter, um sensible Pfade auszublenden.

## Verwendung

```js
const { redactSecrets, isBlockedPath } = require('@menschlichkeit/shared');
```

## Hinweise
- Leichtgewichtige, zero-deps Utilities bevorzugen.
- Browser/Node-Kompatibilität beachten.
