---
title: Alliance — ML Tutorial
type: source
updated: 2026-05-02
sources: [alliance-docs/Machine Learning tutorial.md]
tags: [hpc, alliance, slurm, machine-learning, pytorch, sbatch, training]
---

# Alliance — ML Tutorial

Official guide for porting ML jobs to Alliance clusters. Source: https://docs.alliancecan.ca/wiki/Tutoriel_Apprentissage_machine/en

Five mandatory steps before submitting a job.

## Step 1 — Remove all graphical display

No GUIs on the cluster. Save plots to disk instead of showing them:

```python
# Instead of plt.show():
plt.savefig('result.png')
```

## Step 2 — Archive your dataset

**Critical for file count quota.** Shared filesystems penalize many small files:

```bash
tar cf mydataset.tar mydataset/*      # uncompressed (faster for already-compressed images)
tar czf mydataset.tar.gz mydataset/*  # compressed (better for text/raw data)
```

Then in your job script, unpack to `$SLURM_TMPDIR` (local node storage — fastest I/O):

```bash
mkdir $SLURM_TMPDIR/data
tar xf ~/projects/rrg-<pi>/$USER/mydataset.tar -C $SLURM_TMPDIR/data
```

## Step 3 — Prepare virtual environment

Use `virtualenv`, not conda. See [[alliance-anaconda-policy]].

```bash
module load python/3.11
virtualenv --no-download ~/envs/myenv
source ~/envs/myenv/bin/activate
pip install --no-index torch torchvision   # pre-built wheels (faster, no internet needed)
avail_wheels torch                          # check available pre-built versions first
```

## Step 4 — Debug with interactive job (`salloc`)

Always test interactively before batch submission:

```bash
salloc --account=rrg-<pi> --gres=gpu:1 --cpus-per-task=4 --mem=32000M --time=1:00:00
# Once on the node:
source ~/envs/myenv/bin/activate
python train.py  # test, debug, verify data loading
```

Key thing to check: is the job reading/writing to `$SLURM_TMPDIR` (fast) rather than `/project` or `/scratch` (slow)?

## Step 5 — Batch job (`sbatch`)

### Minimal production script

```bash
#!/bin/bash
#SBATCH --account=rrg-<pi>
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4        # 4-6 CPUs per GPU is typical
#SBATCH --mem=32000M
#SBATCH --time=0-08:00           # DD-HH:MM
#SBATCH --output=%x-%j.out

module load python/3.11 cuda/12.6 cudnn
source ~/envs/myenv/bin/activate

# Unpack data to fast local storage
mkdir $SLURM_TMPDIR/data
tar xf /project/rrg-<pi>/$USER/mydataset.tar -C $SLURM_TMPDIR/data

# Train
python ~/code/myproject/train.py --data $SLURM_TMPDIR/data --output $SLURM_TMPDIR/outputs

# Copy important results back (scratch will be purged!)
cp -r $SLURM_TMPDIR/outputs /project/rrg-<pi>/$USER/results/
```

### Long jobs: checkpoint chaining with `--array`

Maximum job duration is typically 7 days. For longer runs, chain jobs that resume from the last checkpoint:

```bash
#!/bin/bash
#SBATCH --array=1-10%1    # 10 jobs in sequence (%1 = one at a time)
#SBATCH --account=rrg-<pi>
#SBATCH --gres=gpu:1
#SBATCH --time=0-24:00

# ... module loads, env activation, data unpacking ...

CHECKPOINTS=/scratch/$USER/checkpoints/myrun
LAST=$(find $CHECKPOINTS -name "*.pt" -print0 | xargs -r -0 ls -1t | head -1)

if [ -z "$LAST" ]; then
    python train.py --save-to $CHECKPOINTS ...
else
    python train.py --resume $LAST --save-to $CHECKPOINTS ...
fi
```

After the run completes, copy final checkpoint from `/scratch` to `/project`.

## Key reminders

- **1 GPU per job** unless you've verified your code uses multiple (PyTorch / TF default: 1 GPU).
- **Use your RAC account** (e.g. `rrg-<pi>`) for GPU jobs; the priority allocation matters for queue wait time. CPU-only jobs may need `def-<pi>` if your RAC account doesn't include CPU.
- **Never rely on `/scratch`** for permanent storage — it gets purged after 60 days.
- **Login nodes are shared** — no intensive computation there, only job submission and file management.

## Connections

- [[narval-cheat-sheet]] — commands reference
- [[alliance-storage-and-file-management]] — storage types and policies
- [[alliance-anaconda-policy]] — why not to use conda
- [[alliance-running-jobs]] — full SLURM reference
