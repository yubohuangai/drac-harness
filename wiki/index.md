---
title: Wiki Index
type: index
updated: 2026-05-02
---

# Wiki Index

Catalog of all wiki pages, organized by category. New pages added during ingestion should be appended to the right section.

## Canonicals — per-cluster CLAUDE.md templates

Templated `~/.claude/CLAUDE.md` files. Run `bin/setup.sh` once, then `bin/install-claude-md.sh` to substitute placeholders and install the per-cluster file to `~/.claude/CLAUDE.md`.

- [[claude-code-narval-instructions]] — Narval (A100-40G)
- [[claude-code-rorqual-instructions]] — Rorqual (H100-80G)

If your cluster doesn't have a canonical here yet, run the **"Onboard a new cluster"** workflow defined in the repo's `CLAUDE.md`. Claude will detect the cluster, run recon, draft a new canonical, and ask you to review.

## Cheatsheets — quick command references

- [[alliance-workflow-cheatsheet]] — end-to-end routine: connect, tmux, venv, salloc/sbatch, monitor, transfer
- [[narval-cheat-sheet]] — Narval command reference (mostly transfers to other clusters)
- [[globus-cli-on-alliance]] — install, auth, `data_access` consent, inter-cluster transfer
- [[tmux-cheat-sheet]] — full tmux key reference

## Summaries — distilled upstream Alliance docs

One page per `raw/alliance-docs/` source. Read these for fast orientation; consult the upstream for full detail.

### Job submission and monitoring
- [[alliance-running-jobs]] — `sbatch`, `salloc`, `squeue`, accounts, array jobs
- [[alliance-monitoring-jobs]] — `sq`, `seff`, `sacct`, the right-sizing feedback loop
- [[alliance-multi-instance-gpu]] — MIG slices on A100 / H100

### Storage and data transfer
- [[alliance-storage-and-file-management]] — HOME / PROJECT / SCRATCH / NEARLINE / SLURM_TMPDIR
- [[alliance-transferring-data]] — Globus, rsync (the `--no-g --no-p` rule), scp, sftp, rclone

### Software and environments
- [[alliance-available-software]] — module / wheelhouse / CVMFS tiers; site-specific software
- [[alliance-python]] — `module load python`, `virtualenv --no-download`, the wheelhouse, HF
- [[alliance-anaconda-policy]] — why not conda; virtualenv is the sanctioned approach
- [[alliance-apptainer]] — containers (the official Docker alternative on the Alliance)
- [[alliance-opencv]] — load via module, headless variant, `gcc cuda opencv` order
- [[alliance-cuda-tutorial]] — CUDA basics; compute capability table
- [[alliance-nextflow]] — workflow orchestration, nf-core, Alliance config

### Cluster orientation
- [[alliance-getting-started]] — system list, CCDB, MFA, training resources
- [[alliance-infrastructure-renewal]] — 2024–26 H100 transition; old → new mapping
- [[alliance-prolonging-terminal-sessions]] — SSH keepalive, tmux, screen, login-node pinning
- [[alliance-ml-tutorial]] — five-step ML job recipe (display, archive, venv, salloc, sbatch)

## Concepts — transferable ideas

- [[apptainer]] — what Apptainer is, why HPC uses it, key differences from Docker
- [[cuda]] — compute capability, toolkit vs driver, ML-relevance
- [[cuda-extension-build-gotchas]] — recurring failures (`tinycudann`, `simple-knn`, login-node arch)

## Entities — named things

- [[digital-research-alliance-canada]] — the Alliance organization

## Analyses — cross-source syntheses

- [[alliance-cluster-comparison]] — picking the right cluster (RGU, MIG, RAC priority)

## Operations log

- [[log]] — chronological record of ingest, query, lint, update, create, onboard operations
