# 技能：process-iteration — 迭代变更处理

处理已有功能的变更请求（迭代变更），有别于首次需求解析（`/process-requirements`）。

**触发方式：** `/process-iteration [可选文件路径]`

**适用场景：**
- 修改已实现的功能
- 在已有功能基础上新增子功能
- 需求调整（根据用户反馈的变更）
- 产品迭代（v1 → v2）

---

## Step 1：读取变更内容

检查以下来源：
1. `docs/prd/` 中的新文件（文件名含 `change-`、`iteration-`、`v2-` 等）
2. 用户在对话中直接描述的变更

若用户在对话中描述了变更，先保存到 `docs/prd/iteration-<日期>.md`，再处理。

---

## Step 2：解析变更类型

对每个变更请求，判断其类型：

| 变更类型 | 说明 | 处理方式 |
|---------|------|---------|
| `extend` | 在已有功能基础上新增能力 | 创建子功能 FEAT-XXX-EXT |
| `modify` | 修改已有功能的行为/样式 | 创建 CHANGE-XXX 并关联原功能 |
| `replace` | 完全替换某功能 | 将原功能标记为 deprecated，创建新功能 |
| `new` | 全新功能（原功能列表中不存在） | 正常创建新 FEAT-XXX |
| `remove` | 删除某功能 | 将原功能标记为 removed，清理相关代码 |

---

## Step 3：影响分析

对每个变更，分析：

```
变更：<描述>
受影响功能：<FEAT-XXX>
受影响文件：<可能需要修改的代码文件>
受影响功能（依赖链）：<依赖该功能的其他 FEAT-YYY>
设计变更：是否需要更新 design-spec.md
向后兼容：本次变更是否为破坏性变更（影响 API 接口/数据结构）
```

---

## Step 4：更新 features.json

### 添加变更记录

在 `features.json` 中添加 `change_requests` 数组（不存在则创建）：

```json
{
  "change_requests": [
    {
      "id": "CHANGE-001",
      "title": "<变更标题>",
      "type": "extend | modify | replace | new | remove",
      "target_feature": "FEAT-XXX",
      "description": "<详细变更描述>",
      "reason": "<变更原因>",
      "acceptance_criteria": ["<标准 1>", "<标准 2>"],
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
变更历史：
  - CHANGE-001 (2026-03-25)：<变更摘要>
```

对于 `replace` 类型，将原功能的 `status` 改为 `deprecated`。

---

## Step 5：输出变更解析报告

```
=== 迭代变更解析完成 ===

【变更列表】（共 N 个变更）

🔧 CHANGE-001 [modify] FEAT-002 用户登录
   变更：新增微信/Google 第三方登录
   受影响文件：frontend/web/src/pages/login.tsx, services/auth/src/routes/oauth.ts
   破坏性变更：否（新增接口，不修改已有接口）

➕ CHANGE-002 [extend] FEAT-005 商品列表
   变更：支持多维度筛选（价格区间、分类、评分）
   受影响文件：services/api/src/routes/products.ts, apps/web/src/components/FilterPanel.tsx
   破坏性变更：否

🔄 CHANGE-003 [replace] FEAT-008 支付模块
   变更：将模拟支付替换为真实支付宝集成
   受影响文件：services/payment/（整个目录重写）
   破坏性变更：是（API 参数结构变更）
   ⚠️ 原功能 FEAT-008 将被标记为 deprecated

【影响评估】
- 共影响 <N> 个已有文件
- 通过依赖链影响 <N> 个功能（可能需要协同修改）
- 破坏性变更：<N> 个（需特别注意）

【建议实现顺序】
1. CHANGE-001（无依赖）
2. CHANGE-003（先备份 FEAT-008 逻辑）
3. CHANGE-002（依赖 CHANGE-001 完成）

确认后运行 /implement-feature CHANGE-001 开始实现。
====================
```

---

## 实现变更时的注意事项

### modify 类型

修改已有代码时：
1. 在文件头部注释追加变更记录：
   ```
   // CHANGE-001 (2026-03-25)：<变更摘要>
   ```
2. 保留原有逻辑（注释保留），除非是完全替换
3. 优先扩展而非修改（开闭原则）

### replace 类型

1. 先读取原功能代码，了解已有逻辑
2. 创建新实现（可以是新文件）
3. 切换引用
4. 新实现确认可用后，删除旧代码

### 当 breaking_change = true 时

必须：
1. 在 `claude-progress.txt` 中明确标记 `[BREAKING CHANGE]`
2. 列出所有受影响的调用方
3. 提供迁移说明（改了什么、调用方需要怎么做）

---

## 迭代版本管理

当一个功能经过多次迭代时，在 `features.json` 的对应功能条目中维护版本历史：

```json
{
  "id": "FEAT-003",
  "title": "商品详情页",
  "status": "done",
  "version": "v3",
  "version_history": [
    { "version": "v1", "change": "初始实现", "date": "2026-03-01" },
    { "version": "v2", "change": "CHANGE-002：新增图片轮播", "date": "2026-03-10" },
    { "version": "v3", "change": "CHANGE-007：新增视频播放", "date": "2026-03-20" }
  ]
}
```
