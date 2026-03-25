# frontend/ 目录导航 — AGENTS.md

> 前端应用代码目录。技术栈在 `features.json` 的 `project.tech_stack.frontend` 中定义。

---

## 推荐目录约定

> 技术栈确定后 Claude Code 会创建实际结构。以下为参考约定。

```
frontend/
├── AGENTS.md
├── src/
│   ├── components/     # 可复用 UI 组件（无状态）
│   ├── pages/          # 页面组件（有状态，一文件一路由）
│   ├── layouts/        # 布局组件
│   ├── hooks/          # 自定义 Hooks（React 项目）
│   ├── services/       # API 调用封装
│   ├── store/          # 状态管理
│   ├── utils/          # 工具函数
│   ├── styles/
│   │   └── tokens.css  # 设计 token（来自 design-spec.md）
│   └── types/          # TypeScript 类型定义
├── public/
└── package.json
```

---

## 设计 Token 引用规范

所有颜色、间距、字体必须使用 CSS 变量（来自 `docs/design/extracted/design-spec.md`）：

```css
/* ✅ 正确 */
.btn-primary {
  background-color: var(--color-primary);
  padding: var(--spacing-sm) var(--spacing-md);
  border-radius: var(--radius-md);
}

/* ❌ 错误 — 禁止硬编码样式值 */
.btn-primary {
  background-color: #1677FF;
  padding: 8px 16px;
}
```

---

## 代码规范

**文件命名：**
- 组件：`PascalCase.tsx`（如 `UserCard.tsx`）
- 页面：`kebab-case.tsx`（如 `user-list.tsx`）
- 工具：`camelCase.ts`（如 `formatDate.ts`）

**组件结构顺序：**
1. 导入
2. 类型定义
3. 组件实现
4. 样式（如使用 CSS Modules）
5. 默认导出

**API 调用必须包含：**
- 加载状态处理
- 错误状态处理
- 超时处理（默认 10 秒）

---

## 查看前端功能状态

```bash
cat features.json | grep -A8 '"type": "frontend"'
```

---

*更新: 2026-03-25 | 技术栈确定后此文件会更新*
