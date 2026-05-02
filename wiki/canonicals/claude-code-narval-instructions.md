---
title: Claude Code — Narval Canonical Instructions (template)
type: canonical
created: 2026-04-23
updated: 2026-05-02
sources: []
tags: [claude-code, alliance, narval, canonical, template]
---

# Claude Code — Narval Canonical Instructions

Template for the `~/.claude/CLAUDE.md` file that lives on Narval and instructs Claude Code about the Alliance environment.

This file uses `{{PLACEHOLDER}}` syntax for values that vary per user. Run `bin/setup.sh` once to populate `~/.config/drac-harness/user.conf`, then `bin/install-claude-md.sh` to substitute placeholders and install to `~/.claude/CLAUDE.md`.

## Deploy

```bash
cd {{HARNESS_PATH}}
git pull
bin/install-claude-md.sh
```

The script extracts the block between the ```` ```markdown ```` fences below, substitutes placeholders, and writes the result to `~/.claude/CLAUDE.md`.

## The file

````markdown
# Alliance (Narval) — Claude Code user instructions

You are assisting a user on the Digital Research Alliance of Canada's Narval cluster (A100 GPUs). This file is loaded for every Claude Code session on this machine.

Source of truth (edit there, then redeploy via `bin/install-claude-md.sh`):
{{HARNESS_PATH}}/wiki/canonicals/claude-code-narval-instructions.md

---

## 1. Hard rules (never violate)

- **Account**: GPU jobs use `--account={{RAC_ACCOUNT}}` (RAC priority allocation). For CPU-only jobs, your RAC account may or may not include CPU membership — if `sbatch` returns "you are not a member of {{RAC_ACCOUNT}}" on a CPU job, switch to `--account={{DEF_ACCOUNT}}`. Run `sshare -U` once to see which accounts include which resources.
- **Compute nodes have NO internet**. Pre-stage everything (pip, git clone, apptainer pull) on a login node first.
- **No Docker, no sudo, no conda on the host**. Apptainer + virtualenv are the supported alternatives — see §4 and §5.
- **`$SCRATCH` is auto-purged after 60 days**. Never treat `/scratch/{{USER}}/` as permanent storage.
- **Don't create millions of small files on Lustre** (`$HOME`, `/project`, `/scratch`). Tar datasets; build venvs in `$SLURM_TMPDIR`.
- **A100 = `TORCH_CUDA_ARCH_LIST=8.0`**. To build wheels that also run on H100 clusters (Rorqual, Fir, Nibi, Trillium), use `TORCH_CUDA_ARCH_LIST="8.0;9.0"`.

---

## 2. Request resources (SLURM)

Monitor: `sq` (Alliance wrapper for `squeue`).

**Before submitting any `salloc` / `sbatch`, confirm with the user**: number of GPUs, CPUs, memory, walltime, and whether a MIG slice would suffice. Don't copy the templates below blindly — they're starting points, not defaults. Ask concretely, e.g. "You're building an Apptainer SIF (CPU-only, ~30 min) — propose `--cpus-per-task=4 --mem=16G --time=1:00:00`. OK?"

Sizing heuristics:
- **GPUs**: 1 unless the code is explicitly multi-GPU. MIG slice (`a100_3g.20gb`, ~3/8 of an A100 with 20 GB VRAM) if < 50% compute + < 20 GB VRAM is enough — queues faster.
- **CPUs**: match dataloader workers; usually 4–8. More than 12 rarely helps.
- **Memory**: 4× dataset-in-RAM, or 32 G as a floor for training jobs.
- **Walltime**: round up 50% over best estimate. Prefer ≤ 3 h interactive (fast start) or `--array=1-N%1` with 3 h slots + checkpointing for long runs.

After a job completes, suggest running `seff <jobid>` to check CPU and memory efficiency. If CPU < 70% or memory < 20%, propose a smaller request next time. This is the right-sizing feedback loop.

Interactive (< 3 h, starts fast) — full A100:
```
salloc --account={{RAC_ACCOUNT}} --gres=gpu:1 --cpus-per-task=8 --mem=32G --time=2:00:00
```

MIG slice (3/8 compute, 20 GB VRAM — much faster queue):
```
salloc --account={{RAC_ACCOUNT}} --gpus=a100_3g.20gb:1 --cpus-per-task=2 --mem=40G --time=2:00:00
```

Batch job:
```
sbatch --account={{RAC_ACCOUNT}} --gres=gpu:1 --time=12:00:00 job.sh
```

Array job (checkpoint chaining — 3 h slots, auto-requeue):
```
sbatch --account={{RAC_ACCOUNT}} --array=1-10%1 --time=3:00:00 job.sh
```

---

## 3. Storage layout

| Path | Quota (typical) | Backed up | Purged | Use for |
|---|---|---|---|---|
| `$HOME` | 50 GB / 500K files | yes | no | configs, small code, venvs for editing |
| `/project/{{DEF_ACCOUNT}}/{{USER}}/` | varies (often ~1 TB / 500K files) | yes | no | small shared datasets, configs |
| `/project/{{RAC_ACCOUNT}}/{{USER}}/` | varies (your RAC allocation) | yes | no | large datasets, permanent outputs |
| `$SCRATCH` (`/scratch/{{USER}}/`) | 20 TB / 1M files | no | 60 days | builds, training outputs, intermediate |
| `$SLURM_TMPDIR` | per-node NVMe | no | job-end | venv, dataset unpacking during a job |

Run `diskusage_report` to see your actual quotas across all filesystems.

Workflow: raw data → `/project/{{RAC_ACCOUNT}}`, training outputs → `$SCRATCH` → copy keepers back to `/project/{{RAC_ACCOUNT}}`.

---

## 4. Python virtual environments

Alliance has its own conventions — stock `python -m venv` + PyPI works but is suboptimal.

**Rules**:
- `module load python/<version>` first (not system python).
- Use `virtualenv --no-download` (skips fetching pip/setuptools from PyPI; uses CVMFS).
- Install from Alliance's prebuilt wheelhouse: `pip install --no-index <pkg>`.
- Check availability: `avail_wheels <pkg>` (Alliance-specific command).
- Fall back to normal PyPI only when `--no-index` can't find the package.
- NEVER build CUDA-extension-heavy packages on a login node (pytorch3d, flash-attn, gsplat, kaolin). Use Apptainer (§5) or build inside a GPU `salloc` so `nvcc` sees the right arch.

**Login-node venv** (for editing, small tests):
```
module load python/3.11
virtualenv --no-download ~/envs/myproj
source ~/envs/myproj/bin/activate
pip install --no-index --upgrade pip
pip install --no-index torch torchvision
```

**Batch-job venv** (canonical — build inside `$SLURM_TMPDIR`):
```
module load python/3.11
virtualenv --no-download $SLURM_TMPDIR/env
source $SLURM_TMPDIR/env/bin/activate
pip install --no-index --upgrade pip
pip install --no-index -r requirements.txt
```
The venv is thrown away when the job ends — recreate every job. Benefits: fast NVMe, no Lustre file-count hit.

---

## 5. Containers (Apptainer)

Use when:
- A package needs compilation (pytorch3d, flash-attn, gsplat, kaolin)
- Specific system libs are required (libGL, ffmpeg)
- Reproducibility across clusters matters

```
module load apptainer
apptainer build --fakeroot my.sif my.def
apptainer run --nv -C -W $SLURM_TMPDIR my.sif ...
```

When building A100-targeted CUDA extensions inside a definition file, set `TORCH_CUDA_ARCH_LIST=8.0` in `%post` (or `8.0;9.0` to cover H100 too).

Gotchas:
- `APPTAINER_TMPDIR` must be on healthy scratch (not flaky Lustre). If you see `bus error`, switch to a fresh dir.
- `pip cache purge` fails in containers where pip caching is disabled — remove the line or append `|| true`.
- `git` is NOT in `mambaorg/micromamba` base image. Add `micromamba install -n base -c conda-forge -y git`.
- Build `%post` has no checkpointing — split into `base.def` (stable) + `final.def` (`Bootstrap: localimage`) for fast iteration.

---

## 6. Modules (Lmod)

- `module spider <name>` — search all StdEnvs (use this, not `avail`)
- `module load <name>` — activate
- `module -t list` — current loaded modules
- `StdEnv/2020` is deprecated on newer systems; use the current default.

Common stack: `module load StdEnv gcc cuda python apptainer`.

For OpenCV (CUDA-accelerated, with contrib modules):
```
module load gcc cuda opencv/<version> python/3.11 scipy-stack
```

Available CUDA versions on Narval at time of writing: 11.8, 12.2, 12.6, 12.9. Pick to match your torch / extension expectations; verify with `module spider cuda` — versions change.

---

## 7. Data transfer

- **Globus** — preferred for anything > ~1 minute. Uses Alliance DTNs automatically. If the user has a Globus Connect Personal endpoint set up on a local machine, use it for transfers between local and the cluster.
- **rsync into `/project`** — ALWAYS add `--no-g --no-p`. `/project` enforces quota by group ownership; preserving the source's group breaks the quota and triggers `Disk quota exceeded` even with free space. Canonical form:
    rsync -avzh --no-g --no-p --partial --progress LOCAL user@host:projects/{{RAC_ACCOUNT}}/{{USER}}/dst/
- **scp** — fine for `$HOME` / `$SCRATCH`. **Do NOT use `scp -r` into `/project`** (kills setgid bit, same quota problem). Use rsync (with `--no-g --no-p`) or tar+scp instead.
- **wget / curl / rclone** — only on login nodes (no compute-node internet). rclone is the right tool for Google Drive / S3 / Dropbox.
- **Between clusters** (Narval ↔ Rorqual ↔ …): Globus. If using `ssh`, run `ssh -A` to forward the agent first.

---

## 8. Reference wiki

`{{HARNESS_PATH}}/` is the drac-harness clone. Grep it for deeper docs:

- `wiki/cheatsheets/alliance-workflow-cheatsheet.md` — end-to-end routine
- `wiki/cheatsheets/narval-cheat-sheet.md` — command reference
- `wiki/summaries/alliance-running-jobs.md` — SLURM deep dive
- `wiki/summaries/alliance-python.md` — venv + wheelhouse details
- `wiki/summaries/alliance-apptainer.md` — container recipes
- `wiki/summaries/alliance-storage-and-file-management.md` — filesystems
- `wiki/summaries/alliance-available-software.md` — module tiers, CVMFS
- `wiki/summaries/alliance-prolonging-terminal-sessions.md` — tmux/screen gotchas
- `wiki/analyses/alliance-cluster-comparison.md` — picking the right cluster
- `wiki/entities/digital-research-alliance-canada.md` — what the Alliance is

Always prefer the wiki over guessing. If a topic is missing, tell the user — and offer to ingest a new source or write a fresh wiki page so the next session has it.

---

## 9. Conventions for this session

- Direct, concise answers. Skip "Great question!" preambles.
- Show the copy-paste command first, explain after.
- When build / job commands are long-running, remind the user to run inside `tmux` or a batch script — login-node SSH disconnects are a top cause of frustration.
- Many Alliance users come from non-systems backgrounds (CV, ML, bioinformatics, physics). Explain HPC jargon (CVMFS, Lustre, RGU, MIG) on first use.

---

## 10. Knowledge accumulation — keep growing the harness

`{{HARNESS_PATH}}/` is **bidirectional**: §8 is the read side. The write side is just as important — lessons learned on this cluster should end up in the wiki so they propagate across sessions and devices.

**Propose end-of-session ingestion when**:
- The user signals closure ("let's wrap up", "we're done", "good for now") or hits a major milestone.
- A debugging session uncovered a non-obvious failure mode + fix.
- A research session produced a synthesis across multiple sources.
- A methodology recipe was worked out that's likely to apply again.

**Worth ingesting** (durable, transferable):
- Technical decisions + their *rationale* (the why, not the what).
- Methodology recipes (env builds, debugging patterns, failure modes).
- Tool comparisons, dataset descriptions, lessons learned.

**Skip** (ephemeral):
- Job IDs, commit SHAs, timestamps, file paths in `$SCRATCH`.
- Single-task progress notes.
- Routine commits or commands.
- Anything already in the project's PROJECT.md / STATUS.md / git log.

**How to ingest** (don't do automatically — propose first):

1. Write a fresh source markdown to `{{HARNESS_PATH}}/raw/<topic>-lessons-YYYY-MM-DD.md`. Curated bullets, not a chat transcript.
2. Invoke the harness's `Ingest from external project` workflow (see `{{HARNESS_PATH}}/CLAUDE.md`). It distributes the lessons across entity / concept / analysis pages.
3. After the wiki updates, `git push` to the user's fork. If the lesson is generic (no personal info), suggest opening a PR to upstream drac-harness so the next user benefits.

**When this helps**: any future Claude session on this cluster (or any other cluster with the harness cloned) starts with full context for the topic instead of re-deriving lessons from chat history.
````

## Maintenance

- **Authored** in this template, edited from any device with drac-harness cloned.
- **Deployed** to `~/.claude/CLAUDE.md` on Narval via `bin/install-claude-md.sh` (substitutes `{{PLACEHOLDERS}}`).
- When a new Narval quirk is discovered, update this template first, then redeploy.
- The template should stay free of personal info so it remains shareable upstream.

## Related

- [[claude-code-rorqual-instructions]] — sister canonical for Rorqual (H100s)
- [[alliance-cluster-comparison]] — when to pick which cluster
- [[alliance-workflow-cheatsheet]] — human-facing version of the same content
- [[narval-cheat-sheet]] — command quick reference
