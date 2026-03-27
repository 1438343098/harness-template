# 技能：process-requirements — 需求解析

将用户提供的粗糙需求文档解析为结构化的 features.json 功能列表。

## 前提条件

用户已在以下位置提供需求：
- `docs/prd/` 目录下的任意文件
- 或直接粘贴在对话中的文字
- 或只有一个模糊想法（此时先用 `kz-prd` 技能生成 PRD）

## Step 0：判断是否为迭代需求

首先检查：
- `features.json` 中 `requirements_processed` 是否已为 `true`
- 文档内容是否包含"修改"、"迭代"、"v2"、"调整"等关键词
- 文档是否引用了现有功能（FEAT-XXX）

若为迭代需求 → 停止并告知用户改用 `/process-iteration`。
若为首次需求 → 继续以下步骤。

---

## Step 0.5：检查是否需要先生成 PRD

```bash
ls docs/prd/
```

检查 `docs/prd/` 下是否存在**非模板**的用户需求文档（排除 `AGENTS.md` 和 `REQUIREMENTS_TEMPLATE.md`）。

**若无任何文档，且用户只提供了模糊描述或口头想法：**

→ 读取并执行 `.claude/skills/kz-prd/SKILL.md` 中定义的 `kz-prd` 技能：
  1. 基于用户描述，逐一提问以收集完整需求信息
  2. 若需求涉及表单控件（input、select、checkbox 等），额外读取 `.claude/skills/kz-prd/ref/form.md` 并针对每个控件补充提问
  3. 根据收集到的信息生成结构化 PRD（Executive Summary → User Stories → Functional Requirements → Design Considerations → Risks & Roadmap）
  4. 将生成的 PRD 保存到 `docs/prd/[feature-name].md`

→ PRD 生成完毕后，继续 Step 1 进行解析。

**若已有文档：** 跳过本步骤，直接进入 Step 1。

---

## Step 1：定位需求文档

```bash
ls docs/prd/
```

读取所有非模板文件（排除 AGENTS.md 和 REQUIREMENTS_TEMPLATE.md）。

若用户在对话中粘贴了内容，先保存为 `docs/prd/user-requirements.md`，再处理。

## Step 2：结构化解析

读取完整需求文档，提取以下内容：

**1. 产品目标**
- 这个应用解决什么问题
- 目标用户是谁

**2. 核心功能模块**
- 主要功能领域（如用户管理、商品管理、订单系统）

**3. 具体功能点**
- 每个模块内的具体功能（如用户注册、用户登录、修改密码）

**4. 隐含技术需求**
- 用户未明说但必须存在的（如鉴权、数据持久化、API 接口）

**5. UI/页面需求**
- 需要哪些页面（如登录页、仪表盘、列表页、详情页）

**6. 模糊或不清晰的需求**
- 需要进一步澄清的部分

**处理规则：**
- "类似 xxx 的功能" → 提取 xxx 的核心特征
- "等等/类似/之类的" → 登记为功能，在 notes 中标记"需用户澄清"
- 重复概念 → 合并为一个功能
- 矛盾需求 → 选择更简单的实现，在 notes 中记录冲突

## Step 2.5：识别并注册子项目

根据需求判断需要创建哪些前端应用和后端服务：

**识别规则：**
- "用户端网站" / "官网" / "商城" → `apps/web`
- "管理后台" / "运营平台" / "CMS" → `apps/admin`
- "移动端" / "App" → `apps/mobile`
- "API" / "接口服务" / "后端" → `services/api`
- "定时任务" / "异步处理" / "队列" → `services/worker`
- "鉴权" / "SSO" / "登录服务" → `services/auth`

**查询用户偏好（`user-preferences.json`）：**
- 若 `tech_stack.frontend` 已有默认值 → 直接使用，不再询问
- 若 `tech_stack.language.backend` 已有默认值 → 直接使用
- 无偏好的选项 → 询问用户并记录到 `decision_log`

