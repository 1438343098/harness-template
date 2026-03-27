# 技能：delegate-subagent — 并行功能分发

将多个独立功能分发给并行子 Agent 同时实现，缩短总开发时间。

**触发方式：** `/delegate-subagent [可选数量，默认 3]`

**适用条件：**
- features.json 中有 2 个以上互相独立（无未完成依赖）的 pending 功能
- 这些功能分属不同的 app/service（天然的文件级隔离）
- 用户希望加快开发进度

---

## Step 1：读取当前状态

```bash
# 读取元数据和 summary
cat features.json
cat agents.json
cat user-preferences.json

# 读取所有功能详情，筛选 pending 状态
for f in features/*.json; do cat "$f"; echo "---"; done
```

提取：
- 所有 `status: pending` 的功能
- agents.json 中已处于 `running` 状态的功能 ID（排除这些）
- 已确认的用户偏好（直接写入子 Agent 的 prompt）

---

## Step 2：筛选可并行的候选功能

**筛选条件（须全部满足）：**

1. `status: pending`
2. `dependencies` 中所有功能的 `status` 均为 `done`
3. 不在 agents.json 的 `running` 列表中
4. **每个 `app` 最多选 1 个功能**（同一 app 内的功能通常存在隐式文件依赖）

**排序：** 按 `priority` 升序排列（数字越小优先级越高）

**数量：** 取前 N 个，N = min(参数值, `agents.json.max_parallel`, 候选数量)

若候选功能不足 2 个，停止并显示：
```
候选功能不足，无法进行并行分发。
当前可并行的独立 pending 功能：<N> 个
建议：直接使用 /implement-feature <FEAT-ID>
```

---

## Step 3：注册到 agents.json

为每个候选功能在 `agents.json` 的 `agents` 数组中写入：

```json
{
  "id": "agent-<YYYYMMDD>-<index>",
  "feature_id": "<FEAT-ID>",
  "app": "<app 字段值>",
  "title": "<功能标题>",
  "status": "running",
  "started_at": "<当前 ISO 8601>",
  "completed_at": null,
  "error": null
}
```

同时将 `active_session` 更新为当前时间戳，`last_updated` 更新为当前时间。

---

## Step 4：查找每个功能的项目信息

从 `features.json` 的 `projects.apps` 和 `projects.services` 中，通过功能的 `app` 字段找到对应项目的：
- `path`（代码将写入的目录）
- `tech_stack`（技术栈）
- `language`（编程语言，services 类型适用）

---

## Step 5：为每个子 Agent 构建独立 Prompt

每个子 Agent 的 Prompt 必须完全自包含（子 Agent 没有当前会话的上下文）。

**Prompt 模板：**

```
你是一个专注于实现单个功能的子 Agent。实现完成后，请以结构化格式将结果返回给 Orchestrator。不得修改任何状态文件。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
你的任务
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
实现功能：<FEAT-ID> — <标题>
项目：<app>  路径：<path>
技术栈：<tech_stack>
语言：<language（如适用）>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
功能详情
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
描述：<description>

验收标准：
<逐行列出 acceptance_criteria>

备注：<notes>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
资源位置
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
设计规范：docs/design/extracted/design-spec.md（文件存在时读取）
需求文档：docs/prd/（需要背景上下文时）

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
已确认的用户偏好（直接使用，无需询问）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
<列出 user-preferences.json 中所有 confirmed: true 的偏好>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
代码规范
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- 每个文件必须以注释开头：@feature <FEAT-ID>，@created <日期>
- 函数不得超过 50 行
- 不得硬编码密钥或密码
- 错误必须处理；不允许静默失败
- <例如 TypeScript：禁用 any 类型>
- <例如 Python：使用 snake_case>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
文件隔离约束（严格执行）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
只可在 <path>/ 目录下创建/修改文件。
严禁向其他项目目录写入任何内容。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
禁止操作
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- 不得修改 features.json（索引文件）
- 不得修改 features/FEAT-XXX.json（功能文件）
- 不得修改 agents.json
- 不得修改 .claude/progress/ 下的任何文件
- 不得修改 user-preferences.json
- 不得修改属于其他功能目录的文件

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
完成后按以下格式返回结果（仅此格式，不输出其他内容）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RESULT:
feature_id: <FEAT-ID>
success: true | false
files_created:
  - <文件路径> — <用途>
files_modified:
  - <文件路径> — <改了什么>
acceptance_verified:
  - [✅/❌] <验收标准 1>
  - [✅/❌] <验收标准 2>
issues: <遇到的问题，若无则写 "none">
notes: <给 Orchestrator 的备注，若无则写 "none">
```

---

## Step 6：并行分发子 Agent

**在单条消息中同时启动所有子 Agent 调用（不等一个完成再启动下一个）。**

使用 Claude Code 的 Agent 工具分别调用每个候选功能，使其并行执行。

等所有子 Agent 返回后再进行 Step 7。

---

## Step 7：汇总结果并回写状态

遍历每个子 Agent 返回的结果：

**成功（success: true）：**
- 更新 `features/FEAT-XXX.json`：`status → done`，填写 `completed_at`
- 更新 `agents.json` 中对应条目：`status → done`，填写 `completed_at`

**失败（success: false）：**
- 更新 `features/FEAT-XXX.json`：`status → pending`（回滚），在 `notes` 中追加错误原因
- 更新 `agents.json` 中对应条目：`status → failed`，填写 `error`

更新 `features.json` 中 `summary` 的计数。

---

## Step 8：写入进度日志

在 `.claude/progress/sessions/<YYYY-MM-DD>.session.md` 中追加：

```markdown
## 并行批次 <ISO 8601>
并行数量：<N>

### 批次结果
<列出每个功能的结果>

### 创建文件汇总
<所有子 Agent 创建/修改文件的合并列表>

### 失败功能
<若有失败，列出原因；否则写"无">
```

更新 `.claude/progress/index.json` 的统计数据。

---

## Step 9：输出并行执行报告

```
=== 并行执行完成 ===

【批次结果】（共 N 个）
✅ FEAT-003：<标题> — 已完成（3 个文件）
✅ FEAT-005：<标题> — 已完成（5 个文件）
❌ FEAT-007：<标题> — 失败（原因：<原因>，已回滚为 pending）

【下一步】
剩余 pending 功能：<N> 个
建议：/delegate-subagent（继续并行）或 /implement-feature FEAT-XXX（单个实现）
====================
```

---

## 并行约束参考

| 可以并行 | 不建议并行 |
|---------|-----------|
| 属于不同 app 的功能（apps/web vs services/api） | 同一 app 内的多个功能 |
| 互相无依赖的功能 | 有依赖关系的功能（先实现依赖） |
| 纯前端 + 纯后端功能 | 都涉及共享类型/接口定义的功能 |
| 独立页面 + 独立 API | 都需要修改同一配置文件的功能 |

---

## 紧急中止

若用户在并行执行期间中断（Ctrl+C 或关闭终端）：

下次 `/session-start` 将检测到 agents.json 中的 `running` 条目，自动提示：
```
⚠️ 检测到上次会话遗留的未完成并行任务：
  - FEAT-003（运行自 <时间>）
  - FEAT-005（运行自 <时间>）
建议：检查这些功能在代码文件中是否有部分实现，再决定是重新实现还是手动补全。
```
