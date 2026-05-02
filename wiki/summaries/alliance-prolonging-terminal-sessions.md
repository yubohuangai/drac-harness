---
title: Alliance — Prolonging Terminal Sessions
type: source
updated: 2026-05-02
sources: [alliance-docs/Prolonging terminal sessions.md]
tags: [hpc, alliance, tmux, ssh, terminal, screen]
---

# Alliance — Prolonging Terminal Sessions

How to keep SSH sessions alive and survive disconnections on Alliance clusters.

Source: https://docs.alliancecan.ca/wiki/Prolonging_terminal_sessions/en

## Method 1 — SSH keepalive (always do this)

Add to `~/.ssh/config` on your **local machine**:

```
Host *
    ServerAliveInterval 240
```

Sends a keepalive signal every 4 minutes. Prevents idle disconnections.

## Method 2 — tmux (recommended for interactive work)

Start a tmux session on the login node. If your SSH connection drops, the session keeps running. Reconnect and resume where you left off.

### Critical Alliance-specific caveat: login node pinning

Most Alliance clusters expose multiple login nodes (e.g. `narval1`, `narval2`, …). `ssh narval.alliancecan.ca` lands you on a random one. Your tmux session only exists on the specific node it was started on.

**Fix: always SSH to a specific login node:**

```bash
ssh user@narval1.alliancecan.ca   # always land on narval1
```

Start tmux there, and always reconnect to that same node. **If the login node reboots, the session is lost** — and login-node reboots happen more often than the docs imply, sometimes overnight. Treat tmux sessions as non-persistent across days; always be ready to recreate.

### Basic tmux workflow

```bash
# Connect to a specific login node
ssh user@narval1.alliancecan.ca

# Start or reattach
tmux new -s work      # new named session
tmux a -t work        # reattach later

# Key shortcuts
Ctrl+B D              # detach (session keeps running)
Ctrl+B C              # new window
Ctrl+B N              # next window
Ctrl+B [              # scroll mode (Page-Up/Down, mouse)
Esc                   # exit scroll mode
```

### Nested tmux issue (inside SLURM jobs)

If you submit a job from within tmux and then try to start tmux *inside* the job, you get `lost server`. Fix:

```bash
unset TMUX   # run before starting tmux inside a job
```

Or use `screen` inside jobs (avoids the nesting conflict).

## Method 3 — GNU Screen (alternative)

```bash
screen -S mysession       # start named session
screen -list              # list sessions
screen -d -r mysession    # reattach
```

Useful inside SLURM jobs where nested tmux is problematic.

## Connections

- [[narval-cheat-sheet]] — general cluster commands
- [[alliance-getting-started]]
- [[tmux-cheat-sheet]] — full key reference
