# 🔧 Services — 后端服务容器

## 概述

`services/` 目录存放所有后端服务。每个后端服务（API、Worker、Scheduler 等）都是这里的一个子目录。

## 结构

```
services/
├── api/              # 示例：主 API 服务（Node.js）
│   ├── package.json
│   ├── src/
│   └── AGENTS.md
├── worker/           # 示例：后台任务（Python）
│   ├── requirements.txt
│   ├── src/
│   └── AGENTS.md
└── scheduler/        # 示例：定时任务（Node.js）
    ├── package.json
    ├── src/
    └── AGENTS.md
```

## 工作流

### 首次创建后端项目

运行：
```bash
/process-requirements
```

Claude 会在 `services/` 下自动创建子目录，并在 `features.json` 的 `projects.services[]` 中注册。

### 快速启动后端

**Node.js 服务**:
```bash
cd services/api
npm install
npm run dev
```

**Python 服务**:
```bash
cd services/worker
pip install -r requirements.txt
python -m src.main
```

### 实现功能

```bash
/implement-feature FEAT-001
```

Claude 会在对应的 `services/xxx/src/` 下生成代码。

## 技术栈支持

- **Node.js**：Express / Fastify / NestJS
- **Python**：FastAPI / Django
- **语言**：TypeScript / JavaScript / Python
- **包管理**：npm / pnpm / pip

## 命名规范

- 目录名小写：`api`、`worker`、`scheduler`
- 每个服务独立的 `package.json` 或 `requirements.txt`
- 在 `features.json` 中注册为 `api`、`worker` 等

## 多语言示例

### Node.js 服务

```
services/api/
├── package.json
├── tsconfig.json
└── src/
    ├── main.ts
    ├── routes/
    └── controllers/
```

### Python 服务

```
services/worker/
├── requirements.txt
├── pyproject.toml
└── src/
    ├── main.py
    ├── tasks/
    └── utils/
```

## 相关文档

- [features.json](../features.json) — 查看已注册的服务
- [CLAUDE.md](../CLAUDE.md) — 开发规范
- [docs/prd/](../docs/prd/) — 需求文档

---

**最后更新**: 2026-03-26  
**维护者**: Claude Code
