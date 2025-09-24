# Figma Atoms - Input Komponenten (15+ Typen)

## 📝 Input System Overview

### Base Input Anatomy
```figma
Input Component:
├── Label (Optional)
├── Input Container
│   ├── Leading Element (Icon/Prefix)
│   ├── Input Field
│   └── Trailing Element (Icon/Suffix)
├── Helper Text (Optional)
├── Error Message (Optional)
└── Character Counter (Optional)
```

## 🎯 Input Types & Variants

### 1. Text Input
```figma-spec
Type: text
Placeholder: "Enter text..."
Validation: Required/Optional
Max Length: Variable
Auto Complete: Supported
```

### 2. Email Input
```figma-spec
Type: email
Placeholder: "name@example.com"
Validation: Email format
Leading Icon: @ symbol
Error: "Please enter valid email"
```

### 3. Password Input
```figma-spec
Type: password
Placeholder: "••••••••"
Trailing Icon: Eye toggle (show/hide)
Validation: Strength indicator
Min Length: 8 characters
```

### 4. Number Input
```figma-spec
Type: number
Placeholder: "0"
Trailing: Increment/Decrement buttons
Validation: Min/Max values
Format: Locale-specific
```

### 5. Telephone Input
```figma-spec
Type: tel
Placeholder: "+49 123 456789"
Leading Icon: Phone symbol
Format: International format
Validation: Phone pattern
```

### 6. URL Input
```figma-spec
Type: url
Placeholder: "https://example.com"
Validation: URL format
Leading Icon: Link symbol
Protocol: Auto-detection
```

### 7. Search Input
```figma-spec
Type: search
Placeholder: "Search..."
Leading Icon: Magnifying glass
Trailing Icon: Clear (X)
Auto Suggestions: Dropdown
```

### 8. Date Input
```figma-spec
Type: date
Format: DD.MM.YYYY (German)
Calendar Icon: Trailing
Min/Max Date: Configurable
Validation: Date range
```

### 9. Time Input
```figma-spec
Type: time
Format: HH:MM (24h)
Clock Icon: Trailing
Step: Minutes/Seconds
Validation: Time format
```

### 10. DateTime Input
```figma-spec
Type: datetime-local
Format: DD.MM.YYYY, HH:MM
Icons: Calendar + Clock
Timezone: Local
Validation: Combined
```

### 11. Month Input
```figma-spec
Type: month
Format: MM/YYYY
Placeholder: "Month/Year"
Navigation: Month picker
Validation: Month range
```

### 12. Week Input
```figma-spec
Type: week
Format: Week XX, YYYY
Placeholder: "Select week"
Navigation: Week picker
ISO Standard: Week numbers
```

### 13. Range Input (Slider)
```figma-spec
Type: range
Min/Max: Configurable
Step: Increment value
Labels: Min/Max/Current
Thumb: Custom styled
```

### 14. Color Input
```figma-spec
Type: color
Default: #000000
Picker: Color palette
Format: Hex/RGB/HSL
Preview: Color swatch
```

### 15. File Input
```figma-spec
Type: file
Multiple: Boolean
Accept: File types
Drag & Drop: Enabled
Preview: File thumbnails
```

## 📐 Input Sizes

### Small (sm)
- **Height**: 32px
- **Padding**: 6px 12px
- **Font Size**: 14px
- **Icon Size**: 16x16px
- **Border Radius**: 6px

### Medium (md) - Default
- **Height**: 40px
- **Padding**: 8px 12px
- **Font Size**: 14px
- **Icon Size**: 20x20px
- **Border Radius**: 8px

### Large (lg)
- **Height**: 48px
- **Padding**: 12px 16px
- **Font Size**: 16px
- **Icon Size**: 24x24px
- **Border Radius**: 8px

## 🎨 Input States

### 1. Default State
```figma-spec
Background: white
Border: 1px solid gray-300
Text: gray-900
Placeholder: gray-400
Shadow: none
```

### 2. Hover State
```figma-spec
Border: 1px solid gray-400
Shadow: sm
Transition: 150ms ease
```

### 3. Focus State
```figma-spec
Border: 2px solid primary-500
Ring: 2px primary-100
Outline: none
Shadow: md
```

