# Skill: process-iteration — Iteration Change Processing

Handle change requests for existing features (iteration changes), as distinct from first-time requirements parsing (`/process-requirements`).

**Trigger:** `/process-iteration [optional file path]`

**Applicable Scenarios:**
- Modifying an already-implemented feature
- Adding new sub-features to an existing feature
- Requirements adjustments (changes following user feedback)
- Product iteration (v1 → v2)

---

## Step 1: Read the Change Content

Check the following sources:
1. New files in `docs/prd/` (files named with `change-`, `iteration-`, `v2-`, etc.)
2. Changes described directly by the user in the conversation

If the user describes changes in the conversation, save them to `docs/prd/iteration-<date>.md` first.

---

## Step 2: Parse Change Types

For each change request, determine its type:

| Change Type | Description | Handling |
|-------------|-------------|----------|
| `extend` | Add new capability on top of an existing feature | Create sub-feature FEAT-XXX-EXT |
| `modify` | Change the behavior/style of an existing feature | Create CHANGE-XXX linked to the original feature |
| `replace` | Completely replace a feature | Mark original feature as deprecated, create new feature |
| `new` | Brand new feature (not in original features) | Create new FEAT-XXX normally |
| `remove` | Delete a feature | Mark original feature as removed, clean up related code |

---

## Step 3: Impact Analysis

For each change, analyze:

```
Change: <description>
Affected feature: <FEAT-XXX>
Affected files: <code files that may need modification>
Affected features (dependency chain): <other FEAT-YYY that depend on this feature>
Design change: whether design-spec.md needs to be updated
Backward compatible: whether this change is a breaking change (affects API interfaces/data structures)
```

---

## Step 4: Update features.json

### Add Change Records

Add a `change_requests` array to `features.json` (create it if it does not exist):

```json
{
  "change_requests": [
    {
      "id": "CHANGE-001",
      "title": "<change title>",
      "type": "extend | modify | replace | new | remove",
      "target_feature": "FEAT-XXX",
      "description": "<detailed change description>",
      "reason": "<reason for the change>",
      "acceptance_criteria": ["<criteria 1>", "<criteria 2>"],
      "affected_files": ["<file path>"],
      "breaking_change": false,
      "priority": 1,
      "status": "pending",
      "created_at": "<ISO 8601>",
      "started_at": null,
      "completed_at": null
    }
  ]
}
```

### Mark Original Feature Version

For `modify` type, append to the original feature's `notes`:
```
Change history:
  - CHANGE-001 (2026-03-25): <change summary>
```

For `replace` type, update the original feature's `status` to `deprecated`.

---

## Step 5: Output Change Parsing Report

```
=== Iteration Change Parsing Complete ===

[Change List] (N changes total)

🔧 CHANGE-001 [modify] FEAT-002 User Login
   Change: Add WeChat/Google third-party login
   Affected files: frontend/web/src/pages/login.tsx, services/auth/src/routes/oauth.ts
   Breaking change: No (adds new interface, does not modify existing)

➕ CHANGE-002 [extend] FEAT-005 Product List
   Change: Support multi-dimensional filtering (price range, category, rating)
   Affected files: services/api/src/routes/products.ts, apps/web/src/components/FilterPanel.tsx
   Breaking change: No

🔄 CHANGE-003 [replace] FEAT-008 Payment Module
   Change: Replace mock payment with real Alipay integration
   Affected files: services/payment/ (entire directory rewrite)
   Breaking change: Yes (API parameter structure changes)
   ⚠️ Original feature FEAT-008 will be marked as deprecated

[Impact Assessment]
- <N> existing files affected in total
- <N> features affected via dependency chain (may require coordinated changes)
- Breaking changes: <N> (require special attention)

[Suggested Implementation Order]
1. CHANGE-001 (no dependencies)
2. CHANGE-003 (back up FEAT-008 logic first)
3. CHANGE-002 (depends on CHANGE-001 being complete)

Please confirm and then run /implement-feature CHANGE-001 to start implementation.
====================
```

---

## Notes for Implementing Changes

### modify type

When modifying existing code:
1. Append a change record to the file header comment:
   ```
   // CHANGE-001 (2026-03-25): <change summary>
   ```
2. Preserve original logic (annotated), unless it is a complete replacement
3. Prefer adding over modifying (open/closed principle)

### replace type

1. Read the original feature code first to understand existing logic
2. Create new implementation (can be a new file)
3. Switch references
4. Once new implementation is confirmed working, delete old code

### When breaking_change = true

Must:
1. Clearly mark `[BREAKING CHANGE]` in `claude-progress.txt`
2. List all affected callers
3. Provide migration notes (what changed, what callers need to do)

---

## Iteration Version Management

When a feature goes through multiple iterations, maintain version history in that feature entry in `features.json`:

```json
{
  "id": "FEAT-003",
  "title": "Product Detail Page",
  "status": "done",
  "version": "v3",
  "version_history": [
    { "version": "v1", "change": "Initial implementation", "date": "2026-03-01" },
    { "version": "v2", "change": "CHANGE-002: Add image carousel", "date": "2026-03-10" },
    { "version": "v3", "change": "CHANGE-007: Add video playback", "date": "2026-03-20" }
  ]
}
```
