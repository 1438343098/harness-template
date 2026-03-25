# 使用切换到en分支，main只是用来阅读的

> **[FOR HUMANS ONLY]** This file is not part of the project context. Claude Code does not need to read README.md.

# Harness Engineering — Claude Code 开发模板

**这是一个给 Claude Code 用的项目脚手架。**

解决的核心问题：Claude Code 没有记忆，每次开新会话都是白板，不知道项目做到哪了、之前怎么决策的、下一步该干什么。

它把"项目状态"变成仓库里的文件，让 Claude Code 每次启动时读取，假装自己从没断过。

- `features.json` — 功能清单和状态，替代人脑记"还有什么没做"
- `claude-progress.txt` — 只追加的会话日志，替代"上次做到哪了"
- `user-preferences.json` — 记录你每次的技术选型决策，出现 3 次自动变默认，替代每次都回答"用 React 还是 Vue"
- `.claude/commands/` — 把工作流做成 slash 命令，让 Claude 按固定流程走，不靠临时发挥

用户的操作只有三件事：丢需求文档、丢设计图，然后每次开工 `/session-start`，收工 `/session-end`。

**本质：用文件系统给无状态的 LLM 造了一个有状态的外壳。**

---

## 快速开始

### 第 1 步：准备输入材料

**需求文档（至少一项）：**
- 将你的 PRD / 需求列表 / 想法记录放入 `docs/prd/`
- 格式随意，中文口语描述也没关系

**设计稿（可选）：**
- 将 Figma 导出的 PNG 图片放入 `docs/design/assets/`
- 支持截图、手绘照片等任意格式

> Figma 导出步骤：选中画框 → 右键 → Export → PNG 2x

### 第 2 步：启动 Claude Code

```bash
cd your-project
claude
```

### 第 3 步：初始化会话

```
/session-start
```

### 第 4 步：解析需求（首次使用）

```
/process-requirements
```

Claude 会读取需求文档，提取所有功能点，填写 `features.json`，并询问模糊点。

### 第 5 步：解析设计（首次使用，有设计稿时）

```
/process-design
```

Claude 会分析所有设计图，提取颜色/字体/间距等设计规范，生成 `docs/design/extracted/design-spec.md`。

### 第 6 步：开始开发

```
/implement-feature FEAT-001
```

Claude 会按优先级自动实现功能。确认后继续：

```
/implement-feature FEAT-002
/implement-feature FEAT-003
...
```

### 第 7 步：结束会话

```
/session-end
```

Claude 记录进度，下次会话从断点继续。

---

## 跨会话连续性

每次新会话：

```
/session-start
```

Claude 自动读取上次进度，识别未完成功能，从中断点继续。**不需要重新解释项目背景。**

---

## 工作流图解

```
放需求文档       →  /process-requirements  →  features.json 功能列表
放设计图片       →  /process-design         →  design-spec.md 设计规范
                         ↓
/session-start   →  读取状态，制定计划
                         ↓
/implement-feature FEAT-001  →  实现功能
/implement-feature FEAT-002  →  实现功能
         ...
/session-end     →  记录进度
                         ↓
下次会话 /session-start  →  从断点继续
```

---

## 目录结构

```
harness-template/
├── CLAUDE.md              ← Claude 主指令（每次会话自动读取）
├── AGENTS.md              ← 项目导航
├── features.json          ← 功能状态机 + 项目注册表（自动维护）
├── claude-progress.txt    ← 会话日志（自动维护）
├── user-preferences.json  ← 用户偏好（自动学习默认值）
├── .claude/
│   ├── settings.json      ← 质量门禁配置
│   └── commands/          ← 可用技能（Slash 命令）
├── docs/
│   ├── prd/              ← 放你的需求文档（含迭代变更文档）
│   └── design/
│       ├── assets/       ← 放你的设计图片
│       └── extracted/    ← Claude 自动生成，勿手动修改
├── apps/                 ← 所有前端应用（多项目支持）
│   ├── web/              ← 示例：用户端
│   └── admin/            ← 示例：管理后台
└── services/             ← 所有后端服务（多语言支持）
    ├── api/              ← 示例：Node.js 主 API
    └── worker/           ← 示例：Python 后台任务
```

---

## 可用技能

| 命令 | 用途 |
|------|------|
| `/session-start` | 会话初始化，加载偏好/状态/项目列表 |
| `/session-end` | 会话收尾，记录进度，触发偏好进化 |
| `/process-requirements` | 解析首次 PRD → features.json + 注册项目 |
| `/process-iteration` | 解析迭代需求 → change_requests |
| `/process-design` | 解析设计图 → design-spec.md |
| `/implement-feature [ID]` | 实现 FEAT-xxx 或 CHANGE-xxx |
| `/learn-preferences` | 查看/管理自动学习的默认值 |

---

## 常见问题

**Q: 需求文档格式很乱，Claude 能处理吗？**
A: 可以。`/process-requirements` 专门处理任意格式，包括中文口语。

**Q: 只有 Figma 链接怎么办？**
A: 在 Figma 导出 PNG（2x），放入 `docs/design/assets/`。

**Q: 需求变了怎么办（迭代需求）？**
A: 将变更说明放入 `docs/prd/`（如 `iteration-001.md`），运行 `/process-iteration`。Claude 会分析影响范围，生成变更请求，不影响已完成的功能。

**Q: 我有多个前端项目，比如官网 + 后台，怎么处理？**
A: 在需求文档中说明，`/process-requirements` 会自动在 `apps/` 下创建对应子目录并注册到 `features.json`。每个子项目有独立的 AGENTS.md 和技术栈。

**Q: 后端需要用 Python 写 worker，用 Node 写 API，怎么处理？**
A: 每个 `services/` 子目录可以独立技术栈。`features.json` 中每个 service 单独记录语言和框架，Claude Code 会按各自的规范生成代码。

**Q: Claude 每次都问同样的问题（比如用什么框架），能不能记住？**
A: 会自动学习。同一个决策做 3 次后，自动成为默认值记入 `user-preferences.json`，之后不再询问。运行 `/learn-preferences` 可查看已学习的偏好。

**Q: 怎么知道开发进度？**
A: 运行 `/session-start` 即可看到实时进度，或查看 `features.json`。

---

## 支持的技术栈

**前端：** React / Vue 3 / Next.js（+ TypeScript 推荐）

**后端：** Node.js + Express/Fastify/NestJS | Python + FastAPI/Django

**数据库：** PostgreSQL / MySQL / SQLite / MongoDB

---

## Harness Engineering 核心理念

> "人类只写提示词和约束，代码全部由 Agent 生成。"

六大原则：
1. **仓库即真相** — `features.json` 是唯一状态权威来源
2. **导航优于文档** — 每目录 AGENTS.md，无需长篇大论
3. **机械化执行** — 质量门禁自动触发
4. **Agent 友好架构** — 目录结构对 Claude 最优化
5. **熵管理** — 防止功能状态腐烂
6. **吞吐量驱动** — 功能粒度 1-3 小时，持续交付

---

*Harness Engineering Template v1.0 | 2026-03-25 | Claude Code 专属*