**写入 `features.json` 的 `projects` 字段：**
```json
{
  "projects": {
    "apps": [
      {
        "id": "APP-web",
        "name": "用户端 Web",
        "path": "apps/web",
        "tech_stack": "<已学习的偏好或用户确认的>",
        "description": "<从需求中提取>"
      }
    ],
    "services": [
      {
        "id": "SVC-api",
        "name": "主 API 服务",
        "path": "services/api",
        "language": "<语言>",
        "tech_stack": "<框架>",
        "description": "<从需求中提取>"
      }
    ]
  }
}
```

**为每个子项目创建目录和 AGENTS.md：**
```bash
mkdir -p apps/<name>
mkdir -p services/<name>
```

AGENTS.md 应记录：技术栈、目录结构规范、代码规范、启动命令。

---

## Step 3：功能优先级排序

优先级规则（1 = 最高）：
1. **基础设施** — 没有它其他功能无法运行（数据库、鉴权系统）
2. **核心用户流程** — 用户的主要操作路径
3. **辅助功能** — 提升体验但非必须
4. **优化功能** — 性能调优、UI 打磨等

## Step 4：生成功能文件

### 4a. 更新 `features.json`（索引 + 元数据）

```json
{
  "project": {
    "name": "<从需求中提取的项目名>",
    "description": "<一句话描述>",
    "target_user": "<目标用户>",
    "tech_stack": {
      "frontend": "<技术栈，未指定写 TBD>",
      "backend": "<技术栈，未指定写 TBD>",
      "database": "<数据库，未指定写 TBD>"
    }
  },
  "summary": {
    "total": <功能总数>,
    "pending": <待处理数>,
    "in_progress": 0,
    "done": 0,
    "last_updated": "<ISO 8601>"
  },
  "features_dir": "features/",
  "ambiguities": [
    {
      "description": "<模糊需求描述>",
      "question": "<需向用户确认的问题>",
      "impact": "<不澄清的影响>",
      "default_assumption": "<默认处理方式>"
    }
  ],
  "design_assets": {
    "processed": false,
    "files": [],
    "spec_file": "docs/design/extracted/design-spec.md"
  },
  "requirements_processed": true,
  "last_updated": "<ISO 8601>"
}
```

### 4b. 为每个功能创建独立文件 `features/FEAT-XXX.json`

每个功能独立存为一个 JSON 文件：

```json
{
  "id": "FEAT-001",
  "title": "<功能标题>",
  "module": "<所属模块>",
  "app": "APP-web | SVC-api | SVC-worker | ...",
  "type": "backend|frontend|fullstack|infra",
  "priority": 1,
  "status": "pending",
  "version": "v1",
  "version_history": [],
  "description": "<详细功能描述>",
  "acceptance_criteria": [
    "<验收标准 1>",
    "<验收标准 2>"
  ],
  "dependencies": [],
  "estimated_hours": 2,
  "notes": "<备注，尤其是模糊点>",
  "created_at": "<ISO 8601>",
  "started_at": null,
  "completed_at": null
}
```

**注意：** 每个功能的 `estimated_hours` 不得超过 4 小时。如超过，拆分该功能。

## Step 5：输出解析报告

```
=== 需求解析完成 ===

【项目概述】
<用一段话描述理解的项目>

【功能列表】（共 N 个功能）
优先级 1 - 基础设施：
  ✅ FEAT-001：<标题>（预计 Xh）
  ...

优先级 2 - 核心功能：
  ✅ FEAT-003：<标题>（预计 Xh）
  ...

【技术栈】
前端：<TBD 或已确认>
后端：<TBD 或已确认>
数据库：<TBD 或已确认>

【需要澄清的问题】
1. <问题 1>
   - 影响范围：<影响范围>
   - 默认处理：<若不回答，则...>
2. <问题 2>
   ...

请确认以上理解是否正确。如需调整请告知。
确认后，运行 /process-design（若有设计稿）或 /implement-feature FEAT-001 开始开发。
====================
```
