# docs/ 目录导航 — AGENTS.md

> 本目录存放所有项目文档，包括需求文档和设计文档。

---

## 目录结构

```
docs/
├── prd/           # 产品需求文档（由用户放入）
│   ├── AGENTS.md
│   ├── REQUIREMENTS_TEMPLATE.md  # 需求文档模板
│   └── （用户放入的需求文档）
└── design/        # 设计文档
    ├── AGENTS.md
    ├── DESIGN_INTAKE.md           # 设计解读规范
    ├── assets/                    # 用户放入的设计图片
    └── extracted/                 # Claude 自动生成的设计规范
```

---

## 何时读取本目录

| 任务 | 需读取的文件 |
|------|------------|
| 解析需求 | `docs/prd/` 下的用户文件 |
| 解读设计 | `docs/design/assets/` 中的图片 + `DESIGN_INTAKE.md` |
| 查看设计规范 | `docs/design/extracted/design-spec.md` |

---

## 用户指南

- **放入需求文档：** 将 PRD 放入 `docs/prd/`，任意名称和格式均可
- **放入设计图片：** 将 Figma 导出的图片放入 `docs/design/assets/`
- **查看解析规范：** 见 `docs/design/extracted/`

---

*更新时间：2026-03-25*