### 4. Active State
```figma-spec
Border: 2px solid primary-600
Background: primary-25
Text: gray-900
```

### 5. Disabled State
```figma-spec
Background: gray-100
Border: 1px solid gray-200
Text: gray-400
Cursor: not-allowed
Opacity: 0.6
```

### 6. Error State
```figma-spec
Border: 2px solid error-500
Ring: 2px error-100
Background: error-25
Text: error-900
Icon Color: error-500
```

### 7. Success State
```figma-spec
Border: 2px solid success-500
Ring: 2px success-100
Background: success-25
Text: success-900
Icon Color: success-500
```

### 8. Warning State
```figma-spec
Border: 2px solid warning-500
Ring: 2px warning-100
Background: warning-25
Text: warning-900
Icon Color: warning-500
```

## 🏷️ Label Variants

### 1. Top Label
```figma-layout
Label
Input Field
Helper Text
```

### 2. Left Label
```figma-layout
Label | Input Field
Helper Text (spans full width)
```

### 3. Floating Label
```figma-layout
Input with animated label
Transforms on focus/content
```

### 4. No Label
```figma-layout
Input Field (with placeholder)
Helper Text
```

## 🔗 Helper Elements

### Leading Icons
- **User**: Profile/Login fields
- **Email**: @ symbol
- **Phone**: Telephone icon
- **Search**: Magnifying glass
- **Lock**: Password fields
- **Calendar**: Date fields
- **Clock**: Time fields
- **Link**: URL fields

### Trailing Icons
- **Clear**: X button (removable)
- **Toggle**: Eye for passwords
- **Dropdown**: Chevron down
- **Calendar**: Date picker
- **Search**: Submit search
- **Info**: Help/Tooltip
- **Valid**: Checkmark
- **Error**: Warning icon

### Prefix/Suffix Text
- **Currency**: €, $, £
- **Units**: kg, cm, %
- **Domain**: .com, .de
- **Protocol**: https://
- **Phone Code**: +49, +1

## 📱 Responsive Behavior

### Mobile (xs-sm)
- Touch-friendly size (min 44px)
- Full-width inputs
- Large touch targets
- Stack labels vertically

### Tablet (md-lg)
- Balanced proportions
- Adequate spacing
- Horizontal label option

### Desktop (xl+)
- All sizes available
- Hover states active
- Keyboard navigation optimized

## ♿ Accessibility

### Required Attributes
```html
<label for="input-id">Label</label>
<input 
  id="input-id"
  type="text"
  aria-describedby="helper-text"
  aria-invalid="false"
  aria-required="true"
/>
<div id="helper-text">Helper text</div>
```

### Focus Management
- Clear focus indicators
- Logical tab order
- Screen reader support
- Error announcements

### Color Blind Support
- Icons for state indication
- High contrast ratios
- Pattern-based validation

## 🔄 Validation States

### Real-time Validation
```figma-spec
On Input: Character count
On Blur: Format validation
On Submit: Complete validation
Debounce: 300ms delay
```

### Error Patterns
- **Required**: "This field is required"
- **Format**: "Please enter valid [type]"
- **Length**: "Must be at least X characters"
- **Pattern**: "Please match the requested format"

### Success Patterns
- **Valid**: Green checkmark
- **Saved**: "Changes saved"
- **Verified**: "Email verified"

## 🎬 Micro-Interactions

### Focus Animation
```css
transition: all 150ms ease-out;
border-color: primary-500;
ring: expand from 0 to 2px;
```

### Error Animation
```css
shake: 0.5s ease-in-out;
transform: translateX(-2px) to translateX(2px);
```

### Success Animation
```css
checkmark: draw animation 300ms;
background: pulse success color;
```

## 📋 Input Component Matrix

| Type | Size | State | Element | Total |
|------|------|-------|---------|-------|
| 15 types | 3 sizes | 8 states | 4 elements | **1440 variants** |

### Figma Organization
```
Input/
├── Type=text/Size=md/State=default/Element=none
├── Type=text/Size=md/State=focus/Element=leading
├── Type=email/Size=lg/State=error/Element=trailing
├── ... (all combinations)
└── Type=file/Size=lg/State=success/Element=both
```

**Status**: 📋 Complete Specification | 🎨 Ready for Figma Implementation