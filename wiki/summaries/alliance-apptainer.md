---
title: Alliance — Apptainer (Containers)
type: source
updated: 2026-05-02
sources: [alliance-docs/Apptainer.md]
tags: [alliance, apptainer, singularity, container, docker, reproducibility, sif]
---

# Alliance — Apptainer (Containers)

Apptainer is the Alliance's **official container runtime** — the replacement for Singularity since the Linux Foundation adopted SingularityCE. It fills the role Docker plays elsewhere, but with two crucial differences: **rootless by design** (so it's safe on shared HPC nodes) and **read-only SIF files** by default.

## Why this matters

Docker is explicitly **not** installed on Alliance clusters: "Using Docker on a multiuser cluster creates security risks." But Apptainer can consume Docker images, so the workflow is:

```
Dockerfile → docker build (on a machine where you have sudo) → apptainer build → .sif → ship to the cluster
```

This is the cleanest path when a repo's environment is conda/pip-heavy and brittle.

## Key commands

```bash
module load apptainer            # must load first
module spider apptainer          # list available versions
```

### Pulling an existing image

```bash
apptainer build bb.sif docker://busybox                            # Docker Hub
apptainer build pt.sif docker://nvcr.io/nvidia/pytorch:24.06-py3   # NVIDIA NGC
```

### Running with GPU on a compute node

```bash
apptainer run --nv -C \
  -B /home:/cluster_home -B /project -B /scratch \
  -W $SLURM_TMPDIR \
  image.sif python your_script.py
```

Critical flags:
- `--nv` — bind NVIDIA drivers & libs from the host into the container. **Required for CUDA workloads.**
- `-C` — isolate container from host filesystems, PID, IPC, env. Prevents host Python/conda from shadowing container software.
- `-W $SLURM_TMPDIR` — use node-local disk for working dir (`/tmp` defaults to RAM on Alliance nodes, which gets killed by SLURM memory limits).
- `-B /project -B /scratch` — bind Alliance filesystems so your data/checkpoints are visible inside the container.
- `-B /home:/cluster_home` — **remap** home so host `~/.local/lib/python*` doesn't shadow container packages.

### Interactive shell

```bash
apptainer shell --nv -C -W $SLURM_TMPDIR -B /project -B /scratch image.sif
# prompt becomes Apptainer>
```

## Building images — three routes

| Route | Where | When to use |
|---|---|---|
| `apptainer build x.sif docker://name` | Login node | You already have a public Docker image |
| `apptainer build --fakeroot x.sif image.def` | Login node (Apptainer ≥ 1.1) | You have a `.def` file and don't need sudo during build |
| `docker build` + `apptainer build --fakeroot` | A machine where you have sudo | Complex Dockerfile, root needed during build |

Alliance explicitly **won't build some images without root**, in which case you have to build elsewhere and ship the SIF over.

## Conda inside Apptainer — the documented pattern

Alliance provides a 3-step recipe using `mambaorg/micromamba` as the base:

**`environment.yml`** — the conda env spec (bioinformatics example):
```yaml
name: base
channels: [conda-forge, bioconda, defaults]
dependencies:
  - python
  - pip
  - star
  - bwa
  - multiqc
```

**`image.def`** — the Apptainer definition file:
```
Bootstrap: docker
From: mambaorg/micromamba:latest

%files
    environment.yml /environment.yml

%post
    micromamba install -n base --file environment.yml && \
        micromamba clean --all --yes
```

**Build:**
```bash
module load apptainer
APPTAINER_BIND=' ' apptainer build image.sif image.def
```

This pattern generalizes to any mamba-based stack.

## Cache and temp directories — critical

By default Apptainer writes to `$HOME/.apptainer` and `/tmp`. Both are bad on Alliance clusters:
- `$HOME` has a 50 GB quota; SIF cache fills it fast.
- `/tmp` is tmpfs (RAM) on login/compute nodes; jobs OOM.

Always set these first:
```bash
mkdir -p /scratch/$USER/apptainer/{cache,tmp}
export APPTAINER_CACHEDIR="/scratch/$USER/apptainer/cache"
export APPTAINER_TMPDIR="/scratch/$USER/apptainer/tmp"
```

Add to `~/.bashrc` if you use Apptainer regularly.

## sudo caveat

Alliance does not give users sudo. For images that need root during build:
- Build on a machine where you do have root (your laptop or a lab server) and transfer the SIF over Globus.
- Or try `apptainer build --fakeroot` (works in 1.1+, not every image).
- Or open a support ticket asking an admin to build.

## Dockerfile → Apptainer path

When only a Dockerfile is provided and you have Docker + sudo on a build host:
```bash
docker build -f Dockerfile -t mytag .
docker save mytag -o mytarball.tar
docker image rm mytag
apptainer build --fakeroot myimage.sif docker-archive://mytarball.tar
rm mytarball.tar
```
Then `scp` or Globus the `.sif` to the Alliance cluster.

## Gotchas captured

- `/tmp` is RAM — always use `-W $SLURM_TMPDIR`.
- Avoid **Lustre/GPFS** for `APPTAINER_TMPDIR` (`/project` is Lustre — use `/scratch` or `$SLURM_TMPDIR`).
- Don't bind `/home` directly — remap to `/cluster_home` so host dotfiles don't break the container.
- Don't bind CVMFS paths into the container (defeats the purpose and breaks things).
- For MPI across nodes, extra work is needed; single-node MPI (`--nodes=1`) just works.
- `git` is **not** in `mambaorg/micromamba` base image. Add `micromamba install -n base -c conda-forge -y git`.
- Build `%post` has no checkpointing — split into `base.def` (stable) + `final.def` (`Bootstrap: localimage`) for fast iteration.

## Connections

- [[apptainer]] — the concept page
- [[alliance-anaconda-policy]] — why conda-in-Apptainer is preferred over conda-on-bare-metal
- [[alliance-workflow-cheatsheet]] — general HPC routine
- [[narval-cheat-sheet]] — command reference
- [[alliance-available-software]] — confirms Docker is absent by design; Apptainer is the official path
- [[cuda-extension-build-gotchas]] — recurring failures when building CUDA wheels (relevant inside SIFs too)
