# 技能: process-iteration — 迭代需求处理

处理对已有功能的变更请求（迭代需求），区别于首次需求解析（`/process-requirements`）。

**触发方式：** `/process-iteration [文件路径可选]`

**适用场景：**
- 修改已实现的功能
- 为现有功能增加新的子功能
- 需求调整（用户反馈后的更改）
- 产品迭代（v1 → v2）

---

## 步骤 1：读取变更内容

检查以下来源：
1. `docs/prd/` 中的新文件（以 `change-`、`iteration-`、`v2-` 等命名的文件）
2. 用户在对话中直接描述的变更

如果用户在对话中描述，先保存到 `docs/prd/iteration-<日期>.md`。

---

## 步骤 2：解析变更类型

对每条变更需求，判断类型：

| 变更类型 | 说明 | 处理方式 |
|----------|------|----------|
| `extend` | 在现有功能基础上新增能力 | 创建子功能 FEAT-XXX-EXT |
| `modify` | 修改现有功能的行为/样式 | 创建 CHANGE-XXX 关联原功能 |
| `replace` | 完全替换某个功能 | 将原功能标记 deprecated，创建新功能 |
| `new` | 全新功能（未在原 features 中） | 正常创建新 FEAT-XXX |
| `remove` | 删除某个功能 | 将原功能标记 removed，清理相关代码 |

---

## 步骤 3：影响分析

对每条变更，分析：

```
变更: <描述>
影响的功能: <FEAT-XXX>
影响的文件: <可能需要修改的代码文件>
影响的功能（依赖链）: <其他依赖此功能的 FEAT-YYY>
设计变更: 是否需要更新 design-spec.md
向后兼容: 此变更是否破坏性变更（影响 API 接口/数据结构）
```

---

## 步骤 4：更新 features.json

### 新增变更记录

在 `features.json` 中添加 `change_requests` 数组（如不存在则创建）：

```json
{
  "change_requests": [
    {
      "id": "CHANGE-001",
      "title": "<变更标题>",
      "type": "extend | modify | replace | new | remove",
      "target_feature": "FEAT-XXX",
      "description": "<变更详细描述>",
      "reason": "<变更原因>",
      "acceptance_criteria": ["<标准1>", "<标准2>"],
      "affected_files": ["<文件路径>"],
      "breaking_change": false,
      "priority": 1,
      "status": "pending",
      "created_at": "<ISO 8601>",
      "started_at": null,
      "completed_at": null
    }
  ]
}
```

### 标记原功能版本

对于 `modify` 类型，在原功能的 `notes` 中追加：
```
变更历史:
  - CHANGE-001 (2026-03-25): <变更摘要>
```

对于 `replace` 类型，更新原功能 `status` 为 `deprecated`。

---

## 步骤 5：输出变更解析报告

```
=== 迭代需求解析完成 ===

【变更清单】（共 N 条）

🔧 CHANGE-001 [modify] FEAT-002 用户登录
   变更: 增加微信/Google 第三方登录
   影响文件: frontend/web/src/pages/login.tsx, services/auth/src/routes/oauth.ts
   破坏性: 否（新增接口，不修改原有接口）

➕ CHANGE-002 [extend] FEAT-005 商品列表
   变更: 支持多维度筛选（价格区间、分类、评分）
   影响文件: services/api/src/routes/products.ts, apps/web/src/components/FilterPanel.tsx
   破坏性: 否

🔄 CHANGE-003 [replace] FEAT-008 支付模块
   变更: 从模拟支付替换为真实支付宝集成
   影响文件: services/payment/（整个目录重写）
   破坏性: 是（API 参数结构变化）
   ⚠️ 原功能 FEAT-008 将被标记为 deprecated

【影响评估】
- 总共影响 <N> 个已有文件
- <N> 个功能受依赖链影响（可能需要联动修改）
- 破坏性变更: <N> 个（需要特别关注）

【建议实现顺序】
1. CHANGE-001（无依赖）
2. CHANGE-003（需先备份 FEAT-008 逻辑）
3. CHANGE-002（依赖 CHANGE-001 完成）

请确认后运行 /implement-feature CHANGE-001 开始实现。
====================
```

---

## 实现变更的注意事项

### modify 类型

在修改现有代码时：
1. 在文件头部注释中追加变更记录：
   ```
   // CHANGE-001 (2026-03-25): <变更摘要>
   ```
2. 保留原有逻辑（注释标注），除非完全替换
3. 优先新增，而非修改（开闭原则）

### replace 类型

1. 先读取原功能代码，理解现有逻辑
2. 创建新实现（可以是新文件）
3. 切换引用
4. 确认新实现工作后，删除旧代码

### breaking_change = true 时

必须：
1. 在 `claude-progress.txt` 中明确标注 `[BREAKING CHANGE]`
2. 列出所有受影响的调用方
3. 提供迁移说明（修改了什么、调用方需要做什么）

---

## 迭代版本管理

当一个功能经历多次迭代时，在 `features.json` 的该功能中维护版本历史：

```json
{
  "id": "FEAT-003",
  "title": "商品详情页",
  "status": "done",
  "version": "v3",
  "version_history": [
    { "version": "v1", "change": "初始实现", "date": "2026-03-01" },
    { "version": "v2", "change": "CHANGE-002: 增加图片轮播", "date": "2026-03-10" },
    { "version": "v3", "change": "CHANGE-007: 增加视频播放", "date": "2026-03-20" }
  ]
}
```
