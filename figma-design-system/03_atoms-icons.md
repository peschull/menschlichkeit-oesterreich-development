# Figma Atoms - Icon System (200+ Symbole)

## 🎨 Icon System Overview

### Icon Categories & Counts

#### 1. Navigation & UI (40 Icons)
- **Arrow**: up, down, left, right, diagonal (8)
- **Chevron**: up, down, left, right (4) 
- **Menu**: hamburger, dots (vertical/horizontal), kebab (4)
- **Close**: X, cross, dismiss (3)
- **Home**: house, dashboard (2)
- **Back**: arrow-left, return (2)
- **Search**: magnifying glass, find (2)
- **Filter**: funnel, sort (2)
- **More**: ellipsis, options (2)
- **Expand**: maximize, minimize (2)
- **Refresh**: reload, sync (2)
- **Settings**: gear, cog (2)
- **Info**: question, help (2)
- **Edit**: pencil, modify (2)
- **View**: eye, preview (2)
- **List**: bullets, lines (3)

#### 2. Actions & Controls (35 Icons)
- **Add**: plus, create, new (3)
- **Delete**: trash, remove, bin (3)
- **Save**: disk, download, export (3)
- **Copy**: duplicate, clone (2)
- **Share**: send, forward (2)
- **Print**: printer, document (2)
- **Undo**: arrow-left, revert (2)
- **Redo**: arrow-right, forward (2)
- **Cut**: scissors, slice (2)
- **Paste**: clipboard, insert (2)
- **Select**: cursor, pointer (2)
- **Drag**: grip, move (2)
- **Resize**: arrows, scale (2)
- **Lock**: secure, protect (2)
- **Unlock**: open, access (2)
- **Hide**: eye-off, invisible (2)
- **Show**: eye, visible (2)

#### 3. Communication (25 Icons)
- **Email**: mail, envelope, at-sign (3)
- **Phone**: telephone, mobile, call (3)
- **Message**: chat, bubble, text (3)
- **Notification**: bell, alert (2)
- **Video**: camera, webcam (2)
- **Voice**: microphone, audio (2)
- **Send**: paper-plane, submit (2)
- **Receive**: inbox, download (2)
- **Reply**: arrow-left, respond (2)
- **Forward**: arrow-right, send (2)
- **Attach**: paperclip, file (2)
- **Link**: chain, url (2)

#### 4. Files & Documents (30 Icons)
- **File**: document, page (2)
- **Folder**: directory, category (2)
- **PDF**: document-pdf (1)
- **Image**: photo, picture (2)
- **Video**: film, movie (2)
- **Audio**: music, sound (2)
- **Archive**: zip, compressed (2)
- **Spreadsheet**: table, excel (2)
- **Text**: document, txt (2)
- **Code**: brackets, dev (2)
- **Database**: server, data (2)
- **Cloud**: storage, sync (2)
- **Upload**: arrow-up, send (2)
- **Download**: arrow-down, get (2)
- **Import**: arrow-in, load (2)
- **Export**: arrow-out, save (2)
- **Backup**: shield, protect (1)

#### 5. User & Profile (20 Icons)
- **User**: person, profile (2)
- **Users**: people, team (2)
- **Admin**: shield-user, manager (2)
- **Guest**: user-question, visitor (2)
- **Login**: sign-in, enter (2)
- **Logout**: sign-out, exit (2)
- **Register**: user-plus, signup (2)
- **Avatar**: circle-user, photo (2)
- **Role**: badge, permission (2)
- **Group**: users, organization (2)
- **Contact**: address-book, vcard (2)

#### 6. Status & Feedback (25 Icons)
- **Success**: check, checkmark, tick (3)
- **Error**: X, cross, alert-circle (3)
- **Warning**: triangle, exclamation (2)
- **Info**: info-circle, question (2)
- **Loading**: spinner, progress (2)
- **Complete**: check-circle, done (2)
- **Pending**: clock, waiting (2)
- **Active**: dot, online (2)
- **Inactive**: dot-off, offline (2)
- **New**: star, badge (2)
- **Updated**: refresh, sync (2)
- **Draft**: edit, pencil (2)
- **Published**: globe, live (1)

#### 7. E-Commerce & Finance (20 Icons)
- **Shopping**: cart, bag (2)
- **Payment**: credit-card, money (2)
- **Bank**: building, institution (2)
- **Euro**: currency-eur (1)
- **Dollar**: currency-usd (1)
- **Receipt**: ticket, invoice (2)
- **Wallet**: purse, payment (2)
- **Transaction**: exchange, transfer (2)
- **Refund**: arrow-back, return (2)
- **Discount**: percent, sale (2)
- **Price**: tag, cost (2)
- **Order**: list-check, items (2)

#### 8. Date & Time (15 Icons)
- **Calendar**: date, schedule (2)
- **Clock**: time, hour (2)
- **Today**: calendar-today (1)
- **Week**: calendar-week (1)
- **Month**: calendar-month (1)
- **Year**: calendar-year (1)
- **Timeline**: history, chronology (2)
- **Deadline**: alarm, timer (2)
- **Schedule**: plan, agenda (2)
- **Event**: calendar-event, meeting (1)

#### 9. Security & Privacy (15 Icons)
- **Shield**: protection, security (2)
- **Key**: password, access (2)
- **Fingerprint**: biometric, id (1)
- **Secure**: lock-check, safe (2)
- **Vulnerability**: shield-alert, risk (2)
- **Encryption**: key-modern, cipher (2)
- **Privacy**: eye-off, hidden (2)
- **Audit**: search-check, review (2)

## 📐 Icon Specifications

