---
title: Alliance — Running Jobs (SLURM)
type: source
updated: 2026-05-02
sources: [alliance-docs/Running jobs.md]
tags: [alliance, slurm, sbatch, salloc, jobs, hpc]
---

# Alliance — Running Jobs (SLURM)

Reference for submitting and managing jobs on Alliance clusters via SLURM.

Source: https://docs.alliancecan.ca/wiki/Running_jobs

## The rule: all compute goes through the scheduler

**Never run heavy compute on the login node.** Exceptions: compilation, quick tests under ~10 CPU-minutes and ~4 GB RAM. Everything else: `sbatch` or `salloc`.

## Submit a batch job

```bash
sbatch myjob.sh
```

Minimal job script:

```bash
#!/bin/bash
#SBATCH --account=rrg-<pi>
#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16000M
#SBATCH --gres=gpu:1           # remove if no GPU needed

module load python/3.11
source .venv/bin/activate
python train.py
```

Output goes to `slurm-JOBID.out` in the directory where you ran `sbatch`.

Replace `rrg-<pi>` with your actual RAC allocation (e.g. `rrg-smith`). Run `sshare -U` to see which accounts you belong to.

## Interactive session

```bash
# CPU only
salloc --account=rrg-<pi> --cpus-per-task=4 --mem=16000M --time=1:00:00

# With GPU
salloc --account=rrg-<pi> --gres=gpu:1 --cpus-per-task=4 --mem=32000M --time=1:00:00
```

**Interactive jobs ≤ 3 hours** start almost immediately (dedicated test nodes). Longer interactive jobs wait in the regular queue — can take hours or days.

## Check your jobs

```bash
sq                          # list only your jobs (preferred)
squeue -u $USER             # same, explicit
scancel JOBID               # cancel a job
scancel -u $USER            # cancel all your jobs
scancel -t PENDING -u $USER # cancel only queued jobs
```

Do not poll `sq` from a script — it adds scheduler load. Use email notifications instead (`#SBATCH --mail-user`, `#SBATCH --mail-type=ALL`).

## Memory options

```bash
--mem=32000M          # total memory per node
--mem-per-cpu=4000M   # memory per CPU core (alternative)
```

Request less than the node maximum — some RAM is reserved for OS. On nodes labeled "128G", request ~125G or less.

## Array jobs (checkpointing / parameter sweeps)

Run 10 sequential jobs, only one at a time:

```bash
#SBATCH --array=1-10%1
```

Each job gets `$SLURM_ARRAY_TASK_ID`. Use it (or simple checkpoint detection) to resume:

```bash
if test -e checkpoint.pt; then
    python train.py --resume checkpoint.pt
else
    python train.py
fi
```

## Set default account in ~/.bashrc

To avoid specifying `--account` every time:

```bash
export SLURM_ACCOUNT=rrg-<pi>
export SBATCH_ACCOUNT=$SLURM_ACCOUNT
export SALLOC_ACCOUNT=$SLURM_ACCOUNT
```

Note: env variable takes priority over `#SBATCH --account` in the script. Override with a command-line argument.

## Connections

- [[narval-cheat-sheet]] — quick command reference
- [[alliance-ml-tutorial]] — ML-specific workflow with checkpointing
- [[alliance-multi-instance-gpu]] — use MIG instances for small GPU jobs
- [[alliance-monitoring-jobs]] — observing jobs (sq, scontrol, seff, sacct); the feedback loop for right-sizing future requests
