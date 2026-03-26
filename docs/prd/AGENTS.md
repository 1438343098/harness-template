# docs/prd/ 目录导航 — AGENTS.md

> 本目录存放产品需求文档。支持任意格式；Claude Code 会自动整理。

---

## 目录内容

| 文件 | 说明 |
|------|------|
| `REQUIREMENTS_TEMPLATE.md` | 推荐的格式模板（非必须） |
| `user-requirements.md` | 实际用户需求（任意名称均可） |

---

## 用户说明

**方法 1：使用模板（推荐）**
复制 `REQUIREMENTS_TEMPLATE.md`，按模板填写。

**方法 2：直接丢文件**
将需求文档直接放入本目录，可以是：
- 产品需求文档（PRD）
- 功能列表、用户故事
- 随意的想法记录
- 任意语言的口语描述

**格式再乱也没关系 — Claude Code 会处理。**

**方法 3：在对话中粘贴**
直接在 Claude Code 对话中粘贴需求，然后运行 `/process-requirements`。

---

## Claude 工作流

1. 读取本目录下所有非模板文件
2. 运行 `/process-requirements` 技能解析
3. 将结果写入 `features.json`
4. 输出解析报告并等待用户确认

---

*更新时间：2026-03-25*
