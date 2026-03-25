# Skill: learn-preferences — Self-Evolving Preference Learning

Analyze the user's historical decision patterns and automatically promote high-frequency decisions to defaults, reducing repeated confirmations.

**Trigger:**
- `/learn-preferences` — manual trigger
- Auto-trigger: silently executed on every `/session-end`

---

## Step 1: Read Decision Log

```bash
cat user-preferences.json
```

Extract all records from `decision_log`, grouped and counted by `decision_key`.

---

## Step 2: Identify High-Frequency Patterns

For each `decision_key`, count:
- How many times this decision has been made (`count`)
- What value was chosen in the last 5 instances (are they consistent?)
- Whether it is already a default (`confirmed: true`)

**Evolution Rules:**

| Condition | Action |
|-----------|--------|
| count >= threshold (default 3) and values are fully consistent | Auto-promote to default, `confirmed: true` |
| count >= threshold but values are inconsistent | Report conflict, ask user which to choose |
| count < threshold | Continue observing, no change |
| Already a default but last 2 choices were a different value | Demote, restart observation |

---

## Step 3: Execute Evolution

For preferences meeting the criteria, update `user-preferences.json`:

```json
{
  "preferences": {
    "<decision_key>": {
      "value": "<high-frequency chosen value>",
      "count": <count>,
      "confirmed": true,
      "source": "auto-learned",
      "evolved_at": "<ISO 8601>",
      "description": "<meaning of this preference>"
    }
  }
}
```

---

## Step 4: Update CLAUDE.md (for significant preference promotions)

When the following types of preferences are auto-promoted, also update the default behavior description in `CLAUDE.md`:

- Tech stack choices (`tech_stack.*`)
- Code style (`code_style.*`)
- Architecture decisions (`architecture.*`)
- Naming conventions (`naming.*`)

**Update location:** Append to the `## Auto-Learned User Preferences` section at the bottom of `CLAUDE.md`.

---

## Step 5: Output Evolution Report

**Only output when `/learn-preferences` is triggered manually; when auto-triggered, execute silently and only notify the user if there are new evolutions.**

```
=== Preference Evolution Report ===

[Auto-promoted to defaults (no further confirmation needed)]
✅ tech_stack.frontend = React + TypeScript (chosen 4 times)
✅ css_framework = Tailwind CSS (chosen 3 times)
✅ api_style = RESTful (chosen 5 times)

[Under observation (threshold not yet reached)]
📊 database = PostgreSQL (chosen 2/3 times)
📊 test_framework = Vitest (chosen 1/3 times)

[Conflicts detected (your confirmation needed)]
⚠️ auth_method: chosen JWT 2 times, Session 1 time
   → Please choose a default: [1] JWT  [2] Session

[Recently demoted preferences (usage pattern changed)]
🔄 ui_library: previously defaulted to Ant Design, recently switched to shadcn/ui, observation reset
====================
```

---

## Trackable Decision Types

The following decisions are automatically recorded by Claude Code to `decision_log`:

### Technology Stack

| decision_key | Description | Example Values |
|-------------|-------------|----------------|
| `tech_stack.frontend` | Frontend framework | React, Vue, Next.js |
| `tech_stack.backend` | Backend framework | Express, FastAPI, NestJS |
| `tech_stack.database` | Database | PostgreSQL, MongoDB, MySQL |
| `tech_stack.language.backend` | Backend language | TypeScript, Python, Go |
| `ui_library` | UI component library | Ant Design, shadcn/ui, Radix |
| `css_framework` | CSS approach | Tailwind, CSS Modules, styled-components |
| `auth_method` | Authentication method | JWT, Session, OAuth |
| `orm` | ORM/database tool | Prisma, Drizzle, SQLAlchemy |
| `api_style` | API style | RESTful, GraphQL, tRPC |
| `state_management` | State management | Zustand, Jotai, Redux |

### Code Style

| decision_key | Description | Example Values |
|-------------|-------------|----------------|
| `code_style.indent` | Indentation | 2spaces, 4spaces, tabs |
| `code_style.quotes` | Quotes | single, double |
| `naming.component` | Component naming | PascalCase, kebab-case |
| `naming.file.page` | Page file naming | PascalCase, kebab-case |
| `naming.api.route` | API route naming | kebab-case, camelCase |

### Architecture Decisions

| decision_key | Description | Example Values |
|-------------|-------------|----------------|
| `architecture.api_prefix` | API path prefix | /api/v1, /api, /v1 |
| `architecture.error_format` | Error response format | {code,message,data}, {error,message} |
| `architecture.folder_structure` | Directory organization | feature-based, layer-based |
| `architecture.monorepo` | Whether monorepo | true, false |

---

## How to Record Decisions During a Session

Each time Claude Code makes one of the following types of decisions, append it to `decision_log` in `user-preferences.json`:

```json
{
  "timestamp": "<ISO 8601>",
  "decision_key": "tech_stack.frontend",
  "value": "React + TypeScript",
  "context": "FEAT-001 — user specified in requirements document",
  "source": "user_explicit | user_confirmed | auto_default | inferred"
}
```

**source meanings:**
- `user_explicit` — User explicitly specified in the requirements document or conversation
- `user_confirmed` — Claude asked and the user confirmed
- `auto_default` — Already evolved to a default, used automatically
- `inferred` — Claude inferred (not yet confirmed by the user)

---

## Preference Query Interface

When implementing features, Claude Code should query preferences first:

```
Check user-preferences.json. If <decision_key> already has a confirmed: true preference,
use that value directly without asking the user.
Record in the progress log: "[preference] Using learned default: <key> = <value>".
```
