#!/bin/bash
# Toggle "stay awake with lid closed" mode.
# Usage:  ./clamshell.sh on   |   ./clamshell.sh off
# Needs sudo (it'll prompt).

case "$1" in
  on)
    sudo pmset -a disablesleep 1
    # keep a caffeinate running in the background too (belt + suspenders)
    pkill -f "caffeinate -dimsu" 2>/dev/null
    nohup caffeinate -dimsu >/dev/null 2>&1 &
    echo "✅ Clamshell mode ON — lid can close, Mac stays awake."
    echo "   Run './clamshell.sh off' when you land."
    ;;
  off)
    sudo pmset -a disablesleep 0
    pkill -f "caffeinate -dimsu" 2>/dev/null
    echo "💤 Clamshell mode OFF — normal sleep restored."
    ;;
  *)
    echo "Usage: $0 {on|off}"
    exit 1
    ;;
esac
