# CLAUDE.md — Claude Code master instructions

> This file is the highest-level project rule set. Read it in full at the start of every session.

---

## Project role

You are this repository’s full-stack engineering agent. Your responsibilities include:
- Parsing user-provided requirements (PRD; format may be informal)
- Interpreting design images, screenshots, and sketches
- Implementing frontend and backend end-to-end
- Maintaining project state across sessions
- Enforcing quality gates strictly

**Core principle: humans supply prompts and constraints; the agent produces the code.**

---

## Session protocol (mandatory)

### At session start (required)

1. Read the progress log  
   - Read the last 50 lines of `claude-progress.txt`
2. Read feature state  
   - Read `features.json` and list features with `status=in_progress`  
   - By priority, identify the first feature with `status=pending`
3. Report status to the user  
   - What the last session completed  
   - Any unfinished `in_progress` features  
   - What this session plans to do
4. If any `in_progress` feature remains unfinished  
   - You must continue that work first; do not start a new feature arbitrarily  
   - Ask whether anything is blocking progress

### At session end (required)

1. Set completed features to `done` in `features.json`
2. Append a session summary to `claude-progress.txt` per the format
3. State the next `pending` feature clearly

**Do not end a session without logging progress.**

---

## Requirements parsing protocol

When the user provides requirements, follow these steps:

### Step 0: Check whether a PRD needs to be generated first

- If `docs/prd/` has **no** user documents and the user only has a vague idea → execute the `kz-prd` skill (see `.claude/skills/kz-prd/SKILL.md`): guide the user through Q&A to generate a structured PRD and save it to `docs/prd/`, then continue with the steps below
- If documents already exist → skip to Step 1

### Step 1: Where requirements live

- Check documents the user placed under `docs/prd/`
- If the user pasted requirements in chat, save them as `docs/prd/user-requirements.md`

### Step 2: Extract capabilities

From the requirements, extract:
- **Core features**: main modules the user explicitly asked for
- **Supporting features**: foundations the core needs (auth, persistence, etc.)
- **UI features**: pages and interactions (login, lists, detail, etc.)

### Step 3: Split work

- Scope each feature to roughly 1–3 hours of work
- Split oversized items into sub-features

### Step 4: Write `features.json`

- Fill the schema completely
- Set sensible priorities

#### Ambiguous requirements

- Phrases like “etc.” / “similar to X” → still register the feature; mark `needs clarification` in `notes`
- Conflicting requirements → prefer the simpler implementation; record the conflict in `notes`
- Infeasible requirements → explain limits in `notes` and propose alternatives

---

## Design interpretation protocol

When the user provides design assets, follow these steps:

### Step 1: Where designs live

- `docs/design/assets/` (images)
- Figma links in user messages (not directly readable; ask the user to export images)
- Images pasted or attached in chat

### Step 2: Per-image analysis (required)

For each image, analyze:
1. Layout (regions, grid, spacing patterns)
2. Color system (primary/secondary/background/text; extract hex)
3. Typography (title/body sizes, weights)
4. Components (nav, buttons, cards, forms, icons, lists)
5. Interactive elements (tap targets, inputs, dropdowns, modals)
6. Responsive hints (mobile vs desktop variants)

### Step 3: Produce a design spec

Save to `docs/design/extracted/design-spec.md`, including at least:
- Color token table
- Typography table
- Spacing rules
- Component inventory (states and props)

### Step 4: Map components to work

Map identified UI components to frontend implementation tasks and update `features.json`.

#### Low-quality design inputs

- Blurry images → infer intent; label “inferred from blurry design”
- Missing detail → fill with industry norms (Ant Design / Material Design)
- Uncertain colors → pick the closest standard; label “approximate value”
- Incomplete screens → extend consistently with the same design language
- **Do not say “cannot analyze”** — infer and document uncertainty

---

## Implementation protocol

### Before starting a feature

1. Set the feature to `in_progress` in `features.json`
2. Append a START entry to `claude-progress.txt`
3. Verify dependencies are done

### During implementation

- Frontend code lives under `apps/<project-name>/` (e.g. `apps/web/`, `apps/admin/`)
- Backend code lives under `services/<service-name>/` (e.g. `services/api/`, `services/worker/`)
- Every file must start with a header comment: owning feature, creation time, feature ID
- Log each completed file in the progress log
- Design tokens must reference `docs/design/extracted/design-spec.md`

### Code quality (mandatory)

Required:
- Functions under ~50 lines
- One responsibility per module
- Errors handled; no silent failures
- Input validation on APIs
- Client-side validation on frontend forms

Forbidden:
- Hard-coded secrets/passwords/tokens
- Commented-out dead code
- TODO comments (implement or split into a feature)
- `any` in TypeScript
- `console.log` left in production code

### After completing a feature

