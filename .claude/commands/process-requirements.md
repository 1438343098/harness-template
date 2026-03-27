# Skill: process-requirements — Requirements Parsing

Parse a rough requirements document provided by the user into a structured features.json feature list.

## Prerequisites

The user has provided requirements in one of the following locations:
- Any file under the `docs/prd/` directory
- Or text pasted directly into the conversation
- Or only a vague idea (in this case, use the `kz-prd` skill first to generate a PRD)

## Step 0: Determine Whether This Is an Iteration

Check first:
- Whether `requirements_processed` in `features.json` is already `true`
- Whether the document content contains keywords like "modify", "iteration", "v2", "adjustment"
- Whether the document references existing features (FEAT-XXX)

If this is an iteration → Stop and inform the user to use `/process-iteration` instead.
If this is a first-time requirement → Continue with the steps below.

---

## Step 0.5: Check Whether a PRD Needs to Be Generated First

```bash
ls docs/prd/
```

Check whether **non-template** user requirements documents exist under `docs/prd/` (excluding `AGENTS.md` and `REQUIREMENTS_TEMPLATE.md`).

**If no documents exist and the user only has a vague description or rough idea:**

→ Read and execute the `kz-prd` skill defined in `.claude/skills/kz-prd/SKILL.md`:
  1. Based on the user's description, ask questions one by one to collect complete requirements information
  2. If the requirements involve form controls (input, select, checkbox, etc.), additionally read `.claude/skills/kz-prd/ref/form.md` and ask follow-up questions for each control
  3. Based on the collected information, generate a structured PRD (Executive Summary → User Stories → Functional Requirements → Design Considerations → Risks & Roadmap)
  4. Save the generated PRD to `docs/prd/[feature-name].md`

→ Once the PRD is generated, continue with Step 1 for parsing.

**If documents already exist:** Skip this step and proceed directly to Step 1.

---

## Step 1: Locate Requirements Document

```bash
ls docs/prd/
```

Read all non-template files (exclude AGENTS.md and REQUIREMENTS_TEMPLATE.md).

If the user pasted content in the conversation, save it to `docs/prd/user-requirements.md` first, then process it.

## Step 2: Structured Parsing

Read the entire requirements document and extract the following:

**1. Product Goal**
- What problem this application solves
- Who the target users are

**2. Core Feature Modules**
- Main functional areas (e.g., user management, product management, order system)

**3. Specific Feature Points**
- Specific features within each module (e.g., user registration, user login, change password)

**4. Implicit Technical Requirements**
- Things the user did not state but are necessary (e.g., authentication, data persistence, API interfaces)

**5. UI/Page Requirements**
- Which pages are needed (e.g., login page, dashboard, list page, detail page)

**6. Ambiguous or Unclear Requirements**
- Parts that need clarification

**Processing Rules:**
- "Features like xxx" → Extract the core characteristics of xxx
- "etc. / and so on / similar" → Record as a feature, mark notes as "needs user clarification"
- Repeated concepts → Merge into one feature
- Contradictory requirements → Choose the simpler implementation, record the contradiction in notes

## Step 2.5: Identify and Register Sub-Projects

Based on the requirements, identify which frontend apps and backend services need to be created:

**Identification Rules:**
- "User-facing website" / "official site" / "storefront" → `apps/web`
- "Admin panel" / "operations dashboard" / "CMS" → `apps/admin`
- "Mobile" / "App" → `apps/mobile`
- "API" / "interface service" / "backend" → `services/api`
- "Scheduled tasks" / "async processing" / "queue" → `services/worker`
- "Authentication" / "SSO" / "login service" → `services/auth`

**Query user preferences (`user-preferences.json`):**
- If `tech_stack.frontend` already has a default → Use it directly, do not ask
- If `tech_stack.language.backend` already has a default → Use it directly
- Options without a preference → Ask the user and record in `decision_log`

