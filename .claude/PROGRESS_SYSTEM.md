# 📋 项目进度日志系统

## 概述

项目进度日志已从单一 `claude-progress.txt` 文件迁移到**分层目录结构**，解决了大文件膨胀和查询性能的问题。

## 🏗️ 目录结构

```
.claude/
├── progress/                    # 进度日志根目录
│   ├── index.json              # 元数据索引（快速查询）
│   ├── update-index.sh         # 索引更新脚本
│   ├── sessions/               # 会话日志（按日期）
│   │   ├── 2026-03-25.session.md
│   │   └── 2026-03-26.session.md
│   ├── features/               # 功能日志（按 FEAT-ID）
│   │   ├── FEAT-001.log
│   │   ├── FEAT-002.log
│   │   └── FEAT-003.log
│   └── blocks/                 # 阻塞项记录（按 BLOCK-ID）
│       ├── BLOCK-001.md
│       └── BLOCK-002.md
├── progress-cli.sh             # 命令行查询工具
├── .gitignore                  # 日志目录的 git 规则
└── commands/
```

## ✨ 优势

| 特性 | 单文件 | 分层结构 |
|-----|--------|--------|
| 文件大小管理 | ❌ 易膨胀 | ✅ 按需扩展 |
| 查询速度 | ❌ 线性搜索 | ✅ 索引加速 |
| 并发安全 | ❌ 锁冲突 | ✅ 独立文件 |
| 功能查询 | ❌ 全文扫描 | ✅ 直接访问 |
| 版本管理 | ❌ 大 diff | ✅ 细粒度 diff |

## 🔍 查询方法

### 方法 1: 使用 CLI 工具（推荐）

```bash
# 查看最新进度
./.claude/progress-cli.sh latest

# 查询特定功能
./.claude/progress-cli.sh search FEAT-001

# 模糊搜索
./.claude/progress-cli.sh search "数据库连接"

# 列出所有功能
./.claude/progress-cli.sh features

# 查看所有阻塞项
./.claude/progress-cli.sh blocks

# 统计信息
./.claude/progress-cli.sh stats

# 获取帮助
./.claude/progress-cli.sh help
```

### 方法 2: 直接查看文件

```bash
# 查看最新会话
cat .claude/progress/sessions/2026-03-25.session.md

# 查看特定功能
cat .claude/progress/features/FEAT-001.log

# 查看所有阻塞项
ls -la .claude/progress/blocks/

# 查看索引
jq '.' .claude/progress/index.json
```

### 方法 3: 使用 jq 查询索引

```bash
# 查看统计信息
jq '.statistics' .claude/progress/index.json

# 列出所有功能
jq '.features[]' .claude/progress/index.json

# 获取最新会话
jq '.latest_session' .claude/progress/index.json
```

## 📝 文件格式

### sessions/YYYY-MM-DD.session.md

```markdown
# Session: 2026-03-25
**时间**: 2026-03-25
**状态**: 项目初始化
**描述**: 模板已就绪，等待用户提供需求文档和设计稿

## 操作清单
- [ ] 任务 1
- [ ] 任务 2

## 关联功能
- FEAT-001: 用户认证
- FEAT-002: 数据库迁移

## 阻塞项
- BLOCK-001: 设计稿未收到

---
**记录者**: Claude Code
**最后更新**: 2026-03-25T14:30:00Z
```

### features/FEAT-XXX.log

```
[FEAT-001] START: 用户认证模块
时间: 2026-03-25T10:00:00Z

[FEAT-001] FILE: src/auth/login.ts 已创建
时间: 2026-03-25T10:15:00Z

[FEAT-001] FILE: src/auth/register.ts 已创建
时间: 2026-03-25T10:30:00Z

[FEAT-001] DONE: 用户认证模块完成
时间: 2026-03-25T11:00:00Z
状态: ✅ 完成
```

### blocks/BLOCK-XXX.md

```markdown
# Block: BLOCK-001
**标题**: 设计稿延迟交付
**严重度**: 🔴 高
**发现时间**: 2026-03-25T14:00:00Z
**预计解决**: 2026-03-26

## 描述
设计团队未按时提交首页设计稿，导致前端开发无法开始。

## 影响范围
- FEAT-002: 前端首页开发被阻塞

## 解决方案
- [ ] 跟进设计进度
- [ ] 获取临时设计
- [ ] 开始后端开发

---
**记录者**: Claude Code
**状态**: 🔴 Open
```

