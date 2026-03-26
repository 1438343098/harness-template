# 📋 Layered progress log system

## Overview

Progress logging moved from a single `claude-progress.txt` file to a **layered directory layout** to avoid huge files and slow searches.

## 🏗️ Layout

```
.claude/
├── progress/                    # Progress root
│   ├── index.json              # Metadata index (fast lookup)
│   ├── update-index.sh         # Index refresh script
│   ├── sessions/               # Session logs (by date)
│   │   ├── 2026-03-25.session.md
│   │   └── 2026-03-26.session.md
│   ├── features/               # Feature logs (by FEAT-ID)
│   │   ├── FEAT-001.log
│   │   ├── FEAT-002.log
│   │   └── FEAT-003.log
│   └── blocks/                 # Blockers (by BLOCK-ID)
│       ├── BLOCK-001.md
│       └── BLOCK-002.md
├── progress-cli.sh             # CLI helper
├── .gitignore                  # Git rules for logs
└── commands/
```

## ✨ Benefits

| Aspect | Single file | Layered |
|--------|-------------|---------|
| Size | ❌ Grows without bound | ✅ Grows by file |
| Query speed | ❌ Linear scan | ✅ Index-backed |
| Concurrency | ❌ Lock contention | ✅ Separate files |
| Feature lookup | ❌ Full-text scan | ✅ Direct paths |
| Diffs | ❌ Huge | ✅ Granular |

## 🔍 How to query

### Option 1: CLI (recommended)

```bash
# Latest progress
./.claude/progress-cli.sh latest

# Specific feature
./.claude/progress-cli.sh search FEAT-001

# Fuzzy search
./.claude/progress-cli.sh search "database connection"

# List features
./.claude/progress-cli.sh features

# Blockers
./.claude/progress-cli.sh blocks

# Stats
./.claude/progress-cli.sh stats

# Help
./.claude/progress-cli.sh help
```

### Option 2: Read files directly

```bash
# Latest session
cat .claude/progress/sessions/2026-03-25.session.md

# Feature log
cat .claude/progress/features/FEAT-001.log

# Blocker files
ls -la .claude/progress/blocks/

# Full index
jq '.' .claude/progress/index.json
```

### Option 3: jq on the index

```bash
jq '.statistics' .claude/progress/index.json
jq '.features[]' .claude/progress/index.json
jq '.latest_session' .claude/progress/index.json
```

## 📝 File formats

### sessions/YYYY-MM-DD.session.md

```markdown
# Session: 2026-03-25
**Date**: 2026-03-25
**Status**: Project bootstrap
**Summary**: Template ready; waiting for requirements and design assets

## Checklist
- [ ] Task 1
- [ ] Task 2

## Related features
- FEAT-001: User authentication
- FEAT-002: Database migration

## Blockers
- BLOCK-001: Design not received

---
**Author**: Claude Code
**Updated**: 2026-03-25T14:30:00Z
```

### features/FEAT-XXX.log

```
[FEAT-001] START: Authentication module
Time: 2026-03-25T10:00:00Z

[FEAT-001] FILE: created src/auth/login.ts
Time: 2026-03-25T10:15:00Z

[FEAT-001] FILE: created src/auth/register.ts
Time: 2026-03-25T10:30:00Z

[FEAT-001] DONE: Authentication module complete
Time: 2026-03-25T11:00:00Z
Status: ✅ done
```

### blocks/BLOCK-XXX.md

```markdown
# Block: BLOCK-001
**Title**: Design delivery delayed
**Severity**: 🔴 High
**Opened**: 2026-03-25T14:00:00Z
**ETA**: 2026-03-26

## Description
Design did not deliver the homepage mock; frontend cannot start.

## Impact
- FEAT-002: Homepage work blocked

## Mitigation
- [ ] Follow up with design
- [ ] Use temporary wireframes
- [ ] Start backend work in parallel

---
**Author**: Claude Code
**Status**: 🔴 Open
```

### index.json

