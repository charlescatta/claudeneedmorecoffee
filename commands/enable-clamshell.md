---
description: Enable true clamshell mode (stay awake with the lid closed) by authorizing passwordless pmset. One-time setup.
disable-model-invocation: true
argument-hint: ""
allowed-tools: Bash(sudo -n /usr/bin/pmset*)
---

You are setting up **true clamshell mode** for the `claudeneedmorecoffee` plugin. This lets the
Mac stay awake with the lid closed (on battery) while Claude works, by authorizing the user to
run `pmset -a disablesleep` without a password. Without this, the plugin still works but degrades
to `caffeinate`-only (awake with lid open, or closed only on external power/display).

Follow these steps exactly:

1. **Check if it's already enabled.** Run:
   ```bash
   sudo -n /usr/bin/pmset -a disablesleep 1 2>/dev/null && sudo -n /usr/bin/pmset -a disablesleep 0 2>/dev/null && echo ENABLED || echo NOT_ENABLED
   ```
   - If the output is `ENABLED`: tell the user true clamshell mode is **already set up** — nothing
     to do — and stop here.

2. **If `NOT_ENABLED`,** the setup script needs an interactive sudo password, which I (Claude)
   cannot provide — my shell is non-interactive. So hand it to the user to run themselves.
   - The installer lives at `$CLAUDE_PLUGIN_ROOT/scripts/install-sudoers.sh`. Resolve that to a
     concrete absolute path (echo `$CLAUDE_PLUGIN_ROOT` if needed).
   - Then tell the user to paste this line **into their next prompt** (the leading `!` runs it in
     their terminal, where the password prompt works):

     ```
     ! sudo /absolute/path/to/scripts/install-sudoers.sh
     ```

     Substitute the real absolute path. Explain it will ask for their **login password once** and
     write `/etc/sudoers.d/claudeneedmorecoffee` (validated with `visudo`). They can undo it later
     with `sudo rm /etc/sudoers.d/claudeneedmorecoffee`.

3. **After the user runs it,** re-run the check from step 1.
   - `ENABLED` → confirm true clamshell mode is now active; it takes effect on the next prompt.
   - still `NOT_ENABLED` → report that setup didn't complete and the plugin will use
     caffeinate-only until it's fixed; offer to show the installer's output.

Keep your messages short and concrete. Always show the exact command the user must paste.
