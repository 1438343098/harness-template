# 📁 项目结构优化记录

## 优化时间
2026-03-26

## 🎯 优化目标

统一项目架构，从混杂的 `frontend/backend` + `apps/services` 双重结构优化为唯一标准的 **多项目容器架构**。

## 📋 改动清单

### ❌ 删除的目录
- `frontend/` — 旧的单体项目模板
- `backend/` — 旧的单体项目模板

### ✅ 保留的目录
- `apps/` — 前端应用容器（官方标准）
- `services/` — 后端服务容器（官方标准）

### 📝 新增文档
- `apps/AGENTS.md` — 前端多项目结构说明
- `services/AGENTS.md` — 后端多服务结构说明
- `.claude/STRUCTURE_MIGRATION.md` — 本文档

### 🔧 更新的文件
- `README.md` — 更新目录结构和 Q&A 部分
- `.claude/settings.json` — 调整权限配置
- `.claude/progress-cli.sh` — 补充进度查询工具文档

## 🤔 为什么要改？

### 原问题：结构冲突

| 问题 | 原因 | 影响 |
|------|------|------|
| 两套命名规范 | 同时存在 `frontend/` 和 `apps/` | 新手困惑，命令脚本维护困难 |
| 特性不对应 | `features.json` 只支持 `apps/services` | 代码所在地 ≠ 注册地，导致跟踪困难 |
| 文档重复 | `frontend/` 和 `apps/` 有两份 AGENTS.md | 易过时，维护成本高 |
| 无法扩展 | `backend/` 假设单体架构 | 想加第二个后端服务要重构 |

### 新架构：统一且可扩展

✅ **唯一的标准** — 所有项目都在 `apps/` 或 `services/` 下  
✅ **与 features.json 对齐** — 生成的代码位置与注册位置一致  
✅ **天然多项目** — 从单体到分布式无需重构  
✅ **简化文档** — 一套规范即可覆盖所有场景  

## 📚 使用指南

### 单体项目（1 个前端 + 1 个后端）

```
apps/web/
├── package.json
├── src/
└── AGENTS.md

services/api/
├── package.json
├── src/
└── AGENTS.md
```

**好处**：代码组织清晰，后续可轻松扩展。

### 多项目场景（官网 + 后台 + 移动）

```
apps/
├── web/          # 用户端网站
├── admin/        # 管理后台
├── mobile/       # React Native 移动端
└── AGENTS.md

services/
├── api/          # Node.js API
├── worker/       # Python 后台任务
├── scheduler/    # Node.js 定时器
└── AGENTS.md
```

**好处**：一个模板支持任意规模，无需特殊处理。

## 🚀 迁移步骤

### 对现有项目的影响

**如果你已经在用这个模板**:
- 代码文件位置不变（如果你按照规范使用）
- `features.json` 不变，系统自动识别新结构
- 无需手动迁移代码

**如果你在 `frontend/` 或 `backend/` 下有自己的代码**:
```bash
# 手动迁移
mv frontend/src/* apps/web/src/
mv backend/src/* services/api/src/
```

### 对新项目的建议

```bash
# 1. 清空旧目录（如果存在）
rm -rf frontend backend

# 2. 运行初始化
/session-start

# 3. 解析需求（自动创建项目）
/process-requirements

# 完成！你的项目已在 apps/ 和 services/ 下了
```

## 📊 结构对比

### 旧结构（混杂）
```
.
├── frontend/
│   └── src/
├── backend/
│   └── src/
├── apps/
│   └── (empty, 文档说这里是前端容器但没人用)
└── services/
    └── (empty, 文档说这里是后端容器但没人用)
```

🔴 **问题**: `features.json` 指向 `apps/services`，但代码在 `frontend/backend`

### 新结构（规范）
```
.
├── apps/
│   ├── web/
│   │   └── src/
│   └── AGENTS.md
└── services/
    ├── api/
    │   └── src/
    └── AGENTS.md
```

🟢 **优点**: 一致、清晰、可扩展

## 🔍 快速验证

验证结构正确性：

```bash
# 查看项目列表
jq '.projects' features.json

# 查看前端应用
ls -la apps/

# 查看后端服务
ls -la services/

# 建议的输出
# apps: 包含 web/ admin/ 等
# services: 包含 api/ worker/ 等
```

## 📖 相关文档

- [README.md](../../README.md) — 项目总览
- [AGENTS.md](../../AGENTS.md) — 导航指南
- [apps/AGENTS.md](../../apps/AGENTS.md) — 前端项目结构
- [services/AGENTS.md](../../services/AGENTS.md) — 后端服务结构
- [features.json](../../features.json) — 项目状态

---

**优化版本**: 1.0  
**优化日期**: 2026-03-26  
**优化者**: Claude Code  

维护建议：
- ✅ 每次 `/process-requirements` 后检查 `features.json.projects`
- ✅ 不要直接在 `frontend/` 或 `backend/` 下创建代码
- ✅ 定期使用 `./.claude/progress-cli.sh stats` 监控项目指标
