#!/bin/bash
# ckpt plugin installer
# Usage: bash install.sh
set -e

PLUGIN_DIR="$HOME/.claude/plugins/ckpt"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== ckpt installer ==="

# If running from the plugin folder itself
if [ -f "$SCRIPT_DIR/scripts/ckpt" ]; then
    echo "[1/3] Plugin files ready at $SCRIPT_DIR"
    PLUGIN_DIR="$SCRIPT_DIR"
else
    echo "[1/3] Copying plugin to $PLUGIN_DIR ..."
    mkdir -p "$PLUGIN_DIR"
    cp -r "$SCRIPT_DIR"/* "$PLUGIN_DIR/"
fi

# Make scripts executable
chmod +x "$PLUGIN_DIR/scripts/ckpt" "$PLUGIN_DIR/hooks/ckpt-hook.sh" 2>/dev/null || true

# Initialize checkpoint repo
echo "[2/3] Initializing checkpoint repository..."
bash "$PLUGIN_DIR/scripts/ckpt" init

# Terminal shortcut (optional)
SHELL_RC=""
if [ -f "$HOME/.bashrc" ]; then SHELL_RC="$HOME/.bashrc"; fi
if [ -f "$HOME/.zshrc" ]; then SHELL_RC="$HOME/.zshrc"; fi

if [ -n "$SHELL_RC" ] && ! grep -q 'ckpt' "$SHELL_RC" 2>/dev/null; then
    echo "[3/3] Adding ckpt alias to $SHELL_RC ..."
    echo "alias ckpt='bash $PLUGIN_DIR/scripts/ckpt'" >> "$SHELL_RC"
    echo "       → Run 'source $SHELL_RC' or restart terminal to use 'ckpt' command"
else
    echo "[3/3] Alias already configured, or no .bashrc/.zshrc found"
fi

echo ""
echo "✓ ckpt installed!"
echo ""
echo "  Auto-snapshot: restart Claude Code to activate the hook"
echo "  Manual:        bash $PLUGIN_DIR/scripts/ckpt steps"
echo "  Repo:          $HOME/.claude/ckpt/repo"
echo ""
echo "  Share with others: zip the plugin folder and send it over"
echo "    cd ~/.claude/plugins && zip -r ckpt.zip ckpt/"
