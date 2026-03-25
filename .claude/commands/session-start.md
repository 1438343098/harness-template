# Skill: session-start — Session Initialization

Execute the following steps to report project status to the user and formulate a plan for the current session.

## Step 0: Read User Preferences

```bash
cat user-preferences.json
```

Extract all preferences with `confirmed: true`. For all relevant decisions in this session, use these as defaults directly without asking again.

---

## Step 1: Read Progress Log

```bash
tail -80 claude-progress.txt
```

If the file does not exist or has no SESSION END record, this is the first session.

## Step 2: Read Feature Status

```bash
cat features.json
```

Parse and categorize:
- `in_progress` feature list (leftover tasks, handle first)
- `pending` feature list (sorted by priority)
- `done` feature count

## Step 2.5: Check Leftover State from Parallel Tasks

```bash
cat agents.json
```

Check whether there are entries with `status: running` in the `agents` array:

**If there are running entries:**

This means the previous session was interrupted mid-parallel execution. For each running entry:

```
Check the status of the corresponding feature in features.json:

Case A: The feature in features.json is done
→ The sub-Agent finished but the Orchestrator did not get to clean up agents.json
→ Directly change the status of that entry in agents.json to done
→ No need to re-implement

Case B: The feature in features.json is in_progress
→ Inconsistent state, the sub-Agent was interrupted mid-way
→ Reset that feature in features.json to pending, clear started_at
→ Change the entry status in agents.json to failed, set error to "session interrupted"
→ Show a warning in the session brief

Case C: The feature in features.json is pending
→ agents.json was not registered in time before the interruption
→ Directly change the entry status in agents.json to failed
```

**If there are no running entries:** Continue to the next step, no action needed.

## Step 3: Check Document Readiness

```bash
ls docs/prd/
ls docs/design/assets/
ls docs/design/extracted/
```

Identify:
- Whether `docs/prd/` has user requirements documents that have not been parsed (features.json is empty)
- Whether `docs/design/assets/` has design images and `extracted/` does not have design-spec.md

## Step 3.5: Read Project Registry

```bash
cat features.json
```

Extract `projects.apps` and `projects.services` to understand what sub-projects currently exist.

## Step 4: Output Session Brief

Output in the following format:

```
=== Session Brief ===
Date: <today's date>

[User Preferences (learned defaults)]
<List all confirmed preferences, or write "None yet, will be learned this session" if empty>

[Project List]
Frontend apps/:
  - <APP-id>: <name> (<tech_stack>) — <path>
Backend services/:
  - <SVC-id>: <name> (<language>/<tech_stack>) — <path>
(If the project list is empty, prompt the user to run /process-requirements to register projects)

[Completed]
<N> features completed in total
Last session: <summary of the last SESSION END in claude-progress.txt, or "First session" if none>

[Leftover Parallel Tasks] (if any interrupted parallel tasks)
⚠️ <FEAT-ID>: <title> — status has been reset to pending, needs re-implementation

[In Progress (handle first)]
<List all in_progress features (with their project), or write "None" if empty>

[Pending Queue]
Feature: next FEAT-XXX (<project>) — <title>
Change: next CHANGE-XXX — <title>
<N> more features and <M> change requests in queue

[Document Status]
Requirements doc: <parsed / pending (run /process-requirements)>
Design spec: <extracted / pending (run /process-design)>

[Plan for This Session]
1. <specific plan>
2. <next steps>
================
```

## Step 5: Wait for User Confirmation

Ask the user if there are any changes or new inputs. If not, proceed as planned.

## Notes

- When there are `in_progress` features, they must be resumed first — do not start new features
- When `features.json` is empty, prompt the user to run `/process-requirements`
- When `docs/design/assets/` has images but no `extracted/design-spec.md`, prompt the user to run `/process-design`
