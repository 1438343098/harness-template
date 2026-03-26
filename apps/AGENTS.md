# 📱 Apps — 前端应用容器

## 概述

`apps/` 目录存放所有前端应用。每个前端项目（Web、Admin、Mobile 等）都是这里的一个子目录。

## 结构

```
apps/
├── web/              # 示例：用户端网站
│   ├── package.json
│   ├── src/
│   └── AGENTS.md
├── admin/            # 示例：管理后台
│   ├── package.json
│   ├── src/
│   └── AGENTS.md
└── mobile/           # 示例：移动应用
    ├── package.json
    ├── src/
    └── AGENTS.md
```

## 工作流

### 首次创建前端项目

运行：
```bash
/process-requirements
```

Claude 会在 `apps/` 下自动创建子目录，并在 `features.json` 的 `projects.apps[]` 中注册。

### 快速启动前端

```bash
cd apps/web
npm install
npm run dev
```

### 实现功能

```bash
/implement-feature FEAT-001
```

Claude 会在对应的 `apps/xxx/src/` 下生成代码。

## 技术栈支持

- **框架**：React / Vue 3 / Next.js
- **语言**：TypeScript / JavaScript
- **包管理**：npm / pnpm
- **构建**：Vite / Webpack / Next.js

## 命名规范

- 目录名小写：`web`、`admin`、`mobile`
- 每个应用独立的 `package.json`
- 在 `features.json` 中注册为 `web`、`admin` 等

## 相关文档

- [features.json](../features.json) — 查看已注册的应用
- [CLAUDE.md](../CLAUDE.md) — 开发规范
- [docs/prd/](../docs/prd/) — 需求文档

---

**最后更新**: 2026-03-26  
**维护者**: Claude Code
