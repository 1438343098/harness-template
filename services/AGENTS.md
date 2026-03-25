# services/ 目录导航 — AGENTS.md

> 所有后端服务目录。每个子目录是一个独立的后端服务，可以使用不同语言和框架。

---

## 目录结构

```
services/
├── AGENTS.md              # 本文件
├── api/                   # 示例：主 API 服务（Node.js）
│   └── AGENTS.md
├── worker/                # 示例：后台任务（Python）
│   └── AGENTS.md
└── gateway/               # 示例：API 网关（Go）
    └── AGENTS.md
```

> 实际子目录在 `/process-requirements` 解析出服务后由 Claude Code 创建。

---

## 子服务命名约定

| 类型 | 推荐目录名 | 示例技术栈 |
|------|-----------|-----------|
| 主 API | `api` | Node.js + Express / Python + FastAPI |
| 认证服务 | `auth` | Node.js + JWT |
| 后台任务 | `worker` | Python + Celery |
| 实时通信 | `realtime` | Node.js + Socket.io |
| 文件处理 | `storage` | Go / Node.js |
| 消息队列 | `queue` | Python / Go |
| API 网关 | `gateway` | Go / Node.js |

---

## 每个子服务包含

- `AGENTS.md` — 该服务的语言、框架、API 规范、启动方式
- 实际代码（由 Claude Code 生成）
- `package.json` / `pyproject.toml` / `go.mod` 等构建配置
- `.env.example` — 环境变量模板

---

## 跨服务通信约定

- **同步调用：** REST API（`http://service-name:port/api/v1/...`）
- **异步消息：** 消息队列（在 `features.json` 的 `infrastructure` 中定义）
- **共享类型：** 放置于项目根目录的 `shared/types/` 目录

---

## 查看所有后端服务状态

```bash
cat features.json | python3 -c "import sys,json; d=json.load(sys.stdin); [print(p['id'],p['name'],p['tech_stack'],p['language']) for p in d.get('projects',{}).get('services',[])]"
```

---

*更新: 2026-03-25*
