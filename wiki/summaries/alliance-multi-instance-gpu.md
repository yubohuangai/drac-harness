---
title: Alliance — Multi-Instance GPU (MIG)
type: source
updated: 2026-05-02
sources: [alliance-docs/Multi-Instance GPU.md]
tags: [alliance, gpu, mig, narval, rorqual, slurm, a100, h100]
---

# Alliance — Multi-Instance GPU (MIG)

MIG partitions a single physical GPU into multiple independent virtual GPUs, each with its own compute and memory slice. Jobs on instances consume less allocation priority → shorter queues and more jobs per day.

Source: https://docs.alliancecan.ca/wiki/Multi-Instance_GPU

## When to use a MIG instance

Use an instance when your job uses **less than half** of GPU compute power AND **less than half** of GPU memory. In most cases it will run just as fast and cost less allocation.

Check with `nvidia-smi` on a running job: if power draw is < 50% of TDP and GPU memory is < 50% used, switch to an instance next time.

## Available instances on Narval (A100-40 GB)

| Instance | Compute | Memory | CPUs | System RAM |
|----------|---------|--------|------|-----------|
| `a100_3g.20gb` | 3/8 | 20 GB | 2 | 40 GB |
| `a100_4g.20gb` | 4/8 | 20 GB | 6 | 62 GB |

## Available instances on H100 clusters (Rorqual / Fir / Nibi / Trillium, H100-80 GB)

| Instance | Compute | VRAM | Use case |
|----------|---------|------|----------|
| `nvidia_h100_80gb_hbm3_1g.10gb` | 1/7 | 10 GB | inference, light dev |
| `nvidia_h100_80gb_hbm3_2g.20gb` | 2/7 | 20 GB | small training |
| `nvidia_h100_80gb_hbm3_3g.40gb` | 3/7 | 40 GB | ≈ A100-40G — comfortable training |
| (full H100) | 7/7 | 80 GB | big training |

## SLURM syntax

```bash
# Narval — interactive A100 MIG slice (3/8 power, 20 GB)
salloc --account=rrg-<pi> --gpus=a100_3g.20gb:1 --cpus-per-task=2 --mem=40G --time=1:0:0

# Rorqual — interactive H100 MIG slice (1/7, 10 GB)
salloc --account=rrg-<pi> --gres=gpu:nvidia_h100_80gb_hbm3_1g.10gb:1 --cpus-per-task=4 --mem=16G --time=1:00:00

# Batch
#SBATCH --account=rrg-<pi>
#SBATCH --gpus=a100_4g.20gb:1
#SBATCH --cpus-per-task=6
#SBATCH --mem=62G
#SBATCH --time=24:00:00
```

## Limitations

- **Cannot request more than one MIG instance** in a single job (no CUDA IPC across instances). Request a larger instance, a full GPU, or multiple full GPUs instead.
- No graphics APIs (OpenGL, Vulkan).
- CPU core limits per instance depend on cluster configuration.

## Check available GPU flavours

```bash
sinfo -o "%G" | grep gpu | sed 's/gpu://g' | sed 's/),/\n/g' | cut -d: -f1 | sort | uniq
```

## Why MIG matters more on H100 clusters

H100 is so capable that **most jobs don't need a full one**. With fewer GPUs in the H100 pool than the old A100 pool, the cultural pattern is shifting toward MIG slices. See [[alliance-infrastructure-renewal]] for the per-cluster GPU counts. For workloads that fit on a 40 GB A100, the `3g.40gb` slice on H100 gives equivalent VRAM with much shorter queues.

## Connections

- [[narval-cheat-sheet]] — general SLURM commands
- [[alliance-ml-tutorial]] — full training job workflow
- [[alliance-running-jobs]] — SLURM fundamentals
- [[alliance-infrastructure-renewal]] — why the H100 clusters have fewer GPUs and why MIG is now expected
- [[alliance-cluster-comparison]] — picking which cluster to run on
