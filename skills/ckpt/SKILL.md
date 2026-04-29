---
name: ckpt
description: |
  AI 文件修改检查点系统。每次修改前自动保存旧版本，支持查看历史、回滚、分支探索。
  Trigger: /ckpt 命令，或提及"检查点"、"回滚"、"追溯修改"、"撤销AI修改"
allowed-tools: Bash, Read, Grep, Glob
version: 1.0.0
---

# ckpt — AI 文件修改检查点系统

Record file state BEFORE every AI modification. Trace, rollback, explore.

## Commands

Use `bash ~/.claude/plugins/ckpt/scripts/ckpt <command>`:

| Command | Description |
|---------|-------------|
| `init` | Initialize checkpoint repo |
| `pre <file>` | Manually save a file snapshot |
| `steps` | List all checkpoints with timestamps |
| `restore <N>` | Restore files to checkpoint N |
| `try <name>` | Create exploration branch |
| `end [msg]` | Squash all checkpoints into one clean commit |

## Behavior

- **Auto-snapshot**: Every Edit/Write/MultiEdit triggers `ckpt pre` before modification
- **Repo location**: `~/.claude/ckpt/repo/` (a bare git repo)
- **Only saves existing files** — new file writes are skipped silently

## Examples

```
bash ~/.claude/plugins/ckpt/scripts/ckpt steps
bash ~/.claude/plugins/ckpt/scripts/ckpt restore 5
bash ~/.claude/plugins/ckpt/scripts/ckpt try experiment-2
```
