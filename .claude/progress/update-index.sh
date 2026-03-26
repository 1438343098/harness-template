#!/bin/bash

# Refresh index.json from disk

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INDEX_FILE="$SCRIPT_DIR/index.json"

update_index() {
  local sessions=$(ls -1 "$SCRIPT_DIR/sessions/" 2>/dev/null | wc -l)
  local features=$(ls -1 "$SCRIPT_DIR/features/" 2>/dev/null | wc -l)
  local blocks=$(ls -1 "$SCRIPT_DIR/blocks/" 2>/dev/null | wc -l)
  local latest=$(ls -1 "$SCRIPT_DIR/sessions/" 2>/dev/null | sort | tail -1 | sed 's/.session.md//')
  
  # Build sessions array
  local sessions_json="["
  first=true
  for session_file in "$SCRIPT_DIR/sessions/"*.session.md; do
    if [ -f "$session_file" ]; then
      if [ "$first" = true ]; then
        first=false
      else
        sessions_json+=","
      fi
      date=$(basename "$session_file" .session.md)
      sessions_json+="{\"date\":\"$date\",\"status\":\"completed\",\"file\":\"sessions/$(basename $session_file)\"}"
    fi
  done
  sessions_json+="]"
  
  # Build features array
  local features_json="["
  first=true
  for feat_file in "$SCRIPT_DIR/features/"*.log; do
    if [ -f "$feat_file" ]; then
      if [ "$first" = true ]; then
        first=false
      else
        features_json+=","
      fi
      feat_id=$(basename "$feat_file" .log)
      features_json+="\"$feat_id\""
    fi
  done
  features_json+="]"
  
  # Write index.json
  jq --arg sessions "$sessions_json" \
     --arg features "$features_json" \
     --arg latest "$latest" \
     --arg updated "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
     '.statistics.total_sessions = '$sessions' |
      .statistics.total_features = '$features' |
      .statistics.total_blocks = '$blocks' |
      .statistics.total_entries = ((.statistics.total_sessions // 0) + (.statistics.total_features // 0) + (.statistics.total_blocks // 0)) |
      .updated_at = $updated |
      .latest_session = $latest' "$INDEX_FILE" > "$INDEX_FILE.tmp" && \
  mv "$INDEX_FILE.tmp" "$INDEX_FILE"
  
  echo "✓ Index updated"
}

update_index
