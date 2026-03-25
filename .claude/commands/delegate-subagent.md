# 技能: delegate-subagent — 并行功能调度

将多个独立功能分配给并行子 Agent 同时实现，缩短总开发时间。

**触发方式：** `/delegate-subagent [数量可选，默认3]`

**适用条件：**
- features.json 中有 2 个以上互相独立（无未完成的依赖）的 pending 功能
- 这些功能属于不同的 app/service（文件级天然隔离）
- 用户想加速开发节奏

---

## 步骤 1：读取当前状态

```bash
cat features.json
cat agents.json
cat user-preferences.json
```

提取：
- 所有 `status: pending` 的功能
- agents.json 中已 `running` 的功能 ID（排除这些）
- 用户已 confirmed 的偏好（子 Agent prompt 中直接使用）

---

## 步骤 2：筛选可并行的候选功能

**过滤条件（全部满足才能入选）：**

1. `status: pending`
2. `dependencies` 中所有功能都是 `status: done`
3. 不在 agents.json 的 `running` 列表中
4. **同一 `app` 最多选 1 个**（同 app 内的功能常有隐式文件依赖）

**排序：** 按 `priority` 升序（数字越小越优先）

**数量：** 取前 N 个，N = min(参数, `agents.json.max_parallel`, 候选数量)

如果候选功能不足 2 个，停止并提示：
```
候选功能不足，无需并行调度。
当前可并行的独立 pending 功能: <N> 个
建议直接使用 /implement-feature <FEAT-ID>
```

---

## 步骤 3：注册到 agents.json

在 `agents.json` 的 `agents` 数组中为每个候选功能写入：

```json
{
  "id": "agent-<YYYYMMDD>-<序号>",
  "feature_id": "<FEAT-ID>",
  "app": "<app字段值>",
  "title": "<功能标题>",
  "status": "running",
  "started_at": "<当前 ISO 8601>",
  "completed_at": null,
  "error": null
}
```

同时更新 `active_session` 为当前时间戳，`last_updated` 为当前时间。

---

## 步骤 4：查找每个功能的项目信息

从 `features.json` 的 `projects.apps` 和 `projects.services` 中，
根据功能的 `app` 字段，找到对应项目的：
- `path`（代码写入目录）
- `tech_stack`（技术栈）
- `language`（编程语言，services 类型）

---

## 步骤 5：为每个子 Agent 构造独立 Prompt

每个子 Agent 的 prompt 必须完全自包含（子 Agent 没有当前会话上下文）。

**Prompt 模板：**

```
你是专注于单个功能实现的子 Agent。在实现完成后，将结果以结构化格式返回给 Orchestrator，不要修改任何状态文件。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
你的任务
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
实现功能: <FEAT-ID> — <title>
所属项目: <app> 路径: <path>
技术栈: <tech_stack>
语言: <language（如有）>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
功能详情
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
描述: <description>

验收标准:
<acceptance_criteria 逐条列出>

注意事项: <notes>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
资源位置
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
设计规范: docs/design/extracted/design-spec.md（如文件存在则读取）
需求文档: docs/prd/（如需要了解背景）

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
已确认的用户偏好（直接使用，不要询问）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
<逐条列出 user-preferences.json 中 confirmed: true 的偏好>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
代码规范
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- 每个文件开头必须写注释: @feature <FEAT-ID>, @created <日期>
- 函数不超过 50 行
- 禁止硬编码密钥或密码
- 错误必须处理，不允许 silent fail
- <如 TypeScript: 禁止 any 类型>
- <如 Python: 使用 snake_case>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
文件隔离约束（严格遵守）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
你只能创建/修改 <path>/ 目录下的文件。
严禁写入其他项目目录。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
禁止操作
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- 不要修改 features.json
- 不要修改 agents.json
- 不要修改 claude-progress.txt
- 不要修改 user-preferences.json
- 不要修改其他功能所属目录的文件

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
完成后，以以下格式返回结果（不要有其他内容）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RESULT:
feature_id: <FEAT-ID>
success: true | false
files_created:
  - <文件路径> — <用途>
files_modified:
  - <文件路径> — <修改内容>
acceptance_verified:
  - [✅/❌] <验收标准1>
  - [✅/❌] <验收标准2>
issues: <遇到的问题，如无则写"无">
notes: <给 Orchestrator 的备注，如无则写"无">
```

---

## 步骤 6：并行派发子 Agent

**在同一条消息中同时发起所有子 Agent 调用（不要等一个完成再发下一个）。**

使用 Claude Code 的 Agent 工具，为每个候选功能分别调用，使其并行执行。

等待所有子 Agent 返回后再执行步骤 7。

---

## 步骤 7：收集结果，统一写回状态

遍历每个子 Agent 的返回结果：

**成功（success: true）：**
- 更新 `features.json` 对应功能：`status → done`，填写 `completed_at`
- 更新 `agents.json` 对应条目：`status → done`，填写 `completed_at`

**失败（success: false）：**
- 更新 `features.json` 对应功能：`status → pending`（回滚），`notes` 追加错误原因
- 更新 `agents.json` 对应条目：`status → failed`，填写 `error`

更新 `features.json` 的 `summary` 计数。

---

## 步骤 8：追加进度日志

在 `claude-progress.txt` 末尾追加：

```
================================================================================
PARALLEL BATCH
时间: <ISO 8601>
并行数量: <N>
================================================================================

【批次结果】
<逐条列出每个功能的结果>

【创建的文件汇总】
<所有子 Agent 创建/修改的文件合并列表>

【失败的功能】
<如有失败，列出原因，否则写"无">

================================================================================
```

---

## 步骤 9：输出并行执行报告

```
=== 并行执行完成 ===

【批次结果】（共 N 个）
✅ FEAT-003: <标题> — 完成（3个文件）
✅ FEAT-005: <标题> — 完成（5个文件）
❌ FEAT-007: <标题> — 失败（原因: <原因>，已回滚为 pending）

【下一步】
剩余 pending 功能: <N> 个
建议: /delegate-subagent（继续并行）或 /implement-feature FEAT-XXX（单个实现）
====================
```

---

## 并行约束参考

| 可以并行 | 不建议并行 |
|----------|-----------|
| 不同 app 的功能（apps/web vs services/api） | 同一 app 的多个功能 |
| 无依赖关系的功能 | 有依赖关系的功能（先实现被依赖方） |
| 纯前端 + 纯后端功能 | 都涉及共享 types/interfaces 定义的功能 |
| 独立页面 + 独立 API | 都需要修改同一个配置文件 |

---

## 紧急中止

如果并行执行过程中用户中断（Ctrl+C 或关闭终端）：

下次 `/session-start` 会检测到 agents.json 中的 `running` 条目，自动提示：
```
⚠️ 检测到上次并行任务未完成:
  - FEAT-003 (running since <时间>)
  - FEAT-005 (running since <时间>)
建议: 检查这些功能的代码文件是否存在部分实现，然后决定重新实现还是手动补全。
```
