# 技能：process-design — 设计解析

将用户提供的粗糙设计稿（截图/图片/Figma 导出）解析为结构化设计规范。

## 前提条件

用户已在以下位置提供设计文件：
- `docs/design/assets/` — 图片文件
- 或直接在对话中发送的图片

## Step 0：读取设计解读指南

必须先读取 `docs/design/DESIGN_INTAKE.md`，了解 A/B/C/D 四级处理规则。

## Step 1：定位设计文件

```bash
ls docs/design/assets/
```

列出所有图片文件，按文件名排序，推断页面名称。

**若用户提供了 Figma 链接：**
```
Claude Code 无法直接访问 Figma 链接。
请在 Figma 中选中画框 → 右键 → Export → PNG（2x 分辨率）
将导出的图片放入 docs/design/assets/ 目录，然后重新运行 /process-design
```

## Step 2：评估每张图片的质量级别

- **A 级**：精确的 Figma 导出，文字清晰，颜色准确
- **B 级**：普通截图，整体清晰，细节略模糊
- **C 级**：拍照所得，分辨率低，高度压缩
- **D 级**：无图片，仅文字描述

## Step 3：逐图分析

对每张图片，按以下框架分析：

### 页面级别
```
页面名称：<推断的页面名>
页面路由：/<路径>
页面用途：<功能用途>
质量级别：A / B / C
```

### 颜色分析（遵循 DESIGN_INTAKE.md 对应级别规则）
```
主色：#xxxxxx
辅色：#xxxxxx
背景色：#xxxxxx
卡片背景：#xxxxxx
主文字：#xxxxxx
次文字：#xxxxxx
边框：#xxxxxx
成功：#xxxxxx
警告：#xxxxxx
错误：#xxxxxx
```

### 字体分析
```
H1 标题：<大小>px / <字重>
H2 标题：<大小>px / <字重>
正文：<大小>px / Regular
辅助文字：<大小>px
字体族：<若可识别，否则写"系统默认">
```

### 间距分析
```
页面边距：<值>px
组件间距：<值>px
内边距：<常用值>px
圆角：<常用值>px
```

### 组件识别

检查以下每个组件是否存在并记录其样式：
- [ ] 顶部导航栏（Header/Navbar）
- [ ] 侧边菜单（Sidebar）
- [ ] 面包屑
- [ ] 主按钮 / 次按钮
- [ ] 输入框
- [ ] 下拉选择
- [ ] 数据表格
- [ ] 卡片
- [ ] 标签 / 徽章
- [ ] 弹窗
- [ ] 加载状态
- [ ] 空状态
- [ ] 分页
- [ ] 表单
- [ ] 图表

## Step 4：生成统一设计规范

分析所有图片后，合并为统一的设计令牌，保存到 `docs/design/extracted/design-spec.md`：

```markdown
# 设计规范
生成时间：<日期>
来源图片：<文件列表>
整体质量：<A/B/C>

## 颜色令牌
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
<每个页面的路由、布局模式和主要组件列表>

## 组件规范
<每个识别出组件的详细规范>

## 推断与假设
<所有进行了推断或假设的地方>
```

## Step 5：更新功能文件

检查 `features/` 目录下已有的功能文件，为设计中识别的每个页面新增对应的前端功能文件 `features/FEAT-XXX.json`（若不存在）。

同步更新 `features.json`：
- 将 `design_assets.processed` 更新为 `true`，填写 `files` 列表
- 更新 `summary.total` 和 `summary.pending` 计数

## Step 6：输出解析报告

```
=== 设计解析完成 ===

【已分析 N 张设计图】
- <图片 1>：<页面名> — 质量：<级别>
- <图片 2>：<页面名> — 质量：<级别>

【已提取页面列表】
1. <页面名> — <路由> — <主要功能>
2. ...

【设计规范已保存至】
docs/design/extracted/design-spec.md

【新增/确认的前端功能】
- FEAT-xxx：<页面功能>
- ...

【设计稿中的问题/缺失元素】
- <问题>：<处理方式>

【推断与假设（请确认）】
- <颜色推断>：使用了 <颜色值>，原因：<图片质量级别>
- <布局模式推断>：...

====================
```

## 特殊情况

**图片质量极差：** 不得说"无法分析"。描述所有可见信息，不确定的部分用 Ant Design 标准填充，并标注为"推断值"。

**仅有文字描述（无图片）：** 根据应用类型选择设计系统（管理后台 → Ant Design，消费端产品 → Material Design），生成符合该设计系统的令牌。
