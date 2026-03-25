# docs/prd/ Directory Navigation — AGENTS.md

> This directory holds product requirements documents. Any format is supported; Claude Code will organize them automatically.

---

## Directory Contents

| File | Description |
|------|------|
| `REQUIREMENTS_TEMPLATE.md` | Recommended format template (not required) |
| `user-requirements.md` | Actual user requirements (any name is fine) |

---

## User Instructions

**Method 1: Use the template (recommended)**
Copy `REQUIREMENTS_TEMPLATE.md` and fill it in according to the template.

**Method 2: Drop files directly**
Place requirements documents directly into this directory. They can be:
- Product requirements documents (PRDs)
- Feature lists, user stories
- Casual idea notes
- Informal descriptions in any language

**It doesn't matter how messy the format is — Claude Code will handle it.**

**Method 3: Paste in conversation**
Paste requirements directly into the Claude Code conversation and run `/process-requirements`.

---

## Claude Workflow

1. Read all non-template files in this directory
2. Run the `/process-requirements` Skill to parse them
3. Write results to `features.json`
4. Output a parsing report and wait for user confirmation

---

*Updated: 2026-03-25*
