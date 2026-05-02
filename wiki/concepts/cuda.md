---
title: CUDA
type: concept
updated: 2026-05-02
sources: [alliance-docs/CUDA tutorial.md]
tags: [cuda, gpu, nvidia, parallel-computing]
---

# CUDA

NVIDIA's parallel computing platform. "Compute Unified Device Architecture." Provides a C/C++ dialect (`nvcc`), runtime libraries (cuBLAS, cuDNN, cuFFT, …), and a hardware driver abstraction so the same binary can run on many generations of NVIDIA GPUs.

## Compute capability

Each NVIDIA GPU has a **compute capability** version — the feature set and ISA its SMs implement. Kernels must be compiled for specific capabilities. Key values for Alliance hardware:

| GPU | Family | Capability |
|---|---|---|
| A100 | Ampere | 8.0 |
| H100 | Hopper | 9.0 |

For wheels that need to work on both Narval and the H100 clusters: `TORCH_CUDA_ARCH_LIST="8.0;9.0"`.

## CUDA toolkit vs driver

- **Driver** — kernel module on the host OS; provides `libcuda.so`. Tied to the OS and the physical GPU.
- **Toolkit** — userspace: `nvcc`, cuBLAS, cuDNN, headers. Versioned independently.

A toolkit version T requires driver version ≥ T_min. The Alliance's CUDA modules and the `cuda-toolkit` conda packages provide the toolkit; the driver is the host's. This is why mismatched toolkits can still work if the host driver is new enough.

## Why ML people care

PyTorch, JAX, TensorFlow all ship CUDA kernels for GPU ops. "PyTorch cu126" = PyTorch wheels linked against CUDA 12.6 libraries. The PyTorch wheel bundles its own CUDA runtime, so as long as the host driver is new enough, you usually don't need a system CUDA install.

But **CUDA extensions** (pytorch3d, gsplat, flash-attn, xformers sdists) *do* need the toolkit at build time because they invoke `nvcc` to compile custom kernels. That's why installing them on Alliance requires either loading the `cuda/12.x` module or having the conda env bundle `cuda-toolkit`.

## Related concepts

- [[alliance-cuda-tutorial]] — Alliance's intro tutorial
- [[alliance-multi-instance-gpu]] — MIG partitioning of A100/H100
- [[cuda-extension-build-gotchas]] — recurring failures when building CUDA wheels (`tinycudann`, `simple-knn`, login-node arch mis-targeting)
