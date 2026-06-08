# ☕ claudeneedmorecoffee

A Claude Code plugin that keeps your Mac awake **while Claude is working** and lets it
sleep again **when Claude finishes its work or you quit**. No more manually toggling
`caffeinate` before a long agentic task.

## How it works

The plugin wires three Claude Code hooks to a tiny pair of scripts:

| Hook              | Action            | When                              |
| ----------------- | ----------------- | --------------------------------- |
| `UserPromptSubmit`| `caffeine-on.sh`  | You send a prompt (Claude starts) |
| `Stop`            | `caffeine-off.sh` | Claude finishes the turn          |
| `SessionEnd`      | `caffeine-off.sh` | You quit Claude Code (safety net) |

Staying awake is done in two layers:

1. **`caffeinate -dimsu`** — keeps the system awake. No sudo needed. Works with the lid
   open, or closed while on external power/display.
2. **`pmset -a disablesleep 1`** — *true clamshell*, stays awake even with the lid closed
   on battery. This needs root, so it only runs if you install the one-time sudoers entry
   below. Without it the plugin silently falls back to caffeinate-only.

Concurrent Claude sessions are handled with a small reference count (one marker file per
`session_id`), so one session finishing won't yank coffee away from another that's still
working.

## Install

### 1. Install the plugin (from inside Claude Code)

```text
/plugin marketplace add charlescatta/claudeneedmorecoffee
/plugin install claudeneedmorecoffee@coffee
```

That's it — the hooks are active on your next prompt. (The repo is both a plugin and a
single-plugin marketplace named `coffee`.)

> **Local / dev install** instead: clone the repo and launch with
> `claude --plugin-dir /path/to/claudeneedmorecoffee`.

### 2. (Optional) Enable true clamshell mode

To stay awake with the lid **closed on battery**, authorize passwordless `pmset` once. The
easiest way is the bundled command — run it inside Claude Code and follow the prompt:

```text
/claudeneedmorecoffee:enable-clamshell
```

It checks whether setup is needed and, if so, hands you the exact one-time `sudo` line to run.
Prefer doing it by hand? Run the installer directly:

```bash
sudo ./scripts/install-sudoers.sh
```

Skip this entirely and everything still works — just caffeinate-only (awake with the lid open,
or closed on external power/display).

## Verify

```bash
# Simulate a prompt: Mac should now be kept awake
echo '{"session_id":"test"}' | ./scripts/caffeine-on.sh
pmset -g | grep -i disablesleep        # -> 1 (if sudoers installed)
pgrep -fl "caffeinate -dimsu"          # -> a running process

# Simulate finishing: Mac released
echo '{"session_id":"test"}' | ./scripts/caffeine-off.sh
pmset -g | grep -i disablesleep        # -> 0
pgrep -fl "caffeinate -dimsu"          # -> nothing
```

## Notes

- Between turns (Claude idle, you reading/typing) the Mac may sleep — that's the intended
  "off when it finishes its work" behavior. To keep it awake for the whole session instead,
  change `UserPromptSubmit` to `SessionStart` in `hooks/hooks.json`.
- `clamshell.sh` is kept as a manual `on`/`off` override:
  `./clamshell.sh on` / `./clamshell.sh off`.

## Uninstall

```bash
sudo rm /etc/sudoers.d/claudeneedmorecoffee   # if you installed it
# then disable/remove the plugin via /plugin, or drop the --plugin-dir flag
```
