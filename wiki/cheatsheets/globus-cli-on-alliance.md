---
title: Globus CLI on Alliance — install, auth, and inter-cluster transfer
type: cheatsheet
updated: 2026-05-02
sources: []
tags: [globus, cli, alliance, narval, rorqual, data-transfer, cheatsheet]
---

# Globus CLI on Alliance

Recipe for installing and using `globus-cli` on Alliance HPC clusters (Narval, Rorqual, etc.) for **inter-cluster data transfers** between Alliance-managed DTN endpoints. For non-Alliance machines (e.g. your laptop or a lab server) ↔ an Alliance cluster, use Globus Connect Personal instead — see the [Globus Connect Personal docs](https://www.globus.org/globus-connect-personal).

## TL;DR (install + auth + data_access consent)

```bash
# 1. Build a dedicated venv (do NOT use --no-index; wheelhouse
#    globus-cli is too old — 3.2.0+computecanada has bugs and
#    lacks the data_access consent flow).
module load StdEnv/2023 python/3.11
virtualenv --no-download ~/envs/globus-cli
source ~/envs/globus-cli/bin/activate
pip install --upgrade globus-cli      # PyPI; gets 3.41.0+
deactivate

# 2. Symlink into PATH so `globus` works without venv activation
mkdir -p ~/.local/bin
ln -sf ~/envs/globus-cli/bin/globus ~/.local/bin/globus
grep -q "\.local/bin" ~/.bashrc || \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"

# 3. Auth (browser flow — copy URL to local browser, paste code back)
globus login

# 4. Data-access consent for the Alliance Mapped Collections you'll touch.
#    One command for both Narval + Rorqual:
globus session consent 'urn:globus:auth:scope:transfer.api.globus.org:all[*https://auth.globus.org/scopes/a1713da6-098f-40e6-b3aa-034efe8b6e5b/data_access *https://auth.globus.org/scopes/f19f13f5-5553-40e3-ba30-6c151b9d35d4/data_access]'

# 5. Verify (should list directory, not consent error)
globus ls a1713da6-098f-40e6-b3aa-034efe8b6e5b:/scratch/$USER/   # Narval
globus ls f19f13f5-5553-40e3-ba30-6c151b9d35d4:/scratch/$USER/   # Rorqual
```

## Don't use the Alliance wheelhouse for `globus-cli`

`avail_wheels globus-cli` shows `globus_cli 3.2.0+computecanada` — released ~2021 and stale. Specific problems:

- `globus session update --help` crashes with `TypeError: IdentityType.get_metavar() got an unexpected keyword argument 'ctx'` (incompatible with current click).
- `globus login --gcs <id>` only requests `manage_collections` scope, not `data_access` — you cannot list or transfer files on Alliance GCS v5 Mapped Collections.
- `globus session consent` doesn't exist as a subcommand.

The correct path is **PyPI install with internet on a login node**. Compute nodes have no internet, but login nodes do, so a regular `pip install --upgrade globus-cli` works fine and pulls the current release.

## Alliance endpoint UUIDs

These are GCS v5 Mapped Collections owned by Alliance staff. They're stable — fine to record.

| Cluster | UUID | Display name |
|---|---|---|
| Narval | `a1713da6-098f-40e6-b3aa-034efe8b6e5b` | Compute Canada - Narval |
| Rorqual | `f19f13f5-5553-40e3-ba30-6c151b9d35d4` | alliancecan#rorqual |

Discover others via `globus endpoint search "<cluster>"`. Always check the owner — `computecanada@globusid.org`-owned endpoints are official Alliance DTNs; user-owned ones (`<username>@computecanada.ca`) are personal sharing collections, not the right destination for raw filesystem access.

There is also a deprecated/non-functional `4ccf5768-...` "ComputeCanada - Narval" endpoint that returns HTTP 409 ("non_functional"). Skip it.

## The data_access consent flow (why it's separate from login)

Alliance's DTN endpoints are GCS v5 Mapped Collections, which require two separate auth grants:

1. **`globus login`** — base scopes for transfer/auth/groups APIs. Sufficient for `globus endpoint search`, `globus whoami`, but NOT for `globus ls` / `globus transfer` against a Mapped Collection.
2. **`globus session consent`** with a `data_access` dependent scope — per-collection grant to actually read/write data on that specific endpoint.

Without step 2, `globus ls` returns:
> The collection you are trying to access data on requires you to grant consent for the Globus CLI to access it.
> Please run: `globus session consent 'urn:globus:auth:scope:transfer.api.globus.org:all[*https://auth.globus.org/scopes/<UUID>/data_access]'`

The CLI tells you the exact command. Just paste it. For multiple endpoints in one browser flow, combine the data_access scopes inside the bracket (space-separated):

```bash
globus session consent 'urn:globus:auth:scope:transfer.api.globus.org:all[*https://auth.globus.org/scopes/<UUID-A>/data_access *https://auth.globus.org/scopes/<UUID-B>/data_access]'
```

Each `*<scope>` after the `*` prefix is a dependent scope on the parent transfer scope.

## Inter-cluster transfer (Narval ↔ Rorqual example)

```bash
# Submit
globus transfer \
    a1713da6-098f-40e6-b3aa-034efe8b6e5b:/scratch/$USER/mydata/ \
    f19f13f5-5553-40e3-ba30-6c151b9d35d4:/scratch/$USER/mydata/ \
    --recursive --label "mydata migration"

# Returns a Task ID. Monitor:
globus task list                  # see all your tasks
globus task show <task-id>        # progress + bytes transferred
globus task wait <task-id>        # block until done (useful in scripts)
```

Transfers run server-side; your CLI just submits the job. You can log out of the source cluster and the transfer continues. Files copy between Alliance DTNs over the high-speed backplane; expect 100s of MB/s for large files.

## Common errors and fixes

| Symptom | Cause | Fix |
|---|---|---|
| `Missing required data_access consent` | New endpoint, no `data_access` consent yet | `globus session consent '…data_access…'` (CLI prints the exact command) |
| `is not in your identity set` (with endpoint UUID arg) | Wrong syntax — `globus session update` takes identity IDs, not endpoint IDs | Use `globus session consent` (newer) or `globus login --gcs <ep_id>:<col_id>` (older) |
| HTTP 409 `non_functional` | Endpoint deprecated | Search for current endpoint via `globus endpoint search` and pick `computecanada@globusid.org`-owned one |
| `Aborted!` after login URL | You hit Ctrl+C at the code-paste prompt | Re-run `globus login`, this time complete the browser auth and paste the code back |
| `pip install --no-index globus-cli` fails to compile cffi | System python, not module | `module load StdEnv/2023 python/3.11` first; build in a venv |
| `globus-cli 3.2.0` from wheelhouse, missing features | Stale Alliance wheelhouse | `pip install --upgrade globus-cli` (PyPI, NOT `--no-index`) on login node |

## Connections

- [[alliance-transferring-data]] — broader data-transfer doc; covers rsync, scp, between-cluster patterns
- [[claude-code-narval-instructions]] / [[claude-code-rorqual-instructions]] — per-machine canonical CLAUDE.md, references these endpoints
- [[alliance-cluster-comparison]] — analysis that motivates inter-cluster moves; uses Globus to migrate datasets
