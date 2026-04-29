#!/bin/bash
# ckpt plugin installer (cross-platform: Linux, macOS, Windows Git Bash)
# Usage: bash install.sh
set -e

PLUGIN_DIR="$HOME/.claude/plugins/ckpt"
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo "$PWD")"

echo "=== ckpt installer ==="

# ---- detect platform ----
case "$(uname -s)" in
    Linux*)   PLATFORM=linux ;;
    Darwin*)  PLATFORM=macos ;;
    MINGW*|MSYS*|CYGWIN*)  PLATFORM=windows ;;
    *)        PLATFORM=unknown ;;
esac

# ---- step 1: ensure plugin files in place ----
if [ -f "$SCRIPT_DIR/scripts/ckpt" ]; then
    echo "[1/4] Plugin files ready at $SCRIPT_DIR"
    PLUGIN_DIR="$SCRIPT_DIR"
else
    echo "[1/4] Copying plugin to $PLUGIN_DIR ..."
    mkdir -p "$PLUGIN_DIR"
    cp -r "$SCRIPT_DIR"/* "$PLUGIN_DIR/"
fi

# ---- step 2: make scripts executable ----
echo "[2/4] Setting executable permissions..."
chmod +x "$PLUGIN_DIR/scripts/ckpt" 2>/dev/null || true
chmod +x "$PLUGIN_DIR/hooks/ckpt-hook.sh" 2>/dev/null || true

# ---- step 3: initialize checkpoint repo ----
echo "[3/4] Initializing checkpoint repository..."
bash "$PLUGIN_DIR/scripts/ckpt" init

# ---- step 4: add shell alias ----
echo "[4/4] Configuring shell alias..."
SHELL_RC=""
for f in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.zshrc"; do
    [ -f "$f" ] && SHELL_RC="$f" && break
done

# On Windows Git Bash, create .bashrc if no rc file exists
if [ -z "$SHELL_RC" ] && [ "$PLATFORM" = "windows" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

CKPT_PATH="$PLUGIN_DIR/scripts/ckpt"
# Normalize backslashes to forward slashes (Windows)
CKPT_PATH="${CKPT_PATH//\\//}"

if [ -n "$SHELL_RC" ]; then
    if grep -q 'ckpt' "$SHELL_RC" 2>/dev/null; then
        echo "       → alias already exists in $(basename "$SHELL_RC")"
    else
        echo "alias ckpt='bash \"$CKPT_PATH\"'" >> "$SHELL_RC"
        echo "       → alias added to $(basename "$SHELL_RC")"
        echo "       → Run 'source $SHELL_RC' or restart terminal to use 'ckpt'"
    fi
else
    echo "       → No shell rc file found, skip alias setup"
fi

# ---- done ----
echo ""
echo "✓ ckpt installed!"
echo ""
echo "  [重要] 请确认 ~/.claude/settings.json 中包含 ckpt hook 配置:"
echo "    \"hooks\": {"
echo "      \"PreToolUse\": [{"
echo "        \"matcher\": \"Edit|Write|MultiEdit\","
echo "        \"hooks\": [{"
echo "          \"type\": \"command\","
echo "          \"command\": \"bash ~/.claude/plugins/ckpt/hooks/ckpt-hook.sh\","
echo "          \"timeout\": 10"
echo "        }]"
echo "      }]"
echo "    }"
echo ""
echo "  Auto-snapshot: restart Claude Code to activate the hook"
echo "  Manual:        bash $PLUGIN_DIR/scripts/ckpt steps"
echo "  Repo:          $HOME/.claude/ckpt/repo"
echo ""
echo "  Share with others: cd ~/.claude/plugins && zip -r ckpt.zip ckpt/"
