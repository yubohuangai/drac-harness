---
title: Alliance — Nextflow
type: source
updated: 2026-05-02
sources: [alliance-docs/Nextflow.md]
tags: [alliance, nextflow, workflow, pipeline, nf-core, reproducibility]
---

# Alliance — Nextflow

Nextflow is a **workflow orchestrator**: write your pipeline as a DAG of tasks in its DSL, and Nextflow handles scheduling them onto SLURM, containerizing each step with Apptainer, and retrying failures.

Alliance provides Nextflow as a module: `module load nextflow`. Most relevant for bioinformatics workflows or any reproducible end-to-end ML pipeline.

Source: https://docs.alliancecan.ca/wiki/Nextflow

## Why it exists

Bioinformatics in particular has massive, fragile pipelines (alignment → variant calling → annotation → QC) that historically were bash scripts + Makefiles. Nextflow's model: each step is a task with declared inputs/outputs, runs in its own container, and the runtime walks the DAG. **Reproducible across machines**, restart-from-failure, parallel where possible.

## The nf-core ecosystem

[nf-core](https://nf-co.re/) is a curated collection of peer-reviewed Nextflow pipelines (rnaseq, atacseq, sarek, etc.). Each is a Git repo + container images + tests. Alliance hosts an official [nf-core config](https://github.com/nf-core/configs/blob/master/conf/alliance_canada.config) that sets up SLURM limits for Fir, Narval, Nibi, Rorqual, Trillium.

## 5-step Alliance workflow (from the doc)

1. Drop the nf-core alliance config into `~/.nextflow/config`:
   ```bash
   curl -o ~/.nextflow/config https://raw.githubusercontent.com/nf-core/configs/refs/heads/master/conf/alliance_canada.config
   export SLURM_ACCOUNT=rrg-<pi>
   ```
2. Install nf-core on a **login node** (compute nodes have no internet):
   ```bash
   module purge
   module load python/3.11 rust postgresql
   python -m venv nf-core-env
   source nf-core-env/bin/activate
   pip install nf_core==2.13
   ```
3. Download pipeline + container images on the login node.
4. Prepare input sample sheet.
5. Submit via an `sbatch` job (Nextflow acts as the driver; it dispatches sub-tasks).

## Key cluster-specific constraints

- **Don't run on Trillium** unless the pipeline was designed for it.
- Config caps: ≤ 100 jobs in SLURM queue, ≤ 60 submitted/min.
- Cluster-specific node specs (cores, RAM, max time) live in the alliance_canada.config file — read it before submitting.

## When to use it

Use Nextflow when:
- Each step can ship as an Apptainer SIF.
- Failures on one input shouldn't nuke the whole batch.
- You want the DAG to be self-documenting.

Don't use it for: a single training/inference run with one `python` invocation. Plain `sbatch` is simpler.

## Connections

- [[alliance-apptainer]] — Nextflow uses Apptainer as its container runtime on Alliance
- [[alliance-running-jobs]] — SLURM fundamentals
