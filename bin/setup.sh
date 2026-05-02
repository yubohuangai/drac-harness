#!/bin/bash
# setup.sh — first-time configuration for drac-harness
#
# Auto-detects your cluster username and RAC / default account, and
# writes ~/.config/drac-harness/user.conf without any user input when
# detection is unambiguous.
#
# Detection sources, in order:
#   1. sshare -U (your SLURM associations — primary signal on Alliance)
#   2. id -nG    (Unix group membership — fallback on Alliance, since
#                 group names mirror SLURM account names)
#
# `bin/install-claude-md.sh` reads the config and substitutes
# placeholders into the per-cluster canonical when installing to
# ~/.claude/CLAUDE.md.
#
# Flags:
#   --interactive, -i   Prompt for each value before writing. Use this
#                       if auto-detection picks the wrong account
#                       (e.g. you belong to multiple PI groups).
#   --help, -h          Show this help.
#
# Re-run any time to update — the script overwrites user.conf (after
# backing up to user.conf.bak.<timestamp>).

set -euo pipefail

# ---------- Argument parsing ----------

INTERACTIVE=false
case "${1:-}" in
    --interactive|-i) INTERACTIVE=true ;;
    --help|-h)
        sed -n '/^# /,/^$/{/^$/q;p;}' "$0" | sed 's/^# \?//'
        exit 0 ;;
    "") ;;
    *) echo "Unknown arg: $1. See --help." >&2; exit 1 ;;
esac

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/drac-harness"
CONFIG_FILE="$CONFIG_DIR/user.conf"
mkdir -p "$CONFIG_DIR"

# ---------- Detection ----------

# Strip _cpu/_gpu/_<partition> suffix some clusters add to sshare
# association rows (e.g. Rorqual: rrg-vislearn_gpu → rrg-vislearn).
strip_partition_suffix() {
    sed -E 's/_[a-z]+[[:space:]]*$//; s/[[:space:]]+$//'
}

detect_via_sshare() {
    command -v sshare >/dev/null 2>&1 || return 1
    sshare -U --noheader --format=Account 2>/dev/null | \
        grep -E '^(rrg|def|ctb)-' | strip_partition_suffix | sort -u
}

detect_via_groups() {
    id -nG 2>/dev/null | tr ' ' '\n' | grep -E '^(rrg|def|ctb)-' | sort -u
}

DETECT_SOURCE=""
DETECTED=$(detect_via_sshare)
[ -n "$DETECTED" ] && DETECT_SOURCE="sshare -U"

if [ -z "$DETECTED" ]; then
    DETECTED=$(detect_via_groups)
    [ -n "$DETECTED" ] && DETECT_SOURCE="id -nG"
fi

RAC_LIST=$(echo "$DETECTED" | grep '^rrg-' || true)
DEF_LIST=$(echo "$DETECTED" | grep '^def-' || true)
RAC_COUNT=$(printf '%s\n' "$RAC_LIST" | grep -c . || true)
DEF_COUNT=$(printf '%s\n' "$DEF_LIST" | grep -c . || true)

# Force interactive if multiple matches in either category (user
# belongs to >1 PI group; can't auto-pick without their input).
if { [ "$RAC_COUNT" -gt 1 ] || [ "$DEF_COUNT" -gt 1 ]; } && [ "$INTERACTIVE" = false ]; then
    echo "[setup] Multiple accounts detected (you appear to belong to more than one"
    echo "        PI group). Switching to interactive mode so you can pick."
    echo "        Detected:"
    echo "$DETECTED" | sed 's/^/          /'
    echo
    INTERACTIVE=true
fi

# ---------- Header ----------

echo "drac-harness — first-time setup"
echo "==============================="
echo

# ---------- Determine values ----------

USER_NAME="$USER"
RAC_DEFAULT=$(printf '%s\n' "$RAC_LIST" | head -1 | sed 's/^[[:space:]]*//')
DEF_DEFAULT=$(printf '%s\n' "$DEF_LIST" | head -1 | sed 's/^[[:space:]]*//')

