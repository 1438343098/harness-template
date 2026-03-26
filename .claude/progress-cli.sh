#!/bin/bash

# 进度日志 CLI 工具
# 用法: ./.claude/progress-cli.sh <命令> [参数]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROGRESS_DIR="$SCRIPT_DIR/progress"
INDEX_FILE="$PROGRESS_DIR/index.json"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
  echo -e "${BLUE}════════════════════════════════════════${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}════════════════════════════════════════${NC}"
}

# 查看最新进度
latest() {
  print_header "📋 最新进度"
  
  if [ -f "$INDEX_FILE" ]; then
    latest_session=$(jq -r '.latest_session' "$INDEX_FILE" 2>/dev/null)
    if [ -f "$PROGRESS_DIR/sessions/${latest_session}.session.md" ]; then
      echo -e "${GREEN}最新会话: ${latest_session}${NC}"
      echo ""
      tail -30 "$PROGRESS_DIR/sessions/${latest_session}.session.md"
    fi
  else
    echo -e "${RED}index.json 未找到${NC}"
  fi
}

# 查询特定功能
search() {
  local query=$1
  print_header "🔍 搜索: $query"
  
  if [[ $query =~ ^FEAT- ]]; then
    feat_file="$PROGRESS_DIR/features/${query}.log"
    if [ -f "$feat_file" ]; then
      cat "$feat_file"
    else
      echo -e "${RED}功能 $query 未找到${NC}"
    fi
  else
    # 模糊搜索
    echo -e "${YELLOW}在所有日志中搜索...${NC}"
    find "$PROGRESS_DIR" -type f \( -name "*.md" -o -name "*.log" \) -exec grep -l "$query" {} \;
  fi
}

# 列出所有功能
features() {
  print_header "✨ 功能列表"
  
  if [ -f "$INDEX_FILE" ]; then
    count=$(jq '.statistics.total_features' "$INDEX_FILE" 2>/dev/null)
    if [ "$count" -eq 0 ]; then
      echo -e "${YELLOW}暂无功能记录${NC}"
    else
      jq -r '.features[]' "$INDEX_FILE" 2>/dev/null | while read feat; do
        echo -e "${GREEN}✓ $feat${NC}"
      done
    fi
  fi
}

# 列出阻塞项
blocks() {
  print_header "🚨 阻塞项"
  
  if [ -f "$INDEX_FILE" ]; then
    blocks=$(jq '.statistics.total_blocks' "$INDEX_FILE" 2>/dev/null)
    if [ "$blocks" -eq 0 ]; then
      echo -e "${GREEN}✓ 无阻塞项${NC}"
    else
      ls -1 "$PROGRESS_DIR/blocks/" 2>/dev/null | while read block; do
        echo -e "${RED}⚠ $block${NC}"
      done
    fi
  fi
}

# 统计信息
stats() {
  print_header "📊 统计信息"
  
  if [ -f "$INDEX_FILE" ]; then
    jq '.statistics' "$INDEX_FILE"
    echo ""
    echo "📁 日志目录: $PROGRESS_DIR"
  fi
}

# 帮助
usage() {
  cat << 'HELP'
进度日志 CLI - 快速查询项目进度

用法:
  ./.claude/progress-cli.sh <命令> [参数]

命令:
  latest              显示最新进度 (最后 30 行)
  search <FEAT-ID>    查询特定功能 (例: search FEAT-001)
  search <关键字>     模糊搜索关键字
  features            列出所有功能
  blocks              显示所有阻塞项
  stats               显示统计信息
  help                显示此帮助

例子:
  ./.claude/progress-cli.sh latest
  ./.claude/progress-cli.sh search FEAT-001
  ./.claude/progress-cli.sh search "数据库"
  ./.claude/progress-cli.sh features
  ./.claude/progress-cli.sh stats

HELP
}

# 主入口
case "${1:-latest}" in
  latest)
    latest
    ;;
  search)
    if [ -z "$2" ]; then
      echo -e "${RED}错误: 缺少搜索参数${NC}"
      usage
      exit 1
    fi
    search "$2"
    ;;
  features)
    features
    ;;
  blocks)
    blocks
    ;;
  stats)
    stats
    ;;
  help)
    usage
    ;;
  *)
    echo -e "${RED}未知命令: $1${NC}"
    echo ""
    usage
    exit 1
    ;;
esac
