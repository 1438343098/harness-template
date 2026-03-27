# 技能：session-end — 会话收尾

执行以下步骤，安全结束当前会话并保存状态。

## Step 1：汇总本次会话完成情况

整理本次会话的完成清单：
- 完成了哪些功能（功能 ID + 标题）
- 创建/修改了哪些文件
- 遇到了什么问题或决策
- 哪些内容未完成

## Step 2：更新功能文件

对每个**本次会话涉及的功能**，更新对应的 `features/FEAT-XXX.json`：

**已完成的功能：**
```json
{
  "status": "done",
  "completed_at": "<当前 ISO 8601 时间>",
  "notes": "<完成备注，说明与预期的偏差>"
}
```

**已开始但未完成的功能：**
```json
{
  "status": "in_progress",
  "notes": "<当前进度说明，下次会话的入口点>"
}
```

同步更新 `features.json` 中的 `summary` 字段计数（`total`、`pending`、`in_progress`、`done` 等）。

## Step 3：写入进度会话日志

创建或更新 `.claude/progress/sessions/<YYYY-MM-DD>.session.md`（同一天多次结束则追加内容）：

```markdown
# Session: <YYYY-MM-DD>
**时间**: <YYYY-MM-DD HH:MM>
**状态**: 已完成

## 本次完成
<列出每个已完成的功能，格式：- FEAT-XXX：<标题>>

## 文件变更记录
### 新增
- <文件路径> — <用途>

### 修改
- <文件路径> — <改了什么>

## 遇到的问题
<技术问题、需求不清、设计缺失等，若无则写"无">

## 未完成事项
<列出 in_progress 功能及原因，若无则写"无">

## 下次会话入口
1. <具体的第一步操作>
2. <后续步骤>

## 给下一个 Claude 的备注
<重要背景、决策、注意事项。若无则写"无">

---
**记录者**: Claude Code
**最后更新**: <ISO 8601 时间>
```

然后更新 `.claude/progress/index.json`：
- 在 `sessions` 数组中添加或更新本次会话条目
- 更新 `statistics.total_sessions`
- 更新 `latest_session` 和 `updated_at`

## Step 3.5：触发偏好进化（静默执行）

执行 `/learn-preferences` 逻辑（静默模式，不输出完整报告）：

1. 统计本次会话新增的 `decision_log` 条目数
2. 检查是否有 decision_key 已达到进化阈值（`evolution_threshold`）
3. 若有 → 更新 `user-preferences.json`，将该偏好升级为 `confirmed: true`
4. 若有新进化 → 在输出摘要中添加一行通知用户

---

## Step 4：输出状态摘要

```
✅ 会话已安全结束

已完成功能：<N>
已完成变更：<N>
进行中：<N>（下次会话优先处理）
待处理：<N> 个功能，<M> 个变更请求
进度日志：已更新

【偏好进化】
<若有新进化，列出：✨ 新默认值：<key> = <value>（出现 N 次）>
<若无新进化，写：本次会话无新进化>

下次运行 /session-start 从此处继续。
```

## 必检项

- [ ] 本次会话涉及的所有功能已更新对应的 `features/FEAT-XXX.json`
- [ ] `features.json` 中的 `summary` 计数已同步
- [ ] `.claude/progress/sessions/<YYYY-MM-DD>.session.md` 已写入
- [ ] `.claude/progress/index.json` 已更新
- [ ] 所有 in_progress 功能都有未完成的原因说明
