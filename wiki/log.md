---
title: Operations Log
type: log
updated: 2026-05-02
---

# Operations Log

Chronological record of ingest, query, lint, update, create, and onboard operations on this drac-harness clone. Append new entries at the bottom.

Format:

```markdown
## [YYYY-MM-DD] operation | Description

Details of what was done, pages created/updated.
```

Operations: `ingest`, `query`, `lint`, `update`, `create`, `onboard`.

---

## [2026-05-02] create | initialized drac-harness

Repository scaffolded as a sanitized, generalized fork of the Alliance-related portion of a personal LLM-Wiki knowledge base.

Initial content:

- **Canonicals** (`wiki/canonicals/`): templated `CLAUDE.md` for Narval (A100) and Rorqual (H100). Use `{{USER}}`, `{{RAC_ACCOUNT}}`, `{{DEF_ACCOUNT}}`, `{{HARNESS_PATH}}` placeholders, substituted at install time by `bin/install-claude-md.sh` from `~/.config/drac-harness/user.conf`.
- **Summaries** (`wiki/summaries/`): 16 one-page distillations of upstream Alliance docs.
- **Cheatsheets** (`wiki/cheatsheets/`): alliance-workflow, narval, globus-cli, tmux.
- **Concepts** (`wiki/concepts/`): apptainer, cuda, cuda-extension-build-gotchas.
- **Entities** (`wiki/entities/`): digital-research-alliance-canada.
- **Analyses** (`wiki/analyses/`): alliance-cluster-comparison (Narval vs the H100 clusters; RGU values; MIG sizing).
- **Raw sources** (`raw/alliance-docs/`): 17 mirrored Alliance docs, CC-BY-SA-4.0; attribution in `raw/LICENSING.md`.
- **Raw sources** (`raw/community-notes/`): 1 Mila DRAC overview, attributed.
- **Scripts** (`bin/`): `setup.sh` (interactive prompts → `~/.config/drac-harness/user.conf`), `install-claude-md.sh` (extract canonical, substitute, write `~/.claude/CLAUDE.md`).
- **License**: MIT for code, CC-BY-4.0 for docs.

## [2026-05-02] create | onboarded nibi

Drafted `wiki/canonicals/claude-code-nibi-instructions.md` after live recon on `l3.nibi.sharcnet`. Nibi-specific adaptations vs the Rorqual template: heterogeneous accelerator mix (`gpu:h100:8`, `gpu:a100:8`, `gpu:mi300a:4`) promoted to a hard rule requiring explicit `--gres=gpu:<type>:1` selection — A100 needs `TORCH_CUDA_ARCH_LIST=8.0`, H100 `9.0`, and MI300A is AMD ROCm (not CUDA) with APU-style unified memory; partition family uses the `interac` / `bycore_b1..b5` / `bynode_b1..b5` / `bygpu_b1..b5` / `backfill` walltime tier scheme (b1=3h → b5=7d) with `cpularge_*` for high-memory CPU and `gpubase_bygpu_*` instead of Rorqual's `gpubase_bynode_*`; scratch quota is **1 TiB / 1M files** (vs 20 TB on Narval/Rorqual), flagged as a watch-item; `/nearline` is documented (~9.3 TiB group quota with a hard 5000-file cap, tar-only). Wheelhouse `torch 2.11.0` ships for cp311–cp314 (x86-64-v3); ROCm wheels are not in the Alliance index, so MI300A users need `rocm/pytorch`-based Apptainer images. Operator (SHARCNET) recorded. Install verified: `~/.claude/CLAUDE.md` written (257 lines, all four placeholders resolved).
