# ckpt — AI 文件修改检查点系统

每次 Claude Code 修改文件**之前**自动保存旧版本。支持查看历史、瞬间回滚、分支探索。

## 安装

### 方式一：Claude Code 插件市场

```bash
# 添加市场
claude /plugin marketplace add HUGE/ckpt

# 安装插件
claude /plugin install ckpt@HUGE/ckpt
```

### 方式二：Git Clone

```bash
git clone https://github.com/HUGE/ckpt.git ~/.claude/plugins/ckpt
bash ~/.claude/plugins/ckpt/install.sh
```

### 方式三：手动安装

将本仓库复制到 `~/.claude/plugins/ckpt/`，运行 `install.sh`。

## 使用

```bash
ckpt steps          # 查看所有检查点
ckpt restore 3      # 回滚到第 3 个检查点
ckpt try 新方案     # 创建分支探索
ckpt end "最终版"   # 合并所有快照
```

## 原理

- **PreToolUse Hook**：在 Edit/Write/MultiEdit 执行前，自动调用 `ckpt pre <文件>` 保存旧版本
- **Git 存储**：所有快照保存在 `~/.claude/ckpt/repo/` 的 git 仓库中
- **零配置**：安装即用，无需额外设置

## 许可

MIT
