---
title: Alliance Cluster Comparison — picking the right cluster
type: analysis
updated: 2026-05-02
sources: [alliance-docs/Infrastructure renewal.md]
tags: [alliance, gpu, h100, a100, rorqual, narval, recommendation, hpc]
---

# Alliance Cluster Comparison

How to choose between the available Alliance clusters for ML / GPU work. The summary: **if you have RAC priority on more than one cluster, the H100 clusters (Rorqual, Fir, Nibi, Trillium) are roughly 3× faster than Narval (A100) per GPU; check CCDB to see where you have allocation, and prefer clusters where you have RAC.**

## Hardware comparison (post-2024 renewal)

| Cluster | GPU | VRAM | RGU/GPU | Notable |
|---|---|---|---|---|
| **Rorqual** | H100-80G | 80 GB | 12.15 | Replaces Beluga |
| **Fir** | H100-80G | 80 GB | 12.15 | Replaces Cedar |
| **Nibi** | H100-80G | 80 GB | 12.15 | Replaces Graham |
| **Trillium** | H100-80G + CPU | 80 GB | 12.15 | Replaces Niagara/Mist; CPU-focused, large parallel jobs |
| **Narval** | A100-40G | 40 GB | 4.0 | Not part of the 2024–26 renewal |

**RGU** = "Reference GPU Units" — the Alliance's normalized accounting unit for cross-cluster GPU comparison. H100-80G is rated 12.15 vs A100-40G at 4.0, which tracks real-world ML throughput reasonably well (FP32 + FP16 + memory bandwidth).

For ML training, expect a **2–3× wall-clock speedup** moving from A100 to H100. CPU-bound work (Apptainer builds, data preprocessing) won't speed up much — but those are rarely bottlenecks.

## Decision flowchart

```
Do you have RAC priority on ≥1 H100 cluster (Rorqual, Fir, Nibi, Trillium)?
├── Yes → use that cluster (H100 + priority queue beats Narval at almost everything)
└── No  → use Narval if you have RAC there
         else → Fir (H100 with default `def-<pi>` works, but queue waits are long)
```

Check your allocations at https://ccdb.alliancecan.ca → My Resources and Allocations.

## Why Narval is still useful

- Smaller-VRAM jobs (≤ 40 GB) fit comfortably without MIG.
- Established A100 stack — fewer surprises building extensions (`TORCH_CUDA_ARCH_LIST=8.0`).
- Often less crowded than the headline H100 clusters during peak training periods.
- If your RAC moved to Narval, that's where your priority queue is.

## When to prefer an H100 cluster

- Training that needs > 40 GB VRAM (larger models, bigger batches).
- Workloads that exploit H100's transformer engine (diffusion, attention-heavy training).
- Your RAC is on Rorqual / Fir / Nibi / Trillium.
- You're hitting Narval's queue limits.

## H100 MIG slices — important on the new clusters

H100 is so capable that **most jobs don't need a full one**. With fewer GPUs in the H100 pool than the old A100 pool, the cultural pattern is shifting toward MIG slices:

| H100 MIG slice | Compute | VRAM | Use case |
|---|---|---|---|
| `1g.10gb` | 1/7 | 10 GB | Inference, light dev |
| `2g.20gb` | 2/7 | 20 GB | Small training |
| `3g.40gb` | 3/7 | 40 GB | **≈ A100-40G** — comfortable training |
| Full H100 | 7/7 | 80 GB | Big training |

For workloads that fit on a 40 GB A100, request `3g.40gb` on Rorqual: same effective hardware, much shorter queue. See [[alliance-multi-instance-gpu]].

## TamIA / AIP

Some H100 / H200 capacity is allocated through the [Pan-Canadian AI Compute Environment (AIP)](https://alliancecan.ca/en/services/advanced-research-computing/pan-canadian-ai-compute-environment), not standard DRAC RAC. If your supervisor / institution has an AIP allocation, ask to be added — H200 with 141 GB VRAM is a generation ahead.

## What carries over between clusters

These constraints apply to **every** Alliance cluster:

- Compute nodes have no internet — pre-stage everything on a login node.
- No Docker, no sudo, no conda on the host. Apptainer + virtualenv.
- `$SCRATCH` auto-purged after 60 days.
- File-count quotas matter — tar datasets, build venvs in `$SLURM_TMPDIR`.
- `rsync --no-g --no-p` into `/project`.
- SLURM is the same: `sbatch`, `salloc`, `sq`, `seff`.

Migrating between clusters means: copy data via Globus, rebuild venvs (the wheelhouse is per-cluster), update `TORCH_CUDA_ARCH_LIST` (8.0 → 9.0 for A100 → H100, or 8.0;9.0 for both), pre-cache any HF/PyTorch weights on the new login node.

## When NOT to switch

- You're mid-deadline and the current cluster is working. Migration costs days.
- The current bottleneck isn't GPU speed (e.g. you're stuck on data prep or SfM).
- You haven't yet validated that your build/run works at all.

## Connections

- [[alliance-infrastructure-renewal]] — Alliance's official upgrade doc
- [[alliance-multi-instance-gpu]] — MIG slicing strategy on H100s
- [[alliance-transferring-data]] — `rsync --no-g --no-p` for moving data
- [[globus-cli-on-alliance]] — Globus CLI for inter-cluster migration
- [[claude-code-narval-instructions]] — Narval-specific CLAUDE.md template
- [[claude-code-rorqual-instructions]] — Rorqual-specific CLAUDE.md template
