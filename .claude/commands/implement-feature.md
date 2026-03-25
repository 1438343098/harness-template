# Skill: implement-feature — Feature Implementation

Implement a single feature specified in features.json.

**Usage:** `/implement-feature FEAT-001`

## Step 0: Query User Preferences

```bash
cat user-preferences.json
```

Extract all preferences with `confirmed: true`. When making technology choices during implementation, use these as defaults without asking the user again.

---

## Step 1: Read Feature Information

```bash
cat features.json
```

Extract the target feature's: `title`, `description`, `type`, `app` (owning project), `acceptance_criteria`, `dependencies`, `notes`

Using the `app` field, find the corresponding project's `path` and `tech_stack` in `features.json`'s `projects` section, and place code in that project directory.

## Step 2: Check Dependencies

Check the status of each feature ID in the `dependencies` list.

If any dependency is not complete (not `done`), stop and report:
```
[BLOCKED] Feature <ID> depends on <dependency ID> (<dependency title>) which is not yet complete
Suggestion: implement first with /implement-feature <dependency ID>
```

## Step 3: Read Design Spec

```bash
cat docs/design/extracted/design-spec.md
```

Locate the page/component design spec corresponding to this feature.

## Step 4: Set Feature Status to in_progress

Update the feature's `status` to `in_progress` in `features.json`, and fill in `started_at`.

Append to `claude-progress.txt`:
```
[FEAT-XXX] START: <feature title> — <time>
```

## Step 5: Output Implementation Plan (Wait for User Confirmation)

```
=== Implementation Plan: FEAT-XXX <feature title> ===

Type: <frontend / backend / fullstack / infra>
Estimated steps:
1. <step 1>
2. <step 2>
...

Files to be created/modified:
- <file path> — <purpose>
- ...

Acceptance criteria:
- <criteria 1>
- <criteria 2>
```

If the user says "continue", "OK", or does not object, begin implementation immediately.

## Step 6: Implement Code

### File Header Comment (required)

```javascript
/**
 * @feature FEAT-XXX: <feature title>
 * @module <module name>
 * @created <date>
 * @description <brief description>
 */
```

### Implementation Order

**Backend (type: backend)**:
1. Data model / Schema definition
2. Database migrations (if needed)
3. Service layer
4. API routes/controllers
5. Input validation
6. Error handling

**Frontend (type: frontend)**:
1. Read the corresponding page/component spec in `docs/design/extracted/design-spec.md`
2. Create CSS variables file (referencing design tokens)
3. Base UI components (stateless)
4. Page components (stateful, connected to data)
5. Route configuration
6. API integration

**Full-stack (type: fullstack)**: Backend first, then frontend.

**Infrastructure (type: infra)**:
1. Configuration files
2. Middleware/plugins
3. Environment variable template updates

### After creating each file, append a progress log entry

```
[FEAT-XXX] FILE: <file path> — <file purpose>
```

## Step 7: Run Validation

```bash
# Frontend
npm run build 2>&1 | tail -20

# Backend (Node.js)
node -e "require('./src/app')" 2>&1

# Backend (Python)
python -m py_compile <file path> 2>&1
```

If validation fails, it must be fixed before proceeding.

## Step 8: Update Feature Status to done

Update `features.json`:
- `status`: `done`
- `completed_at`: current time

Append to `claude-progress.txt`:
```
[FEAT-XXX] DONE: <feature title> — <time>
  Acceptance:
  ✅ <acceptance criteria 1>
  ✅ <acceptance criteria 2>
  Files:
  - <file path>
```

## Step 9: Output Completion Report

```
=== Feature Complete: FEAT-XXX <feature title> ===

✅ All acceptance criteria passed

[Files Created]
- <path>: <purpose>

[Files Modified]
- <path>: <what changed>

[Notes]
<things to be aware of when using this feature>

[Recommended Next Steps]
Next pending feature: FEAT-XXX <title> (priority: X)
Run: /implement-feature FEAT-XXX
```

## Common Situations

| Situation | Handling |
|------|------|
| Dependency not complete | Stop, prompt to implement dependency first |
| Design spec missing | Use Ant Design / Material Design standards as placeholder, note it |
| Tech stack undecided | Ask user, record in features.json notes |
| Build failure | Must fix; skipping is not allowed |
| Ambiguous requirements | Complete using default assumptions in notes, then explain after |
