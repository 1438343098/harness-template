# Design Interpretation Spec — DESIGN_INTAKE.md

> Claude Code must read this file when interpreting design mockups. Defines how to handle design inputs of various quality levels.
> **Core principle: never say "unable to analyze" — always infer and annotate uncertainty.**

---

## Four-Level Design Input Processing Rules

### Class A — High quality (precise Figma export, 2x resolution)

**Characteristics:** Text clearly legible, colors accurate, spacing evident
**Handling:** Precisely extract all design tokens, use directly for implementation

---

### Class B — Medium quality (1x screenshot, compressed, ordinary screen capture)

**Characteristics:** Generally clear, slightly blurry details, text mostly legible
**Handling:**
- Colors: inferred value, annotated as "possible ±10% error"
- Spacing: estimated value, annotated as "estimated"
- Font size: estimated value, corrected against standard scale ratios

---

### Class C — Low quality (photo taken, highly compressed, hand-drawn sketch)

**Characteristics:** Low resolution, photo noise, hand-drawn or whiteboard photos
**Handling:**
- Colors: identify tone only (warm/cool/neutral), substitute with color palette below
- Layout: identify overall layout pattern only (top bar + content, sidebar + content, etc.)
- Components: identify component type only, do not extract specific styles
- Note: "Inferred implementation based on low-quality design; user review recommended"

---

### Class D — No design (text description only)

**Characteristics:** User describes what they want with no visual reference
**Handling:**
- Admin dashboard → use Ant Design spec
- User-facing web app → use Material Design spec
- Mobile app → use platform native spec (iOS/Android)
- Note: "Design spec AI-generated, based on <reference design system>"

---

## Color Inference Palette (for Class B/C)

### Blue tones (tech / business / SaaS)
```
Primary:    #1677FF  (Ant Design Blue)
Dark:       #0958D9
Light:      #69B1FF
Background: #E6F4FF
```

### Green tones (finance / health / nature)
```
Primary:    #52C41A
Dark:       #389E0D
Light:      #95DE64
Background: #F6FFED
```

### Purple tones (creative / premium / AI)
```
Primary:    #722ED1
Dark:       #531DAB
Light:      #B37FEB
Background: #F9F0FF
```

### Orange tones (e-commerce / energy / consumer)
```
Primary:    #FA8C16
Dark:       #D46B08
Light:      #FFD591
Background: #FFF7E6
```

### Neutral colors (universal, used in all types)
```
White background:   #FFFFFF
Light gray bg:      #F5F5F5 / #FAFAFA
Card background:    #FFFFFF
Primary text:       #1C1C1E (deep black, modern)
Secondary text:     #8C8C8C
Disabled text:      #BFBFBF
Border:             #D9D9D9
Divider:            #F0F0F0
Success:            #52C41A
Warning:            #FAAD14
Error:              #FF4D4F
```

---

## Layout Pattern Detection

| Pattern name | Characteristics | Common use |
|----------|------|----------|
| Top bar + content | Horizontal navigation at top, full-width content | Portals, marketing pages, official sites |
| Sidebar + content | Vertical navigation on the left | Admin dashboards, tools |
| Sidebar + top bar + content | Dual navigation (side menu + top toolbar) | Complex admin systems |
| Full-screen single column | No obvious navigation, full-screen content | Login page, onboarding, 404 |
| Card grid | Content arranged in grid cards | Product listings, content aggregation, dashboards |
| Master-detail layout | Left list + right detail | Email clients, CRM, file managers |
| Full-screen form | Form is the main content | Registration, settings, fill-in flows |

---

## Component Detection Ambiguity Handling

Default inference rules when a component is difficult to identify:

| Ambiguous case | Inferred as |
|----------|--------|
| Rectangular area, purpose unclear | Card |
| Dark horizontal bar at the top | Header |
| Dark vertical bar on the left | Sidebar |
| Small rectangle with border | Input |
| Small filled rectangle without border (with text inside) | Button |
| Repeated rows with dividing lines | Table or List |
| Rounded rectangle containing short text | Tag / Badge |
| Semi-transparent overlay + centered content | Modal |
| Progress-bar-like element | Progress or Steps |

---

## Design Spec Standard Ratios

Ensure extracted values conform to standard ratios; auto-correct when there is deviation:

**Font sizes (8pt system):**
`12 / 14 / 16 / 20 / 24 / 32 / 40 / 48`

**Spacing (4px base grid):**
`4 / 8 / 12 / 16 / 20 / 24 / 32 / 40 / 48 / 64`

**Corner radii (common values):**
`0 / 2 / 4 / 6 / 8 / 12 / 16 / 9999 (circle)`

---

## Extraction Result Self-check Checklist

Verify after extraction is complete:

- [ ] Every page has a corresponding component tree
- [ ] Number of color tokens is reasonable (8–15, not too fragmented)
- [ ] Spacing values conform to the 4px base grid
- [ ] Font sizes conform to standard ratios
- [ ] All inferred values are annotated as "inferred" or "estimated"
- [ ] States which quality level was used for processing

---

*This file is referenced by Claude Code when executing the `/process-design` Skill*
*Updated: 2026-03-25*
