---
title: Alliance — Getting Started
type: source
updated: 2026-05-02
sources: [alliance-docs/Getting started.md]
tags: [hpc, alliance, ssh, getting-started]
---

# Alliance — Getting Started

Official Alliance onboarding guide. Source: https://docs.alliancecan.ca/wiki/Getting_started

## Available systems

| Cluster | Type | Best for |
|---|---|---|
| **Narval** | General-purpose HPC, A100 GPUs | GPU/ML on the established A100 stack |
| **Rorqual** | General-purpose HPC, H100 GPUs | GPU/ML — successor to Beluga |
| **Fir** | General-purpose HPC, H100 GPUs | GPU/ML — successor to Cedar |
| **Nibi** | General-purpose HPC, H100 GPUs | GPU/ML — successor to Graham |
| **Trillium** | Homogeneous HPC, H100 GPUs + CPU | Large parallel jobs (> 1000 cores), CPU-focused — successor to Niagara/Mist |
| **Arbutus** | Cloud (OpenStack) | VMs, web portals, interactive software |

> Beluga, Cedar, and Graham have been retired and replaced. See [[alliance-infrastructure-renewal]] for the timeline.

Request access to any system at: https://ccdb.alliancecan.ca/me/access_systems

## Credentials

- Login: same username/password as CCDB (https://ccdb.alliancecan.ca).
- Your CCI (Compute Canada Identifier) is visible when logged into CCDB — it identifies you across the federation.
- **MFA** required on most clusters: Duo Push to phone, or a TOTP authenticator.

## Training resources

- **Alliance training portal**: https://training.alliancecan.ca
- **Upcoming events**: https://explora.alliancecan.ca/events
- **Local regional consortia** (WestDRI, Calcul Québec, SHARCNET, ACENET, Compute Ontario) often run their own bootcamps; check your home institution's research-computing site.

## Key documentation links

- Software available: https://docs.alliancecan.ca/wiki/Available_software
- How modules work: https://docs.alliancecan.ca/wiki/Utiliser_des_modules/en
- Running jobs (SLURM): https://docs.alliancecan.ca/wiki/Running_jobs
- Storage: https://docs.alliancecan.ca/wiki/Storage_and_file_management
- AI/ML guide: https://docs.alliancecan.ca/wiki/AI_and_Machine_Learning
- Python virtualenv: https://docs.alliancecan.ca/wiki/Python#Creating_and_using_a_virtual_environment
- Globus (large transfers): https://docs.alliancecan.ca/wiki/Globus

## Connections

- [[digital-research-alliance-canada]] — the umbrella organization
- [[alliance-storage-and-file-management]]
- [[alliance-ml-tutorial]]
- [[alliance-infrastructure-renewal]] — what changed in 2024–2026
- [[narval-cheat-sheet]]
