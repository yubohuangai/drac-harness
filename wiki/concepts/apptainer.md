---
title: Apptainer
type: concept
updated: 2026-05-02
sources: [alliance-docs/Apptainer.md]
tags: [container, hpc, apptainer, singularity, docker]
---

# Apptainer

Linux container runtime, like Docker but designed for shared HPC. Rootless by default, consumes Docker images, produces compressed read-only `.sif` artifacts.

**Background.** Originally called Singularity (started at LBNL, 2015), renamed Apptainer in 2021 when the Linux Foundation adopted the open-source fork. "SingularityCE" continues separately under Sylabs. On the Alliance, Singularity is deprecated in favor of Apptainer — they are API-compatible but the command is now `apptainer`, not `singularity`.

## Why HPC uses it, not Docker

Docker requires a root-privileged daemon (`dockerd`). On a shared cluster, any user who can talk to `dockerd` can effectively become root on the host. Apptainer runs entirely in the user's own UID — no daemon, no privilege escalation.

## The SIF file

A **Singularity Image Format** file is a single compressed artifact containing a squashfs of the root filesystem. Benefits:
- One file to move around (unlike Docker's layered tar bundles).
- Read-only by default — scientific runs are reproducible bit-for-bit.
- Only counts as one file against HPC filesystem quotas (important on Alliance clusters where the file-count quota is often more constraining than the byte quota).

## Key differences from Docker

| Aspect | Docker | Apptainer |
|---|---|---|
| Daemon | yes (`dockerd`) | no |
| Needs root | yes (to run) | no |
| Image format | layered tar | single SIF squashfs |
| Default rw | yes | no (read-only) |
| HPC-friendly | no | yes |
| GPU flag | `--gpus all` | `--nv` |

Apptainer can **consume Docker images directly**: `apptainer build out.sif docker://user/image`. That makes the Docker ecosystem (Docker Hub, NGC, GHCR) fully usable on HPC without running Docker there.

## The Alliance pattern

Build somewhere with sudo (your laptop, a lab server) → produce SIF → `scp`/Globus to the cluster → `module load apptainer && apptainer run --nv ...`. See [[alliance-apptainer]] for commands.

## Connections

- [[alliance-apptainer]] — the Alliance source doc with command details
- [[alliance-anaconda-policy]] — conda-in-Apptainer is preferred over conda-on-bare-metal
- [[cuda-extension-build-gotchas]] — CUDA wheel build issues recur inside SIFs too
