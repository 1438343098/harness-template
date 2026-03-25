# 技能: process-design — 设计解析

将用户提供的混乱设计稿（截图/图片/Figma导出）解析为结构化的设计规范。

## 前置条件

用户已在以下位置提供设计文件：
- `docs/design/assets/` — 图片文件
- 或在对话中直接发送图片

## 步骤 0：阅读设计解读规范

必须先阅读 `docs/design/DESIGN_INTAKE.md`，了解 A/B/C/D 四级处理规则。

## 步骤 1：定位设计文件

```bash
ls docs/design/assets/
```

列出所有图片文件，按文件名排序，推断页面名称。

**如果用户提供了 Figma 链接：**
```
Claude Code 无法直接访问 Figma 链接。
请在 Figma 中选择画框 → 右键 → Export → PNG（2x分辨率）
将导出图片放入 docs/design/assets/ 目录，然后重新运行 /process-design
```

## 步骤 2：判断每张图片的质量等级

- **A类**：Figma 精准导出，文字清晰，颜色准确
- **B类**：普通截图，大体清晰，细节稍模糊
- **C类**：照片拍摄、低分辨率、压缩严重
- **D类**：无图片，只有文字描述

## 步骤 3：逐一分析每张设计图

对每张图片，按以下框架分析：

### 页面级别
```
页面名称: <推断的页面名称>
页面路由: /<路径>
页面用途: <功能目的>
质量等级: A / B / C
```

### 颜色分析（按 DESIGN_INTAKE.md 对应等级规则处理）
```
主色 (Primary): #xxxxxx
辅色 (Secondary): #xxxxxx
背景色: #xxxxxx
卡片背景: #xxxxxx
文字主色: #xxxxxx
文字次色: #xxxxxx
边框色: #xxxxxx
成功色: #xxxxxx
警告色: #xxxxxx
错误色: #xxxxxx
```

### 字体分析
```
H1标题: <字号>px / <字重>
H2标题: <字号>px / <字重>
正文: <字号>px / Regular
辅助文字: <字号>px
字体族: <如可识别，否则写"系统默认">
```

### 间距分析
```
页面边距: <值>px
组件间距: <值>px
内边距: <常用值>px
圆角: <常用值>px
```

### 组件识别

逐一检查以下组件是否存在，并记录其样式：
- [ ] 顶部导航栏 (Header/Navbar)
- [ ] 侧边菜单 (Sidebar)
- [ ] 面包屑 (Breadcrumb)
- [ ] 主按钮 / 次要按钮
- [ ] 输入框 (Input)
- [ ] 下拉选择 (Select)
- [ ] 数据表格 (Table)
- [ ] 卡片 (Card)
- [ ] 标签/徽章 (Tag/Badge)
- [ ] 模态弹窗 (Modal)
- [ ] 加载状态 (Loading)
- [ ] 空状态 (Empty State)
- [ ] 分页 (Pagination)
- [ ] 表单 (Form)
- [ ] 图表 (Chart)

## 步骤 4：生成统一设计规范

分析完所有图片后，合并为统一的设计 token，保存到 `docs/design/extracted/design-spec.md`：

```markdown
# 设计规范 (Design Spec)
生成时间: <日期>
来源图片: <文件列表>
整体质量: <A/B/C>

## 颜色 Token
--color-primary: #xxxxxx
--color-primary-hover: #xxxxxx
--color-secondary: #xxxxxx
--color-background: #xxxxxx
--color-surface: #xxxxxx
--color-text-primary: #xxxxxx
--color-text-secondary: #xxxxxx
--color-border: #xxxxxx
--color-success: #52C41A
--color-warning: #FAAD14
--color-error: #FF4D4F

## 字体系统
--font-size-xs: 12px
--font-size-sm: 14px
--font-size-md: 16px
--font-size-lg: 20px
--font-size-xl: 24px
--font-size-2xl: 32px
--font-weight-regular: 400
--font-weight-medium: 500
--font-weight-bold: 700

## 间距系统
--spacing-xs: 4px
--spacing-sm: 8px
--spacing-md: 16px
--spacing-lg: 24px
--spacing-xl: 32px
--spacing-2xl: 48px

## 圆角
--radius-sm: 4px
--radius-md: 8px
--radius-lg: 12px
--radius-full: 9999px

## 阴影
--shadow-sm: 0 1px 2px rgba(0,0,0,0.05)
--shadow-md: 0 4px 6px rgba(0,0,0,0.07)
--shadow-lg: 0 10px 15px rgba(0,0,0,0.1)

## 页面列表
<每个页面的路由、布局、主要组件清单>

## 组件规范
<每个识别到的组件的详细规范>

## 推断和假设说明
<所有做了推断或假设的地方>
```

## 步骤 5：更新 features.json

检查 features.json，为设计中识别的每个页面添加对应的前端功能（如尚未存在）。

将 `design_assets.processed` 更新为 `true`，填写 `files` 列表。

## 步骤 6：输出解析报告

```
=== 设计解析完成 ===

【分析了 N 张设计图】
- <图片1>: <页面名> — 质量: <等级>
- <图片2>: <页面名> — 质量: <等级>

【提取的页面列表】
1. <页面名> — <路由> — <主要功能>
2. ...

【设计规范已保存至】
docs/design/extracted/design-spec.md

【新增/确认的前端功能】
- FEAT-xxx: <页面功能>
- ...

【设计稿中的问题/缺失】
- <问题>: <如何处理>

【推断和假设（请用户确认）】
- <颜色推断>: 使用了 <色值>，原因: <图片质量级别>
- <布局推断>: ...

====================
```

## 特殊情况

**极差质量图片：** 不说"无法分析"，而是描述能看到的所有信息，对不确定部分用 Ant Design 标准填补，并标注"推断值"。

**纯文字描述（无图片）：** 根据应用类型选择设计系统（管理后台→Ant Design，用户产品→Material Design），生成符合该设计系统的 token。
