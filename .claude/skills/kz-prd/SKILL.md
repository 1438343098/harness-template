# PRD

---

name: prd
description: 'Generate high-quality Product Requirements Documents (PRDs) for software systems and AI-powered features. Includes executive summaries, user stories, technical specifications, and risk analysis.'
license: NONE

---

# **Product Requirements Document (PRD)**

## **Overview**

Design comprehensive, production-grade Product Requirements Documents (PRDs) that bridge the gap between business vision and technical execution. This skill works for modern software systems, ensuring that requirements are clearly defined.

## **When to Use**

Use this skill when:

- Starting a new product or feature development cycle
- Translating a vague idea into a concrete technical specification
- Defining requirements for AI-powered features
- Stakeholders need a unified "source of truth" for project scope
- User asks to "write a PRD", "document requirements", or "plan a feature"

## **Work Flow**

1. Receive a feature description from the user.
2. Based on the document requirements, ask as many clarifying questions as possible to ensure all necessary fields are filled.
3. Generate a structured PRD using the Strict PRD Schema below based on answers.
4. Save to **`docs/prd/[feature-name].md`**

## **Strict PRD Schema**

You **MUST** follow this exact structure for the output:

### **1. Executive Summary**

- **Problem Statement**: 1-2 sentences on the pain point.
- **Proposed Solution & GOAL**: 1-2 sentences on the fix.
- **Success Criteria**: 3-5 measurable KPIs.

### **2. User Stories**

Each story needs:

- Title: Short descriptive name
- Description: "As a [user], I want [feature] so that [benefit]"
- Priority: P0 / P1 / P2
- FR: Related Functional Requirements
- Acceptance Criteria: Verifiable checklist of what "done" means
- Each story should be small enough to implement in one focused session.

**Format:**

```
### US-001: [Title]
**Priority:** PN

**Desc:** As a [user], I want [feature] so that [benefit].

**FR:** FR-001, FR-002

**AC:**
- [ ] Specific verifiable criterion
- [ ] Another criterion
```

**Important:**

Acceptance criteria must be verifiable, not vague. "Works correctly" is bad. "Button shows confirmation dialog before deleting" is good.

### **3. Functional Requirements**

Maintain a **numbered catalog** of capabilities (`FR-001`, `FR-002`, …). Each entry must be **explicit, testable, and unambiguous** — no hand-waving.

**What each FR must include**

| Subsection | Purpose |
| ---------- | ------- |
| **Description** | What the system shall deliver, in one tight paragraph (scope in / out if helpful). |
| **Relevant User Stories** | Cross-reference story IDs (e.g. `US-001`, `US-002`). |
| **Actors** | Who initiates or is affected: end user, admin, sub-account, main account, system/integration, etc. |
| **Preconditions** | State, permissions, or data that must hold before the flow can start. |
| **Trigger** | What starts the flow: user gesture (with **where** in the UI), API request, schedule, webhook, background job, etc. |
| **Main Flow** | Numbered **happy-path** steps in order. |
| **Alternative Flows** | Labeled branches (`A1`, `A2`, …): errors, validation failure, cancel, timeout, permission denied, partial success. |
| **Postconditions** | Expected system/data state after **success**; call out failure outcomes if they differ. |
| **Acceptance Criteria** | Verifiable conditions — prefer **Given / When / Then** per scenario, or an equivalent checklist QA can execute. |

**Scoping rules**

- **One FR = one cohesive capability.** If it gets large, split into `FR-002`, `FR-003`, … with clear boundaries.
- **UI and triggers must be locatable:** name screen/region/control and the resulting behavior. _Bad:_ "When the user clicks a button, a dialog opens." _Good:_ "When the user taps **Delete** on the bottom-right of a list row, a **second-confirmation** modal opens with **Cancel** and **Delete** actions."
- **Alternative flows are mandatory** where failure or variation is realistic (auth, network, empty state, limits).

**Format template**

```markdown
## FR-001

### Description

...

### Relevant User Stories

US-001, US-002

### Actors

...

### Preconditions

...

### Trigger

...

### Main Flow

1. ...
2. ...

### Alternative Flows

- **A1:** ...
- **A2:** ...

### Postconditions

...

### Acceptance Criteria

- **Given** ...
- **When** ...
- **Then** ...
```

**Important:**

- The document must clearly specify the business domain of the requirement. A single requirement must only affect one business domain — e.g., explicitly modifying the user profile domain, or explicitly modifying a specific feature in the cloud storage domain.
- The document must describe the current state of the system.
- User interaction descriptions must be precise enough for both AI and humans to understand unambiguously. Use as many qualifiers as needed. "When the user clicks a button, a dialog appears" is bad. "When the user clicks the **Delete** button at the bottom-right of a list item, a second-confirmation modal appears" is good.
- The document must clearly define the scope of the change — e.g., "Move the submit button at the bottom of panel C (opened by clicking button B on page A) to the top-left of the panel."
- The document must define the operational logic boundary — e.g., "Clarify whether the display logic for a user's favorited works is scoped to the individual user, the organization, or all users."

### **4. Design Considerations (Optional)**

- UI/UX requirements
- Link to mockups if available
- Relevant existing components to reuse

### **5. Risks & Roadmap**

- **Phased Rollout**: MVP → v1.1 → v2.0.
- **Technical Risks**: Latency, cost, or dependency failures.

## **Implementation Guidelines**

### **Requirements Quality**

Use concrete, measurable criteria. Avoid "fast", "easy", or "intuitive".

```
# Vague (BAD)
- The search should be fast and return relevant results.
- The UI must look modern and be easy to use.

# Concrete (GOOD)
+ The search must return results within 200ms for a 10k record dataset.
+ The search algorithm must achieve >= 85% Precision@10 in benchmark evals.
+ The UI must follow the 'Vercel/Next.js' design system and achieve 100% Lighthouse Accessibility score.
```

### **DO (Always)**

- **Define Testing**: For AI systems, specify how to test and validate output quality.
- **Iterate**: Present a draft and ask for feedback on specific sections.

### **DON'T (Avoid)**

- **Skip Discovery**: Never write a PRD without asking at least 5 clarifying questions first.
- **Hallucinate Constraints**: If the user didn't specify a tech stack, ask or label it as TBD.
- **Include implementation details**: PRDs describe the problem context, user needs (User Stories), and functional requirements only — avoid introducing technical implementation details.

### **DO when condition is met**

- **Form design**:
  - Condition: requirements involve form controls, e.g. text input, number input, select, checkbox, radio, slider, date picker, file upload, etc.
  - Reference: `./ref/form.md`
