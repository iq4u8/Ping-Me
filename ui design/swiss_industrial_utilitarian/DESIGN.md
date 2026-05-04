---
name: Swiss Industrial Utilitarian
colors:
  surface: '#17130f'
  surface-dim: '#17130f'
  surface-bright: '#3d3834'
  surface-container-lowest: '#110d0a'
  surface-container-low: '#1f1b17'
  surface-container: '#231f1b'
  surface-container-high: '#2e2925'
  surface-container-highest: '#393430'
  on-surface: '#eae1db'
  on-surface-variant: '#d4c4b7'
  inverse-surface: '#eae1db'
  inverse-on-surface: '#342f2c'
  outline: '#9c8e82'
  outline-variant: '#50453b'
  surface-tint: '#f0bd8b'
  primary: '#f2be8c'
  on-primary: '#482904'
  primary-container: '#d4a373'
  on-primary-container: '#5b3912'
  inverse-primary: '#7d562d'
  secondary: '#c8c6c5'
  on-secondary: '#303030'
  secondary-container: '#474746'
  on-secondary-container: '#b6b5b4'
  tertiary: '#a7ccea'
  on-tertiary: '#06344c'
  tertiary-container: '#8cb1ce'
  on-tertiary-container: '#1d445d'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdcbd'
  primary-fixed-dim: '#f0bd8b'
  on-primary-fixed: '#2c1600'
  on-primary-fixed-variant: '#623f18'
  secondary-fixed: '#e4e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1b1c1c'
  on-secondary-fixed-variant: '#474746'
  tertiary-fixed: '#c9e6ff'
  tertiary-fixed-dim: '#a6cbe9'
  on-tertiary-fixed: '#001e2f'
  on-tertiary-fixed-variant: '#244a63'
  background: '#17130f'
  on-background: '#eae1db'
  surface-variant: '#393430'
typography:
  h1:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  h2:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  h3:
    fontFamily: Space Grotesk
    fontSize: 18px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  body-m:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '500'
    lineHeight: '1.5'
    letterSpacing: '0'
  body-s:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '500'
    lineHeight: '1.4'
    letterSpacing: '0'
  data-mono:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '400'
    lineHeight: '1.0'
    letterSpacing: '0'
  label-caps:
    fontFamily: Space Grotesk
    fontSize: 11px
    fontWeight: '700'
    lineHeight: '1.0'
    letterSpacing: 0.05em
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  gutter: 16px
  container-padding: 24px
---

## Brand & Style

This design system is informed by the Swiss International Style and the functionalist ethos of mid-century industrial design. It prioritizes clarity, objective order, and terminal-like precision. The brand personality is disciplined and austere, removing all decorative elements to focus on the raw utility of communication.

The aesthetic draws heavily from the Dieter Rams "Less but better" philosophy. It utilizes a strict mathematical grid, high-contrast typography, and a "dark mode only" environment to evoke the feeling of a professional-grade instrument. There is no room for organic shapes or visual fluff; every pixel must serve a functional purpose.

## Colors

The palette is strictly functional, utilizing a high-contrast dark scheme to ensure legibility and reduce ocular strain. 

- **Foundation:** The background uses a warm black (#0A0A0A) to provide depth without the harshness of pure black. Surfaces are layered using a slightly lighter value (#141414).
- **Accents:** Ochre (#D4A373) is used sparingly for primary actions and critical focus states.
- **Feedback:** Sage and Sienna are utilized for status indicators, maintaining the muted, industrial temperature of the system. 
- **Rule:** Gradients and transparency are strictly prohibited. All colors must be solid hex codes.

## Typography

The typographic hierarchy is the primary driver of the visual interface. 

1. **Headers:** Space Grotesk is used for all structural headings. It must always be Bold and All Caps with a -0.02em tracking to mimic high-end industrial labeling.
2. **Body:** Inter (Medium weight) at 15px provides the core messaging experience, balanced for high readability in dense chat environments.
3. **Technical Data:** JetBrains Mono is reserved for timestamps, IDs, and metadata, reinforcing the "terminal" aesthetic of the system.

## Layout & Spacing

This design system employs a rigid 4px baseline grid. All spacing, margins, and padding must be multiples of 4px. 

- **Grid:** A 12-column fixed grid is used for desktop views, while mobile layouts rely on a single-column stack with 24px side margins.
- **Rhythm:** Elements are separated by 1px solid borders (#2A2A2A) rather than whitespace where possible, creating a "compartmentalized" look reminiscent of technical schematics.
- **Density:** Information density should be high. Use tight padding (8px or 12px) for list items to maximize data visibility.

## Elevation & Depth

Depth is conveyed through a strict hierarchy of 1px solid outlines and tonal shifts. Shadows and blurs are entirely omitted.

- **Level 0 (Background):** #0A0A0A.
- **Level 1 (Surfaces/Cards):** #141414 with a 1px solid #2A2A2A border.
- **Level 2 (Modals/Popovers):** #141414 with a 1px solid #D4A373 (Ochre) border to indicate active focus or interruption.

To show that an element is "above" another, use a 1px border. Interactive states are indicated by color fills (#2A2A2A) rather than physical elevation.

## Shapes

The shape language is predominantly rectilinear. A maximum corner radius of 4px is permitted for buttons and input fields to prevent them from feeling "sharp" to the touch, but all layout containers and larger surfaces must remain at 0px (sharp corners).

Icons must follow a custom 1.5px stroke weight. All icon terminals (ends of lines) must be sharp/butt-ended rather than rounded. Geometric shapes (circles, squares, triangles) are preferred over organic metaphors.

## Components

- **Buttons:** 
  - *Primary:* Solid #D4A373 (Ochre) fill with #0A0A0A text. Sharp 4px radius.
  - *Secondary:* Solid #2A2A2A fill with #E8E6E3 text. Sharp 4px radius.
  - *Tertiary:* Transparent fill, 1px solid #2A2A2A border.
- **Input Fields:** 1px solid #2A2A2A border, #141414 background. Text uses "Inter" 15px. Focus state triggers a 1px #D4A373 border.
- **Chips/Tags:** Sharp 0px corners, #2A2A2A background, "JetBrains Mono" 11px text in All Caps.
- **Message Bubbles:** No bubbles. Messages are displayed as "blocks" separated by 1px horizontal lines or simple indentation, consistent with an IRC or Terminal interface.
- **Lists:** Each item is separated by a 1px solid #2A2A2A horizontal rule. Hover states use a #141414 background fill.
- **Icons:** Custom 24x24px grid, 1.5px stroke, no rounded caps.