# Skill: process-design — Design Parsing

Parse messy design mockups provided by the user (screenshots/images/Figma exports) into a structured design spec.

## Prerequisites

The user has provided design files in one of the following locations:
- `docs/design/assets/` — image files
- Or images sent directly in the conversation

## Step 0: Read the Design Intake Guidelines

Must read `docs/design/DESIGN_INTAKE.md` first to understand the A/B/C/D four-tier processing rules.

## Step 1: Locate Design Files

```bash
ls docs/design/assets/
```

List all image files, sort by filename, and infer page names.

**If the user provided a Figma link:**
```
Claude Code cannot access Figma links directly.
Please select a frame in Figma → right-click → Export → PNG (2x resolution)
Place the exported images in the docs/design/assets/ directory, then re-run /process-design
```

## Step 2: Assess the Quality Level of Each Image

- **Class A**: Precise Figma export, text is sharp, colors are accurate
- **Class B**: Regular screenshot, generally clear, minor detail blur
- **Class C**: Photo-taken, low resolution, heavily compressed
- **Class D**: No image, text description only

## Step 3: Analyze Each Design Image Individually

For each image, analyze using the following framework:

### Page Level
```
Page Name: <inferred page name>
Page Route: /<path>
Page Purpose: <functional purpose>
Quality Level: A / B / C
```

### Color Analysis (follow the corresponding tier rules in DESIGN_INTAKE.md)
```
Primary: #xxxxxx
Secondary: #xxxxxx
Background: #xxxxxx
Card Background: #xxxxxx
Text Primary: #xxxxxx
Text Secondary: #xxxxxx
Border: #xxxxxx
Success: #xxxxxx
Warning: #xxxxxx
Error: #xxxxxx
```

### Typography Analysis
```
H1 Heading: <size>px / <weight>
H2 Heading: <size>px / <weight>
Body Text: <size>px / Regular
Supporting Text: <size>px
Font Family: <if identifiable, otherwise write "System Default">
```

### Spacing Analysis
```
Page Margin: <value>px
Component Gap: <value>px
Padding: <common value>px
Border Radius: <common value>px
```

### Component Identification

Check whether each of the following components exists and record its style:
- [ ] Top Navigation Bar (Header/Navbar)
- [ ] Side Menu (Sidebar)
- [ ] Breadcrumb
- [ ] Primary Button / Secondary Button
- [ ] Input Field
- [ ] Dropdown Select
- [ ] Data Table
- [ ] Card
- [ ] Tag / Badge
- [ ] Modal Dialog
- [ ] Loading State
- [ ] Empty State
- [ ] Pagination
- [ ] Form
- [ ] Chart

## Step 4: Generate Unified Design Spec

After analyzing all images, merge into unified design tokens and save to `docs/design/extracted/design-spec.md`:

```markdown
# Design Spec
Generated: <date>
Source Images: <file list>
Overall Quality: <A/B/C>

## Color Tokens
--color-primary: #xxxxxx
--color-primary-hover: #xxxxxx
--color-secondary: #xxxxxx
--color-background: #xxxxxx
--color-surface: #xxxxxx
--color-text-primary: #xxxxxx
--color-text-secondary: #xxxxxx
--color-border: #xxxxxx
--color-success: #52C41A
--color-warning: #FAAD14
--color-error: #FF4D4F

## Typography System
--font-size-xs: 12px
--font-size-sm: 14px
--font-size-md: 16px
--font-size-lg: 20px
--font-size-xl: 24px
--font-size-2xl: 32px
--font-weight-regular: 400
--font-weight-medium: 500
--font-weight-bold: 700

## Spacing System
--spacing-xs: 4px
--spacing-sm: 8px
--spacing-md: 16px
--spacing-lg: 24px
--spacing-xl: 32px
--spacing-2xl: 48px

## Border Radius
--radius-sm: 4px
--radius-md: 8px
--radius-lg: 12px
--radius-full: 9999px

## Shadows
--shadow-sm: 0 1px 2px rgba(0,0,0,0.05)
--shadow-md: 0 4px 6px rgba(0,0,0,0.07)
--shadow-lg: 0 10px 15px rgba(0,0,0,0.1)

## Page List
<route, layout pattern, and main component list for each page>

## Component Spec
<detailed spec for each identified component>

## Inferences and Assumptions
<all places where inferences or assumptions were made>
```

## Step 5: Update features.json

Check features.json and add corresponding frontend features for each page identified in the design (if not already present).

Update `design_assets.processed` to `true` and fill in the `files` list.

## Step 6: Output Parsing Report

```
=== Design Parsing Complete ===

[Analyzed N design images]
- <image 1>: <page name> — Quality: <level>
- <image 2>: <page name> — Quality: <level>

[Extracted Page List]
1. <page name> — <route> — <main functionality>
2. ...

[Design Spec Saved To]
docs/design/extracted/design-spec.md

[New/Confirmed Frontend Features]
- FEAT-xxx: <page feature>
- ...

[Issues / Missing Elements in Design Mockups]
- <issue>: <how it was handled>

[Inferences and Assumptions (please confirm)]
- <color inference>: used <color value>, reason: <image quality level>
- <layout pattern inference>: ...

====================
```

## Special Cases

**Very Poor Quality Images:** Do not say "unable to analyze". Instead, describe all visible information, fill in uncertain parts with Ant Design standards, and mark them as "inferred value".

**Text Description Only (No Images):** Choose a design system based on the application type (admin panel → Ant Design, consumer product → Material Design), and generate tokens conforming to that design system.
