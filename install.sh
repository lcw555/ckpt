#!/bin/bash
# ckpt plugin installer (cross-platform: Linux, macOS, Windows Git Bash)
# Usage:
#   方式一（一键）:  curl -fsSL https://raw.githubusercontent.com/lcw555/ckpt/master/install.sh | bash
#   方式二（本地）:  git clone ... && bash ~/.claude/plugins/ckpt/install.sh
set -e

PLUGIN_DIR="$HOME/.claude/plugins/ckpt"
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo "$PWD")"
REPO_URL="https://github.com/lcw555/ckpt.git"

echo "=== ckpt installer ==="

# ---- detect platform ----
case "$(uname -s)" in
    Linux*)   PLATFORM=linux ;;
    Darwin*)  PLATFORM=macos ;;
    MINGW*|MSYS*|CYGWIN*)  PLATFORM=windows ;;
    *)        PLATFORM=unknown ;;
esac

# ---- step 0: ensure plugin files exist ----
if [ -f "$SCRIPT_DIR/scripts/ckpt" ]; then
    # Running from inside the plugin repo
    echo "[0/4] Using plugin files from: $SCRIPT_DIR"
    PLUGIN_DIR="$SCRIPT_DIR"
elif [ -d "$PLUGIN_DIR/scripts" ]; then
    # Already cloned
    echo "[0/4] Plugin already exists at: $PLUGIN_DIR"
else
    # Standalone mode: clone the repo
    echo "[0/4] Cloning ckpt from GitHub..."
    if ! command -v git >/dev/null 2>&1; then
        echo "ERROR: git is required. Install git first: https://git-scm.com"
        exit 1
    fi
    git clone "$REPO_URL" "$PLUGIN_DIR"
    echo "       → cloned to $PLUGIN_DIR"
fi

# ---- step 1: make scripts executable ----
echo "[1/4] Setting executable permissions..."
chmod +x "$PLUGIN_DIR/scripts/ckpt" 2>/dev/null || true
chmod +x "$PLUGIN_DIR/hooks/ckpt-hook.sh" 2>/dev/null || true

# ---- step 2: initialize checkpoint repo ----
echo "[2/4] Initializing checkpoint repository..."
bash "$PLUGIN_DIR/scripts/ckpt" init

# ---- step 3: configure Claude Code hook ----
echo "[3/4] Configuring Claude Code hook..."
SETTINGS_FILE="$HOME/.claude/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    if grep -q 'ckpt-hook.sh' "$SETTINGS_FILE" 2>/dev/null; then
        echo "       → hook already configured in settings.json"
    else
        # Backup original
        cp "$SETTINGS_FILE" "$SETTINGS_FILE.ckpt.bak"
        echo "       → backup saved to settings.json.ckpt.bak"

        # Use python to merge the hook config (much safer than sed)
        PYTHON=""
        for p in python3 python; do
            command -v "$p" >/dev/null 2>&1 && PYTHON="$p" && break
        done

        if [ -n "$PYTHON" ]; then
            "$PYTHON" -c "
import json, sys
with open('$SETTINGS_FILE', 'r') as f:
    cfg = json.load(f)

cfg.setdefault('hooks', {}).setdefault('PreToolUse', [])

# Check if ckpt hook already present
already = any(
    'ckpt-hook.sh' in h.get('command', '')
    for entry in cfg['hooks']['PreToolUse']
    for h in entry.get('hooks', [])
)
if not already:
    cfg['hooks']['PreToolUse'].append({
        'matcher': 'Edit|Write|MultiEdit',
        'hooks': [{
            'type': 'command',
            'command': 'bash ~/.claude/plugins/ckpt/hooks/ckpt-hook.sh',
            'timeout': 10
        }]
    })
    with open('$SETTINGS_FILE', 'w') as f:
        json.dump(cfg, f, indent=2, ensure_ascii=False)
    print('       → hook added to settings.json')
else:
    print('       → hook already configured in settings.json')
"
        else
            echo "       → WARNING: python not found, cannot auto-configure settings.json"
            echo "       → Please manually add the hook config (see README.md)"
        fi
    fi
else
    echo "       → settings.json not found, creating default config..."
    cat > "$SETTINGS_FILE" << 'SETEOF'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/plugins/ckpt/hooks/ckpt-hook.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
SETEOF
    echo "       → created settings.json with ckpt hook"
fi

# ---- step 4: add shell alias ----
echo "[4/4] Configuring shell alias..."
SHELL_RC=""
for f in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.zshrc"; do
    [ -f "$f" ] && SHELL_RC="$f" && break
done
if [ -z "$SHELL_RC" ] && [ "$PLATFORM" = "windows" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

CKPT_PATH="$PLUGIN_DIR/scripts/ckpt"
CKPT_PATH="${CKPT_PATH//\\//}"

if [ -n "$SHELL_RC" ]; then
    if grep -q 'ckpt' "$SHELL_RC" 2>/dev/null; then
        echo "       → alias already exists in $(basename "$SHELL_RC")"
    else
        echo "alias ckpt='bash \"$CKPT_PATH\"'" >> "$SHELL_RC"
        echo "       → alias added to $(basename "$SHELL_RC")"
        echo "       → Run 'source $SHELL_RC' or restart terminal"
    fi
else
    echo "       → No shell rc file found, skip alias"
fi

# ---- done ----
echo ""
echo "✓ ckpt installed!"
echo ""
echo "  使用方式:"
echo "    ckpt steps          # 查看所有检查点"
echo "    ckpt restore 3      # 回滚到第 3 个检查点"
echo "    ckpt try 新方案     # 创建分支探索"
echo "    ckpt end \"最终版\"   # 合并快照"
echo ""
echo "  ⚠ 重启 Claude Code 使 hook 生效"
echo "  Repo: $HOME/.claude/ckpt/repo"
