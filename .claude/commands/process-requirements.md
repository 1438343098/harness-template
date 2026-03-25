# 技能: process-requirements — 需求解析

将用户提供的粗糙需求文档解析为结构化的 features.json 功能列表。

## 前置条件

用户已在以下位置之一提供需求：
- `docs/prd/` 目录下的任意文件
- 或在对话中直接粘贴文本

## 步骤 0：判断是否为迭代需求

先检查：
- `features.json` 中 `requirements_processed` 是否已为 `true`
- 文档内容是否包含"修改"、"迭代"、"v2"、"调整"等关键词
- 文档是否引用了已有的功能（FEAT-XXX）

如果是迭代需求 → 停止，告知用户改用 `/process-iteration` 处理。
如果是首次需求 → 继续以下步骤。

---

## 步骤 1：定位需求文档

```bash
ls docs/prd/
```

读取所有非模板文件（排除 AGENTS.md 和 REQUIREMENTS_TEMPLATE.md）。

如果用户在对话中粘贴了内容，先保存到 `docs/prd/user-requirements.md`，再处理。

## 步骤 2：结构化解析

阅读整个需求文档，提取以下信息：

**1. 产品目标**
- 这个应用要解决什么问题
- 目标用户是谁

**2. 核心功能模块**
- 主要功能区域（如：用户管理、商品管理、订单系统）

**3. 具体功能点**
- 每个模块下的具体功能（如：用户注册、用户登录、修改密码）

**4. 隐含的技术需求**
- 用户没说但必须有的（如：身份验证、数据持久化、API接口）

**5. UI/页面需求**
- 需要哪些页面（如：登录页、仪表盘、列表页、详情页）

**6. 模糊或不确定的需求**
- 需要澄清的部分

**处理规则：**
- "像 xxx 那样的功能" → 提取 xxx 的核心特征
- "等等/之类的" → 记录为功能，notes 标注"需要用户澄清"
- 重复出现的概念 → 合并为一个功能
- 矛盾的需求 → 选择更简单的实现，notes 中记录矛盾

## 步骤 2.5：识别子项目并注册

根据需求，识别需要创建哪些前端应用和后端服务：

**识别规则：**
- "用户端网站" / "官网" / "商城" → `apps/web`
- "管理后台" / "运营后台" / "CMS" → `apps/admin`
- "移动端" / "App" → `apps/mobile`
- "API" / "接口服务" / "后端" → `services/api`
- "定时任务" / "异步处理" / "队列" → `services/worker`
- "认证" / "SSO" / "登录服务" → `services/auth`

**查询用户偏好（`user-preferences.json`）：**
- 如果 `tech_stack.frontend` 已有默认值 → 直接使用，不询问
- 如果 `tech_stack.language.backend` 已有默认值 → 直接使用
- 没有偏好的选项 → 询问用户，记录到 `decision_log`

**写入 `features.json` 的 `projects` 字段：**
```json
{
  "projects": {
    "apps": [
      {
        "id": "APP-web",
        "name": "用户端 Web",
        "path": "apps/web",
        "tech_stack": "<已学习的偏好 或 用户确认的>",
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

AGENTS.md 中写明该项目的：技术栈、目录结构约定、代码规范、启动命令。

---

## 步骤 3：功能优先级排序

优先级规则（1=最高）：
1. **基础设施** — 没有它其他功能无法运行（数据库、认证系统）
2. **核心用户流程** — 用户最主要的操作路径
3. **辅助功能** — 增强体验但非必须
4. **优化功能** — 性能优化、UI 美化等

## 步骤 4：生成 features.json

将提取的功能写入 `features.json`，格式如下：

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
    "pending": <pending数>,
    "in_progress": 0,
    "done": 0,
    "last_updated": "<ISO 8601>"
  },
  "features": [
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
      "description": "<功能详细描述>",
      "acceptance_criteria": [
        "<验收标准1>",
        "<验收标准2>"
      ],
      "dependencies": [],
      "estimated_hours": 2,
      "notes": "<备注，特别是模糊点>",
      "created_at": "<ISO 8601>",
      "started_at": null,
      "completed_at": null
    }
  ],
  "ambiguities": [
    {
      "description": "<模糊需求描述>",
      "question": "<需要向用户确认的问题>",
      "impact": "<如果不澄清的影响>",
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

**注意：** 每个功能的 `estimated_hours` 不要超过 4 小时，超过则拆分。

## 步骤 5：输出解析报告

```
=== 需求解析完成 ===

【项目概述】
<一段话描述理解的项目>

【功能清单】（共 N 个功能）
优先级1 - 基础设施:
  ✅ FEAT-001: <标题>（预计 Xh）
  ...

优先级2 - 核心功能:
  ✅ FEAT-003: <标题>（预计 Xh）
  ...

【技术选型】
前端: <TBD 或已确定>
后端: <TBD 或已确定>
数据库: <TBD 或已确定>

【需要澄清的问题】
1. <问题1>
   - 影响: <影响范围>
   - 默认处理: <如不回答则...>
2. <问题2>
   ...

请确认以上理解是否正确。如有需要修改的地方请告知。
确认后运行 /process-design（如有设计稿）或 /implement-feature FEAT-001 开始开发。
====================
```
