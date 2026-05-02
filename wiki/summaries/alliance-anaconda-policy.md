---
title: Alliance Anaconda Policy
type: source
updated: 2026-05-02
sources: [alliance-docs/Anaconda.md]
tags: [hpc, alliance, conda, python, virtualenv, apptainer]
---

# Alliance Anaconda Policy

**tl;dr: Don't use conda on Alliance clusters. Use `virtualenv` instead.**

Source: https://docs.alliancecan.ca/wiki/Anaconda/en

## Why conda is problematic on clusters

1. Installs compilers and libraries that already exist as optimized modules — causes conflicts.
2. Installs generic binaries not optimized for the cluster's CPU architecture — jobs run slower.
3. Makes wrong assumptions about system library locations — jobs may crash.
4. **Writes an enormous number of small files to `$HOME`** — a single Anaconda install can use almost half the 500K file-count quota in `/home`. Compounds the group's file count problem in `/project`.
5. Slower than installing via Python wheels.
6. Modifies `~/.bashrc`, causing environment conflicts.

## What to use instead

### Option 1: virtualenv (preferred for most cases)

```bash
module load python/3.11          # use Alliance's optimized Python
virtualenv --no-download ~/envs/myenv
source ~/envs/myenv/bin/activate

avail_wheels torch               # check pre-built wheel versions
pip install --no-index torch torchvision  # install from local wheel cache (fast, no internet)
pip install somepackage          # fall back to PyPI if not in wheel cache
```

The `--no-index` flag uses Alliance's pre-built wheel cache, which is faster and doesn't require internet (compute nodes have no internet access).

### Option 2: Apptainer (when conda dependencies are unavoidable)

For complex dependency chains that genuinely require conda, use **Apptainer** to containerize the environment. Use **micromamba** inside the container (not full Anaconda — avoid license issues).

```bash
# environment.yml defining the conda env
# image.def defining the Apptainer image

module load apptainer
APPTAINER_BIND=' ' apptainer build image.sif image.def
apptainer run image.sif python train.py
```

Store `.sif` files in `/project/<your-account>/` shared with your group to avoid duplication.

## Migrating from conda to virtualenv

1. Run `pip show <package>` or check the repo's `requirements.txt` to list dependencies.
2. Remove non-Python dependencies (CUDA, cuDNN) — these come from `module load`.
3. Install the remaining Python packages via `pip install --no-index` or PyPI.

## Connections

- [[alliance-ml-tutorial]] — full job workflow using virtualenv
- [[narval-cheat-sheet]] — `avail_wheels`, `module load` commands
- [[alliance-storage-and-file-management]] — file-count quota context
- [[alliance-available-software]] — module / wheelhouse / CVMFS tiers; the alternatives conda would duplicate
- [[alliance-apptainer]] — when conda is unavoidable, containerize it
