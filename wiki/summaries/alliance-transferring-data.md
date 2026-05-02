---
title: Alliance — Transferring Data
type: source
updated: 2026-05-02
sources: [alliance-docs/Transferring data.md]
tags: [alliance, data-transfer, globus, rsync, scp, sftp, rclone]
---

# Alliance — Transferring Data

Canonical Alliance reference for moving data in, out, and between clusters. The single most load-bearing piece of advice is **use data transfer nodes (DTNs), not login nodes**, and **use Globus whenever possible**. The most easily-missed gotcha is the `rsync --no-g --no-p` requirement for `/project`.

Source: https://docs.alliancecan.ca/wiki/Transferring_data

## The hierarchy

Alliance's preference order, fastest and most reliable first:

1. **Globus** — always, if both endpoints are Globus-connected. Uses DTNs automatically; resumable, parallel, checksummable.
2. **rsync** over SSH — when Globus isn't an option; small-to-medium transfers between any two hosts.
3. **scp / sftp** — one-off files, no sync semantics.
4. **wget / curl / rclone** — pulls from the web or cloud services.

> If a transfer takes more than **~1 minute**, switch to Globus.

## Data transfer nodes (DTNs)

Each cluster exposes a DTN hostname (look at the top of the cluster's wiki page). DTNs exist because login nodes are shared, limited, and not optimized for bulk I/O. Globus auto-routes to them; scp/rsync users should target the DTN hostname directly where one is advertised.

## Globus

For non-Alliance machines (your laptop, a lab server) ↔ an Alliance cluster, set up Globus Connect Personal: see the official [Globus Connect Personal docs](https://www.globus.org/globus-connect-personal). For **Alliance ↔ Alliance** transfers (e.g. Narval ↔ Rorqual) use the Globus CLI — see [[globus-cli-on-alliance]] for install, auth, and the `data_access` consent recipe.

Useful flags from the web UI:

- **Sync vs. overwrite**: default is overwrite. For incremental updates, open *Transfer & Timer Options* and select *sync*.
- **Sync modes** (fastest → most accurate):
  - *File doesn't exist on destination* — only new files
  - *File size is different* — quick
  - *Modification time is newer* — requires preserving source mtimes
  - *Checksums are different* — slowest, catches silent corruption
- Use *checksums* for scientific data where correctness beats speed.

## rsync — the `/project` gotcha

> **When transferring into `/project`, always add `--no-g --no-p`.**

`/project` enforces quota by **group ownership**. rsync's default `-a` flag preserves group/permissions — when you sync from somewhere with a different group, files get the wrong group, collide with the group quota, and you hit `Disk quota exceeded` even with space free.

Canonical commands:

```bash
# Into /project — note the --no-g --no-p
rsync -avzh --no-g --no-p LOCAL user@narval.alliancecan.ca:projects/rrg-<pi>/$USER/dest/

# Large files: add --partial for resume, --progress for per-file %
rsync -avzh --no-g --no-p --partial --progress LOCAL user@host:path/

# Many small files: use a single aggregate bar
rsync -azh --no-g --no-p --info=progress2 LOCAL user@host:path/

# Pull from cluster to local (no --no-g --no-p needed on local side)
rsync -avzh user@narval.alliancecan.ca:REMOTE ~/dest/
```

This is the most load-bearing operational detail on the page. Missing it is the kind of thing that blows up project quotas with no obvious cause.

## scp

Simpler than rsync, no sync. Run **from your local machine**, not from the cluster.

```bash
scp foo.txt user@rorqual.alliancecan.ca:work/
scp user@fir.alliancecan.ca:projects/def-<pi>/$USER/out.dat .
```

> **Avoid `scp -r` into `/project`.** Recursive scp turns off the setgid bit on created directories; new files created there later inherit the wrong group → `Disk quota exceeded`. Use rsync with `--no-g --no-p` instead, or tar the directory first.

Custom SSH key names (anything beyond `id_rsa`/`id_ed25519`) need `-i /path/to/key`.

## sftp

Interactive file-transfer shell over SSH. Used via `sftp user@host` or with `-i key`. Good for browsing and cherry-picking; poor for bulk.

GUI clients that speak SFTP: WinSCP, MobaXterm (Windows), Filezilla (all), Cyberduck (Mac/Win).

## wget / curl / rclone (from the web)

All three available on every Alliance cluster **without loading a module**.

- **`wget -c`** — resume interrupted download
- **`curl -C -`** — resume
- **rclone** — the right tool for Google Drive, Google Cloud Storage, S3, Dropbox, etc. Configure once with `rclone config`, then `rclone copy remote:path /project/.../`.

## Between clusters (Alliance → Alliance)

Use Globus. If you must scp/rsync, log in with `ssh -A` (SSH agent forwarding) first so the target cluster can reach back:

```bash
ssh -A user@fir.alliancecan.ca
# then, on fir:
scp file user@trillium.alliancecan.ca:
```

## Pre-flight checks

### Read errors on source
```bash
find <dir> ! -readable -ls      # lists unreadable items before transfer fails mid-way
```

### Quota / size mismatch between clusters
Some Alliance filesystems report **compressed size**, others report **apparent size**. A 1 TB dataset on one cluster can become 2 TB on another.

```bash
du dataset       # reported size (may be compressed)
du -b dataset    # apparent size
```

Plan against the apparent size when moving between clusters.

### Checksum verification (when Globus unavailable)
```bash
# On both systems:
find /home/$USER/ -type f -print0 | xargs -0 sha1sum | tee checksum.log
sort -k2 checksum.log -o checksum.log

# Locally:
diff checksum-src.log checksum-dst.log
```

Run the checksum pass inside tmux — it's slow and SSH may drop.

## Connections

- [[globus-cli-on-alliance]] — Globus CLI install + `data_access` consent for Alliance ↔ Alliance transfers
- [[alliance-storage-and-file-management]] — where transfers land; the filesystem layout
- [[alliance-workflow-cheatsheet]] — end-to-end routine
- [[claude-code-narval-instructions]] — §7 Data transfer section (Narval canonical)
- [[claude-code-rorqual-instructions]] — Rorqual canonical
- [[digital-research-alliance-canada]] — parent org
