---
title: Alliance — Python and Virtual Environments
type: source
updated: 2026-05-02
sources: [alliance-docs/Python.md]
tags: [alliance, python, virtualenv, pip, wheels, slurm]
---

# Alliance — Python and Virtual Environments

How to use Python on Alliance clusters. No conda — use `module load` + `virtualenv`.

Source: https://docs.alliancecan.ca/wiki/Python

## Step 1 — Load a Python module

Never use the system default Python. Always load explicitly:

```bash
module avail python          # see what versions are available
module load python/3.11      # load a specific version
module load scipy-stack      # adds numpy, scipy, matplotlib, pandas, IPython
```

## Step 2 — Create a virtual environment

```bash
virtualenv --no-download ~/envs/myproj
source ~/envs/myproj/bin/activate
pip install --no-index --upgrade pip
```

**Do not** create virtualenvs in `$SCRATCH` — they will get auto-purged. Use `$HOME/envs/` or `/project/<your-account>/$USER/envs/`.

## Step 3 — Install packages

Always prefer `--no-index` to use Alliance's pre-built wheels (faster, optimized for cluster hardware, avoids dependency conflicts):

```bash
pip install --no-index numpy        # use Alliance wheel
pip install numpy                   # fallback to PyPI if no wheel exists
```

Check if a wheel is available before falling back to PyPI:

```bash
avail_wheels torch          # list available pre-built versions
```

## Freeze requirements for reproducibility

On a login node or test environment:

```bash
pip freeze --local > requirements.txt
```

Use this file in job scripts to recreate the environment.

## Best practice for batch jobs — venv inside SLURM_TMPDIR

Parallel filesystems are slow for thousands of small files (virtualenvs are exactly that). For single-node jobs, recreate the venv on the compute node's fast local disk:

```bash
#!/bin/bash
#SBATCH --account=rrg-<pi>
#SBATCH --mem-per-cpu=1500M
#SBATCH --time=1:00:00

module load python/3.11
virtualenv --no-download $SLURM_TMPDIR/env
source $SLURM_TMPDIR/env/bin/activate
pip install --no-index --upgrade pip
pip install --no-index -r requirements.txt
python train.py
```

Workflow: create + freeze `requirements.txt` on login node once → job script recreates env in `$SLURM_TMPDIR` each run.

## Hugging Face on Alliance

Compute nodes have no internet — **gated or large HF checkpoints must be pre-downloaded on a login node** before the job runs.

```bash
# Login node, inside an activated venv:
pip install --no-index huggingface_hub packaging   # packaging is NOT pulled in by the wheelhouse install; hf CLI crashes without it
hf auth login                                       # new CLI name (replaced `huggingface-cli` in huggingface_hub 1.x)
hf download <org>/<repo>                            # caches under ~/.cache/huggingface/hub/
```

Gated repos (e.g. `meta-llama/...`): accept the terms on the HF web UI first, and generate a read token at https://huggingface.co/settings/tokens.

By default, the cache lives in `~/.cache/huggingface/`. For large caches, set `HF_HOME=/project/<your-account>/$USER/hf-cache` so weights don't eat your `$HOME` quota.

## Connections

- [[alliance-anaconda-policy]] — why not conda; virtualenv is the sanctioned approach
- [[alliance-opencv]] — load cv2 via `module load opencv` instead of pip
- [[alliance-ml-tutorial]] — full training job workflow with virtualenv
- [[narval-cheat-sheet]] — module and SLURM reference
- [[alliance-available-software]] — the wheelhouse + module tiers feeding `--no-index` installs
