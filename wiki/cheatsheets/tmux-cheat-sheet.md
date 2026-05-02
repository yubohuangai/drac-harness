---
title: Tmux Cheatsheet
type: cheatsheet
updated: 2026-05-02
sources: []
tags: [tmux, terminal, reference, cheatsheet]
---

# Tmux Cheatsheet

Quick reference. Default prefix is **Ctrl+B**.

Source: https://tmuxcheatsheet.com/

---

## Sessions

### Shell commands

| Command | Action |
|---------|--------|
| `tmux new -s mysession` | New named session |
| `tmux new-session -A -s mysession` | Attach or create `mysession` |
| `tmux a -t mysession` | Attach to `mysession` |
| `tmux ls` | List sessions |
| `tmux kill-session -t mysession` | Kill `mysession` |
| `tmux kill-session -a` | Kill all sessions except current |

### Keys (after Ctrl+B)

| Keys | Action |
|------|--------|
| `$` | Rename session |
| `d` | Detach (session keeps running) |
| `s` | Show all sessions |
| `w` | Session and window preview |

---

## Windows

| Keys | Action |
|------|--------|
| `c` | Create window |
| `,` | Rename current window |
| `&` | Close current window |
| `p` / `n` | Previous / next window |
| `0`–`9` | Switch to window by number |

---

## Panes

| Keys | Action |
|------|--------|
| `%` | Split vertically (side by side) |
| `"` | Split horizontally (stacked) |
| ↑ ↓ ← → | Move focus to adjacent pane |
| `z` | Zoom / unzoom current pane |
| `x` | Close current pane |
| `!` | Turn pane into its own window |
| `q` then `0`–`9` | Focus pane by number |
| `Ctrl` + ↑ ↓ ← → | Resize pane |

---

## Copy / scroll mode

### Setup

```bash
# In ~/.tmux.conf — enable vi keys in copy mode
set -g mode-keys vi
```

### Keys

| Keys | Action |
|------|--------|
| `C-b [` | Enter copy/scroll mode |
| `q` | Quit copy mode |
| ↑ ↓ / PgUp PgDn | Scroll |
| `u` / `d` | Half-page up / down (vi mode only) |
| `Space` | Start selection |
| `Enter` | Copy selection to tmux buffer |
| `Esc` | Clear selection |
| `C-b ]` | Paste tmux buffer |

**On macOS:** Hold **Shift** while clicking and dragging to copy with the system clipboard (bypasses tmux). Paste with **Cmd+V**.

---

## Mouse

```bash
# In ~/.tmux.conf
set -g mouse on
```

With mouse on: **Shift+drag** to select text for the system clipboard.

---

## After SSH disconnect (trackpad garbage characters)

When tmux disconnects abruptly, it can leave mouse reporting mode on. Tapping the trackpad sends escape codes into the terminal.

```bash
printf '\033[?1000l'
```

Then reconnect:

```bash
ssh user@<cluster>1.alliancecan.ca
tmux a -t work
```

---

## Misc

| Keys / command | Action |
|----------------|--------|
| `C-b :` | Command mode |
| `C-b ?` | List key bindings |
| `set -g OPTION` | Set option for all sessions |
| `set mouse on` | Enable mouse (command mode) |
| `unset TMUX` | Fix "lost server" when nesting tmux inside SLURM jobs |

---

## Connections

- [[alliance-workflow-cheatsheet]] — how tmux fits into the Alliance workflow
- [[alliance-prolonging-terminal-sessions]] — login-node pinning, nested tmux fix
