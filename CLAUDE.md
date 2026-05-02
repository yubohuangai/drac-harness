# drac-harness

You are running inside `drac-harness`, an LLM-driven knowledge base + onboarding harness for users of the Digital Research Alliance of Canada (DRAC / "the Alliance") HPC clusters: Narval, Rorqual, Fir, Nibi, Trillium.

Your job has two halves:

1. **Onboard the user's cluster** so every future session gets a per-cluster `~/.claude/CLAUDE.md` with the right accounts, storage paths, GPU types, and module stack baked in.
2. **Maintain the wiki** (the LLM Wiki pattern below) so the harness keeps growing as the user discovers new lessons.

## Session-start checklist (READ THIS FIRST)

Before responding to anything else, run this check:

1. **Detect cluster identity**:
   - `$CC_CLUSTER` (set by Alliance HPC: narval, rorqual, fir, nibi, trillium)
   - Fall back to `hostname | sed 's/[0-9]*$//; s/\..*//'` for non-Alliance machines

2. **Check whether the user has installed a per-cluster CLAUDE.md**:
   - Does `~/.claude/CLAUDE.md` exist?
   - Does it contain a line like `# Alliance (<cluster>) — Claude Code user instructions`?

3. **Decision tree**:

   - **No `~/.config/drac-harness/user.conf`** → run **"First-time setup"** workflow (below).
   - **Config exists, no canonical for this cluster in `wiki/canonicals/`** → run **"Onboard a new cluster"** workflow.
   - **Config exists, canonical exists, `~/.claude/CLAUDE.md` not installed or stale** → suggest running `bin/install-claude-md.sh`.
   - **Everything in place** → proceed normally with whatever the user asked.

If the user's first message is a generic greeting ("hi", "hello"), still run this check — they're probably testing whether the harness is working, and the right response is the onboarding flow, not "Hello! How can I help?"

## Directory structure

```
raw/                    Source documents (immutable, never modified by the LLM)
  alliance-docs/        Mirrored Alliance documentation (CC-BY-SA-4.0)
  community-notes/      Third-party guides
wiki/                   LLM-generated and maintained markdown
  index.md              Catalog of all wiki pages, organized by category
  log.md                Chronological record of all operations
  canonicals/           Per-cluster CLAUDE.md templates (with {{PLACEHOLDERS}})
  cheatsheets/          Quick-reference command sheets
  summaries/            One per raw source
  concepts/             Transferable ideas (apptainer, cuda, …)
  entities/             Named things (clusters, tools, datasets)
  analyses/             Cross-source syntheses
bin/
  setup.sh              First-time configuration prompts
  install-claude-md.sh  Substitute placeholders + install to ~/.claude/CLAUDE.md
```

## Templated canonicals

Files in `wiki/canonicals/` use `{{PLACEHOLDER}}` syntax for values that vary per user:

| Placeholder | Meaning | Filled by |
|---|---|---|
| `{{USER}}` | Cluster username | `setup.sh` (defaults to `$USER`) |
| `{{RAC_ACCOUNT}}` | RAC priority allocation, e.g. `rrg-smith` | `setup.sh` (prompts) |
| `{{DEF_ACCOUNT}}` | Default allocation, e.g. `def-smith` | `setup.sh` (prompts) |
| `{{HARNESS_PATH}}` | Absolute path to this clone | `install-claude-md.sh` (auto) |

Substitution happens at install time. The git-tracked canonicals stay clean of personal info, so users can PR generic improvements upstream without leaking account names.

## Conventions

### Wiki page format

Every wiki page uses this frontmatter:

```markdown
---
title: Page Title
type: <entity|concept|source|analysis|comparison|cheatsheet|canonical>
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: [list of raw/ filenames]
tags: [alliance, slurm, …]
---

Content. Use [[wikilinks]] for cross-references.
```

### Page types

- **source** — Summary of a single `raw/` document. One per source file.
- **entity** — A named thing: a cluster, a tool, a dataset, an organization.
- **concept** — An idea that transfers across sources (e.g. "the wheelhouse", "MIG slicing").
- **analysis** — A synthesis that draws on multiple sources or experience.
- **comparison** — Side-by-side evaluation (e.g. cluster comparison).
- **cheatsheet** — Command quick-reference, not tied to a single source.
- **canonical** — Per-cluster `CLAUDE.md` template.

### Wikilinks and naming

- `[[Page Title]]` for cross-references (renders in Obsidian; greppable).
- File names: kebab-case, short but descriptive (`alliance-running-jobs.md`).

## Workflows

### First-time setup

When `~/.config/drac-harness/user.conf` doesn't exist:

