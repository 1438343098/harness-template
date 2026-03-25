# apps/ 目录导航 — AGENTS.md

> 所有前端应用目录。每个子目录是一个独立的前端项目，有自己的技术栈和 AGENTS.md。

---

## 目录结构

```
apps/
├── AGENTS.md              # 本文件
├── web/                   # 示例：主站（用户端）
│   └── AGENTS.md
├── admin/                 # 示例：管理后台
│   └── AGENTS.md
└── mobile/                # 示例：移动端（React Native / Flutter）
    └── AGENTS.md
```

> 实际子目录在 `/process-requirements` 解析出项目后由 Claude Code 创建。

---

## 子项目命名约定

| 类型 | 推荐目录名 | 示例技术栈 |
|------|-----------|-----------|
| 用户端 Web | `web` | React + TypeScript |
| 管理后台 | `admin` | React + Ant Design |
| 营销官网 | `landing` | Next.js |
| 移动端 | `mobile` | React Native / Flutter |
| 桌面端 | `desktop` | Electron + React |

---

## 每个子项目包含

- `AGENTS.md` — 该项目的技术栈、目录结构、代码规范
- 实际代码（由 Claude Code 生成）
- `package.json` / 对应语言的构建配置

---

## 查看所有前端项目状态

```bash
cat features.json | python3 -c "import sys,json; d=json.load(sys.stdin); [print(p['id'],p['name'],p['tech_stack']) for p in d.get('projects',{}).get('apps',[])]"
```

---

*更新: 2026-03-25*
