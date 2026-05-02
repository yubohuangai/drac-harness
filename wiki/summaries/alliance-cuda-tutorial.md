---
title: Alliance — CUDA Tutorial
type: source
updated: 2026-05-02
sources: [alliance-docs/CUDA tutorial.md]
tags: [alliance, cuda, gpu, parallel-computing, tutorial]
---

# Alliance — CUDA Tutorial

Alliance's introductory tutorial to CUDA C/C++ for users new to GPU programming. Most ML users won't write raw CUDA, but this is useful background when debugging compile failures in CUDA extensions (pytorch3d, gsplat, flash-attn).

Source: https://docs.alliancecan.ca/wiki/CUDA_tutorial

## What it covers

- **Hardware model** — GPU = global memory + streaming multiprocessors (SMs); each SM hosts many streaming processors (SPs).
- **Programming model** — Host = CPU/RAM, Device = GPU/VRAM. Typical kernel: allocate on both, init host, H→D copy, run kernel, D→H copy.
- **Execution model** — SIMT (Single Instruction, Multiple Threads). Kernel launched on grid of blocks of threads.
- **Block/thread indexing** — `threadIdx`, `blockIdx`, `blockDim`, `gridDim`.
- **Compilation** — `nvcc` compiler, CUDA toolkit modules (`module load cuda/12.x`).

## Compute capability — practical reference

CUDA kernels must be compiled for a specific GPU compute capability. If you don't set `TORCH_CUDA_ARCH_LIST` when building a CUDA extension, the build script probes for visible GPUs; on a login node with no GPU, this fails or silently targets a useless arch.

| GPU | Family | Compute capability |
|---|---|---|
| RTX 2080 Ti | Turing | 7.5 |
| A100 | Ampere | 8.0 |
| H100 | Hopper | 9.0 |

When building wheels that will run across machines: `TORCH_CUDA_ARCH_LIST="7.5;8.0;9.0"`.

## When to revisit

If you need to write custom CUDA kernels (rare for most ML users), or need to debug deep `nvcc` output from extension builds.

## Related concepts

- [[cuda]] — the platform itself
- [[alliance-multi-instance-gpu]] — MIG partitioning of A100/H100
- [[cuda-extension-build-gotchas]] — recurring failures when building CUDA wheels (`tinycudann` setuptools pin, missing `<cfloat>` includes, login-node arch mis-targeting)
