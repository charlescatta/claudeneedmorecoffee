#!/bin/bash
# Hook: Stop / SessionEnd — Claude finished its work (or the CLI exited).
# Unmarks this session; only when no sessions remain active does it actually
# release the Mac back to normal sleep. Always exits 0.
set -uo pipefail

STATE="${CLAUDE_PLUGIN_DATA:-$HOME/.cache/claudeneedmorecoffee}/active"

session_id="$(jq -r '.session_id // empty' 2>/dev/null)"
[ -z "$session_id" ] && session_id="unknown"

rm -f "$STATE/$(basename "$session_id")" 2>/dev/null || true

# If any other Claude session is still working, leave the coffee on.
if [ -d "$STATE" ] && [ -n "$(ls -A "$STATE" 2>/dev/null)" ]; then
  exit 0
fi

# Last one out: stop keeping the Mac awake.
pkill -f "caffeinate -dimsu" >/dev/null 2>&1 || true
sudo -n /usr/bin/pmset -a disablesleep 0 >/dev/null 2>&1 || true

exit 0
