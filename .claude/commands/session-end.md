# Skill: session-end — Session Wrap-Up

Execute the following steps to safely end the current session and save state.

## Step 1: Collect Session Completion Summary

Compile the completion checklist for this session:
- Which features were completed (feature ID + title)
- Which files were created/modified
- What problems or decisions were encountered
- What was left unfinished

## Step 2: Update feature files

For every feature touched this session, update the corresponding `features/FEAT-XXX.json`:

**Features completed this session:**
```json
{
  "status": "done",
  "completed_at": "<current ISO 8601 time>",
  "notes": "<completion notes, explain any deviations>"
}
```

**Features started but not completed this session:**
```json
{
  "status": "in_progress",
  "notes": "<current progress, entry point for next session>"
}
```

Then sync the `summary` counts in `features.json` (`total`, `pending`, `in_progress`, `done`, `last_updated`).

## Step 3: Write the session progress log

Create or update `.claude/progress/sessions/<YYYY-MM-DD>.session.md` (append if the file already exists for today):

```markdown
# Session: <YYYY-MM-DD>
**Time**: <YYYY-MM-DD HH:MM>
**Status**: Completed

## Completed This Session
<List each completed feature: - FEAT-XXX: <title>>

## File Change Log
### Added
- <file path> — <purpose>

### Modified
- <file path> — <what changed>

## Issues Encountered
<Technical problems, unclear requirements, missing design assets, etc. Write "None" if none.>

## Unfinished Items
<List in_progress features and reasons. Write "None" if none.>

## Entry Points for Next Session
1. <specific first action>
2. <subsequent steps>

## Notes for Next Claude
<Important context, decisions, watch-outs. Write "None" if none.>

---
**Author**: Claude Code
**Last updated**: <ISO 8601 time>
```

Then update `.claude/progress/index.json`:
- Add or update the entry for this session in the `sessions` array
- Increment `statistics.total_sessions` if it's a new session
- Update `latest_session` and `updated_at`

## Step 3.5: Trigger Preference Evolution (Silent Execution)

Execute the `/learn-preferences` logic (silent mode, do not output the full report):

1. Count the new `decision_log` entries added this session
2. Check whether any decision_key has reached the evolution threshold (`evolution_threshold`)
3. If yes → Update `user-preferences.json`, upgrade that preference to `confirmed: true`
4. If there are new evolutions → Add a one-line notification to the output summary for the user

---

## Step 4: Output Status Summary

```
✅ Session safely ended

Features completed: <N>
Changes completed: <N>
In progress: <N> (handle first next session)
Pending: <N> features, <M> change requests
Progress log: updated

[Preference Evolution]
<If there are new evolutions, list: ✨ New default: <key> = <value> (appeared N times)>
<If no new evolutions, write: No new evolutions this session>

Run /session-start next time to continue from here.
```

## Mandatory Checks

- [ ] Each touched feature has its `features/FEAT-XXX.json` updated
- [ ] `features.json` `summary` counts are in sync
- [ ] `.claude/progress/sessions/<YYYY-MM-DD>.session.md` has been written
- [ ] `.claude/progress/index.json` has been updated
- [ ] No in_progress features are missing a reason for being unfinished
