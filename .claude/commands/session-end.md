# Skill: session-end — Session Wrap-Up

Execute the following steps to safely end the current session and save state.

## Step 1: Collect Session Completion Summary

Compile the completion checklist for this session:
- Which features were completed (feature ID + title)
- Which files were created/modified
- What problems or decisions were encountered
- What was left unfinished

## Step 2: Update features.json

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
  "notes": "<description of current progress, entry point for next session>"
}
```

Sync the counts in the `summary` field accordingly.

## Step 3: Append to Progress Log

Append the following to the end of `claude-progress.txt` (**do not modify existing content**):

```
================================================================================
SESSION END
Date: <YYYY-MM-DD>
Time: <HH:MM>
================================================================================

[Completed This Session]
<List each completed feature>

[File Change Log]
Added:
  - <file path> — <purpose>
Modified:
  - <file path> — <what was changed>

[Issues Encountered]
<Technical problems, unclear requirements, missing design elements, etc. Write "None" if none>

[Unfinished Items]
<List in_progress features and reasons, write "None" if none>

[Entry Points for Next Session]
1. <specific first action>
2. <subsequent steps>

[Notes for Next Claude]
<Important context, decisions, things to watch out for. Write "None" if none>

================================================================================
```

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

- [ ] `features.json` has been updated for all features touched this session
- [ ] `claude-progress.txt` has this session's record appended
- [ ] No in_progress features are missing a reason for being unfinished
