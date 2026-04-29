#!/bin/bash
# PreToolUse hook: saves file state BEFORE Edit/Write/MultiEdit
# Cross-platform: Linux, macOS, Windows (Git Bash / MSYS2)
input=$(cat)

# Detect python binary (python3 or python)
PYTHON=""
for p in python3 python; do
    if command -v "$p" >/dev/null 2>&1; then
        PYTHON="$p"
        break
    fi
done

if [ -z "$PYTHON" ]; then
    echo "[ckpt] WARNING: python not found, skip snapshot" >&2
    exit 0
fi

file_path=$("$PYTHON" -c "
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

# Locate ckpt script: try CLAUDE_PLUGIN_ROOT first, then default path
CKPT=""
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -f "${CLAUDE_PLUGIN_ROOT}/scripts/ckpt" ]; then
    CKPT="${CLAUDE_PLUGIN_ROOT}/scripts/ckpt"
elif [ -f "$HOME/.claude/plugins/ckpt/scripts/ckpt" ]; then
    CKPT="$HOME/.claude/plugins/ckpt/scripts/ckpt"
fi

if [ -n "$file_path" ] && [ -n "$CKPT" ] && [ -f "$CKPT" ]; then
    bash "$CKPT" pre "$file_path"
fi

exit 0
