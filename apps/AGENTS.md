# 📱 Apps — frontend application container

## Overview

`apps/` holds every frontend application. Each app (web, admin, mobile, etc.) is a subdirectory here.

## Layout

```
apps/
├── web/              # Example: public-facing site
│   ├── package.json
│   ├── src/
│   └── AGENTS.md
├── admin/            # Example: admin console
│   ├── package.json
│   ├── src/
│   └── AGENTS.md
└── mobile/           # Example: mobile client
    ├── package.json
    ├── src/
    └── AGENTS.md
```

## Workflow

### First-time app scaffolding

Run:

```bash
/process-requirements
```

Claude creates subfolders under `apps/` and registers them in `features.json` under `projects.apps[]`.

### Run a frontend locally

```bash
cd apps/web
npm install
npm run dev
```

### Implement a feature

```bash
/implement-feature FEAT-001
```

Claude generates code under the matching `apps/<name>/src/`.

## Supported stacks

- **Frameworks**: React / Vue 3 / Next.js
- **Languages**: TypeScript / JavaScript
- **Package managers**: npm / pnpm
- **Build**: Vite / Webpack / Next.js

## Naming

- Lowercase directory names: `web`, `admin`, `mobile`
- One `package.json` per app
- Register the same ids in `features.json` (`web`, `admin`, …)

## Related docs

- [features.json](../features.json) — registered apps
- [CLAUDE.md](../CLAUDE.md) — engineering rules
- [docs/prd/](../docs/prd/) — requirements

---

**Last updated:** 2026-03-26  
**Maintainer:** Claude Code
