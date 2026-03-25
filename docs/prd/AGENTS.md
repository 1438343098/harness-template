# docs/prd/ 目录导航 — AGENTS.md

> 此目录存放产品需求文档。支持任意格式，Claude Code 会自动整理。

---

## 目录内容

| 文件 | 说明 |
|------|------|
| `REQUIREMENTS_TEMPLATE.md` | 推荐格式模板（非强制） |
| `user-requirements.md` | 用户实际需求（命名任意） |

---

## 用户使用说明

**方式1：使用模板（推荐）**
复制 `REQUIREMENTS_TEMPLATE.md`，按模板填写。

**方式2：直接放置**
将需求文档直接放入此目录。可以是：
- 产品需求文档（PRD）
- 功能列表、用户故事
- 随意的想法记录
- 中文口语描述

**格式越混乱也没关系，Claude Code 会处理。**

**方式3：对话中粘贴**
直接在 Claude Code 对话中粘贴需求，运行 `/process-requirements` 即可。

---

## Claude 工作流

1. 读取此目录下所有非模板文件
2. 运行 `/process-requirements` 技能解析
3. 结果写入 `features.json`
4. 输出解析报告，等待用户确认

---

*更新: 2026-03-25*
