# CLAUDE.md

Development guide for ghostty-agent-status plugin.

## Architecture

```
ghostty-agent-status/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── hooks/
│   ├── hooks.json           # Hook registrations (SessionStart, UserPromptSubmit, Stop)
│   └── ghostty-tab-status.sh # Core script: event → emoji → OSC 0
├── README.md
└── CLAUDE.md
```

## Hook Input Schemas

Claude Code passes JSON to each hook via stdin.

### SessionStart

```json
{
  "hook_event_name": "SessionStart",
  "session_id": "...",
  "cwd": "/Users/dsy/code/project",
  "source": "startup",
  "model": "claude-sonnet-4-6"
}
```

### UserPromptSubmit

```json
{
  "hook_event_name": "UserPromptSubmit",
  "session_id": "...",
  "cwd": "/Users/dsy/code/project",
  "prompt": "user message here"
}
```

### Stop

```json
{
  "hook_event_name": "Stop",
  "session_id": "...",
  "cwd": "/Users/dsy/code/project",
  "stop_hook_active": true,
  "last_assistant_message": "..."
}
```

## Testing Locally

Test the script directly without Claude Code:

```bash
# Simulate SessionStart
echo '{"hook_event_name":"SessionStart","cwd":"/Users/dsy/code/project"}' \
  | bash hooks/ghostty-tab-status.sh

# Simulate UserPromptSubmit
echo '{"hook_event_name":"UserPromptSubmit","cwd":"/Users/dsy/code/project"}' \
  | bash hooks/ghostty-tab-status.sh

# Simulate Stop
echo '{"hook_event_name":"Stop","cwd":"/Users/dsy/code/project"}' \
  | bash hooks/ghostty-tab-status.sh
```

Watch the current Ghostty tab title change after each command.

## Release Checklist

1. Update version in `.claude-plugin/plugin.json`
2. Update `CHANGELOG.md` (if present)
3. Tag with semantic version: `git tag v1.0.0`
4. Push tag: `git push origin v1.0.0`
