---
title: Alliance — Storage and File Management
type: source
updated: 2026-05-02
sources: [alliance-docs/Storage and file management.md]
tags: [hpc, storage, alliance, slurm]
---

# Alliance — Storage and File Management

Official Alliance docs on filesystem types, quotas, and best practices for the [[digital-research-alliance-canada]] clusters.

Source: https://docs.alliancecan.ca/wiki/Storage_and_file_management

## The five storage types

| Filesystem | Quota | Backed up? | Purged? | Use for |
|---|---|---|---|---|
| **HOME** | ~47 GB | nightly, 30 days | No | Source code, scripts, venvs, small config files |
| **PROJECT** | **1 TB default** (group) | nightly, 30 days | No | Research datasets, trained model checkpoints, shared data |
| **SCRATCH** | 1 TB soft quota | No | **auto-purged** | Training job outputs, temp files; **do not treat as permanent** |
| **NEARLINE** | Large (RAC) | — | No | Cold archival; tape-based; for datasets not accessed for months |
| **`$SLURM_TMPDIR`** | Node-local | No | deleted at job end | Fastest I/O during a job; ideal for processing many small files |

### The rule that catches people: SCRATCH is not permanent

SCRATCH files are subject to the [purging policy](https://docs.alliancecan.ca/wiki/Scratch_purging_policy) — old files are **automatically deleted** after 60 days. The 1 TB soft quota can be temporarily exceeded for up to 60 days, then writes are blocked until you clean up. Always copy important outputs (checkpoints, results) to PROJECT before they get purged.

## Useful commands

```bash
# Check your quota across all filesystems
diskusage_report

# Check per-user usage in project space
lfs quota -u $USER /project

# Count files in a directory (Lustre-friendly)
lfs find <path> -type f | wc -l
```

## Best practices

### Many-small-files problem

Alliance filesystems are optimized for **a few very large files**, not thousands of small ones. Multi-view video → hundreds of frames per camera → thousands of files. **Pack them into archives before storing:**

```bash
tar -czf frames_cam01.tar.gz ./frames/cam01/
```

Even better: keep raw video as `.mp4` and extract frames only into `$SLURM_TMPDIR` at job start.

### Workflow for a training run

```
$SLURM_TMPDIR             ← unpack dataset here at job start (fast local I/O)
     ↓ train
/scratch/$USER/run_xyz/   ← write checkpoints during training
     ↓ after job ends — immediately copy best checkpoint
/project/<your-account>/$USER/checkpoints/   ← permanent storage
```

Never read training data directly from `/project` during a tight training loop — too slow. Unpack to `$SLURM_TMPDIR` first.

### Quotas and how to increase

- Default `/project`: **1 TB per group**, shared with everyone in the group.
- Rapid Access Service (RAS): ask for up to **40 TB** per group with a request to technical support — no competition, processed quickly.
- Resource Allocation Competition (RAC): for very large allocations, annual application.
- Contact: support@tech.alliancecan.ca

## Backups and recovery

- HOME and PROJECT: nightly backups, **retained 30 days**; deleted files retained a further **60 days**.
- To recover a previous version: contact technical support with full path + desired date.
- SCRATCH: **not backed up**. If you delete it, it's gone.

## Connections

- [[digital-research-alliance-canada]] — overview of the Alliance
- [[alliance-transferring-data]] — how to move data in/out without breaking quotas (the `--no-g --no-p` rsync rule)
- [[alliance-running-jobs]] — uses `$SLURM_TMPDIR` for fast local I/O during jobs
