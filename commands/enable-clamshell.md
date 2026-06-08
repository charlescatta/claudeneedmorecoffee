---
description: Enable true clamshell mode (stay awake with the lid closed) by authorizing passwordless pmset. One-time setup.
disable-model-invocation: true
argument-hint: ""
allowed-tools: Bash(sudo -n /usr/bin/pmset*)
---

You are setting up **true clamshell mode** for the `claudeneedmorecoffee` plugin. This lets the
Mac stay awake with the lid closed (on battery) while Claude works, by authorizing the user to
run `pmset -a disablesleep` without a password. Without this, the plugin still works but degrades
to `caffeinate`-only (awake with the lid open, or closed only on external power/display).

Follow these steps exactly:

1. **Check if it's already enabled.** Run:
   ```bash
   sudo -n /usr/bin/pmset -a disablesleep 1 2>/dev/null && sudo -n /usr/bin/pmset -a disablesleep 0 2>/dev/null && echo ENABLED || echo NOT_ENABLED
   ```
   - If the output is `ENABLED`: tell the user true clamshell mode is **already set up** — nothing
     to do — and stop here.

2. **If `NOT_ENABLED`,** this needs an interactive `sudo` password. I cannot provide it — neither
   my Bash tool nor the `!` prompt-prefix has a real terminal, so `sudo` can't ask for a password
   there. The user must run it in a **normal terminal app**.

   Tell the user to **open Terminal.app / iTerm (a real terminal — NOT here, NOT with `!`)** and
   paste this block **once**:

   ```bash
   sudo tee /etc/sudoers.d/claudeneedmorecoffee >/dev/null <<EOF
   $(id -un) ALL=(root) NOPASSWD: /usr/bin/pmset -a disablesleep 0, /usr/bin/pmset -a disablesleep 1
   EOF
   sudo chmod 440 /etc/sudoers.d/claudeneedmorecoffee
   ```

   Explain: it asks for their **login password once** and writes
   `/etc/sudoers.d/claudeneedmorecoffee`, authorizing exactly the two `pmset` commands the plugin
   uses. This is a **one-time** setup — it **never needs re-running, including after plugin
   updates**. They can undo it anytime with `sudo rm /etc/sudoers.d/claudeneedmorecoffee`.

3. **After the user says they've run it,** re-run the check from step 1.
   - `ENABLED` → confirm true clamshell mode is now active; it takes effect on the next prompt.
   - still `NOT_ENABLED` → report that setup didn't complete; the plugin will use caffeinate-only
     until it's fixed.

Keep your messages short and concrete. Always show the exact block the user must paste.