```json
{
  "schema_version": "1.0",
  "created_at": "2026-03-25T00:00:00Z",
  "updated_at": "2026-03-26T14:30:00Z",
  "project": "harness-template",
  "statistics": {
    "total_sessions": 2,
    "total_features": 5,
    "total_blocks": 1,
    "total_entries": 8
  },
  "sessions": [
    {
      "date": "2026-03-25",
      "status": "completed",
      "file": "sessions/2026-03-25.session.md"
    },
    {
      "date": "2026-03-26",
      "status": "active",
      "file": "sessions/2026-03-26.session.md"
    }
  ],
  "features": ["FEAT-001", "FEAT-002", "FEAT-003", "FEAT-004", "FEAT-005"],
  "blocks": ["BLOCK-001"],
  "latest_session": "2026-03-26"
}
```

## 🔄 Workflow

### Automated (Claude Code)

1. **Session start**
   ```
   Create sessions/YYYY-MM-DD.session.md
   Update index.json latest_session
   ```

2. **Feature logging**
   ```
   Create features/FEAT-XXX.log
   Append entries
   Update index.json.features and .statistics.total_features
   ```

3. **Blockers**
   ```
   Create blocks/BLOCK-XXX.md
   Update index.json.blocks and .statistics.total_blocks
   ```

### Manual

1. **Refresh index**
   ```bash
   ./.claude/progress/update-index.sh
   ```

2. **Query**
   ```bash
   ./.claude/progress-cli.sh <command>
   ```

3. **Inspect**
   ```bash
   cat .claude/progress/sessions/2026-03-25.session.md
   ```

## 📊 Index updates

`index.json` should be refreshed after:
- ✅ New session file
- ✅ New feature log
- ✅ New blocker
- ✅ Session status change

**Manual refresh:**
```bash
./.claude/progress/update-index.sh
```

## 🗑️ Archiving

### Automatic (suggested policy)

- **Session file** > 10MB → split into weekly archives
- **Yearly logs** → `archive/2025.tar.gz`
- **Done features** (after 6 months) → `archive/features/`

### Manual

```bash
tar -czf .claude/progress/archive/2025.tar.gz \
  .claude/progress/sessions/2025-*.session.md
rm .claude/progress/sessions/2025-*.session.md
```

## ⚙️ Configuration

### .claude/.gitignore

```
# Temp files
progress/**/*.tmp
progress/**/*.swp

# Backups
progress/backup/

# Large archives
progress/archive/*.tar.gz
```

### .claude/progress/update-index.sh

Scans folders and refreshes `index.json` statistics:

```bash
PROGRESS_DIR=".claude/progress"
sessions=$(ls -1 "$PROGRESS_DIR/sessions/" | wc -l)
features=$(ls -1 "$PROGRESS_DIR/features/" | wc -l)
blocks=$(ls -1 "$PROGRESS_DIR/blocks/" | wc -l)
```

## 📈 Growth expectations

| Horizon | Sessions | Features | Files | Size |
|---------|----------|----------|-------|------|
| 1 week | 7 | 10–20 | 37–47 | ~500 KB |
| 1 month | 30 | 40–80 | 70–110 | ~3 MB |
| 1 year | 365 | 500+ | 900+ | ~50 MB |

✅ **Much better** than a single 200+ MB log file.

## 🚀 Best practices

1. **Check often**
   ```bash
   ./.claude/progress-cli.sh latest   # start of session
   ```

2. **Search on demand**
   ```bash
   ./.claude/progress-cli.sh search FEAT-001
   ```

3. **Weekly stats**
   ```bash
   ./.claude/progress-cli.sh stats
   ```

4. **Month-end housekeeping**
   ```bash
   ./.claude/progress/update-index.sh
   ```

## 🔗 Related files

- [progress.txt](../../progress.txt) — short summary
- [progress-cli.sh](./progress-cli.sh) — CLI
- [index.json](./progress/index.json) — index

---

**Version:** 1.0  
**Created:** 2026-03-25  
**Maintainer:** Claude Code
