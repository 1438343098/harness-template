# Skill: delegate-subagent — Parallel Feature Dispatch

Assign multiple independent features to parallel sub-agents for simultaneous implementation, reducing total development time.

**Trigger:** `/delegate-subagent [optional count, default 3]`

**Applicable conditions:**
- features.json contains 2 or more mutually independent (no unfinished dependencies) pending features
- These features belong to different apps/services (natural file-level isolation)
- The user wants to accelerate development pace

---

## Step 1: Read Current State

```bash
cat features.json
cat agents.json
cat user-preferences.json
```

Extract:
- All features with `status: pending`
- Feature IDs already `running` in agents.json (exclude these)
- User preferences already confirmed (use directly in sub-agent prompts)

---

## Step 2: Filter Parallelizable Candidate Features

**Filter criteria (all must be satisfied):**

1. `status: pending`
2. All features in `dependencies` have `status: done`
3. Not in the `running` list of agents.json
4. **At most 1 feature per `app`** (features within the same app often have implicit file dependencies)

**Ordering:** Sort by `priority` ascending (lower number = higher priority)

**Count:** Take the first N, where N = min(parameter, `agents.json.max_parallel`, candidate count)

If fewer than 2 candidate features exist, stop and display:
```
Insufficient candidate features for parallel dispatch.
Currently parallelizable independent pending features: <N>
Suggestion: use /implement-feature <FEAT-ID> directly
```

---

## Step 3: Register to agents.json

Write the following into the `agents` array in `agents.json` for each candidate feature:

```json
{
  "id": "agent-<YYYYMMDD>-<index>",
  "feature_id": "<FEAT-ID>",
  "app": "<app field value>",
  "title": "<feature title>",
  "status": "running",
  "started_at": "<current ISO 8601>",
  "completed_at": null,
  "error": null
}
```

Also update `active_session` to the current timestamp and `last_updated` to the current time.

---

## Step 4: Look Up Project Info for Each Feature

From `features.json`'s `projects.apps` and `projects.services`,
use the feature's `app` field to find the corresponding project's:
- `path` (directory where code will be written)
- `tech_stack` (technology stack)
- `language` (programming language, for services type)

---

## Step 5: Construct an Independent Prompt for Each Sub-Agent

Each sub-agent's prompt must be fully self-contained (sub-agents have no current session context).

**Prompt template:**

```
You are a sub-agent focused on implementing a single feature. After implementation is complete, return the results to the Orchestrator in structured format. Do not modify any state files.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Your Task
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Implement feature: <FEAT-ID> — <title>
Project: <app>  Path: <path>
Tech stack: <tech_stack>
Language: <language (if applicable)>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature Details
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Description: <description>

Acceptance criteria:
<list acceptance_criteria line by line>

Notes: <notes>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Resource Locations
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Design spec: docs/design/extracted/design-spec.md (read if file exists)
Requirements document: docs/prd/ (if background context is needed)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Confirmed User Preferences (use directly, do not ask)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
<list each preference with confirmed: true from user-preferences.json>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Code Standards
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Every file must start with a comment: @feature <FEAT-ID>, @created <date>
- Functions must not exceed 50 lines
- No hardcoded secrets or passwords
- Errors must be handled; silent fails are not allowed
- <e.g. TypeScript: no any types>
- <e.g. Python: use snake_case>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
File Isolation Constraint (strictly enforced)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
You may only create/modify files under the <path>/ directory.
Writing to any other project directory is strictly forbidden.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Prohibited Actions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Do not modify features.json
- Do not modify agents.json
- Do not modify claude-progress.txt
- Do not modify user-preferences.json
- Do not modify files belonging to other features' directories

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Upon completion, return results in the following format (nothing else)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RESULT:
feature_id: <FEAT-ID>
success: true | false
files_created:
  - <file path> — <purpose>
files_modified:
  - <file path> — <what was changed>
acceptance_verified:
  - [✅/❌] <acceptance criteria 1>
  - [✅/❌] <acceptance criteria 2>
issues: <issues encountered, or "none" if none>
notes: <notes for the Orchestrator, or "none" if none>
```

---

## Step 6: Dispatch Sub-Agents in Parallel

**Launch all sub-agent calls simultaneously in a single message (do not wait for one to finish before starting the next).**

Use Claude Code's Agent tool to call each candidate feature separately so they execute in parallel.

Wait for all sub-agents to return before proceeding to Step 7.

---

## Step 7: Collect Results and Write State Back

Iterate through each sub-agent's returned result:

**Success (success: true):**
- Update the corresponding feature in `features.json`: `status → done`, fill in `completed_at`
- Update the corresponding entry in `agents.json`: `status → done`, fill in `completed_at`

**Failure (success: false):**
- Update the corresponding feature in `features.json`: `status → pending` (rollback), append error reason to `notes`
- Update the corresponding entry in `agents.json`: `status → failed`, fill in `error`

Update the `summary` counts in `features.json`.

---

## Step 8: Append Progress Log

Append to the end of `claude-progress.txt`:

```
================================================================================
PARALLEL BATCH
Time: <ISO 8601>
Parallel count: <N>
================================================================================

[Batch Results]
<list results for each feature>

[Summary of Created Files]
<merged list of all files created/modified by sub-agents>

[Failed Features]
<if any failures, list reasons; otherwise write "none">

================================================================================
```

---

## Step 9: Output Parallel Execution Report

```
=== Parallel Execution Complete ===

[Batch Results] (total: N)
✅ FEAT-003: <title> — completed (3 files)
✅ FEAT-005: <title> — completed (5 files)
❌ FEAT-007: <title> — failed (reason: <reason>, rolled back to pending)

[Next Steps]
Remaining pending features: <N>
Suggestion: /delegate-subagent (continue parallel) or /implement-feature FEAT-XXX (single implementation)
====================
```

---

## Parallel Constraint Reference

| Can parallelize | Not recommended to parallelize |
|----------|-----------|
| Features in different apps (apps/web vs services/api) | Multiple features in the same app |
| Features with no dependencies on each other | Features with dependency relationships (implement the dependency first) |
| Pure frontend + pure backend features | Features that both involve shared types/interfaces definitions |
| Independent pages + independent APIs | Features that both require modifying the same config file |

---

## Emergency Abort

If the user interrupts during parallel execution (Ctrl+C or closes the terminal):

The next `/session-start` will detect `running` entries in agents.json and automatically prompt:
```
⚠️ Detected unfinished parallel tasks from last session:
  - FEAT-003 (running since <time>)
  - FEAT-005 (running since <time>)
Suggestion: Check whether these features have partial implementations in their code files, then decide whether to re-implement or complete manually.
```
