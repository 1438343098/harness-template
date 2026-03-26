# 技能：learn-preferences — 自进化偏好学习

分析用户的历史决策规律，自动将高频决策升级为默认值，减少重复确认。

**触发方式：**
- `/learn-preferences` — 手动触发
- 自动触发：每次 `/session-end` 时静默执行

---

## Step 1：读取决策日志

```bash
cat user-preferences.json
```

提取 `decision_log` 中的所有记录，按 `decision_key` 分组计数。

---

## Step 2：识别高频规律

对每个 `decision_key`，统计：
- 该决策做了多少次（`count`）
- 最近 5 次选择的值（是否一致？）
- 是否已是默认值（`confirmed: true`）

**进化规则：**

| 条件 | 操作 |
|------|------|
| count >= 阈值（默认 3）且取值完全一致 | 自动升级为默认值，`confirmed: true` |
| count >= 阈值但取值不一致 | 报告冲突，询问用户选择哪个 |
| count < 阈值 | 继续观察，不变 |
| 已是默认值但最近 2 次选择了不同值 | 降级，重新观察 |

---

## Step 3：执行进化

对满足条件的偏好，更新 `user-preferences.json`：

```json
{
  "preferences": {
    "<decision_key>": {
      "value": "<高频选择的值>",
      "count": <次数>,
      "confirmed": true,
      "source": "auto-learned",
      "evolved_at": "<ISO 8601>",
      "description": "<该偏好的含义>"
    }
  }
}
```

---

## Step 4：更新 CLAUDE.md（对重要偏好升级时）

当以下类型的偏好被自动升级时，同时更新 `CLAUDE.md` 中的默认行为描述：

- 技术栈选型（`tech_stack.*`）
- 代码风格（`code_style.*`）
- 架构决策（`architecture.*`）
- 命名规范（`naming.*`）

**更新位置：** 追加到 `CLAUDE.md` 底部的 `## 自动学习到的用户偏好` 章节。

---

## Step 5：输出进化报告

**仅在手动触发 `/learn-preferences` 时输出；自动触发时静默执行，仅在有新进化时通知用户。**

```
=== 偏好进化报告 ===

【已自动升级为默认值（不再需要确认）】
✅ tech_stack.frontend = React + TypeScript（已选择 4 次）
✅ css_framework = Tailwind CSS（已选择 3 次）
✅ api_style = RESTful（已选择 5 次）

【观察中（尚未达到阈值）】
📊 database = PostgreSQL（已选择 2/3 次）
📊 test_framework = Vitest（已选择 1/3 次）

【发现冲突（需你确认）】
⚠️ auth_method：选择了 JWT 2 次，Session 1 次
   → 请选择默认值：[1] JWT  [2] Session

【最近降级的偏好（使用规律发生变化）】
🔄 ui_library：之前默认为 Ant Design，近期切换为 shadcn/ui，已重置观察
====================
```

---

## 可跟踪的决策类型

以下决策由 Claude Code 自动记录到 `decision_log`：

### 技术栈

| decision_key | 说明 | 示例值 |
|-------------|------|--------|
| `tech_stack.frontend` | 前端框架 | React, Vue, Next.js |
| `tech_stack.backend` | 后端框架 | Express, FastAPI, NestJS |
| `tech_stack.database` | 数据库 | PostgreSQL, MongoDB, MySQL |
| `tech_stack.language.backend` | 后端语言 | TypeScript, Python, Go |
| `ui_library` | UI 组件库 | Ant Design, shadcn/ui, Radix |
| `css_framework` | CSS 方案 | Tailwind, CSS Modules, styled-components |
| `auth_method` | 鉴权方式 | JWT, Session, OAuth |
| `orm` | ORM/数据库工具 | Prisma, Drizzle, SQLAlchemy |
| `api_style` | API 风格 | RESTful, GraphQL, tRPC |
| `state_management` | 状态管理 | Zustand, Jotai, Redux |

### 代码风格

| decision_key | 说明 | 示例值 |
|-------------|------|--------|
| `code_style.indent` | 缩进 | 2spaces, 4spaces, tabs |
| `code_style.quotes` | 引号 | single, double |
| `naming.component` | 组件命名 | PascalCase, kebab-case |
| `naming.file.page` | 页面文件命名 | PascalCase, kebab-case |
| `naming.api.route` | API 路由命名 | kebab-case, camelCase |

### 架构决策

| decision_key | 说明 | 示例值 |
|-------------|------|--------|
| `architecture.api_prefix` | API 路径前缀 | /api/v1, /api, /v1 |
| `architecture.error_format` | 错误响应格式 | {code,message,data}, {error,message} |
| `architecture.folder_structure` | 目录组织方式 | feature-based, layer-based |
| `architecture.monorepo` | 是否 monorepo | true, false |

---

## 会话期间如何记录决策

每当 Claude Code 做出以下类型的决策时，向 `user-preferences.json` 的 `decision_log` 追加：

```json
{
  "timestamp": "<ISO 8601>",
  "decision_key": "tech_stack.frontend",
  "value": "React + TypeScript",
  "context": "FEAT-001 — 用户在需求文档中明确指定",
  "source": "user_explicit | user_confirmed | auto_default | inferred"
}
```

**source 含义：**
- `user_explicit` — 用户在需求文档或对话中明确指定
- `user_confirmed` — Claude 询问后用户确认
- `auto_default` — 已进化为默认值，自动使用
- `inferred` — Claude 推断（用户尚未确认）

---

## 偏好查询接口

实现功能时，Claude Code 应优先查询偏好：

```
检查 user-preferences.json。若 <decision_key> 已有 confirmed: true 的偏好，
直接使用该值，不询问用户。
在进度日志中记录："[偏好] 使用已学习的默认值：<key> = <value>"。
```
