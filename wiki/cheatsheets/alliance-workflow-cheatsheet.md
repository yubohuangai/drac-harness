---
title: Alliance Workflow Cheatsheet
type: cheatsheet
updated: 2026-05-02
sources: []
tags: [alliance, slurm, tmux, workflow, hpc, cheatsheet]
---

# Alliance Workflow Cheatsheet

End-to-end routine for interactive and batch work on an Alliance cluster.

In examples below, `<pi>` is your supervisor's last name (e.g. `rrg-smith`). Replace with your real account; run `sshare -U` to see your memberships.

---

## 1. Connect (and pin to a specific login node)

```bash
ssh user@<cluster>.alliancecan.ca           # random login node
ssh user@<cluster>1.alliancecan.ca          # always login node 1 (so tmux survives)
```

Pin to a specific login node (e.g. `narval1`, `rorqual2`) so tmux sessions survive reconnects. If the node reboots, the session is gone — just recreate.

## 2. Start or reattach tmux

```bash
tmux new -s work        # first time
tmux a -t work          # reconnecting after SSH drop
```

If SSH drops: reconnect to the **same** login node, then `tmux a -t work`.

---

## 3. Set up virtual environment (once per project)

Do this on the login node before requesting any compute.

```bash
module load python/3.11 gcc cuda
virtualenv --no-download ~/envs/myproj
source ~/envs/myproj/bin/activate
pip install --no-index --upgrade pip
pip install --no-index numpy pandas torch torchvision   # whatever you need
pip freeze --local > requirements.txt
deactivate
```

Store venv in `$HOME/envs/`. Never in `$SCRATCH` (auto-purged).

For batch jobs, recreate the venv inside `$SLURM_TMPDIR` from `requirements.txt` — see [[alliance-python]].

---

## 4. Request compute

### Interactive (debugging / testing)

```bash
# CPU only
salloc --account=def-<pi> --cpus-per-task=12 --mem=16G --time=3:00:00

# With GPU (full)
salloc --account=rrg-<pi> --gres=gpu:1 --cpus-per-task=8 --mem=32G --time=2:00:00

# With MIG slice (Narval A100, 3/8 compute, 20 GB VRAM — much faster queue)
salloc --account=rrg-<pi> --gpus=a100_3g.20gb:1 --cpus-per-task=2 --mem=40G --time=1:00:00

# With MIG slice (Rorqual H100, 1/7 compute, 10 GB VRAM)
salloc --account=rrg-<pi> --gres=gpu:nvidia_h100_80gb_hbm3_1g.10gb:1 --cpus-per-task=4 --mem=16G --time=1:00:00
```

Interactive jobs ≤ 3 hours start nearly instantly.

### Batch (training runs)

```bash
sbatch myjob.sh
```

Minimal `myjob.sh`:

```bash
#!/bin/bash
#SBATCH --account=rrg-<pi>
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=8:00:00
#SBATCH --output=%x-%j.out

module load python/3.11 gcc cuda/12.6
source ~/envs/myproj/bin/activate
python train.py
```

Use your RAC account (`rrg-<pi>`) for GPU jobs — much better priority. If your RAC doesn't include CPU membership, use `def-<pi>` for CPU-only.

---

## 5. Load modules and activate venv on compute node

```bash
module load python/3.11 gcc cuda/12.6
source ~/envs/myproj/bin/activate
```

Modules don't persist — must reload every session.

---

## 6. Monitor and cancel jobs

```bash
sq                          # list your jobs
scancel JOBID               # cancel a specific job
scancel -u $USER            # cancel all your jobs
seff <jobid>                # after job ends — efficiency report (right-size next request)
```

Output of batch jobs: `slurm-JOBID.out` in the directory where you ran `sbatch`.

---

## 7. Storage rules

| Location | Use for | Quota | Notes |
|----------|---------|-------|-------|
| `$HOME` | Code, venvs | 50 GB / 500K files | Backed up |
| `$SCRATCH` (`/scratch/$USER/`) | Active data, job outputs | 20 TB | **Auto-purged after 60 days** |
| `/project/rrg-<pi>/$USER/` | Permanent data, datasets | varies (RAC) | Backed up |

After a job finishes: copy important outputs from `/scratch` → `/project` before 60 days.

```bash
cp -r /scratch/$USER/outputs/ /project/rrg-<pi>/$USER/
```

See [[alliance-storage-and-file-management]] for full details.

---

## 8. Transfer data

### Small files — scp

```bash
# Pull from cluster to local
scp user@narval.alliancecan.ca:/scratch/$USER/file.mp4 ./

# Push from local to cluster
scp ./file.mp4 user@narval.alliancecan.ca:/scratch/$USER/
```

### Large datasets — Globus

For Alliance ↔ Alliance, use the Globus CLI: see [[globus-cli-on-alliance]]. For local ↔ Alliance, set up Globus Connect Personal.

### **Never** `scp -r` into `/project`

Use `rsync -avzh --no-g --no-p` or tar+scp instead. See [[alliance-transferring-data]] for the full reasoning (group-quota gotcha).

---

## Common mistakes

| Mistake | Fix |
|---------|-----|
| SSH to `<cluster>.alliancecan.ca` and starting tmux | Always pin to a specific login node so tmux survives reconnects |
| Running heavy code on login node | Use `salloc` or `sbatch` |
| Using `--account=def-<pi>` for GPU jobs | Use `rrg-<pi>` for better GPU priority |
| Putting venv in `$SCRATCH` | Put venv in `$HOME/envs/` |
| Storing permanent data in scratch | Copy to `/project/rrg-<pi>/$USER/` before 60 days |
| `scp -r` into `/project` | Use `rsync -avzh --no-g --no-p` instead |
| tmux session gone after overnight | Login node was rebooted — recreate the session |

---

## Connections

- [[narval-cheat-sheet]] — SLURM command reference
- [[alliance-running-jobs]] — full `sbatch` / `salloc` reference
- [[alliance-python]] — virtualenv details
- [[alliance-multi-instance-gpu]] — when to use MIG instances
- [[alliance-prolonging-terminal-sessions]] — tmux details
- [[alliance-transferring-data]] — `--no-g --no-p` rationale and full transfer reference
