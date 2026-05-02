---
title: CUDA Extension Build Gotchas
type: concept
updated: 2026-05-02
sources: []
tags: [cuda, extensions, tinycudann, simple-knn, gsplat, pytorch3d, build, gotchas]
---

# CUDA Extension Build Gotchas

Recurring failures when building CUDA-extension Python wheels (`tinycudann`, `simple-knn`, `gsplat`, `pytorch3d`, `flash-attn`, `kaolin`, etc.) on Alliance HPC. These have all hit real users; assume they will hit you.

## 1. `tinycudann` needs `setuptools < 81`

`tiny-cuda-nn/bindings/torch/setup.py` imports `pkg_resources`, which setuptools dropped in v81. Pin before the build:

```bash
pip install 'setuptools<81'
TCNN_CUDA_ARCHITECTURES=80 pip install bindings/torch    # SM 8.0 = A100
TCNN_CUDA_ARCHITECTURES=90 pip install bindings/torch    # SM 9.0 = H100
```

**Symptom if missed:** `ModuleNotFoundError: No module named 'pkg_resources'` mid-`pip install`.

## 2. `simple-knn` and `<cfloat>` (FLT_MAX) on CUDA 12 + GCC 11+

Some `simple-knn` forks (used by 3DGS variants) ship a `simple_knn.cu` that uses `FLT_MAX` without including `<cfloat>`. CUDA 12 + GCC 11+ no longer transitively pulls `<cfloat>` from `<cmath>`, so the build fails:

> `error: identifier "FLT_MAX" is undefined`

**Fix:** add `#include <cfloat>` at the top of `simple_knn.cu` (or apply a vendored patch). The vanilla 3DGS fork has the include; many forks don't.

## 3. Login-node CUDA builds silently mis-target SM

Login nodes have no GPU. When a build script auto-detects compute capability (e.g. via `torch.cuda.get_device_capability()`), it gets nothing or a default — and you end up with a wheel that won't run on the actual training node.

**Always set `TORCH_CUDA_ARCH_LIST` (or extension-specific equivalent) explicitly:**

```bash
export TORCH_CUDA_ARCH_LIST="8.0"          # A100 (Narval)
export TORCH_CUDA_ARCH_LIST="9.0"          # H100 (Rorqual / Fir / Nibi / Trillium)
export TORCH_CUDA_ARCH_LIST="8.0;9.0"      # both
export TCNN_CUDA_ARCHITECTURES=80          # tiny-cuda-nn uses its own var
```

Or **build inside a GPU `salloc`** so `nvcc` and any auto-detection see the right device:

```bash
salloc --account=rrg-<pi> --gres=gpu:1 --cpus-per-task=4 --mem=16G --time=1:00:00
# ... inside the salloc:
module load python/3.11 cuda/12.6 gcc
source ~/envs/myproj/bin/activate
TORCH_CUDA_ARCH_LIST="8.0" pip install <package>
```

## 4. `pip cache purge` fails inside some Apptainer base images

Some containers (`mambaorg/micromamba`, etc.) disable pip caching, so `pip cache purge` errors out and breaks `%post` if it's not last. Either remove the line or append `|| true`:

```
%post
    micromamba install -n base --file environment.yml && \
        micromamba clean --all --yes
    pip install <pkg> || true
    pip cache purge || true
```

## 5. `git` is missing in `mambaorg/micromamba` base

Most mamba-based Apptainer recipes need `git` to clone a CUDA-extension repo during build. The base image doesn't include it. Add explicitly:

```
%post
    micromamba install -n base -c conda-forge -y git
```

## 6. Build `%post` has no checkpointing

If your Apptainer build hits an error 30 minutes in, you start over from `Bootstrap:`. Split into two def files:

- `base.def` — the stable layer (CUDA + python + a stable env)
- `final.def` — `Bootstrap: localimage` from `base.sif`, doing the iterative parts (cloning extensions, applying patches, building wheels)

Iterate on `final.def` cheaply.

## 7. `APPTAINER_TMPDIR` on Lustre causes `bus error`

`/project` is Lustre; using it for `APPTAINER_TMPDIR` periodically gives `bus error` mid-build. Set to `/scratch` or `$SLURM_TMPDIR` instead:

```bash
export APPTAINER_TMPDIR=/scratch/$USER/apptainer/tmp
mkdir -p "$APPTAINER_TMPDIR"
```

## Connections

- [[alliance-apptainer]] — full Apptainer recipe and flags
- [[alliance-python]] — virtualenv + wheelhouse setup
- [[apptainer]] — concept page
- [[cuda]] — compute capabilities, toolkit vs driver
- [[alliance-cuda-tutorial]] — Alliance's intro CUDA doc
