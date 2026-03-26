# 📁 Project structure change log

## When
2026-03-26

## 🎯 Goal

Unify the layout: move from a mixed `frontend/backend` + `apps/services` setup to a single **multi-project container** model.

## 📋 What changed

### ❌ Removed directories
- `frontend/` — legacy monolith-style frontend template
- `backend/` — legacy monolith-style backend template

### ✅ Kept directories
- `apps/` — frontend app container (canonical)
- `services/` — backend service container (canonical)

### 📝 New docs
- `apps/AGENTS.md` — multi-frontend layout
- `services/AGENTS.md` — multi-service layout
- `.claude/STRUCTURE_MIGRATION.md` — this file

### 🔧 Updated files
- `README.md` — tree and Q&A
- `.claude/settings.json` — permission tweaks
- `.claude/progress-cli.sh` — progress CLI documentation

## 🤔 Why change?

### Old problem: conflicting layouts

| Issue | Cause | Impact |
|------|-------|--------|
| Two naming schemes | Both `frontend/` and `apps/` existed | Confusing for newcomers; harder shell maintenance |
| Registry mismatch | `features.json` only tracks `apps/services` | Code location ≠ registered location; tracking breaks |
| Duplicate docs | `frontend/` and `apps/` each had AGENTS.md | Drift and higher maintenance cost |
| Poor scaling | `backend/` assumed one service | Adding a second backend meant rework |

### New model: one standard, scalable

✅ **Single standard** — all projects live under `apps/` or `services/`  
✅ **Aligned with features.json** — generated code sits where it is registered  
✅ **Multi-project by default** — monolith to distributed without restructuring  
✅ **Simpler docs** — one convention covers every case  

## 📚 Usage

### Monolith-style (1 frontend + 1 backend)

```
apps/web/
├── package.json
├── src/
└── AGENTS.md

services/api/
├── package.json
├── src/
└── AGENTS.md
```

**Benefit:** Clear layout; easy to grow later.

### Multi-app (marketing + admin + mobile)

```
apps/
├── web/          # Public site
├── admin/        # Admin console
├── mobile/       # React Native
└── AGENTS.md

services/
├── api/          # Node.js API
├── worker/       # Python worker
├── scheduler/    # Node cron / scheduler
└── AGENTS.md
```

**Benefit:** One template for any scale; no special cases.

## 🚀 Migration

### If you already use this template

- File locations stay the same if you followed the convention
- `features.json` unchanged; tooling expects the new layout
- No manual code migration needed

### If you still have code under `frontend/` or `backend/`

```bash
# Manual move
mv frontend/src/* apps/web/src/
mv backend/src/* services/api/src/
```

### For new projects

```bash
# 1. Remove legacy dirs if present
rm -rf frontend backend

# 2. Initialize session
/session-start

# 3. Parse requirements (creates projects)
/process-requirements

# Done — projects live under apps/ and services/
```

## 📊 Before / after

### Old (mixed)
```
.
├── frontend/
│   └── src/
├── backend/
│   └── src/
├── apps/
│   └── (empty — docs said “frontend container” but unused)
└── services/
    └── (empty — docs said “backend container” but unused)
```

🔴 **Problem:** `features.json` pointed at `apps/services`, but code lived in `frontend/backend`.

### New (canonical)
```
.
├── apps/
│   ├── web/
│   │   └── src/
│   └── AGENTS.md
└── services/
    ├── api/
    │   └── src/
    └── AGENTS.md
```

🟢 **Win:** Consistent, clear, extensible.

## 🔍 Quick verification

```bash
# Project registry
jq '.projects' features.json

# Frontend apps
ls -la apps/

# Backend services
ls -la services/

# Expected
# apps: web/, admin/, …
# services: api/, worker/, …
```

## 📖 Related docs

- [README.md](../../README.md) — project overview
- [AGENTS.md](../../AGENTS.md) — navigation
- [apps/AGENTS.md](../../apps/AGENTS.md) — frontend layout
- [services/AGENTS.md](../../services/AGENTS.md) — backend layout
- [features.json](../../features.json) — registry and status

---

**Version:** 1.0  
**Date:** 2026-03-26  
**Author:** Claude Code  

Maintenance tips:
- ✅ After `/process-requirements`, review `features.json.projects`
- ✅ Do not add new code under `frontend/` or `backend/`
- ✅ Run `./.claude/progress-cli.sh stats` periodically to monitor health
