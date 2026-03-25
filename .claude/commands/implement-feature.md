# 技能: implement-feature — 功能实现

实现 features.json 中指定的单个功能。

**使用方式：** `/implement-feature FEAT-001`

## 步骤 0：查询用户偏好

```bash
cat user-preferences.json
```

提取所有 `confirmed: true` 的偏好。实现过程中需要做技术选型时，优先使用这些默认值，不再询问用户。

---

## 步骤 1：读取功能信息

```bash
cat features.json
```

提取目标功能的：`title`、`description`、`type`、`app`（所属项目）、`acceptance_criteria`、`dependencies`、`notes`

根据 `app` 字段，在 `features.json` 的 `projects` 中找到对应项目的 `path` 和 `tech_stack`，代码放置到该项目目录下。

## 步骤 2：检查依赖项

检查 `dependencies` 列表中每个功能 ID 的状态。

如果有依赖未完成（非 `done`），停止并报告：
```
[阻塞] 功能 <ID> 依赖 <依赖ID>（<依赖标题>）尚未完成
建议先实现: /implement-feature <依赖ID>
```

## 步骤 3：读取设计规范

```bash
cat docs/design/extracted/design-spec.md
```

定位该功能对应的页面/组件设计规范。

## 步骤 4：将功能状态改为 in_progress

更新 `features.json` 中该功能的 `status` 为 `in_progress`，填写 `started_at`。

在 `claude-progress.txt` 追加：
```
[FEAT-XXX] START: <功能标题> — <时间>
```

## 步骤 5：输出实现计划（等待用户确认）

```
=== 实现计划: FEAT-XXX <功能标题> ===

类型: <frontend / backend / fullstack / infra>
预计步骤:
1. <步骤1>
2. <步骤2>
...

将创建/修改的文件:
- <文件路径> — <用途>
- ...

验收标准:
- <标准1>
- <标准2>
```

如果用户说"继续"或"OK"或不反对，立即开始实现。

## 步骤 6：实现代码

### 文件头部注释（必须）

```javascript
/**
 * @feature FEAT-XXX: <功能标题>
 * @module <模块名>
 * @created <日期>
 * @description <简短描述>
 */
```

### 实现顺序

**后端 (type: backend)**：
1. 数据模型 / Schema 定义
2. 数据库迁移（如需）
3. 业务逻辑层（Service）
4. API 路由/控制器
5. 输入验证
6. 错误处理

**前端 (type: frontend)**：
1. 读取 `docs/design/extracted/design-spec.md` 中对应页面/组件规范
2. 创建 CSS 变量文件（引用设计 token）
3. 基础 UI 组件（无状态）
4. 页面组件（有状态，连接数据）
5. 路由配置
6. API 集成

**全栈 (type: fullstack)**：先后端，后前端。

**基础设施 (type: infra)**：
1. 配置文件
2. 中间件/插件
3. 环境变量模板更新

### 每创建一个文件后，追加进度日志

```
[FEAT-XXX] FILE: <文件路径> — <文件用途>
```

## 步骤 7：运行验证

```bash
# 前端
npm run build 2>&1 | tail -20

# 后端 (Node.js)
node -e "require('./src/app')" 2>&1

# 后端 (Python)
python -m py_compile <文件路径> 2>&1
```

如果验证失败，必须修复后才能继续。

## 步骤 8：更新功能状态为 done

更新 `features.json`：
- `status`: `done`
- `completed_at`: 当前时间

在 `claude-progress.txt` 追加：
```
[FEAT-XXX] DONE: <功能标题> — <时间>
  验收:
  ✅ <验收标准1>
  ✅ <验收标准2>
  文件:
  - <文件路径>
```

## 步骤 9：输出完成报告

```
=== 功能完成: FEAT-XXX <功能标题> ===

✅ 所有验收标准已通过

【创建的文件】
- <路径>: <用途>

【修改的文件】
- <路径>: <内容>

【注意事项】
<使用此功能时需注意的事项>

【下一步推荐】
下一个待实现功能: FEAT-XXX <标题> (priority: X)
运行: /implement-feature FEAT-XXX
```

## 常见情况处理

| 情况 | 处理 |
|------|------|
| 依赖未完成 | 停止，提示先实现依赖 |
| 设计规范缺失 | 使用 Ant Design / Material Design 标准暂代，注明 |
| 技术栈未确定 | 询问用户，记录到 features.json notes |
| 构建失败 | 必须修复，不允许跳过 |
| 需求模糊 | 使用 notes 中的默认假设完成，完成后说明 |
