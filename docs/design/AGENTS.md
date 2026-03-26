# docs/design/ 目录导航 — AGENTS.md

> 本目录存放设计稿文件。支持截图、导出图、照片等任意格式。

---

## 目录结构

```
docs/design/
├── AGENTS.md           # 本文件
├── DESIGN_INTAKE.md    # 设计解读规范（Claude 必读）
├── assets/             # 用户放入的设计图片（原始文件）
└── extracted/          # Claude 提取的设计规范（自动生成，勿手动修改）
    └── design-spec.md  # 生成后存在
```

---

## 用户指南

**支持的图片格式：** PNG / JPG / WebP / GIF
**推荐分辨率：** 1x 或 2x（越高越准确）

**命名建议（非必须）：**
```
01-login.png
02-home.png
03-list.png
04-detail.png
```

**不直接支持：**
- Figma 源文件（.fig）→ 请在 Figma 中导出为 PNG
- Sketch 文件 → 请导出为 PNG
- Adobe XD → 请导出为 PNG

**Figma 导出步骤：**
1. 在 Figma 中选中画框
2. 右键 → Export
3. 选择 PNG 格式，分辨率 2x
4. 保存到 `docs/design/assets/`

---

## Claude 工作流

1. 读取 `DESIGN_INTAKE.md` 了解解读规范
2. 读取 `assets/` 中的所有图片文件
3. 系统性地逐图分析（详见 `/process-design` 技能）
4. 将结果保存到 `extracted/design-spec.md`
5. 实现时从 `extracted/design-spec.md` 引用设计令牌

---

*更新时间：2026-03-25*
