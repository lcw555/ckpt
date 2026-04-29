#!/bin/bash
# PreToolUse hook: saves file state BEFORE Edit/Write/MultiEdit
input=$(cat)

file_path=$(python3 -c "
import sys, json
d = json.loads(sys.stdin.read())
ti = d.get('tool_input', {})
fp = ti.get('file_path', '')
if not fp:
    edits = ti.get('edits', [])
    if edits:
        fp = edits[0].get('file_path', '')
print(fp)
" <<< "$input")

CKPT="$HOME/.claude/plugins/ckpt/scripts/ckpt"
if [ -n "$file_path" ] && [ -f "$CKPT" ]; then
    bash "$CKPT" pre "$file_path"
fi

exit 0