**Write to the `projects` field in `features.json`:**
```json
{
  "projects": {
    "apps": [
      {
        "id": "APP-web",
        "name": "User-facing Web",
        "path": "apps/web",
        "tech_stack": "<learned preference or user-confirmed>",
        "description": "<extracted from requirements>"
      }
    ],
    "services": [
      {
        "id": "SVC-api",
        "name": "Main API Service",
        "path": "services/api",
        "language": "<language>",
        "tech_stack": "<framework>",
        "description": "<extracted from requirements>"
      }
    ]
  }
}
```

**Create directory and AGENTS.md for each sub-project:**
```bash
mkdir -p apps/<name>
mkdir -p services/<name>
```

AGENTS.md should document: tech stack, directory structure conventions, code standards, startup commands.

---

## Step 3: Feature Priority Ordering

Priority rules (1 = highest):
1. **Infrastructure** — Without it, other features cannot run (database, authentication system)
2. **Core User Flows** — The user's primary operation paths
3. **Supporting Features** — Enhance the experience but not required
4. **Optimization Features** — Performance tuning, UI polish, etc.

## Step 4: Generate feature files

### 4a. Update `features.json` (index + metadata only)

```json
{
  "project": {
    "name": "<project name extracted from requirements>",
    "description": "<one-sentence description>",
    "target_user": "<target user>",
    "tech_stack": {
      "frontend": "<tech stack, write TBD if unspecified>",
      "backend": "<tech stack, write TBD if unspecified>",
      "database": "<database, write TBD if unspecified>"
    }
  },
  "summary": {
    "total": <total feature count>,
    "pending": <pending count>,
    "in_progress": 0,
    "done": 0,
    "last_updated": "<ISO 8601>"
  },
  "features_dir": "features/",
  "ambiguities": [
    {
      "description": "<ambiguous requirements description>",
      "question": "<question to confirm with user>",
      "impact": "<impact if not clarified>",
      "default_assumption": "<default handling approach>"
    }
  ],
  "design_assets": {
    "processed": false,
    "files": [],
    "spec_file": "docs/design/extracted/design-spec.md"
  },
  "requirements_processed": true,
  "last_updated": "<ISO 8601>"
}
```

### 4b. Create one file per feature: `features/FEAT-XXX.json`

```json
{
  "id": "FEAT-001",
  "title": "<feature title>",
  "module": "<module it belongs to>",
  "app": "APP-web | SVC-api | SVC-worker | ...",
  "type": "backend|frontend|fullstack|infra",
  "priority": 1,
  "status": "pending",
  "version": "v1",
  "version_history": [],
  "description": "<detailed feature description>",
  "acceptance_criteria": [
    "<acceptance criteria 1>",
    "<acceptance criteria 2>"
  ],
  "dependencies": [],
  "estimated_hours": 2,
  "notes": "<notes, especially for ambiguous points>",
  "created_at": "<ISO 8601>",
  "started_at": null,
  "completed_at": null
}
```

**Note:** `estimated_hours` per feature must not exceed 4 hours. Split features that do.

## Step 5: Output Parsing Report

```
=== Requirements Parsing Complete ===

[Project Overview]
<A paragraph describing the understood project>

[Feature List] (N features total)
Priority 1 - Infrastructure:
  ✅ FEAT-001: <title> (estimated Xh)
  ...

Priority 2 - Core Features:
  ✅ FEAT-003: <title> (estimated Xh)
  ...

[Technology Stack]
Frontend: <TBD or confirmed>
Backend: <TBD or confirmed>
Database: <TBD or confirmed>

[Questions Needing Clarification]
1. <question 1>
   - Impact: <scope of impact>
   - Default handling: <if not answered, then...>
2. <question 2>
   ...

Please confirm whether the above understanding is correct. Let us know if anything needs to be changed.
After confirmation, run /process-design (if design mockups exist) or /implement-feature FEAT-001 to start development.
====================
```
