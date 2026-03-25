# 项目导航 — AGENTS.md

> 本文件帮助 Claude Code 快速理解项目结构。每个子目录的 AGENTS.md 提供更详细的信息。

---

## 项目类型

全栈 Web 应用 | 前后端分离 | Harness Engineering 范式 | Claude Code 专属

---

## 目录速览

| 目录/文件 | 职责 | 何时读取 |
|-----------|------|----------|
| `CLAUDE.md` | 主指令，所有协议，质量门禁 | **每次会话开始时（必读）** |
| `features.json` | 功能状态机 + 项目注册表 | 每次会话开始时 |
| `claude-progress.txt` | 会话日志（仅追加） | 每次会话开始时 |
| `user-preferences.json` | 用户偏好，自动进化的默认值 | 每次会话开始时 |
| `docs/prd/` | 需求文档（含迭代变更文档） | 解析需求/迭代时 |
| `docs/design/` | 设计稿和提取的设计规范 | 解读设计时 |
| `apps/` | 所有前端应用（可多个，不同技术栈） | 实现前端功能时 |
| `services/` | 所有后端服务（可多个，不同语言） | 实现后端功能时 |
| `.claude/commands/` | 可用技能（Slash 命令） | 需要执行特定工作流时 |

---

## 当前项目状态

读取 `features.json` 获取实时状态。快速查看命令：

```bash
# 查看功能总览（状态 + 标题）
cat features.json

# 查看最近进度
tail -50 claude-progress.txt
```

---

## 可用技能

| 命令 | 用途 | 使用时机 |
|------|------|----------|
| `/session-start` | 会话初始化，读取偏好/状态/项目，制定计划 | 每次会话开始 |
| `/session-end` | 会话收尾，更新状态，触发偏好进化 | 每次会话结束 |
| `/process-requirements` | 解析首次 PRD，注册项目，填充 features.json | 有新需求文档时 |
| `/process-iteration` | 解析迭代变更需求，生成 change_requests | 需求调整/产品迭代时 |
| `/process-design` | 解析设计稿，提取设计规范 | 有新设计图片时 |
| `/implement-feature [id]` | 实现单个功能或变更（顺序模式） | 功能有依赖或同 app 时 |
| `/delegate-subagent [N]` | 并行派发 N 个独立功能给子 Agent | 有 2+ 个互相独立的 pending 功能时 |
| `/learn-preferences` | 手动查看偏好进化状态 | 想了解/调整默认值时 |

---

## 渐进式披露

需要了解特定区域时，阅读对应的 AGENTS.md：

- `docs/AGENTS.md` — 文档目录详情
- `docs/prd/AGENTS.md` — 需求文档目录详情
- `docs/design/AGENTS.md` — 设计文件目录详情
- `apps/AGENTS.md` — 前端应用目录（所有子项目）
- `apps/<name>/AGENTS.md` — 具体前端项目的技术栈和规范
- `services/AGENTS.md` — 后端服务目录（所有子服务）
- `services/<name>/AGENTS.md` — 具体后端服务的语言/框架/规范

---

## Harness 核心原则（六条）

1. **仓库即真相** — `features.json` 和 `claude-progress.txt` 是唯一权威状态源
2. **导航优于文档** — 每个目录有 AGENTS.md（~100行），不写长篇文档
3. **机械化执行** — 质量门禁自动触发，不依赖人工记忆
4. **Agent 友好架构** — 目录和代码结构对 Claude Code 最优化
5. **熵管理** — 定期清理功能状态，防止状态腐烂
6. **吞吐量驱动** — 每个功能 1-3 小时粒度，持续交付

---

*版本: v1.0 | 更新: 2026-03-25 | Claude Code 专属模板*
