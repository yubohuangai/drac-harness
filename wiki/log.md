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
