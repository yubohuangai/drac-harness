---
title: Alliance — Monitoring Jobs
type: source
updated: 2026-05-02
sources: [alliance-docs/Monitoring jobs.md]
tags: [alliance, slurm, monitoring, seff, sacct, sq, nvidia-smi]
---

# Alliance — Monitoring Jobs

Canonical Alliance doc on how to observe job state — before, during, and after a run. The critical takeaway is **`seff <jobid>` after a job completes**: it tells you whether your CPU/memory request was right-sized, which is the feedback loop for future SLURM resource requests.

Source: https://docs.alliancecan.ca/wiki/Monitoring_jobs

## Running jobs

### List your own
```
squeue -u $USER        # or just: sq
```
`sq` is the Alliance wrapper — less typing, same output.

Filter by state:
```
squeue -u $USER -t RUNNING
squeue -u $USER -t PENDING
```

### Deep-dive on one job
```
scontrol show job -dd <jobid>
```
Prints every field SLURM tracks: node list, partition, QOS, start/end times, requested vs assigned resources, reason codes.

> **Don't poll `squeue` in a tight loop.** Alliance explicitly warns: *"Do not run squeue from a script or program at high frequency (e.g., every few seconds). Responding to squeue adds load to Slurm and may interfere with its performance."* Use `sstat`/`sacct` for automated monitoring instead.

### Live metrics on a running job
```
sstat -j <jobid> --format=JobID,MaxRSS,AveCPU,AveRSS
```
Analog of `sacct` but for jobs still running.

### Email notifications
```
#SBATCH --mail-user=your.email@example.com
#SBATCH --mail-type=ALL       # or BEGIN, END, FAIL
```

### Output buffering caveat
`stdout`/`stderr` from non-interactive SLURM jobs are **buffered** — there can be a many-minute delay before you see output in the log file. Alliance deliberately doesn't recommend disabling buffering (it protects filesystem performance). If you need real-time output: use an interactive `salloc`.

## Completed jobs

### `seff` — the right-sizing feedback loop
```
$ seff 12345678
Job ID: 12345678
State: COMPLETED (exit code 0)
Cores: 1
CPU Utilized: 02:48:58
CPU Efficiency: 99.72% of 02:49:26 core-walltime
Memory Utilized: 213.85 MB
Memory Efficiency: 0.17% of 125.00 GB
```

Two numbers to watch:
- **CPU Efficiency < ~70%** → you over-requested CPUs, or your code isn't using them. Drop `--cpus-per-task` or fix the dataloader.
- **Memory Efficiency < ~20%** → you wildly over-requested RAM. Cut `--mem=` by 3–5×.

The loop: request → run → `seff` → adjust next request.

### `sacct` — detailed history
```
sacct -j <jobid>
sacct -j <jobid> --format=JobID,JobName,MaxRSS,MaxRSSNode,Elapsed,State
```

Rows in `sacct` output:
- **`.bat+`** (batch step) — your submission script. Usually where the work happens.
- **`.0`, `.1`, …** — steps created by `srun` inside the script.
- **`.ext+`** (extern) — SLURM's prologue/epilogue; normally ignorable.

Node-failure restarts: add `--duplicates` to see every retry, not just the last.

**MaxRSS** is the peak resident memory — use this, not your original `--mem=` request, to decide next job's memory.

## Attaching to a running job

Connect to the node and launch auxiliary processes:

```
# Monitor GPU usage in-place
srun --jobid <jobid> --overlap --pty watch -n 30 nvidia-smi
```

Multi-pane with tmux inside the compute node:
```
srun --jobid <jobid> --overlap --pty tmux new-session -d 'htop -u $USER' \; split-window -h 'watch nvidia-smi' \; attach
```

**Only works for `sbatch` jobs, not interactive `salloc`** (for interactive jobs, just open more tmux panes locally).

Shared-resource warning: processes launched via `srun --overlap` eat from the same cgroup. Don't run heavy monitoring tools — they can OOM-kill your main job.

## GPU-specific

For more than quick `nvidia-smi`: use **NVTOP** — interactive GPU top tool (see separate Alliance doc on NVTOP for details).

## Practical workflow

1. Submit with conservative guesses.
2. While running: `sq` to confirm it's scheduled; `srun --jobid X --overlap --pty nvidia-smi` to verify GPU is actually being used.
3. After completion: `seff <jobid>`.
4. If efficiency < 70% CPU or < 20% memory → right-size the next request downward.
5. If job hit walltime → bump `--time` next run, or chain with `--array=1-N%1` + checkpoints.

## Connections

- [[alliance-running-jobs]] — how to *submit* jobs (the action); this page is how to *observe* them
- [[alliance-workflow-cheatsheet]] — end-to-end routine
- [[narval-cheat-sheet]] — command quick-reference
