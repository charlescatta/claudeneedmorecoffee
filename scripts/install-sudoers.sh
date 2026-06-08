#!/bin/bash
# One-time setup: allow this user to run `pmset -a disablesleep 0|1` without a
# password, so the plugin's hooks can enable true clamshell (lid-closed) mode.
#
# Claude Code hooks run non-interactively and cannot prompt for a sudo password,
# so this passwordless entry is the only way the pmset half can run from a hook.
# Without it the plugin still works — it just degrades to caffeinate-only.
#
# Run once:  sudo ./scripts/install-sudoers.sh
set -euo pipefail

DEST="/etc/sudoers.d/claudeneedmorecoffee"

# The invoking (non-root) user — works whether run via sudo or as root.
USER_NAME="${SUDO_USER:-$(whoami)}"

if [ "$(id -u)" -ne 0 ]; then
  echo "❌ Needs root. Run: sudo $0" >&2
  exit 1
fi

PMSET="/usr/bin/pmset"
RULE="$USER_NAME ALL=(root) NOPASSWD: $PMSET -a disablesleep 0, $PMSET -a disablesleep 1"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT
printf '%s\n' "$RULE" > "$TMP"

# Validate before installing — a broken sudoers file is dangerous.
if ! visudo -cf "$TMP" >/dev/null; then
  echo "❌ Generated sudoers rule failed validation; aborting." >&2
  exit 1
fi

install -m 0440 -o root -g wheel "$TMP" "$DEST"
echo "✅ Installed $DEST"
echo "   $USER_NAME can now run pmset disablesleep without a password."
echo "   Verify:  sudo -n $PMSET -a disablesleep 1 && echo ok && sudo -n $PMSET -a disablesleep 0"
echo "   Remove later:  sudo rm $DEST"
