# Figma Atoms - Button Komponenten (20+ Varianten)

## 🔘 Button System

### Base Button Anatomy
```figma
Button Component:
├── Container (Auto Layout)
│   ├── Leading Icon (Optional)
│   ├── Label (Text)
│   └── Trailing Icon (Optional)
├── States: Default | Hover | Active | Focus | Disabled | Loading
├── Variants: Size × Type × State × Icon Position
└── Responsive: xs | sm | md | lg | xl | 2xl
```

## 📐 Button Sizes

### 1. Extra Small (xs)
- **Height**: 24px
- **Padding**: 4px 8px
- **Font**: 12px, Medium (500)
- **Icon**: 12x12px
- **Use Case**: Compact interfaces, table actions

### 2. Small (sm) 
- **Height**: 32px
- **Padding**: 6px 12px
- **Font**: 14px, Medium (500)
- **Icon**: 16x16px
- **Use Case**: Secondary actions, mobile interfaces

### 3. Medium (md) - Default
- **Height**: 40px
- **Padding**: 8px 16px
- **Font**: 14px, Medium (500)
- **Icon**: 16x16px
- **Use Case**: Primary actions, forms

### 4. Large (lg)
- **Height**: 48px
- **Padding**: 12px 24px
- **Font**: 16px, Medium (500)
- **Icon**: 20x20px
- **Use Case**: Hero sections, important CTAs

### 5. Extra Large (xl)
- **Height**: 56px
- **Padding**: 16px 32px
- **Font**: 18px, Medium (500)
- **Icon**: 24x24px
- **Use Case**: Landing pages, prominent actions

## 🎨 Button Types

### 1. Primary Button
```figma-spec
Background: primary-500 (#0ea5e9)
Text: white
Border: none
Shadow: md

Hover:
Background: primary-600 (#0284c7)
Shadow: lg
Transform: translateY(-1px)

Active:
Background: primary-700 (#0369a1)
Transform: translateY(0)

Focus:
Ring: 2px primary-500 with 2px offset
Outline: none

Disabled:
Background: gray-300
Text: gray-500
Cursor: not-allowed
```

### 2. Secondary Button
```figma-spec
Background: transparent
Text: primary-600
Border: 1px solid primary-200
Shadow: sm

Hover:
Background: primary-50
Border: 1px solid primary-300
Shadow: md

Active:
Background: primary-100

Disabled:
Border: gray-200
Text: gray-400
```

### 3. Tertiary Button
```figma-spec
Background: transparent
Text: primary-600
Border: none

Hover:
Background: primary-50
Text: primary-700

Active:
Background: primary-100

Disabled:
Text: gray-400
```

### 4. Destructive Button
```figma-spec
Background: error-500 (#ef4444)
Text: white
Border: none

Hover:
Background: error-600 (#dc2626)

Active:
Background: error-700 (#b91c1c)

Disabled:
Background: gray-300
Text: gray-500
```

### 5. Success Button
```figma-spec
Background: success-500 (#22c55e)
Text: white

Hover:
Background: success-600 (#16a34a)

Active:
Background: success-700 (#15803d)
```

### 6. Warning Button
```figma-spec
Background: warning-500 (#f59e0b)
Text: white

Hover:
Background: warning-600 (#d97706)

Active:
Background: warning-700 (#b45309)
```

### 7. Ghost Button
```figma-spec
Background: transparent
Text: gray-700
Border: none

Hover:
Background: gray-100

Active:
Background: gray-200

Disabled:
Text: gray-400
```

### 8. Outline Button
```figma-spec
Background: transparent
Text: gray-700
Border: 1px solid gray-300

Hover:
Background: gray-50
Border: gray-400

Active:
Background: gray-100
```

## 🔗 Icon Positions

### 1. Leading Icon
```figma-layout
[Icon] Label
Gap: 8px (sm/md), 12px (lg+)
```

### 2. Trailing Icon
```figma-layout
Label [Icon]
Gap: 8px (sm/md), 12px (lg+)
```

### 3. Icon Only
```figma-layout
[Icon]
Square aspect ratio
Padding: equal on all sides
```

### 4. Both Icons
```figma-layout
[Leading] Label [Trailing]
Gap: 8px between each element
```

## ⚡ Interactive States

### Loading State
```figma-spec
Show: Loading spinner (replace leading icon)
Disable: All interactions
Opacity: 0.8
Text: "Loading..." or keep original
Animation: Spin 1s linear infinite
```

### Focus State (Keyboard)
```figma-spec
Ring: 2px primary-500
Offset: 2px
Border-radius: Same as button + 2px
```

### Pressed State
```figma-spec
Transform: translateY(1px) scale(0.98)
Duration: 100ms
```

## 📱 Responsive Behavior

### Mobile (xs-sm)
- Prefer sm/md sizes
- Full-width on small screens
- Touch target: minimum 44x44px
- Stack vertically in groups

### Tablet (md-lg)
- md/lg sizes optimal
- Horizontal groups
- Adequate spacing

### Desktop (xl+)
- All sizes available
- Hover states active
- Keyboard navigation

## ♿ Accessibility

### Required Attributes
```html
role="button"
tabindex="0"
aria-label="Action description"
aria-describedby="helper-text-id"
aria-disabled="true" (when disabled)
```

### Focus Management
- Visible focus indicator
- Logical tab order
- Enter/Space activation

### Color Contrast
- Primary: 4.5:1 minimum
- Secondary: 4.5:1 minimum
- All states meet WCAG AA

## 🎬 Micro-Animations

### Hover Animation
```css
transition: all 200ms ease-out;
transform: translateY(-1px);
box-shadow: elevated;
```

### Click Animation
```css
transition: transform 100ms ease-in;
transform: translateY(1px) scale(0.98);
```

### Loading Animation
```css
spinner: rotate 360deg 1s linear infinite;
opacity: fade-in 150ms;
```

## 📋 Button Component Variants Matrix

| Size | Type | Icon | State | Total |
|------|------|------|-------|-------|
| 5 sizes | 8 types | 4 positions | 6 states | **960 variants** |

### Figma Component Structure
```
Button/
├── Size=xs/Type=primary/Icon=none/State=default
├── Size=xs/Type=primary/Icon=none/State=hover
├── Size=xs/Type=primary/Icon=none/State=active
├── ... (all combinations)
└── Size=2xl/Type=ghost/Icon=both/State=loading
```

## 🔧 Implementation Notes

### Figma Setup
1. Create base component with all properties
2. Set up component properties for variants
3. Configure auto-layout with resizing
4. Add interaction states
5. Create component documentation
6. Set up design tokens connection

### Developer Handoff
- Export all states as separate assets
- Provide CSS specifications
- Include animation timing
- Document accessibility requirements
- Create usage examples

**Status**: 📋 Specification Complete | 🔄 Figma Implementation Pending