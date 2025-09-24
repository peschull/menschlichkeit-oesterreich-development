# Figma Molecules - Navigation Komponenten

## 🧭 Navigation System Overview

Navigation Molecules sind komplexere UI-Elemente, die aus mehreren Atoms bestehen und zusammen funktionale Navigationseinheiten bilden.

## 📋 Navigation Komponenten

### 1. Primary Navigation Bar

#### Desktop Navigation
```figma-spec
Component Structure:
├── Container (Auto Layout - Horizontal)
├── Logo/Brand (Left)
├── Navigation Menu (Center)
│   ├── Nav Item 1 (Home)
│   ├── Nav Item 2 (Services)
│   ├── Nav Item 3 (About)
│   └── Nav Item 4 (Contact)
├── Actions (Right)
│   ├── Search Button
│   ├── User Menu Dropdown
│   └── Language Selector
└── Mobile Menu Toggle (Hidden on Desktop)

Specifications:
Height: 64px
Background: white
Border Bottom: 1px solid gray-200
Shadow: sm on scroll
Z-Index: sticky (1100)
```

#### Mobile Navigation
```figma-spec
Component Structure:
├── Header Bar
│   ├── Logo (Left)
│   ├── Page Title (Center)
│   └── Menu Toggle (Right)
└── Slide-out Menu
    ├── User Profile Section
    ├── Navigation Items (Stacked)
    ├── Secondary Actions
    └── Footer Information

Specifications:
Header Height: 56px
Menu Width: 280px
Animation: Slide from right
Overlay: rgba(0,0,0,0.5)
```

#### Navigation States
- **Default**: Standard appearance
- **Scrolled**: Shadow and background change
- **Search Active**: Search overlay
- **Menu Open**: Mobile menu visible
- **Loading**: Skeleton states

### 2. Breadcrumb Navigation

```figma-spec
Component Structure:
├── Container (Auto Layout - Horizontal)
├── Home Icon + "Home"
├── Separator (Chevron Right)
├── Parent Page Link
├── Separator (Chevron Right)
├── Current Page (Text Only)
└── Responsive Collapse (Mobile)

Specifications:
Height: 40px
Padding: 8px 0
Font Size: 14px
Separators: chevron-right icons
Max Items: 5 (collapse with ...)
```

#### Breadcrumb Variants
- **Standard**: Full path shown
- **Collapsed**: Show Home ... Current
- **Mobile**: Icons only + current
- **Minimal**: Parent > Current only

### 3. Tab Navigation

```figma-spec
Component Structure:
├── Tab Container (Auto Layout)
├── Tab Item 1 (Active)
├── Tab Item 2 (Default)
├── Tab Item 3 (Disabled)
├── More Button (Overflow)
└── Active Indicator (Underline)

Specifications:
Height: 48px
Padding: 12px 16px per tab
Border Bottom: 2px solid (active)
Min Width: 120px per tab
Max Tabs Visible: 6 (then overflow)
```

#### Tab Variants
- **Underlined**: Border bottom indicator
- **Filled**: Background color change
- **Boxed**: Card-like appearance
- **Vertical**: Sidebar navigation
- **Icon + Text**: With leading icons
- **Badge**: With notification counts

### 4. Pagination Navigation

```figma-spec
Component Structure:
├── Container (Auto Layout - Horizontal)
├── Previous Button (Icon + Text)
├── Page Numbers
│   ├── First Page (1)
│   ├── Ellipsis (...) 
│   ├── Current Page (5)
│   ├── Ellipsis (...)
│   └── Last Page (10)
├── Next Button (Text + Icon)
└── Results Info ("Showing X of Y")

Specifications:
Height: 40px
Button Size: 32x32px
Spacing: 4px between items
Max Visible Pages: 7
```

#### Pagination Variants
- **Numbered**: Page numbers visible
- **Simple**: Previous/Next only
- **Compact**: Minimal spacing
- **Load More**: Button instead of pages
- **Infinite**: Auto-loading scroll

### 5. Step Navigation (Wizard)

```figma-spec
Component Structure:
├── Steps Container
├── Step 1 (Completed)
│   ├── Circle with Checkmark
│   ├── Step Label
│   └── Connection Line
├── Step 2 (Current)
│   ├── Circle with Number
│   ├── Step Label (Bold)
│   └── Connection Line
├── Step 3 (Upcoming)
│   ├── Circle (Outline)
│   ├── Step Label (Gray)
│   └── Connection Line
└── Action Buttons
    ├── Back Button
    └── Next/Continue Button

Specifications:
Circle Size: 32px
Connection Width: 2px
Min Step Width: 120px
Mobile: Horizontal scroll
```

#### Step States
- **Completed**: Green circle + checkmark
- **Current**: Blue circle + number
- **Upcoming**: Gray outline + number
- **Error**: Red circle + warning icon
- **Disabled**: Muted appearance

### 6. Sidebar Navigation

```figma-spec
Component Structure:
├── Sidebar Container
├── Header Section
│   ├── Logo/Title
│   └── Collapse Toggle
├── Main Navigation
│   ├── Primary Items (Level 1)
│   ├── Sub-items (Level 2)
│   └── Expandable Groups
├── Secondary Navigation
│   ├── Settings
│   ├── Help
│   └── Logout
└── Footer Section
    ├── User Profile
    └── Status Indicator

Specifications:
Width: 240px (expanded), 60px (collapsed)
Animation: 200ms ease
Hierarchy: Max 3 levels deep
Icons: 20px for all items
```

