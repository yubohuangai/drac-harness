#!/bin/bash
# install-claude-md.sh
#
# Extract the per-cluster CLAUDE.md content from
# `wiki/canonicals/claude-code-<cluster>-instructions.md`, substitute
# placeholders ({{USER}}, {{RAC_ACCOUNT}}, {{DEF_ACCOUNT}},
# {{HARNESS_PATH}}) using values from ~/.config/drac-harness/user.conf,
# and write the result to `~/.claude/CLAUDE.md`.
#
# The wiki canonical wraps the CLAUDE.md content in a ````markdown ... ````
# fenced block so it renders nicely in Obsidian and stays distinct from
# the wiki's prose preamble. This script extracts the block content,
# substitutes placeholders, and writes the per-cluster file.
#
# Usage:
#   <harness>/bin/install-claude-md.sh
#
# Cluster detection (auto, in order):
#   1. $CLUSTER env var (override)
#   2. $CC_CLUSTER env var (Alliance HPC sets this: narval, rorqual, …)
#   3. hostname stripped of trailing digits and domain
#      (e.g. "rorqual2.alliancecan.ca" → "rorqual")
#
# If no canonical exists for the detected cluster, the script errors with
# a pointer to the "Onboard a new cluster" workflow in CLAUDE.md.
#
# Override the destination via env var (useful for testing):
#   CLAUDE_MD_DEST=/tmp/test.md ./install-claude-md.sh
#
# Behavior:
#   - Backs up any existing $DEST to $DEST.bak.<timestamp>.
#   - Refuses to overwrite if extracted content is suspiciously short.
#   - Errors if user.conf is missing — points to bin/setup.sh.
#   - Idempotent: safe to re-run after `git pull` updates the canonical.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/drac-harness/user.conf"

# Load user.conf (provides USER_NAME, RAC_ACCOUNT, DEF_ACCOUNT)
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: $CONFIG_FILE does not exist." >&2
    echo "       Run $REPO_ROOT/bin/setup.sh first." >&2
    exit 1
fi
# shellcheck source=/dev/null
. "$CONFIG_FILE"

for var in USER_NAME RAC_ACCOUNT DEF_ACCOUNT; do
    if [ -z "${!var:-}" ]; then
        echo "ERROR: $var not set in $CONFIG_FILE." >&2
        echo "       Re-run $REPO_ROOT/bin/setup.sh." >&2
        exit 1
    fi
done

# Detect cluster
DETECTED="${CC_CLUSTER:-}"
if [ -z "$DETECTED" ]; then
    DETECTED=$(hostname | sed 's/[0-9]*$//; s/\..*//')
fi
CLUSTER="${CLUSTER:-$DETECTED}"

WIKI="$REPO_ROOT/wiki/canonicals/claude-code-${CLUSTER}-instructions.md"
DEST="${CLAUDE_MD_DEST:-$HOME/.claude/CLAUDE.md}"

if [ ! -f "$WIKI" ]; then
    echo "ERROR: no canonical for cluster '$CLUSTER' at:" >&2
    echo "       $WIKI" >&2
    echo "" >&2
    echo "Detected via:" >&2
    echo "  \$CC_CLUSTER='${CC_CLUSTER:-<unset>}'" >&2
    echo "  hostname-stripped='$(hostname | sed 's/[0-9]*$//; s/\..*//')'" >&2
    echo "" >&2
    echo "Available canonicals:" >&2
    ls "$REPO_ROOT/wiki/canonicals/" 2>/dev/null | \
        grep '^claude-code-.*-instructions\.md$' | \
        sed 's/^claude-code-/  - /; s/-instructions\.md$//' >&2 || true
    echo "" >&2
    echo "Options:" >&2
    echo "  1. Onboard this cluster: start a Claude session in" >&2
    echo "     drac-harness (cd $REPO_ROOT && claude). It will detect" >&2
    echo "     the missing canonical and run the 'Onboard a new" >&2
    echo "     cluster' workflow (see CLAUDE.md)." >&2
    echo "  2. Override detection: CLUSTER=<other> $0" >&2
    exit 1
fi

mkdir -p "$(dirname "$DEST")"

# Backup existing file (timestamped)
if [ -f "$DEST" ]; then
    BACKUP="$DEST.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$DEST" "$BACKUP"
    echo "[install-claude-md] backed up existing → $BACKUP"
fi

# Extract content between ```` ```markdown / ```` fences (4-tick fences,
# robust to nested triple-backtick code blocks inside).
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT
awk '
    /^````markdown$/ {flag=1; next}
    /^````$/ && flag {flag=0; exit}
    flag {print}
' "$WIKI" > "$TMP"

LINES=$(wc -l < "$TMP")
if [ "$LINES" -lt 50 ]; then
    echo "ERROR: extracted only $LINES lines (expected 100+)." >&2
    echo "       Check that $WIKI has '\`\`\`\`markdown' / '\`\`\`\`' fences" >&2
    echo "       wrapping the CLAUDE.md content." >&2
    exit 1
fi

# Substitute placeholders.
TMP2=$(mktemp)
trap 'rm -f "$TMP" "$TMP2"' EXIT
sed -e "s|{{USER}}|$USER_NAME|g" \
    -e "s|{{RAC_ACCOUNT}}|$RAC_ACCOUNT|g" \
    -e "s|{{DEF_ACCOUNT}}|$DEF_ACCOUNT|g" \
    -e "s|{{HARNESS_PATH}}|$REPO_ROOT|g" \
    "$TMP" > "$TMP2"

# Verify no placeholders survived (catches typos in either the canonical
# or the user.conf).
if grep -nE '\{\{[A-Z_]+\}\}' "$TMP2" >&2; then
    echo "" >&2
    echo "ERROR: unresolved placeholders found above. Either the canonical" >&2
    echo "       uses a placeholder this script doesn't substitute, or" >&2
    echo "       user.conf is missing a value." >&2
    exit 1
fi

mv "$TMP2" "$DEST"
trap - EXIT
rm -f "$TMP"

echo "[install-claude-md] cluster: $CLUSTER"
echo "[install-claude-md] wrote $LINES lines to $DEST"
echo "[install-claude-md] source: $WIKI"
echo "[install-claude-md] verify: head -3 \"$DEST\""
echo
head -3 "$DEST"
