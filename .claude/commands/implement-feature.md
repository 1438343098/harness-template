# 技能：implement-feature — 功能实现

实现 features.json 中指定的单个功能。

**用法：** `/implement-feature FEAT-001`

## Step 0：查询用户偏好

```bash
cat user-preferences.json
```

提取所有 `confirmed: true` 的偏好。实现过程中的技术选型直接使用这些默认值，无需再次询问用户。

---

## Step 1：读取功能信息

```bash
cat features.json
```

提取目标功能的：`title`、`description`、`type`、`app`（所属项目）、`acceptance_criteria`、`dependencies`、`notes`

通过 `app` 字段，在 `features.json` 的 `projects` 中找到对应项目的 `path` 和 `tech_stack`，将代码放在该项目目录下。

## Step 2：检查依赖

检查 `dependencies` 列表中每个功能 ID 的状态。

若有依赖未完成（未达到 `done`），停止并汇报：
```
[BLOCKED] 功能 <ID> 依赖 <依赖 ID>（<依赖标题>），该依赖尚未完成
建议：先通过 /implement-feature <依赖 ID> 实现
```

## Step 3：读取设计规范

```bash
cat docs/design/extracted/design-spec.md
```

找到本功能对应的页面/组件设计规范。

## Step 4：将功能状态改为 in_progress

在 `features.json` 中将该功能的 `status` 改为 `in_progress`，并填写 `started_at`。

在 `claude-progress.txt` 中追加：
```
[FEAT-XXX] START: <功能标题> — <时间>
```

## Step 5：输出实现计划（等待用户确认）

```
=== 实现计划：FEAT-XXX <功能标题> ===

类型：<frontend / backend / fullstack / infra>
预计步骤：
1. <步骤 1>
2. <步骤 2>
...

待创建/修改的文件：
- <文件路径> — <用途>
- ...

验收标准：
- <标准 1>
- <标准 2>
```

若用户回复"继续"、"OK"或没有反对意见，立即开始实现。

## Step 6：实现代码

### 文件头部注释（必须）

```javascript
/**
 * @feature FEAT-XXX: <功能标题>
 * @module <模块名>
 * @created <日期>
 * @description <简要描述>
 */
```

### 实现顺序

**后端（type: backend）：**
1. 数据模型 / Schema 定义
2. 数据库迁移（如需要）
3. Service 层
4. API 路由/控制器
5. 输入校验
6. 错误处理

**前端（type: frontend）：**
1. 读取 `docs/design/extracted/design-spec.md` 中对应的页面/组件规范
2. 创建 CSS 变量文件（引用设计令牌）
3. 基础 UI 组件（无状态）
4. 页面组件（有状态，连接数据）
5. 路由配置
6. API 集成

**全栈（type: fullstack）：** 先实现后端，再实现前端。

**基础设施（type: infra）：**
1. 配置文件
2. 中间件/插件
3. 更新环境变量模板

### 每创建一个文件后，追加进度日志

```
[FEAT-XXX] FILE: <文件路径> — <文件用途>
```

## Step 7：运行校验

```bash
# 前端
npm run build 2>&1 | tail -20

# 后端（Node.js）
node -e "require('./src/app')" 2>&1

# 后端（Python）
python -m py_compile <文件路径> 2>&1
```

校验失败必须修复，不可跳过。

## Step 8：将功能状态更新为 done

更新 `features.json`：
- `status`：`done`
- `completed_at`：当前时间

在 `claude-progress.txt` 中追加：
```
[FEAT-XXX] DONE: <功能标题> — <时间>
  验收：
  ✅ <验收标准 1>
  ✅ <验收标准 2>
  文件：
  - <文件路径>
```

## Step 9：输出完成报告

```
=== 功能完成：FEAT-XXX <功能标题> ===

✅ 所有验收标准通过

【已创建文件】
- <路径>：<用途>

【已修改文件】
- <路径>：<改了什么>

【注意事项】
<使用此功能时需注意的事项>

【推荐下一步】
下一个 pending 功能：FEAT-XXX <标题>（优先级：X）
运行：/implement-feature FEAT-XXX
```

## 常见情况

| 情况 | 处理方式 |
|------|---------|
| 依赖未完成 | 停止，提示先实现依赖 |
| 设计规范缺失 | 使用 Ant Design / Material Design 标准作为占位，并注明 |
| 技术栈未定 | 询问用户，记录在 features.json 的 notes 中 |
| 构建失败 | 必须修复；不允许跳过 |
| 需求模糊 | 按默认假设完成，在 notes 中说明，之后解释 |
