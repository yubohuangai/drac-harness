# raw/

Source documents that the wiki distills. Two flavors:

- **`alliance-docs/`** — mirrored upstream pages from [docs.alliancecan.ca](https://docs.alliancecan.ca). CC-BY-SA-4.0; attribution preserved. See `LICENSING.md`.
- **`community-notes/`** — third-party HPC notes (Mila DRAC docs, blog posts). Subject to upstream licenses; see `LICENSING.md`.

## Adding new sources

Drop new files in this directory and ask Claude to ingest them:

```bash
cp my-debugging-notes.md ~/github/drac-harness/raw/
cd ~/github/drac-harness
claude
> please ingest raw/my-debugging-notes.md
```

The ingestion workflow (defined in the repo's `CLAUDE.md`) will:

1. Read the source fully.
2. Create a one-page summary at `wiki/summaries/<topic>.md`.
3. Update or create entity pages for any clusters / tools / people / datasets mentioned.
4. Update or create concept pages for transferable ideas.
5. Update `wiki/index.md` and append to `wiki/log.md`.
6. Cross-link the new content to existing pages.

## What belongs here

- Upstream Alliance documentation (mirror with attribution; helps offline use)
- Cluster-specific guides (cluster announcements, infrastructure changes)
- Build recipes for tricky CUDA extensions
- Bug-fix notes that other users will hit
- Lessons distilled from real research workflows (formatted as `<topic>-lessons-YYYY-MM-DD.md` per the **Ingest from external project** workflow)

## What does NOT belong here

- Personal credentials, account names, or project paths — those go in your fork only, not upstream PRs
- Job IDs, commit SHAs, timestamps, scratch paths
- Application-specific files (data, weights, model checkpoints — those don't ingest into a wiki)
