# backend/ 目录导航 — AGENTS.md

> 后端服务代码目录。技术栈在 `features.json` 的 `project.tech_stack.backend` 中定义。

---

## 推荐目录约定

> 技术栈确定后 Claude Code 会创建实际结构。以下为参考约定。

```
backend/
├── AGENTS.md
├── src/
│   ├── routes/         # API 路由定义
│   ├── controllers/    # 请求处理层
│   ├── services/       # 业务逻辑层
│   ├── models/         # 数据模型/Schema
│   ├── middleware/     # 中间件（认证、日志、错误处理）
│   ├── utils/          # 工具函数
│   └── types/          # TypeScript 类型定义
├── tests/              # 测试文件
├── migrations/         # 数据库迁移文件
├── .env.example        # 环境变量示例（不含真实值）
└── package.json 或 pyproject.toml
```

---

## API 设计规范

### RESTful 约定

```
GET    /api/v1/<资源>          # 列表
GET    /api/v1/<资源>/:id      # 详情
POST   /api/v1/<资源>          # 创建
PUT    /api/v1/<资源>/:id      # 完整更新
PATCH  /api/v1/<资源>/:id      # 部分更新
DELETE /api/v1/<资源>/:id      # 删除
```

### 统一响应格式

```json
// 成功
{ "code": 0, "message": "success", "data": { ... } }

// 错误
{ "code": <错误码>, "message": "<可读错误描述>", "data": null }
```

---

## 安全规范（强制）

**必须：**
- 所有 API 输入必须验证（类型、长度、格式）
- 密码必须使用 bcrypt 或 argon2 哈希
- JWT 密钥必须在环境变量中，不得硬编码
- 数据库查询使用参数化查询，防止 SQL 注入

**禁止：**
- 代码中硬编码密码、密钥、Token
- 返回详细的数据库错误信息给客户端
- 在日志中记录密码或完整 Token

---

## 环境变量管理

`.env.example` 中列出所有必需环境变量（无真实值）：
```env
DATABASE_URL=
JWT_SECRET=
PORT=3000
NODE_ENV=development
```

实际值放在 `.env`，必须在 `.gitignore` 中排除。

---

## 查看后端功能状态

```bash
cat features.json | grep -A8 '"type": "backend"'
```

---

*更新: 2026-03-25 | 技术栈确定后此文件会更新*
