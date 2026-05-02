---
title: Alliance — Available Software
type: source
updated: 2026-05-02
sources: [alliance-docs/Available software.md]
tags: [alliance, modules, software, cvmfs, lmod]
---

# Alliance — Available Software

The canonical Alliance page listing software available via the **Lmod module system** plus conventions for Python/R/Perl packages. Most useful as a reference for "is X already installed, or do I need to ship my own container?"

## How software is delivered on Alliance

Three tiers, in order of Alliance's preference:

1. **Lmod modules** — `module load foo` exposes a preinstalled package. Most non-Python scientific software lives here (CUDA, GCC, OpenMPI, OpenCV, R base, etc.).
2. **Python wheels** — PyPI mirror at `/cvmfs/soft.computecanada.ca/custom/python/wheelhouse/`. Accessed via `pip install --no-index foo`. Alliance prebuilds wheels for their CPU architectures. See [[alliance-python]].
3. **User-installed** — R/Perl packages in personal/group space; conda and custom stacks via Apptainer ([[alliance-apptainer]]).

## StdEnv caveat

> `StdEnv/2020` is now deprecated/hidden on the newer systems.

Software lists are tied to the loaded **StdEnv**. Different module versions appear under different StdEnvs. On the newer systems (Fir, Nibi, Rorqual, Trillium) older modules may be unavailable.

Check current env with `module -t list`; switch with `module load StdEnv/<year>`. Default on the newer clusters is `StdEnv/2023`.

## Docker is absent by design

> Docker is not available on our clusters but Apptainer is available by loading the module `apptainer`.

Confirmed in the official docs, not just inferred from community wisdom. See [[apptainer]] for the concept and [[alliance-apptainer]] for the commands.

## Site-specific software

A handful of packages are installed only on specific clusters, usually due to license restrictions:

| Package | Clusters | Notes |
|---|---|---|
| ADF, AMS, AMBER, Gaussian | Nibi (some also Fir) | Computational chemistry |
| SAS | Cedar (legacy) | Licensed seats |
| Galaxy, GBrowse, TPP | Cedar (legacy) | Bioinformatics; Galaxy requires admin setup |
| DIRAC | Cedar (legacy) | Relativistic quantum chemistry |

## Implicitly available (not listed)

OS-level tools are **part of the default environment** and don't appear in the module list:

- Autotools, Make, Git, standard GNU userland
- Basic Python (usually a stub; use `module load python` for a specific version)

So `git` is always there on login nodes, but **not inside an Apptainer base image** — that's why most Apptainer build recipes need a `micromamba install -n base -c conda-forge -y git` step.

## CVMFS

Most modules live on **CVMFS** (CernVM File System) — a distributed read-only filesystem that mounts the same software tree across all Alliance clusters. This is why `module load` gives consistent versions everywhere.

You can also mount CVMFS on your own machine ([Accessing CVMFS](https://docs.alliancecan.ca/wiki/Accessing_CVMFS)) to use Alliance's software stack locally.

## Practical takeaways

1. **Before Apptainer, check modules.** `module spider <name>` might save you a build. OpenCV, CUDA, Python, PyTorch (some cuda-paired wheels) are all module-available.
2. **Python wheels are prebuilt.** `pip install --no-index torch` on a login node tries the CVMFS wheelhouse first — faster than PyPI and pre-tested on Alliance hardware. See [[alliance-ml-tutorial]].
3. **Containers override everything.** Once you're inside an Apptainer SIF, nothing from the host module system is visible unless you bind-mount it. That's by design (reproducibility).
4. **Default shell has git, make, ssh.** Don't install them; they're already there on login nodes.

## Connections

- [[alliance-python]] — how to use the Python wheelhouse
- [[alliance-apptainer]] — the container-based alternative when modules aren't enough
- [[alliance-anaconda-policy]] — why conda is discouraged (modules + wheels + apptainer cover most needs)
- [[alliance-opencv]] — a specific module-loading example
- [[alliance-ml-tutorial]] — the canonical workflow that uses modules + virtualenv + wheels
- [[digital-research-alliance-canada]] — the umbrella org
