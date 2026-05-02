# drac-harness

A Claude Code harness for the Digital Research Alliance of Canada (DRAC / "the Alliance") HPC clusters — Narval, Rorqual, Fir, Nibi, Trillium.

---

## Why this exists

Alliance clusters are powerful but unfriendly to newcomers. Setting up environments is finicky, job submission is tedious, and the right combination of `module load`, `salloc --account=…`, `--gres=`, `$SLURM_TMPDIR`, and the wheelhouse takes weeks to internalize — by which point you've already burned most of your patience.

**`drac-harness` hides that complexity behind your AI coding agent** (Claude Code out of the box; easy to adapt to Codex, OpenCode, or others). Drop into any Alliance cluster, start your agent (e.g. `claude`), and it will detect your cluster, propose right-sized SLURM submissions, build virtual environments the Alliance way, and translate "I want to train this" into a correct `sbatch` script. With it, **you'll be flying on the Alliance** — the cluster feels like a normal server, just with H100s and hundreds of terabytes at your disposal.

---

## Quick start

```bash
# 1. Clone (login node of any Alliance cluster)
git clone https://github.com/<owner>/drac-harness.git ~/github/drac-harness

# 2. Install Claude Code (per Anthropic docs)
#    https://docs.claude.com/en/docs/claude-code
npm install -g @anthropic-ai/claude-code

# 3. Start a session in the harness directory and say hi
cd ~/github/drac-harness
claude
> hi
```

On first run, Claude will:

1. **Detect the cluster** via `$CC_CLUSTER` (Alliance HPC sets this) or hostname.
2. **Run `bin/setup.sh`** to ask for your username, RAC account (`rrg-<pi>`), and default account (`def-<pi>`), and save them to `~/.config/drac-harness/user.conf`.
3. **Run `bin/install-claude-md.sh`** to substitute your values into the per-cluster canonical and write `~/.claude/CLAUDE.md`.
4. From the next session onward, every Claude conversation on this machine inherits the cluster-aware rules — accounts, storage paths, GPU types, module stacks, the wheelhouse, Apptainer recipes, all of it.

If your cluster doesn't have a pre-built canonical (Fir, Nibi, Trillium, …), Claude runs an **"Onboard a new cluster"** workflow instead: it queries the system (`sshare -U`, `module spider`, `diskusage_report`), drafts a canonical for that cluster, asks you to review, and commits it. You can then PR the new canonical back upstream so the next user on that cluster gets it for free.

---

## What's inside

The harness ships with distilled knowledge from:

