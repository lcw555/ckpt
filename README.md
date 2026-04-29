# ckpt — AI 文件修改检查点系统

每次 Claude Code 修改文件**之前**自动保存旧版本。支持查看历史、瞬间回滚、分支探索。

## 安装

### 方式一：一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/lcw555/ckpt/master/install.sh | bash
```

脚本会自动完成：clone 仓库 → 初始化检查点 → 配置 settings.json hook → 添加 shell alias。

安装后**重启 Claude Code** 生效。

### 方式二：Claude Code 插件市场

```bash
claude /plugin marketplace add lcw555/ckpt
claude /plugin install ckpt@lcw555/ckpt
```

### 方式三：手动 Git Clone

```bash
git clone https://github.com/lcw555/ckpt.git ~/.claude/plugins/ckpt
bash ~/.claude/plugins/ckpt/install.sh
```

## 使用

### 快捷方式

在 `~/.bashrc` 中添加 alias，之后可直接用 `ckpt` 命令：

```bash
alias ckpt='bash ~/.claude/plugins/ckpt/scripts/ckpt'
```

或每次使用完整路径：

```bash
bash ~/.claude/plugins/ckpt/scripts/ckpt <命令>
```

### 命令

| 命令 | 说明 |
|------|------|
| `ckpt steps` | 查看所有检查点历史 |
| `ckpt restore <N>` | 回滚文件到第 N 个检查点 |
| `ckpt try <名称>` | 创建分支探索新方案 |
| `ckpt end "信息"` | 合并所有快照为一个提交 |
| `ckpt pre <文件>` | 手动保存某个文件的快照 |
| `ckpt init` | 初始化检查点仓库 |

### 示例

```bash
ckpt steps              # 列出所有检查点
ckpt restore 5          # 回滚到第 5 个检查点
ckpt try experiment-2   # 开分支探索
ckpt end "完成重构"     # 合并快照
```

## 验证是否生效

修改文件后运行 `ckpt steps`，如果看到新的 `ckpt-N` 记录则说明 hook 正常工作。

## 跨平台支持

支持 Linux、macOS、Windows (Git Bash / MSYS2)。脚本会自动：

- 检测 `python3` / `python`（Windows 上常为后者）
- 转换 Windows 盘符路径 (`C:/foo` → `/c/foo`) 和反斜杠
- 适配 shell rc 文件位置（`.bashrc` / `.bash_profile` / `.zshrc`）
- `chmod` 在 Windows 上静默跳过

## 故障排查

| 现象 | 原因 | 解决 |
|------|------|------|
| 编辑文件没有记录 | settings.json 未配置 hook | 按上面步骤手动添加 hook 配置并重启 |
| Hook 运行但未保存 | Python 未安装或不在 PATH | `which python3 python` 确认，安装 Python 3 |
| install.sh 报错 | 非 bash 环境运行 | 在 Git Bash 中执行 `bash install.sh` |
| 新文件未保存 | 设计如此 | ckpt 只保存已存在文件的旧版本，新文件跳过 |

## 原理

- **PreToolUse Hook**：在 Edit/Write/MultiEdit 执行前，自动调用 `ckpt pre <文件>` 保存旧版本
- **Git 存储**：所有快照保存在 `~/.claude/ckpt/repo/` 的 git 仓库中，每次保存打 `ckpt-N` tag
- **只保存已有文件**：新建文件不会被保存（首次写入没有"旧版本"可存）

## 许可

MIT