### index.json

```json
{
  "schema_version": "1.0",
  "created_at": "2026-03-25T00:00:00Z",
  "updated_at": "2026-03-26T14:30:00Z",
  "project": "harness-template",
  "statistics": {
    "total_sessions": 2,
    "total_features": 5,
    "total_blocks": 1,
    "total_entries": 8
  },
  "sessions": [
    {
      "date": "2026-03-25",
      "status": "completed",
      "file": "sessions/2026-03-25.session.md"
    },
    {
      "date": "2026-03-26",
      "status": "active",
      "file": "sessions/2026-03-26.session.md"
    }
  ],
  "features": ["FEAT-001", "FEAT-002", "FEAT-003", "FEAT-004", "FEAT-005"],
  "blocks": ["BLOCK-001"],
  "latest_session": "2026-03-26"
}
```

## 🔄 工作流程

### Claude Code 自动操作

1. **会话开始**
   ```
   创建 sessions/YYYY-MM-DD.session.md
   更新 index.json 的 latest_session
   ```

2. **记录功能**
   ```
   创建 features/FEAT-XXX.log
   追加操作记录
   更新 index.json.features 和 .statistics.total_features
   ```

3. **记录阻塞**
   ```
   创建 blocks/BLOCK-XXX.md
   更新 index.json.blocks 和 .statistics.total_blocks
   ```

### 手动操作

1. **刷新索引**
   ```bash
   ./.claude/progress/update-index.sh
   ```

2. **查询进度**
   ```bash
   ./.claude/progress-cli.sh <命令>
   ```

3. **查看文件**
   ```bash
   cat .claude/progress/sessions/2026-03-25.session.md
   ```

## 📊 索引更新规则

索引文件 (`index.json`) 在以下操作后自动更新：

- ✅ 创建新会话文件
- ✅ 创建新功能日志
- ✅ 创建新阻塞项
- ✅ 会话状态变更

**手动更新**:
```bash
./.claude/progress/update-index.sh
```

## 🗑️ 归档规则

### 自动归档条件

- **单个会话日志** > 10MB → 拆分为周档案
- **年度日志** → 压缩成 `archive/2025.tar.gz`
- **完成的功能** (6个月后) → 移至 `archive/features/`

### 手动归档

```bash
# 归档去年的会话
tar -czf .claude/progress/archive/2025.tar.gz \
  .claude/progress/sessions/2025-*.session.md

# 清理
rm .claude/progress/sessions/2025-*.session.md
```

## ⚙️ 配置

### .claude/.gitignore

```
# 临时文件
progress/**/*.tmp
progress/**/*.swp

# 备份
progress/backup/

# 大型归档
progress/archive/*.tar.gz
```

### .claude/progress/update-index.sh

自动扫描目录并更新 `index.json` 的统计信息：

```bash
PROGRESS_DIR=".claude/progress"
sessions=$(ls -1 "$PROGRESS_DIR/sessions/" | wc -l)
features=$(ls -1 "$PROGRESS_DIR/features/" | wc -l)
blocks=$(ls -1 "$PROGRESS_DIR/blocks/" | wc -l)
```

## 📈 预期增长

| 时间范围 | 会话数 | 功能数 | 文件数 | 总大小 |
|---------|--------|--------|--------|--------|
| 1 周 | 7 | 10-20 | 37-47 | ~500 KB |
| 1 月 | 30 | 40-80 | 70-110 | ~3 MB |
| 1 年 | 365 | 500+ | 900+ | ~50 MB |

✅ **远好于** 单一文件的 200+ MB 增长！

## 🚀 最佳实践

1. **定期查看**
   ```bash
   ./.claude/progress-cli.sh latest  # 每次会话开始
   ```

2. **按需搜索**
   ```bash
   ./.claude/progress-cli.sh search FEAT-001  # 查询功能
   ```

3. **定期统计**
   ```bash
   ./.claude/progress-cli.sh stats  # 周报告
   ```

4. **定期归档**
   ```bash
   ./.claude/progress/update-index.sh  # 月底刷新
   ```

## 🔗 相关文件

- [progress.txt](../../progress.txt) - 摘要版本
- [progress-cli.sh](./.claude/progress-cli.sh) - 查询工具
- [index.json](./.claude/progress/index.json) - 索引文件

---

**版本**: 1.0  
**创建日期**: 2026-03-25  
**维护者**: Claude Code
