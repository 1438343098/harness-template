# 🔧 Services — backend service container

## Overview

`services/` holds every backend service. Each service (API, worker, scheduler, …) is a subdirectory here.

## Layout

```
services/
├── api/              # Example: primary API (Node.js)
│   ├── package.json
│   ├── src/
│   └── AGENTS.md
├── worker/           # Example: background worker (Python)
│   ├── requirements.txt
│   ├── src/
│   └── AGENTS.md
└── scheduler/        # Example: scheduled jobs (Node.js)
    ├── package.json
    ├── src/
    └── AGENTS.md
```

## Workflow

### First-time service scaffolding

Run:

```bash
/process-requirements
```

Claude creates subfolders under `services/` and registers them in `features.json` under `projects.services[]`.

### Run a backend locally

**Node.js:**

```bash
cd services/api
npm install
npm run dev
```

**Python:**

```bash
cd services/worker
pip install -r requirements.txt
python -m src.main
```

### Implement a feature

```bash
/implement-feature FEAT-001
```

Claude generates code under the matching `services/<name>/src/`.

## Supported stacks

- **Node.js**: Express / Fastify / NestJS
- **Python**: FastAPI / Django
- **Languages**: TypeScript / JavaScript / Python
- **Package managers**: npm / pnpm / pip

## Naming

- Lowercase directory names: `api`, `worker`, `scheduler`
- One `package.json` or `requirements.txt` per service
- Register the same ids in `features.json` (`api`, `worker`, …)

## Multi-language examples

### Node.js service

```
services/api/
├── package.json
├── tsconfig.json
└── src/
    ├── main.ts
    ├── routes/
    └── controllers/
```

### Python service

```
services/worker/
├── requirements.txt
├── pyproject.toml
└── src/
    ├── main.py
    ├── tasks/
    └── utils/
```

## Related docs

- [features.json](../features.json) — registered services
- [CLAUDE.md](../CLAUDE.md) — engineering rules
- [docs/prd/](../docs/prd/) — requirements

---

**Last updated:** 2026-03-26  
**Maintainer:** Claude Code
