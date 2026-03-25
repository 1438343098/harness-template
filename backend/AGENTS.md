# backend/ Directory Navigation — AGENTS.md

> Backend service code directory. The tech stack is defined in `features.json` under `project.tech_stack.backend`.

---

## Recommended Directory Convention

> Claude Code will create the actual structure once the tech stack is determined. The following is a reference convention.

```
backend/
├── AGENTS.md
├── src/
│   ├── routes/         # API route definitions
│   ├── controllers/    # Request handling layer
│   ├── services/       # Service layer
│   ├── models/         # Data models / Schema
│   ├── middleware/     # Middleware (auth, logging, error handling)
│   ├── utils/          # Utility functions
│   └── types/          # TypeScript type definitions
├── tests/              # Test files
├── migrations/         # Database migration files
├── .env.example        # Environment variable example (no real values)
└── package.json or pyproject.toml
```

---

## API Design Standards

### RESTful Convention

```
GET    /api/v1/<resource>          # List
GET    /api/v1/<resource>/:id      # Detail
POST   /api/v1/<resource>          # Create
PUT    /api/v1/<resource>/:id      # Full update
PATCH  /api/v1/<resource>/:id      # Partial update
DELETE /api/v1/<resource>/:id      # Delete
```

### Unified Response Format

```json
// Success
{ "code": 0, "message": "success", "data": { ... } }

// Error
{ "code": <error code>, "message": "<human-readable error description>", "data": null }
```

---

## Security Standards (Mandatory)

**Required:**
- All API inputs must be validated (type, length, format)
- Passwords must be hashed using bcrypt or argon2
- JWT secrets must be in environment variables; hardcoding is not allowed
- Database queries must use parameterized queries to prevent SQL injection

**Prohibited:**
- Hardcoding passwords, secrets, or tokens in code
- Returning detailed database error messages to clients
- Logging passwords or full tokens

---

## Environment Variable Management

`.env.example` lists all required environment variables (no real values):
```env
DATABASE_URL=
JWT_SECRET=
PORT=3000
NODE_ENV=development
```

Actual values go in `.env`, which must be excluded via `.gitignore`.

---

## View Backend Feature Status

```bash
cat features.json | grep -A8 '"type": "backend"'
```

---

*Updated: 2026-03-25 | This file will be updated once the tech stack is determined*
