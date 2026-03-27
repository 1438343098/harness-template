# 技能：session-start — 会话初始化

执行以下步骤，向用户汇报项目状态并为本次会话制定计划。

## Step 0：读取用户偏好

```bash
cat user-preferences.json
```

提取所有 `confirmed: true` 的偏好。本次会话中所有相关决策，直接使用这些默认值，无需再次询问。

---

## Step 1：读取进度日志

```bash
# 1. 读取索引，找到最新会话文件
cat .claude/progress/index.json

# 2. 读取最新会话文件（latest_session 字段对应的文件）
cat .claude/progress/sessions/<latest_session>.session.md

# 3. 若存在多个近期会话，也读取前一个以获取完整上下文
```

若 `.claude/progress/sessions/` 下没有文件，则为首次会话。

## Step 2：读取功能状态

```bash
# 读取功能索引（摘要和元数据）
cat features.json

# 读取所有功能详情
ls features/*.json 2>/dev/null && for f in features/*.json; do cat "$f"; echo "---"; done
```

解析并分类：
- `in_progress` 功能列表（遗留任务，优先处理）
- `pending` 功能列表（按优先级排序）
- `done` 功能数量

## Step 2.5：检查并行任务遗留状态

```bash
cat agents.json
```

检查 `agents` 数组中是否存在 `status: running` 的条目：

**若存在 running 条目：**

说明上一次会话在并行执行中途被中断。对每个 running 条目：

```
检查 features.json 中对应功能的状态：

情况 A：features.json 中该功能为 done
→ 子 Agent 已完成，但 Orchestrator 未来得及清理 agents.json
→ 直接将该条目状态改为 done
→ 无需重新实现

情况 B：features.json 中该功能为 in_progress
→ 状态不一致，子 Agent 在实现途中被中断
→ 将 features.json 中该功能重置为 pending，清空 started_at
→ 将 agents.json 中该条目状态改为 failed，error 设为 "session interrupted"
→ 在会话简报中显示警告

情况 C：features.json 中该功能为 pending
→ 在中断前 agents.json 尚未来得及注册
→ 直接将该条目状态改为 failed
```

**若无 running 条目：** 继续下一步，无需操作。

## Step 3：检查文档就绪状态

```bash
ls docs/prd/
ls docs/design/assets/
ls docs/design/extracted/
```

识别：
- `docs/prd/` 是否有尚未解析的用户需求文档（`features/*.json` 为空）
- `docs/design/assets/` 是否有设计图，且 `extracted/` 中尚无 design-spec.md

## Step 3.5：读取项目注册表

提取 `features.json` 中的 `projects.apps` 和 `projects.services`，了解当前存在哪些子项目。

## Step 4：输出会话简报

按以下格式输出：

```
=== 会话简报 ===
日期：<今天的日期>

【用户偏好（已学习的默认值）】
<列出所有 confirmed 的偏好，若为空则写"暂无，本次会话将开始学习">

【项目列表】
前端 apps/:
  - <APP-id>：<名称>（<技术栈>）— <路径>
后端 services/:
  - <SVC-id>：<名称>（<语言>/<技术栈>）— <路径>
（若项目列表为空，提示用户运行 /process-requirements 注册项目）

【已完成】
共完成 <N> 个功能
上次会话：<最新 .claude/progress/sessions/ 会话文件的摘要，若无则写"首次会话">

【并行任务遗留】（若有被中断的并行任务）
⚠️ <FEAT-ID>：<标题> — 状态已重置为 pending，需重新实现

【进行中（优先处理）】
<列出所有 in_progress 功能（含所属项目），若无则写"无">

【待处理队列】
功能：下一个 FEAT-XXX（<项目>）— <标题>
变更：下一个 CHANGE-XXX — <标题>
队列中还有 <N> 个功能和 <M> 个变更请求

【文档状态】
需求文档：<已解析 / 待处理（运行 /process-requirements）>
设计规范：<已提取 / 待处理（运行 /process-design）>

【本次会话计划】
1. <具体计划>
2. <后续步骤>
================
```

## Step 5：等待用户确认

询问用户是否有任何变更或新输入。若无，按计划执行。

## 注意事项

- 存在 `in_progress` 功能时，必须优先续做 — 不得开启新功能
- `features/` 目录为空（无 `*.json` 文件）时，提示用户运行 `/process-requirements`
- `docs/design/assets/` 有图片但无 `extracted/design-spec.md` 时，提示用户运行 `/process-design`
