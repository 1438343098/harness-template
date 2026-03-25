# Project Navigation — AGENTS.md

> This file helps Claude Code quickly understand the project structure. Each subdirectory's AGENTS.md provides more detailed information.

---

## Project Type

Full-stack web application | Decoupled frontend and backend | Harness Engineering paradigm | Built exclusively for Claude Code

---

## Directory Overview

| Directory / File | Responsibility | When to read |
|------------------|---------------|--------------|
| `CLAUDE.md` | Master instructions, all protocols, quality gates | **At the start of every session (required)** |
| `features.json` | Feature state machine + project registry | At the start of every session |
| `claude-progress.txt` | Session log (append-only) | At the start of every session |
| `user-preferences.json` | User preferences, auto-evolving defaults | At the start of every session |
| `docs/prd/` | Requirements documents (including iteration change docs) | When parsing requirements or iterations |
| `docs/design/` | Design files and extracted design specs | When interpreting designs |
| `apps/` | All frontend applications (multiple, different tech stacks) | When implementing frontend features |
| `services/` | All backend services (multiple, different languages) | When implementing backend features |
| `.claude/commands/` | Available skills (slash commands) | When executing specific workflows |

---

## Current Project Status

Read `features.json` for real-time status. Quick inspection commands:

```bash
# View feature overview (status + title)
cat features.json

# View recent progress
tail -50 claude-progress.txt
```

---

## Available Skills

| Command | Purpose | When to use |
|---------|---------|-------------|
| `/session-start` | Session initialization — load preferences, state, and projects; form a plan | At the start of every session |
| `/session-end` | Session wrap-up — update state, trigger preference evolution | At the end of every session |
| `/process-requirements` | Parse initial PRD, register project, populate features.json | When a new requirements doc is available |
| `/process-iteration` | Parse iteration change requirements, generate change_requests | When requirements change or product iterates |
| `/process-design` | Parse design files, extract design specs | When new design images are available |
| `/implement-feature [id]` | Implement a single feature or change (sequential mode) | When features have dependencies or share the same app |
| `/delegate-subagent [N]` | Dispatch N independent features to sub-agents in parallel | When 2+ mutually independent pending features exist |
| `/learn-preferences` | Manually inspect preference evolution state | When you want to review or adjust defaults |

---

## Progressive Disclosure

When you need to understand a specific area, read the corresponding AGENTS.md:

- `docs/AGENTS.md` — docs directory details
- `docs/prd/AGENTS.md` — requirements document directory details
- `docs/design/AGENTS.md` — design files directory details
- `apps/AGENTS.md` — frontend applications directory (all sub-projects)
- `apps/<name>/AGENTS.md` — tech stack and conventions for a specific frontend project
- `services/AGENTS.md` — backend services directory (all sub-services)
- `services/<name>/AGENTS.md` — language, framework, and conventions for a specific backend service

---

## Harness Core Principles (Six)

1. **Repository as source of truth** — `features.json` and `claude-progress.txt` are the single authoritative state sources
2. **Navigation over documentation** — every directory has an AGENTS.md (~100 lines); no lengthy documents
3. **Mechanical enforcement** — quality gates trigger automatically, no reliance on human memory
4. **Agent-friendly architecture** — directory and code structure optimized for Claude Code
5. **Entropy management** — periodically clean up feature state to prevent state rot
6. **Throughput-driven** — every feature scoped to 1–3 hours, continuous delivery

---

*Version: v1.0 | Updated: 2026-03-25 | Template built exclusively for Claude Code*
