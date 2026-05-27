#!/usr/bin/env bash
# ghostty-tab-status.sh
# Traffic-light status indicator for Claude Code agent tabs in Ghostty terminal.
#
# This script is triggered by Claude Code hooks (SessionStart, UserPromptSubmit, Stop)
# and updates the current Ghostty tab title via OSC 0 escape sequences.

set -euo pipefail

# ── 1. Read JSON input from stdin ──
input=$(cat)

# ── 2. Parse hook_event_name and cwd ──
# Prefer jq for robust JSON parsing; fall back to sed for compatibility.
if command -v jq >/dev/null 2>&1; then
  event=$(echo "$input" | jq -r '.hook_event_name // "Unknown"')
  cwd=$(echo "$input" | jq -r '.cwd // "."')
else
  event=$(echo "$input" | sed -n 's/.*"hook_event_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
  cwd=$(echo "$input" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
  [[ -z "$cwd" ]] && cwd="$PWD"
fi

# ── 3. Resolve display name: git repo name > directory name ──
name=""
if [[ -n "$cwd" && -d "$cwd" ]]; then
  if command -v git >/dev/null 2>&1 && git -C "$cwd" rev-parse --show-toplevel >/dev/null 2>&1; then
    name=$(basename "$(git -C "$cwd" rev-parse --show-toplevel)")
  else
    name=$(basename "$cwd")
  fi
else
  name=$(basename "$PWD")
fi

# ── 4. Map event to traffic-light emoji ──
# Semantic meaning:
#   🔴 red    = agent just started / initializing
#   🟡 yellow = agent is processing user prompt
#   🟢 green  = agent finished, waiting for user input
#   ⚪ white  = unknown event (fallback)
case "$event" in
  SessionStart)     emoji="🔴" ;;
  UserPromptSubmit) emoji="🟡" ;;
  Stop)             emoji="🟢" ;;
  *)                emoji="⚪" ;;
esac

# ── 5. Send OSC 0 to update the current tab title ──
# Format: ESC ] 0 ; <title> BEL
printf "\033]0;%s %s\007" "$emoji" "$name"

exit 0
