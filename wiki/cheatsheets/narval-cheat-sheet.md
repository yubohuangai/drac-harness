---
title: Narval Cheatsheet
type: cheatsheet
updated: 2026-05-02
sources: []
tags: [hpc, narval, alliance, slurm, cheatsheet, commands]
---

# Narval Cheatsheet

Command reference for Narval. Most commands also work on the H100 clusters (Rorqual, Fir, Nibi, Trillium) — Narval is just the most-documented example.

In examples, `<pi>` is your supervisor's last name; replace with your real account.

## Login

```bash
ssh user@narval.alliancecan.ca       # MFA required (Duo Push or TOTP)
ssh -Y user@narval.alliancecan.ca    # with X11 forwarding (for GUIs)
```

For interactive work, pin to a specific login node (e.g. `narval1`) so tmux survives — see [[alliance-prolonging-terminal-sessions]].

## Useful paths

```bash
$HOME                              # /home/$USER  (50 GB, backed up — scripts, configs)
$SCRATCH                           # /scratch/$USER  (20 TB, NOT backed up, auto-purged after 60 days)
/project/rrg-<pi>/$USER/           # ← store your data here (RAC allocation, backed up)
/project/def-<pi>/$USER/           # default allocation (smaller, often near file-count quota)
$SLURM_TMPDIR                      # fast local node storage during a job only
```

## Storage commands

```bash
diskusage_report                    # your quota across all filesystems
diskusage_report --per_user         # breakdown per user in shared projects
diskusage_explorer /project/rrg-<pi>   # interactive size explorer

lfs quota -u $USER /project         # per-user project usage
lfs find <path> -type f | wc -l     # count files in a directory
```

## Module system (software)

```bash
module spider                  # search all available software (preferred)
module spider python           # search for a specific package
module load python/3.11        # load a module
module load cuda/12.6 cudnn    # load CUDA
module list                    # see what's currently loaded
module purge                   # unload everything
```

Use `module spider`, not `module avail` — `spider` searches across StdEnvs.

## SLURM job submission

```bash
sbatch job.sh                  # submit a job
sq                             # see your running/pending jobs (Alliance wrapper)
scancel <jobid>                # cancel a job
sinfo                          # see available nodes and partitions
seff <jobid>                   # efficiency report after job completes
```

### Minimal GPU job script template

```bash
#!/bin/bash
#SBATCH --account=rrg-<pi>          # RAC allocation
#SBATCH --gres=gpu:1                # number of GPUs
#SBATCH --cpus-per-task=4           # CPU cores
#SBATCH --mem=32G                   # RAM
#SBATCH --time=0-08:00              # DD-HH:MM
#SBATCH --output=%x-%j.out          # log file

module load python/3.11 cuda/12.6 cudnn
source ~/envs/myenv/bin/activate

# Copy dataset to fast local storage
cp -r /project/rrg-<pi>/$USER/my_dataset $SLURM_TMPDIR/
cd $SLURM_TMPDIR

# Run training
python train.py --data $SLURM_TMPDIR/my_dataset

# Copy results back
cp -r ./outputs /project/rrg-<pi>/$USER/results/
```

### Interactive GPU session (debugging)

```bash
salloc --account=rrg-<pi> --gres=gpu:1 --cpus-per-task=4 \
       --mem=16G --time=1:00:00
```

## File management

```bash
# Archive many small files into one (critical for file count quota)
tar -czf archive.tar.gz ./my_folder/ && rm -rf ./my_folder/
tar -xzf archive.tar.gz              # extract

# Transfer data between projects (no --no-g --no-p needed within same /project)
rsync -av /project/def-<pi>/$USER/data/ /project/rrg-<pi>/$USER/data/

# Large transfers — use Globus
# or rsync with tmux/screen so it survives disconnects
```

## Environment / venv

```bash
module load python/3.11
virtualenv --no-download ~/envs/myenv      # Alliance recommends virtualenv over conda
source ~/envs/myenv/bin/activate
pip install --no-index torch                # use pre-built wheels (faster)
pip install torch                           # fallback to PyPI if not available

# List pre-built wheels available on the cluster
avail_wheels torch
avail_wheels --all                          # all available
```

> Alliance recommends `virtualenv` over conda on their clusters (conda is slow on shared filesystems and generates many small files). See [[alliance-anaconda-policy]].

## Monitoring jobs

```bash
sq -o "%.18i %.9P %.30j %.8u %.2t %.10M %.6D %R"   # detailed view
sacct -j <jobid> --format=JobID,State,CPUTime,MaxRSS,Elapsed     # after job ends
nvidia-smi                                          # GPU usage (run on a compute node)
htop                                                # CPU/memory (compute node)
```

## Quick reference: where does my data go?

| Situation | Path |
|---|---|
| New datasets, models to keep | `/project/rrg-<pi>/$USER/` |
| Active training run outputs | `$SCRATCH` → copy keepers to `/project/rrg-<pi>/$USER/` |
| Training data *during a job* | `$SLURM_TMPDIR` (unpack here, fastest) |
| Scripts, venv, configs | `$HOME` |
| Old data not accessed for months | `/nearline/rrg-<pi>/` |

## Connections

- [[alliance-storage-and-file-management]] — full storage policy reference
- [[alliance-workflow-cheatsheet]] — end-to-end routine
- [[digital-research-alliance-canada]] — overview of the Alliance