#### Sidebar Variants
- **Fixed**: Always visible
- **Collapsible**: Expand/collapse toggle
- **Overlay**: Mobile slide-over
- **Mini**: Icons only when collapsed
- **Tree**: Hierarchical structure

### 7. Footer Navigation

```figma-spec
Component Structure:
├── Footer Container
├── Column 1: Company
│   ├── Logo
│   ├── Description
│   └── Social Links
├── Column 2: Product
│   ├── Features
│   ├── Pricing
│   └── Updates
├── Column 3: Support
│   ├── Help Center
│   ├── Contact
│   └── Status
├── Column 4: Legal
│   ├── Privacy
│   ├── Terms
│   └── Cookies
└── Bottom Bar
    ├── Copyright
    ├── Language
    └── Additional Links

Specifications:
Desktop: 4-column grid
Mobile: Single column stack
Padding: 48px vertical
Background: gray-50 or dark theme
```

## 🎨 Navigation Design Patterns

### Visual Hierarchy
1. **Primary Navigation**: Most prominent, top level
2. **Secondary Navigation**: Supporting, contextual
3. **Utility Navigation**: Settings, user actions
4. **Footer Navigation**: Sitemap, legal links

### Interactive States
- **Default**: Resting state
- **Hover**: Visual feedback on desktop
- **Active**: Currently selected item
- **Focus**: Keyboard navigation highlight
- **Disabled**: Unavailable options
- **Loading**: Progress indication

### Responsive Behavior
- **Desktop**: Full horizontal layout
- **Tablet**: Condensed with priorities
- **Mobile**: Hamburger menu + critical items
- **Touch**: Larger tap targets (44px min)

## ♿ Accessibility Guidelines

### Navigation Requirements
- **Semantic HTML**: `<nav>` elements
- **ARIA Labels**: Clear descriptions
- **Keyboard Navigation**: Tab/Enter/Arrow keys
- **Skip Links**: "Skip to content"
- **Focus Management**: Visible indicators
- **Screen Reader**: Proper announcements

### Implementation Example
```html
<nav aria-label="Main navigation" role="navigation">
  <ul>
    <li><a href="/" aria-current="page">Home</a></li>
    <li><a href="/about">About</a></li>
    <li>
      <button aria-expanded="false" aria-haspopup="true">
        Services
      </button>
      <ul aria-hidden="true">
        <li><a href="/service-1">Service 1</a></li>
      </ul>
    </li>
  </ul>
</nav>
```

## 📱 Mobile Navigation Patterns

### 1. Bottom Tab Navigation
- Fixed at screen bottom
- 3-5 primary sections
- Always visible
- Icon + label design

### 2. Hamburger Menu
- Top-left menu icon
- Slide-out full menu
- Overlay background
- Close button/gesture

### 3. Tab Bar (iOS Style)
- Clean minimal design
- Badge notifications
- Safe area compliance
- Haptic feedback

### 4. Navigation Drawer (Android)
- Material Design patterns
- Swipe from edge
- Account selection
- Section dividers

## 🔄 Interactive Behaviors

### Menu Animations
- **Slide**: Horizontal movement
- **Fade**: Opacity transitions
- **Scale**: Size transformations
- **Bounce**: Playful entrance
- **Stagger**: Sequential appearance

### State Transitions
```css
.nav-item {
  transition: all 200ms ease-out;
}

.nav-item:hover {
  background-color: primary-50;
  transform: translateY(-1px);
}

.nav-item.active {
  color: primary-600;
  font-weight: 600;
}
```

## 📊 Navigation Analytics

### Tracking Points
- Menu open/close rates
- Click-through rates per item
- Search usage in navigation
- Mobile vs desktop behavior
- Drop-off points in wizards

### Performance Metrics
- Navigation load time
- Menu animation performance
- Touch target effectiveness
- Accessibility compliance score

## 🎯 Component Variants Matrix

| Component | Variants | States | Responsive | Accessibility | Total |
|-----------|----------|--------|------------|---------------|-------|
| Nav Bar | 4 layouts | 5 states | 3 breakpoints | Full support | **60 variants** |
| Breadcrumbs | 4 styles | 3 states | 2 modes | Full support | **24 variants** |
| Tabs | 6 styles | 4 states | 2 orientations | Full support | **48 variants** |
| Pagination | 5 styles | 3 states | 2 modes | Full support | **30 variants** |
| Steps | 3 styles | 4 states | 2 orientations | Full support | **24 variants** |
| Sidebar | 5 styles | 3 states | 2 modes | Full support | **30 variants** |
| Footer | 3 layouts | 2 themes | 2 responsive | Full support | **12 variants** |

**Total Navigation Molecules**: **228 variants**

## 🔧 Implementation Checklist

### Design Phase
- [ ] All navigation patterns defined
- [ ] Responsive breakpoints specified  
- [ ] Animation timings documented
- [ ] Accessibility requirements met
- [ ] Color contrast verified
- [ ] Touch targets sized properly

### Development Phase
- [ ] Semantic HTML structure
- [ ] ARIA attributes implemented
- [ ] Keyboard navigation working
- [ ] Focus management correct
- [ ] Screen reader tested
- [ ] Performance optimized

### Testing Phase
- [ ] Cross-browser compatibility
- [ ] Mobile device testing
- [ ] Accessibility audit passed
- [ ] User testing completed
- [ ] Analytics tracking implemented
- [ ] Documentation updated

**Status**: 📋 Navigation Molecules Complete | 🔄 Ready for Figma Implementation

**Next**: Create Card and Form Molecules