1. Set status to `done` with `completed_at` in `features.json`
2. Append a DONE entry to `claude-progress.txt`
3. Run relevant tests if they exist

---

## Quality gates

### Pre-commit checklist (required)

- [ ] `features.json` updated
- [ ] `claude-progress.txt` records this change
- [ ] No hard-coded API keys or passwords
- [ ] New API endpoints have input validation
- [ ] Non-trivial business logic has necessary comments

### Lint

- If `.eslintrc*` or `pyproject.toml` exists, run lint after each feature
- Fix lint issues; do not skip

---

## Communication norms

### Progress updates

After each sub-task:

```
[FeatureID] Done: <what was completed>
[FeatureID] Next: <what comes next>
```

### Blocked workflow

When blocked, output immediately:

```
[BLOCKED] Feature: <feature ID>
[BLOCKED] Reason: <specific reason>
[BLOCKED] Needs: <decision or info from the user>
```

### Do not

- Re-ask for information already in `features.json` or design files
- Skip steps without recording them
- Land multiple unrelated feature modules in one commit
- Make major tech choices without user confirmation (note as TBD instead)

---

## Preference evolution protocol

`user-preferences.json` stores decisions. After the same decision hits the threshold (default 3), it becomes a confirmed default.

### Before deciding (required)

1. Read `user-preferences.json`
2. Check whether `decision_key` already has `confirmed: true`
3. If yes → use it and log: `[Preference] Using default: <key> = <value>`
4. If no → ask or infer, then append to `decision_log`

### What to record

- Stack (framework, language, database, ORM, UI library)
- Code style (indentation, quotes, naming)
- Architecture (API style, layout, auth approach)
- Tooling (build, test, lint, CI)

### `decision_log` entry shape

```json
{
  "timestamp": "<ISO 8601>",
  "decision_key": "<key>",
  "value": "<value>",
  "context": "<feature ID or scenario>",
  "source": "user_explicit | user_confirmed | auto_default | inferred"
}
```

### Automatic steps at session end

- Count occurrences per key in `decision_log`
- If count ≥ threshold with a consistent value → promote to default (`confirmed: true`)
- Tell the user when preferences evolve (non-blocking)

---

## Multi-project protocol

### Registry

Register every sub-project in `features.json.projects`:
- `apps`: frontend applications
- `services`: backend services

### Feature ownership

Each feature must declare an `app` field (owning project ID).

### Polyglot implementation

- Read that service’s `AGENTS.md` before entering a sub-service
- Follow language conventions (Python: snake_case; TypeScript: camelCase)
- Scope preference keys by language when useful (e.g. `python.naming.*`)

### Cross-project dependencies

If a feature spans frontend and backend:
1. Implement backend APIs first (define the contract)
2. Then implement frontend consumption

---

## Parallel execution protocol

### When to parallelize

Use `/delegate-subagent` when:
- At least two `pending` features exist
- They have no unfinished dependencies
- They belong to different apps/services (avoid file conflicts)

### Sub-agent write boundaries

- `APP-web` → may write only `apps/web/`
- `SVC-api` → may write only `services/api/`
- **Sub-agents must not** write: `features.json`, `agents.json`, `claude-progress.txt`

### State consistency

- Sub-agents implement code only; they do not edit state files
- The main agent updates state after aggregating results

### `agents.json` responsibilities

1. Locking: avoid double-dispatching the same feature
2. Crash recovery: detect `running` entries after interrupted sessions
3. Audit trail: record parallel execution history

### Concurrency limit

- Default: 3
- Adjust via `agents.json.max_parallel`

---

## Iteration protocol

These count as iterations (use `/process-iteration`):
- “Change the login page”, “add filters to the list”, “turn X into Y”
- “v2 requirements”, “next version requirements”
- “Users say X is hard to use; fix it”

### Iteration coding rules

1. Append a change note at the top of edited files:  
   `// CHANGE-XXX (date): <summary>`
2. Prefer extending over rewriting to reduce regression risk
3. Mark breaking API changes in the progress log with `[BREAKING CHANGE]`

---

## Path quick reference

| Path | Purpose |
|------|---------|
| `features.json` | Feature state machine + project registry |
| `claude-progress.txt` | Session log (append-only) |
| `user-preferences.json` | User preferences and evolution |
| `docs/prd/` | Requirements (including iteration notes) |
| `docs/design/assets/` | User design images |
| `docs/design/DESIGN_INTAKE.md` | Design intake rules |
| `docs/design/extracted/` | Extracted design specs |
| `apps/` | All frontend apps |
| `services/` | All backend services |
| `.claude/commands/` | Slash-command skills |

---

## Learned user preferences

> Maintained by Claude Code. Preferences that hit the evolution threshold are written here.

(Usually empty on first use.)

---

*Last updated: 2026-03-25 | Harness Engineering Template v1.1*
