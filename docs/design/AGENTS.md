# docs/design/ Directory Navigation — AGENTS.md

> This directory holds design mockup files. Screenshots, exports, photos, and any other format are supported.

---

## Directory Structure

```
docs/design/
├── AGENTS.md           # This file
├── DESIGN_INTAKE.md    # Design interpretation spec (required reading for Claude)
├── assets/             # User-placed design images (original files)
└── extracted/          # Design specs extracted by Claude (auto-generated, do not edit manually)
    └── design-spec.md  # Present once generated
```

---

## User Guide

**Supported image formats:** PNG / JPG / WebP / GIF
**Recommended resolution:** 1x or 2x (higher = more accurate)

**Naming suggestions (not required):**
```
01-login.png
02-home.png
03-list.png
04-detail.png
```

**Not directly supported:**
- Figma source files (.fig) → please export as PNG from Figma
- Sketch files → please export as PNG
- Adobe XD → please export as PNG

**Figma export steps:**
1. Select a frame in Figma
2. Right-click → Export
3. Choose PNG format, resolution 2x
4. Save to `docs/design/assets/`

---

## Claude Workflow

1. Read `DESIGN_INTAKE.md` to understand the interpretation spec
2. Read all image files in `assets/`
3. Systematically analyze each image (see the `/process-design` Skill for details)
4. Save results to `extracted/design-spec.md`
5. Reference design tokens from `extracted/design-spec.md` during implementation

---

*Updated: 2026-03-25*