- **Selected Alliance official documentation** — *Running Jobs*, *Python*, *Apptainer*, *Storage and File Management*, *Multi-Instance GPU*, *Transferring Data*, *Available Software*, *Monitoring Jobs*, and more, sourced from [docs.alliancecan.ca](https://docs.alliancecan.ca) (CC-BY-SA-4.0, attribution preserved in `raw/alliance-docs/`).
- **Third-party HPC notes** — Mila's DRAC documentation, community blog posts on virtualenv-on-CVMFS, container build recipes, and similar guides (`raw/community-notes/`).
- **Field-tested lessons** — account allocation pitfalls, MIG sizing heuristics, container-build gotchas, tmux-on-login-node failure modes, the `--no-g --no-p` rsync rule, etc. — distilled from real research workflows on Narval and Rorqual.
- **Per-cluster canonicals** (`wiki/canonicals/`) — templated `CLAUDE.md` files for Rorqual (H100) and Narval (A100). Run the install script to substitute your account names and install to `~/.claude/CLAUDE.md`.

```
drac-harness/
├── README.md
├── CLAUDE.md                  # entry point for the AI agent
├── bin/
│   ├── setup.sh               # one-time: configure your accounts
│   └── install-claude-md.sh   # write per-cluster CLAUDE.md to ~/.claude/
├── raw/
│   ├── alliance-docs/         # mirrored upstream Alliance docs
│   └── community-notes/       # third-party guides
└── wiki/
    ├── index.md               # catalog of all wiki pages
    ├── log.md                 # chronological record of operations
    ├── canonicals/            # per-cluster CLAUDE.md templates
    ├── cheatsheets/           # alliance-workflow, globus-cli, tmux, …
    ├── summaries/             # one-page distillations of each raw source
    ├── analyses/              # cross-source syntheses (cluster comparison, …)
    ├── concepts/              # apptainer, cuda, …
    └── entities/              # the Alliance, individual clusters, …
```

---

## How it works

The harness follows the [LLM Wiki pattern](https://github.com/tobi/llm-wiki):

```
raw/                immutable source documents
  │
  │  (you ask Claude to ingest a file)
  ▼
wiki/summaries/     one-page distillations linked back to raw/
wiki/concepts/      transferable ideas mentioned across sources
wiki/entities/      named things (clusters, tools, datasets)
wiki/analyses/      cross-source syntheses
  │
  │  (Claude reads these in every session via CLAUDE.md)
  ▼
~/.claude/CLAUDE.md per-cluster instructions installed from wiki/canonicals/
```

Three things happen automatically once installed:

1. **Every Claude session knows your cluster.** Account names, GPU type, storage quotas, module stack, wheelhouse versions — all loaded.
2. **Every command Claude proposes follows the rules.** No `--account=def-<pi>` for GPU jobs, no `pip install` without `--no-index` first, no `scp -r` into `/project`, etc. Claude refuses to do the wrong thing.
3. **The harness keeps growing as you use it.** When you hit a new gotcha and figure it out, ask Claude to ingest the lesson — it adds it to `wiki/concepts/` or `wiki/analyses/`, and every future session benefits.

---

## Adding your own knowledge

```bash
# Drop a new source file in raw/
cp my-debugging-notes.md ~/github/drac-harness/raw/

# Ask Claude to ingest it
claude
> please ingest raw/my-debugging-notes.md
```

Claude will read the source, distribute the content across the appropriate wiki page types (one source summary plus updates to relevant concept/entity/analysis pages), update `wiki/index.md`, and append to `wiki/log.md`. Workflow is defined in `CLAUDE.md` under **Ingest a source**.

Generic, lab-agnostic improvements can be PR'd back upstream so the next user benefits. Personal or lab-specific notes stay in your fork.

---

## Adapting to other AI agents

The harness content is plain markdown. To use a different agent:

| Agent | Instruction file location |
|---|---|
| Claude Code | `~/.claude/CLAUDE.md` |
| OpenAI Codex | `~/.codex/AGENTS.md` (or project-local `AGENTS.md`) |
| OpenCode | `~/.config/opencode/instructions.md` |

Edit `bin/install-claude-md.sh` to write to your agent's path instead of `~/.claude/CLAUDE.md`. The canonical content itself doesn't change.

---

## Status and freshness

Alliance details (CUDA versions, wheelhouse contents, partition names, GPU types) drift over time. Wherever a snapshot is dated (e.g. *"as of 2026-Q2"*), it should be re-verified against `module spider` and `avail_wheels` quarterly. PRs welcome.

Out-of-scope for this harness:
- Non-Alliance HPC clusters (use a different harness, or fork)
- General-purpose agent configuration (this is HPC-specific)
- Application-specific workflows (3DGS, NeRF, LLM training, etc. — those belong in your project repo)

---

## Contributing

PRs welcome for:
- New cluster canonicals (Fir, Nibi, Trillium)
- Updated module/wheelhouse versions
- Corrections to summaries when upstream docs change
- New cheatsheets and concept pages

Please keep contributions cluster-generic. Personal or lab-specific content stays in forks.

---

## License

- **Code** (`bin/`): MIT — see [LICENSE](LICENSE).
- **Documentation** (`README.md`, `CLAUDE.md`, `wiki/`): CC-BY-4.0 — see [LICENSE-DOCS](LICENSE-DOCS).
- **Mirrored Alliance documentation** (`raw/alliance-docs/`): CC-BY-SA-4.0 (upstream license preserved) — see [`raw/LICENSING.md`](raw/LICENSING.md).