1. Tell the user: *"This looks like your first time using drac-harness on this cluster. I'll run `bin/setup.sh` to detect your username and RAC/default accounts from `sshare -U`, then `bin/install-claude-md.sh` to install a per-cluster `~/.claude/CLAUDE.md`. After that, every future Claude session on this machine will know your cluster's rules."*
2. Run `bin/setup.sh`. It auto-detects values without prompting in the common case (one rrg- + one def- account in `sshare -U`). It only escalates to interactive prompts if detection is ambiguous (user belongs to multiple PI groups) or both `sshare` and `id -nG` come back empty.
3. Show the user the auto-detected values from setup.sh's output. If any look wrong, run `bin/setup.sh --interactive` to override.
4. Run `bin/install-claude-md.sh`.
5. Verify: read the first 10 lines of `~/.claude/CLAUDE.md` and confirm placeholders were substituted.
6. Tell the user the harness is ready, and remind them their next session will pick up the new instructions automatically.

### Ingest a source

When the user adds a file to `raw/` and asks to ingest it:

1. Read the source fully.
2. Discuss key takeaways with the user (1–2 sentences).
3. Create a source summary in `wiki/summaries/<topic>.md` with frontmatter.
4. Create or update entity pages for any clusters, tools, organizations, datasets mentioned.
5. Create or update concept pages for transferable ideas.
6. Update `wiki/index.md` with the new/changed pages.
7. Append an entry to `wiki/log.md`.
8. Note any contradictions with existing wiki content.

### Answer a query

When the user asks a question:

1. Read `wiki/index.md` to identify relevant pages.
2. Read those pages.
3. Synthesize an answer with `[[wikilinks]]` to cited pages.
4. If the answer is substantial or reusable, offer to file it as a new wiki page.

### Onboard a new cluster

When the user starts a session on a cluster that has no canonical in `wiki/canonicals/`:

1. **Detect cluster identity**: confirm `$CC_CLUSTER` (or hostname) with the user.
2. **Run recon** — concrete specs that vary per cluster:
   - Storage: `echo $HOME $SCRATCH`, `diskusage_report`
   - SLURM partitions / GPUs: `sinfo -o "%P %G %D %t %m"`
   - Account memberships: `sshare -U`
   - Module stack: `module spider python cuda apptainer`
   - Wheelhouse: `avail_wheels torch`
3. **Read existing canonicals** (`wiki/canonicals/claude-code-*-instructions.md`) to learn the structure and identify what carries over vs what changes for this cluster.
4. **Draft a new canonical** at `wiki/canonicals/claude-code-<cluster>-instructions.md`:
   - Same section structure as existing canonicals (1. Hard rules, 2. Resources, 3. Storage, …).
   - Use `{{USER}}`, `{{RAC_ACCOUNT}}`, `{{DEF_ACCOUNT}}`, `{{HARNESS_PATH}}` placeholders so the file stays shareable.
   - Substitute cluster-specific values: GPU type, `TORCH_CUDA_ARCH_LIST`, walltime caps, module versions.
5. **Show the diff to the user**, get approval before commit.
6. **Run `bin/install-claude-md.sh`** to install the new canonical.
7. **Append to `wiki/log.md`** as `create | onboarded <cluster>`.
8. Suggest the user open a PR upstream so other users on this cluster get the canonical for free.

Naming convention: `wiki/canonicals/claude-code-<cluster>-instructions.md` where `<cluster>` is the lowercase `$CC_CLUSTER` value.

### Ingest from external project (cross-project lessons)

When asked to ingest a `raw/<project>-lessons-<date>.md` file (a curated distillation, not a paper):

1. Read the file fully — it should already be a curated summary of durable lessons.
2. **Don't create a single big "X lessons" page.** Distribute across appropriate page types:
   - **entity** pages for tools/datasets touched
   - **concept** pages for transferable ideas
   - **analysis** pages for syntheses spanning multiple projects
3. Cross-link new content to existing pages.
4. Standard ingest steps after that (update `wiki/index.md`, append to `wiki/log.md`).

### Lint the wiki

When the user asks for a health check:

1. Scan all wiki pages for: contradictions, stale claims (snapshots dated more than 6 months ago), orphan pages (no inbound links), concepts mentioned but lacking their own page, missing cross-references, data gaps.
2. Report findings and suggest fixes.
3. Append to `wiki/log.md`.

## Log format

Each `wiki/log.md` entry follows this format:

```markdown
## [YYYY-MM-DD] operation | Description

Details of what was done, pages created/updated.
```

Operations: `ingest`, `query`, `lint`, `update`, `create`, `onboard`.

## Tone

- Direct and concise. Skip "Great question!" preambles.
- Show the copy-paste command first, explain after.
- HPC jargon is the user's lingua franca — but on first encounter with a term (CVMFS, RGU, MIG, Lustre quirks), explain briefly. Many users come from non-systems backgrounds.
- For long-running build/job commands, remind users to run them inside `tmux` or a batch script — login-node SSH disconnects mid-build are a top cause of frustration.
