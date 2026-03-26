#!/bin/bash

# Progress log CLI
# Usage: ./.claude/progress-cli.sh <command> [args]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROGRESS_DIR="$SCRIPT_DIR/progress"
INDEX_FILE="$PROGRESS_DIR/index.json"

# Colors
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

# Latest progress
latest() {
  print_header "📋 Latest progress"
  
  if [ -f "$INDEX_FILE" ]; then
    latest_session=$(jq -r '.latest_session' "$INDEX_FILE" 2>/dev/null)
    if [ -f "$PROGRESS_DIR/sessions/${latest_session}.session.md" ]; then
      echo -e "${GREEN}Latest session: ${latest_session}${NC}"
      echo ""
      tail -30 "$PROGRESS_DIR/sessions/${latest_session}.session.md"
    fi
  else
    echo -e "${RED}index.json not found${NC}"
  fi
}

# Search feature or keyword
search() {
  local query=$1
  print_header "🔍 Search: $query"
  
  if [[ $query =~ ^FEAT- ]]; then
    feat_file="$PROGRESS_DIR/features/${query}.log"
    if [ -f "$feat_file" ]; then
      cat "$feat_file"
    else
      echo -e "${RED}Feature $query not found${NC}"
    fi
  else
    echo -e "${YELLOW}Searching all logs...${NC}"
    find "$PROGRESS_DIR" -type f \( -name "*.md" -o -name "*.log" \) -exec grep -l "$query" {} \;
  fi
}

# List features
features() {
  print_header "✨ Features"
  
  if [ -f "$INDEX_FILE" ]; then
    count=$(jq '.statistics.total_features' "$INDEX_FILE" 2>/dev/null)
    if [ "$count" -eq 0 ]; then
      echo -e "${YELLOW}No feature logs yet${NC}"
    else
      jq -r '.features[]' "$INDEX_FILE" 2>/dev/null | while read feat; do
        echo -e "${GREEN}✓ $feat${NC}"
      done
    fi
  fi
}

# List blockers
blocks() {
  print_header "🚨 Blockers"
  
  if [ -f "$INDEX_FILE" ]; then
    blocks=$(jq '.statistics.total_blocks' "$INDEX_FILE" 2>/dev/null)
    if [ "$blocks" -eq 0 ]; then
      echo -e "${GREEN}✓ No blockers${NC}"
    else
      ls -1 "$PROGRESS_DIR/blocks/" 2>/dev/null | while read block; do
        echo -e "${RED}⚠ $block${NC}"
      done
    fi
  fi
}

# Statistics
stats() {
  print_header "📊 Statistics"
  
  if [ -f "$INDEX_FILE" ]; then
    jq '.statistics' "$INDEX_FILE"
    echo ""
    echo "📁 Log root: $PROGRESS_DIR"
  fi
}

# Help
usage() {
  cat << 'HELP'
Progress CLI — quick project progress queries

Usage:
  ./.claude/progress-cli.sh <command> [args]

Commands:
  latest              Show latest progress (last 30 lines)
  search <FEAT-ID>    Open a feature log (e.g. search FEAT-001)
  search <keyword>    Fuzzy search across logs
  features            List all features
  blocks              List blockers
  stats               Show statistics
  help                Show this help

Examples:
  ./.claude/progress-cli.sh latest
  ./.claude/progress-cli.sh search FEAT-001
  ./.claude/progress-cli.sh search "database"
  ./.claude/progress-cli.sh features
  ./.claude/progress-cli.sh stats

HELP
}

# Entry point
case "${1:-latest}" in
  latest)
    latest
    ;;
  search)
    if [ -z "$2" ]; then
      echo -e "${RED}Error: search needs an argument${NC}"
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
    echo -e "${RED}Unknown command: $1${NC}"
    echo ""
    usage
    exit 1
    ;;
esac
