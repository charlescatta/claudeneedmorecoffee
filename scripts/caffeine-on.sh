#!/bin/bash
# Hook: UserPromptSubmit — Claude started working, keep the Mac awake.
# Reads hook JSON on stdin, marks this session active, ensures the Mac stays awake.
# Always exits 0: a sleep-management hook must never block Claude.
set -uo pipefail

STATE="${CLAUDE_PLUGIN_DATA:-$HOME/.cache/claudeneedmorecoffee}/active"

# Identify this session so concurrent Claude sessions don't fight over coffee.
session_id="$(jq -r '.session_id // empty' 2>/dev/null)"
[ -z "$session_id" ] && session_id="unknown"

mkdir -p "$STATE"
# Sanitize: keep the marker filename to a safe basename.
touch "$STATE/$(basename "$session_id")" 2>/dev/null || true

# Belt: caffeinate keeps the system awake without sudo (lid open / on power).
if ! pgrep -f "caffeinate -dimsu" >/dev/null 2>&1; then
  nohup caffeinate -dimsu >/dev/null 2>&1 &
fi

# Suspenders: true clamshell (lid closed) needs root. Only works if the
# passwordless-sudo entry from scripts/install-sudoers.sh is installed;
# otherwise this silently no-ops and we degrade to caffeinate-only.
sudo -n /usr/bin/pmset -a disablesleep 1 >/dev/null 2>&1 || true

exit 0
