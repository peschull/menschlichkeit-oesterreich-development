# Komponenten-Bibliothek — Accessibility & Props

## Tokens

Die `docs/design-tokens.json` enthält Farben, Typographie, Spacing, Radii, Shadows.

## Komponenten (Kurz)

- Header
  - Props: `transparent:boolean`, `showSearch:boolean`
  - Accessibility: `role=banner`, `skiplink` to `#main-content`, nav toggle `aria-expanded`
- Footer
  - Landmark `role=contentinfo`
- Card
  - Props: `image, eyebrow, title, body, cta`
  - Accessibility: image `alt` required, keyboard focusable if clickable
- CTA
  - Variants: `primary, secondary, ghost`
  - Accessibility: `aria-label` when text not descriptive
- Form
  - Patterns: label above input, error message inline with `aria-describedby`, `role=alert` for summary
  - Validation: client + server; focus first invalid field on submit
- Accordion
  - Implement as `<button aria-expanded>` controlling `div role="region" aria-hidden`
- Tabs
  - roving tabindex, `tablist`/`tab`/`tabpanel`
- Spenden/Membership Widget
  - Steps: select amount/membership -> details -> payment
  - Accessibility: progress indicator, keyboard order, form summary

## Error messaging pattern

- Inline errors under respective field
- Summary at top with `role=alert` and anchor links to fields

## Focus management

- Modals trap focus; Esc closes; focus returns to opener

## Form constraints & sizes

- Touch targets >= 44x44px, font-size >= 16px (UI target 24px for main CTAs)
