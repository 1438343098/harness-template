# frontend/ Directory Navigation — AGENTS.md

> Frontend application code directory. The tech stack is defined in `features.json` under `project.tech_stack.frontend`.

---

## Recommended Directory Convention

> Claude Code will create the actual structure once the tech stack is determined. The following is a reference convention.

```
frontend/
├── AGENTS.md
├── src/
│   ├── components/     # Reusable UI components (stateless)
│   ├── pages/          # Page components (stateful, one file per route)
│   ├── layouts/        # Layout components
│   ├── hooks/          # Custom Hooks (React projects)
│   ├── services/       # API call wrappers
│   ├── store/          # State management
│   ├── utils/          # Utility functions
│   ├── styles/
│   │   └── tokens.css  # Design tokens (from design-spec.md)
│   └── types/          # TypeScript type definitions
├── public/
└── package.json
```

---

## Design Token Reference Standard

All colors, spacing, and typography must use CSS variables (sourced from `docs/design/extracted/design-spec.md`):

```css
/* ✅ Correct */
.btn-primary {
  background-color: var(--color-primary);
  padding: var(--spacing-sm) var(--spacing-md);
  border-radius: var(--radius-md);
}

/* ❌ Wrong — hardcoded style values are forbidden */
.btn-primary {
  background-color: #1677FF;
  padding: 8px 16px;
}
```

---

## Code Standards

**File naming:**
- Components: `PascalCase.tsx` (e.g. `UserCard.tsx`)
- Pages: `kebab-case.tsx` (e.g. `user-list.tsx`)
- Utilities: `camelCase.ts` (e.g. `formatDate.ts`)

**Component structure order:**
1. Imports
2. Type definitions
3. Component implementation
4. Styles (if using CSS Modules)
5. Default export

**API calls must include:**
- Loading state handling
- Error state handling
- Timeout handling (default 10 seconds)

---

## View Frontend Feature Status

```bash
cat features.json | grep -A8 '"type": "frontend"'
```

---

*Updated: 2026-03-25 | This file will be updated once the tech stack is determined*
