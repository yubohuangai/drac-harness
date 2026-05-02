---
title: Alliance — Infrastructure Renewal (2024–2026)
type: source
updated: 2026-05-02
sources: [alliance-docs/Infrastructure renewal.md]
tags: [alliance, infrastructure, h100, a100, narval, rorqual, fir, nibi, trillium, gpu-upgrade]
---

# Alliance — Infrastructure Renewal (2024–2026)

The Alliance replaced **~80% of its compute infrastructure** between winter 2024–2025 and early 2026. Old clusters were retired; new clusters with H100 GPUs took over. **Narval is the only cluster not in this upgrade cycle** — it stays as-is with A100-40G.

Source: https://docs.alliancecan.ca/wiki/Infrastructure_renewal

## Old → new mapping

| Retired cluster | Replacement | New GPU | Status |
|---|---|---|---|
| Beluga | **Rorqual** | H100-80G | Done (Beluga decommissioned 2026-06-20) |
| Cedar | **Fir** | H100-80G | Done (Cedar retired 2025-09-12) |
| Niagara + Mist | **Trillium** | H100-80G + CPU | Done (Niagara retired 2025-09-30) |
| Graham | **Nibi** | H100-80G | Done (Graham retired 2025-09-01) |
| Cloud (legacy) | Arbutus | (cloud) | In progress until 2026-08-31 |

**Narval** keeps its A100-40G GPUs; it was not part of this renewal cycle.

> "The remaining cluster — Narval — is not having an upgrade this cycle." — SHARCNET migration webinar, 2025-07-30.

## What changed

- **Total GPU compute capacity grew ~3.5×** across the Alliance.
- **Number of physical GPUs dropped from ~3200 to ~2100** — fewer GPUs, but each one (H100) is much more powerful than the old P100/V100/A100.
- **Per-job GPU sharing became essential.** With fewer, larger GPUs, the old "one GPU per job" pattern doesn't fit. **MIG (Multi-Instance GPU)** and **MPS (Multi-Process Service)** are now the recommended way to run smaller jobs. See [[alliance-multi-instance-gpu]].

## Why MIG/MPS matters more on the new clusters

> "Older GPUs (P100, V100) will be replaced with the newest H100 GPUs from NVIDIA. The total GPU computing power of the upgraded systems will grow by a factor of 3.5, but the number of GPUs will decrease significantly (from 3200 to 2100). This will present a significant challenge for users, as the usual practice of using a whole GPU for each process or MPI rank will no longer be feasible in most cases." — SHARCNET, Nov 2024.

A single full H100-80G is overkill for many jobs. The right pattern on Rorqual / Fir / Nibi / Trillium is:
- Small jobs → MIG slice (e.g., `1g.10gb`, `2g.20gb`, `3g.40gb`)
- Medium jobs → full H100 (80 GB)
- Large jobs → multi-H100 (rare)

## RAC transition gotcha

> "Because the old clusters will mostly be out of service before all new ones are available, if you hold both a 2024 and a 2025 RAC award you will experience a period when neither award is available to you."

Check CCDB for which clusters your specific RAC moved to. The migration window for Cedar / Beluga / Niagara / Graham is past — those clusters are gone.

## Filesystem migration

For each retired→new pair, files migrate automatically (same physical filesystem reused):
- Cedar files → Fir (no action needed)
- Graham files → Nibi (no action needed)
- Beluga files → Rorqual (no action needed)
- Niagara files → Trillium (action may be needed; see Trillium quickstart)

## Practical takeaways

1. **Don't submit jobs to retired clusters** (Cedar, Graham, Niagara, Mist, Beluga). They're gone.
2. **The H100 clusters are Rorqual, Fir, Nibi, Trillium.** Narval keeps A100-40G.
3. **For ML jobs that don't need 80 GB VRAM**, use MIG slices on the H100 clusters — much shorter queues.
4. **CUDA arch list**: H100 is compute capability 9.0; A100 is 8.0. Set `TORCH_CUDA_ARCH_LIST="8.0;9.0"` to build binaries that work on both.
5. **Compute nodes still have no internet** — same constraint as before, applies on every cluster.

## Connections

- [[alliance-cluster-comparison]] — picking which cluster to use
- [[alliance-multi-instance-gpu]] — MIG slicing, more important on H100 clusters
- [[digital-research-alliance-canada]] — the Alliance organization page
