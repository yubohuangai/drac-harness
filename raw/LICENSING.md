# Licensing — `raw/`

This directory contains documents authored by third parties, mirrored here for offline reference and to feed the harness's ingestion workflow. Each subdirectory has its own license terms.

## `alliance-docs/`

Mirrored from [docs.alliancecan.ca](https://docs.alliancecan.ca/wiki/Technical_documentation), the official documentation of the Digital Research Alliance of Canada.

**License:** [Creative Commons Attribution-ShareAlike 4.0 International (CC-BY-SA-4.0)](https://creativecommons.org/licenses/by-sa/4.0/), per the Alliance docs licensing terms.

**Attribution:** © Digital Research Alliance of Canada. Source URLs are listed in the `sources:` frontmatter of each corresponding wiki summary in `wiki/summaries/`. Each mirrored file links back to its upstream URL in the wiki summary that distills it.

Local file → upstream URL mapping (current as of 2026-05-02):

| Local file | Upstream URL |
|---|---|
| `Anaconda.md` | https://docs.alliancecan.ca/wiki/Anaconda/en |
| `Apptainer.md` | https://docs.alliancecan.ca/wiki/Apptainer |
| `Available software.md` | https://docs.alliancecan.ca/wiki/Available_software |
| `CUDA tutorial.md` | https://docs.alliancecan.ca/wiki/CUDA_tutorial |
| `Digital Research Alliance of Canada (the Alliance).md` | https://alliancecan.ca / https://docs.alliancecan.ca/wiki/Technical_documentation |
| `Getting started.md` | https://docs.alliancecan.ca/wiki/Getting_started |
| `Infrastructure renewal.md` | https://docs.alliancecan.ca/wiki/Infrastructure_renewal |
| `Machine Learning tutorial.md` | https://docs.alliancecan.ca/wiki/Tutoriel_Apprentissage_machine/en |
| `Monitoring jobs.md` | https://docs.alliancecan.ca/wiki/Monitoring_jobs |
| `Multi-Instance GPU.md` | https://docs.alliancecan.ca/wiki/Multi-Instance_GPU |
| `Nextflow.md` | https://docs.alliancecan.ca/wiki/Nextflow |
| `OpenCV.md` | https://docs.alliancecan.ca/wiki/OpenCV |
| `Prolonging terminal sessions.md` | https://docs.alliancecan.ca/wiki/Prolonging_terminal_sessions/en |
| `Python.md` | https://docs.alliancecan.ca/wiki/Python |
| `Running jobs.md` | https://docs.alliancecan.ca/wiki/Running_jobs |
| `Storage and file management.md` | https://docs.alliancecan.ca/wiki/Storage_and_file_management |
| `Transferring data.md` | https://docs.alliancecan.ca/wiki/Transferring_data |

If you ingest more Alliance docs, please add them to this table and preserve the CC-BY-SA-4.0 attribution.

## `community-notes/`

Third-party HPC documentation, blog posts, and guides written by individuals or organizations outside the Alliance.

**License:** Subject to each upstream's terms. We mirror under fair-use / fair-dealing for educational and reference purposes; users should consult the upstream license before redistributing.

| Local file | Source / author | Upstream URL |
|---|---|---|
| `DRAC clusters - Mila Technical Documentation.md` | Mila — Quebec AI Institute | https://docs.mila.quebec/ |

If you contribute a new community note, add a row here with the source and a link.

## This repository's own content

Everything in `wiki/`, `bin/`, `README.md`, and `CLAUDE.md` is the original work of `drac-harness` contributors:

- Code (`bin/`, scripts): MIT License — see [`LICENSE`](../LICENSE).
- Documentation (`wiki/`, `README.md`, `CLAUDE.md`): CC-BY-4.0 — see [`LICENSE-DOCS`](../LICENSE-DOCS).