### Size Variants
- **12px**: Inline text, compact UI
- **16px**: Form elements, buttons (sm)
- **20px**: Standard UI, buttons (md)
- **24px**: Headers, buttons (lg)
- **32px**: Feature icons, cards
- **48px**: Hero sections, illustrations

### Style Variants
- **Outline**: Stroke-only, 1.5px weight
- **Filled**: Solid color fill
- **Duo-tone**: Two-color combination
- **Light**: Thin stroke, 1px weight
- **Bold**: Thick stroke, 2px weight

### Color Variants
- **Default**: currentColor (inherits)
- **Primary**: primary-500
- **Secondary**: secondary-500
- **Success**: success-500
- **Warning**: warning-500
- **Error**: error-500
- **Muted**: gray-400

## 🎯 Icon Component System

### Base Icon Component
```figma
Icon/
├── Size: 12|16|20|24|32|48
├── Style: outline|filled|duo-tone|light|bold
├── Color: default|primary|secondary|success|warning|error|muted
├── State: default|hover|active|disabled
└── Rotation: 0°|90°|180°|270°
```

### Icon Variants Matrix
| Category | Icons | Sizes | Styles | Colors | States | Rotation | Total |
|----------|-------|-------|--------|--------|--------|----------|-------|
| 9 cats | 225 icons | 6 sizes | 5 styles | 7 colors | 4 states | 4 rotations | **75,600 variants** |

## 🏗️ Figma Structure

### Master Icons
```
Icons/
├── Navigation/
│   ├── Arrow-Up/Size=20/Style=outline/Color=default
│   ├── Arrow-Down/Size=20/Style=filled/Color=primary
│   └── ...
├── Actions/
├── Communication/
├── Files/
├── User/
├── Status/
├── Commerce/
├── DateTime/
└── Security/
```

### Icon Library Organization
1. **Master Components**: Base icon shapes
2. **Instance Variants**: Size/style/color combinations
3. **Usage Examples**: In context (buttons, forms, etc.)
4. **Icon Grid**: All icons overview
5. **Search Tags**: Metadata for findability

## 🎨 Design Guidelines

### Consistency Rules
- **Grid System**: 24x24px base grid
- **Stroke Width**: Consistent across family
- **Corner Radius**: 2px for rounded elements
- **Optical Alignment**: Visual center, not geometric
- **Keyline Shapes**: Circle, square, rectangle, triangle

### Visual Balance
- **Icon Weight**: Match text weight
- **Negative Space**: Adequate breathing room
- **Line Endings**: Rounded caps
- **Intersections**: Clean connections
- **Details**: Simplified at small sizes

## ♿ Accessibility

### Icon Requirements
- **Alternative Text**: Descriptive labels
- **Color Independence**: Meaning not color-dependent
- **Focus States**: Keyboard navigation support
- **Size Requirements**: Minimum 16x16px touch target
- **Contrast Ratio**: 3:1 minimum against background

### Implementation
```html
<svg role="img" aria-label="Search">
  <title>Search</title>
  <path d="..."/>
</svg>

<!-- Or as decorative -->
<svg aria-hidden="true">
  <path d="..."/>
</svg>
```

## 🔄 Icon States

### Default State
- Standard opacity (1.0)
- Defined color value
- No additional effects

### Hover State
- Opacity: 0.8
- Color shift: +100 (lighter)
- Transition: 150ms

### Active/Pressed State
- Opacity: 0.6
- Color shift: +200 (darker)
- Scale: 0.95

### Disabled State
- Opacity: 0.4
- Color: gray-400
- No interactions

## 📱 Responsive Behavior

### Mobile (xs-sm)
- Prefer 24px+ sizes
- Touch-friendly targets (44x44px min)
- High contrast colors
- Simple, bold styles

### Desktop (lg+)
- All sizes appropriate
- Hover states active
- Detailed styles possible
- Keyboard navigation

## 🔧 Export Specifications

### SVG Export
- **Format**: SVG 1.1
- **Optimization**: SVGO processed
- **Viewbox**: 0 0 24 24 (normalized)
- **Stroke**: currentColor
- **Fill**: currentColor or none

### PNG Export (Fallback)
- **Sizes**: 12, 16, 20, 24, 32, 48px
- **Format**: PNG-24 with transparency
- **Density**: 1x, 2x, 3x variants
- **Naming**: icon-name-size-style

### Icon Font (Optional)
- **Format**: WOFF2 + WOFF
- **Unicode**: Private Use Area
- **Glyph Names**: Semantic naming
- **CSS Classes**: .icon-name

## 🎬 Animation Guidelines

### Micro-Interactions
- **Hover**: Gentle scale/fade
- **Click**: Brief scale down
- **State Change**: Smooth transition
- **Loading**: Spin/pulse animation

### Animation Properties
```css
.icon {
  transition: all 150ms ease-out;
}

.icon:hover {
  transform: scale(1.1);
  opacity: 0.8;
}

.icon:active {
  transform: scale(0.95);
}
```

## 📋 Icon Audit Checklist

### Quality Assurance
- [ ] Consistent stroke weight
- [ ] Proper optical alignment
- [ ] Clean anchor points
- [ ] Scalable at all sizes
- [ ] Semantic naming
- [ ] Proper categorization
- [ ] Accessibility labels
- [ ] Export optimization

### Implementation Ready
- [ ] Master components created
- [ ] All variants generated
- [ ] Documentation complete
- [ ] Usage examples provided
- [ ] Export files prepared
- [ ] Developer handoff ready

**Status**: 📋 Complete Icon System Specification | 🎨 Ready for Figma Implementation

**Next**: Create master icon components in Figma with complete variant system