if [ "$INTERACTIVE" = true ]; then
    echo "Interactive mode. Press Enter to accept the auto-detected default in [brackets]."
    echo

    if [ -n "$DETECT_SOURCE" ]; then
        echo "Detected accounts via '$DETECT_SOURCE':"
        echo "$DETECTED" | sed 's/^/  /'
        echo
    fi

    read -rp "Cluster username [$USER_NAME]: " input
    USER_NAME="${input:-$USER_NAME}"

    read -rp "RAC account (rrg-…)${RAC_DEFAULT:+ [$RAC_DEFAULT]}: " input
    RAC_ACCOUNT="${input:-$RAC_DEFAULT}"
    if [ -z "$RAC_ACCOUNT" ]; then
        echo "ERROR: RAC_ACCOUNT is required (e.g. rrg-smith)." >&2
        exit 1
    fi

    read -rp "Default account (def-…)${DEF_DEFAULT:+ [$DEF_DEFAULT]}: " input
    DEF_ACCOUNT="${input:-$DEF_DEFAULT}"
    if [ -z "$DEF_ACCOUNT" ]; then
        echo "ERROR: DEF_ACCOUNT is required (e.g. def-smith)." >&2
        exit 1
    fi
else
    # ---------- Auto mode ----------

    if [ -z "$RAC_DEFAULT" ] && [ -z "$DEF_DEFAULT" ]; then
        echo "[setup] ERROR: could not auto-detect any rrg- or def- account from"
        echo "        either 'sshare -U' or Unix groups."
        echo
        echo "Re-run with --interactive to enter values manually:"
        echo "  $0 --interactive"
        exit 1
    fi

    # If one is missing, fall back to the other (with a warning).
    if [ -z "$RAC_DEFAULT" ]; then
        RAC_DEFAULT="$DEF_DEFAULT"
        echo "[setup] WARNING: no rrg-* (RAC) account detected. Using '$DEF_DEFAULT'"
        echo "        for both RAC_ACCOUNT and DEF_ACCOUNT. GPU jobs without RAC"
        echo "        priority will queue much longer; consider applying for a"
        echo "        Resource Allocation Competition (RAC) award if you run GPU"
        echo "        jobs frequently."
        echo
    fi
    if [ -z "$DEF_DEFAULT" ]; then
        DEF_DEFAULT="$RAC_DEFAULT"
        echo "[setup] WARNING: no def-* (default) account detected. Using"
        echo "        '$RAC_DEFAULT' for both. CPU-only jobs may fail if your RAC"
        echo "        account does not include CPU membership."
        echo
    fi

    RAC_ACCOUNT="$RAC_DEFAULT"
    DEF_ACCOUNT="$DEF_DEFAULT"

    echo "[setup] Auto-detected via $DETECT_SOURCE:"
    echo "  USER_NAME    = $USER_NAME"
    echo "  RAC_ACCOUNT  = $RAC_ACCOUNT"
    echo "  DEF_ACCOUNT  = $DEF_ACCOUNT"
    echo
fi

# ---------- Write user.conf ----------

# Backup existing config.
if [ -f "$CONFIG_FILE" ]; then
    BACKUP="$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$CONFIG_FILE" "$BACKUP"
    echo "[setup] backed up existing config → $BACKUP"
fi

cat > "$CONFIG_FILE" <<EOF
# drac-harness user config
# Generated by bin/setup.sh on $(date -u +%Y-%m-%dT%H:%M:%SZ)
# Substituted into wiki/canonicals/*.md by bin/install-claude-md.sh.
# Re-run setup.sh (or setup.sh --interactive) to update.

USER_NAME="$USER_NAME"
RAC_ACCOUNT="$RAC_ACCOUNT"
DEF_ACCOUNT="$DEF_ACCOUNT"
EOF

chmod 600 "$CONFIG_FILE"

echo "[setup] wrote $CONFIG_FILE"
echo
echo "If any value is wrong, edit the file directly or re-run with:"
echo "  $0 --interactive"
echo
echo "Next: run bin/install-claude-md.sh to install the per-cluster"
echo "      CLAUDE.md to ~/.claude/CLAUDE.md."
