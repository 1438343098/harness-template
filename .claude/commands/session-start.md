# 技能: session-start — 会话初始化

执行以下步骤，向用户汇报项目状态并制定本次会话计划。

## 步骤 0：读取用户偏好

```bash
cat user-preferences.json
```

提取所有 `confirmed: true` 的偏好，本次会话中所有相关决策直接使用这些默认值，不再询问。

---

## 步骤 1：读取进度日志

```bash
tail -80 claude-progress.txt
```

如果文件不存在或没有 SESSION END 记录，说明这是第一次会话。

## 步骤 2：读取功能状态

```bash
cat features.json
```

解析并分类：
- `in_progress` 功能列表（遗留任务，优先处理）
- `pending` 功能列表（按 priority 排序）
- `done` 功能数量

## 步骤 2.5：检查并行任务遗留状态

```bash
cat agents.json
```

检查 `agents` 数组中是否有 `status: running` 的条目：

**如果有 running 条目：**

说明上次会话在并行执行中途中断。对每个 running 条目：

```
检查 features.json 中对应功能的状态：

情况A: features.json 中该功能是 done
→ 子 Agent 完成了但 Orchestrator 没来得及清理 agents.json
→ 直接将 agents.json 中该条目 status 改为 done
→ 无需重新实现

情况B: features.json 中该功能是 in_progress
→ 状态不一致，子 Agent 中途中断
→ 将 features.json 中该功能重置为 pending，清空 started_at
→ 将 agents.json 中该条目 status 改为 failed，error 写"会话中断"
→ 在会话简报中展示警告

情况C: features.json 中该功能是 pending
→ agents.json 未及时注册就中断了
→ 直接将 agents.json 中该条目 status 改为 failed
```

**如果没有 running 条目：** 继续下一步，无需处理。

## 步骤 3：检查文档准备情况

```bash
ls docs/prd/
ls docs/design/assets/
ls docs/design/extracted/
```

识别：
- `docs/prd/` 是否有用户需求文档且尚未解析（features.json 为空）
- `docs/design/assets/` 是否有设计图片且 `extracted/` 下没有 design-spec.md

## 步骤 3.5：读取项目注册表

```bash
cat features.json
```

提取 `projects.apps` 和 `projects.services`，了解当前有哪些子项目。

## 步骤 4：输出会话简报

按以下格式输出：

```
=== 会话简报 ===
日期: <今天日期>

【用户偏好（已学习的默认值）】
<列出所有 confirmed 偏好，如无则写"暂无，将在本次会话中学习">

【项目列表】
前端 apps/:
  - <APP-id>: <name> (<tech_stack>) — <path>
后端 services/:
  - <SVC-id>: <name> (<language>/<tech_stack>) — <path>
（如项目列表为空，提示运行 /process-requirements 来注册项目）

【已完成】
共 <N> 个功能已完成
上次会话: <claude-progress.txt 中最后一次 SESSION END 的摘要，如没有则写"首次会话">

【上次并行任务遗留】（如有中断的并行任务）
⚠️ <FEAT-ID>: <标题> — 状态已重置为 pending，需重新实现

【进行中（需优先处理）】
<列出所有 in_progress 功能（含所属项目），如没有则写"无">

【待处理队列】
功能: 下一个 FEAT-XXX（<所属项目>）— <标题>
变更: 下一个 CHANGE-XXX — <标题>
队列中还有 <N> 个功能，<M> 个变更请求

【文档状态】
需求文档: <已解析 / 待解析（请运行 /process-requirements）>
设计规范: <已提取 / 待提取（请运行 /process-design）>

【本次计划】
1. <具体计划>
2. <后续步骤>
================
```

## 步骤 5：等待用户确认

询问用户是否有变更或新输入。如果没有，按计划继续。

## 注意事项

- 有 `in_progress` 功能时，必须优先恢复，不得开始新功能
- `features.json` 为空时，提示用户运行 `/process-requirements`
- `docs/design/assets/` 有图片但没有 `extracted/design-spec.md` 时，提示运行 `/process-design`
