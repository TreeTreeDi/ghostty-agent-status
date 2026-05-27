# ghostty-agent-status

Traffic-light status indicators for Claude Code agent tabs in [Ghostty](https://ghostty.org/) terminal.

![demo](https://user-images.githubusercontent.com/placeholder/demo.png)

## What It Does

When you run multiple Claude Code agents in different Ghostty tabs, this plugin adds a colored emoji to each tab title so you can tell at a glance which agent is busy:

| Emoji | State | Trigger |
|-------|-------|---------|
| 🔴 | **Starting** | Agent session just started |
| 🟡 | **Processing** | You sent a prompt, agent is working |
| 🟢 | **Idle** | Agent finished, waiting for your next input |

## Requirements

- [Ghostty](https://ghostty.org/) terminal
- [Claude Code](https://claude.ai/code) CLI
- `jq` (optional, for robust JSON parsing; script falls back to `sed`)
- `git` (optional, for repo-name detection)

## Installation

### 1. Install via Marketplace（推荐）

在 Claude Code 交互式会话中输入：

```
/plugin add https://github.com/TreeTreeDi/ghostty-agent-status
```

选择 `ghostty-agent-status` 插件安装，然后运行 `/reload-plugins` 生效。

### 2. Manual Install

如果 marketplace 方式不可用，直接 clone 到 plugins 目录：

```bash
git clone https://github.com/TreeTreeDi/ghostty-agent-status.git \
  ~/.claude/plugins/ghostty-agent-status
```

然后在 Claude Code 中运行 `/reload-plugins`。

### 2. Configure Ghostty

Add to `~/.config/ghostty/config`:

```ini
# Allow hook scripts to control tab titles
shell-integration-features = no-title
```

> **Note:** This disables Ghostty's automatic directory-based title updates. The hook script will use the project/directory name instead.

Restart Ghostty for the change to take effect.

## Usage

1. Open multiple Ghostty tabs
2. Start Claude Code (`claude`) in each tab (ideally in different project directories)
3. Send a prompt — the tab title turns 🟡
4. Wait for the response — the tab title turns 🟢

## Customization

### Change the emoji mapping

Edit `hooks/ghostty-tab-status.sh` and modify the `case` statement:

```bash
case "$event" in
  SessionStart)     emoji="🔴" ;;
  UserPromptSubmit) emoji="🟡" ;;
  Stop)             emoji="🟢" ;;
  *)                emoji="⚪" ;;
esac
```

### Include the current model name in the title

The `SessionStart` hook input includes a `model` field. To display it:

```bash
model=$(echo "$input" | jq -r '.model // ""')
[[ -n "$model" ]] && name="${name} (${model})"
```

## How It Works

The plugin registers three Claude Code [hooks](https://docs.anthropic.com/en/docs/claude-code/hooks):

- `SessionStart` — fired when a Claude Code session begins
- `UserPromptSubmit` — fired when you submit a prompt
- `Stop` — fired when the assistant finishes its response

Each hook executes `ghostty-tab-status.sh`, which:

1. Reads the hook's JSON input from stdin
2. Parses the event type and current working directory
3. Resolves a display name (git repo name → directory name)
4. Sends an [OSC 0 escape sequence](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h3-Operating-System-Commands) to update the current Ghostty tab title

Because hooks are executed directly by the Claude Code main process, their stdout reaches the TTY unfiltered — unlike subprocess output, which is captured by Claude Code.

## License

MIT
