#!/usr/bin/env bash
# compile.sh — Run the wiki compiler
# Usage: ./scripts/compile.sh [--provider <name>] [--personal <username>]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROVIDER="claude"
PERSONAL_USER=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --provider)
            PROVIDER="${2:?--provider requires a value}"
            shift 2
            ;;
        --personal)
            PERSONAL_USER="${2:?--personal requires a username}"
            shift 2
            ;;
        *)
            # Legacy positional argument (claude|ollama) for backward compatibility
            PROVIDER="$1"
            shift
            ;;
    esac
done

PROVIDER_SCRIPT="$REPO_ROOT/providers/${PROVIDER}.sh"
if [ ! -f "$PROVIDER_SCRIPT" ]; then
    echo "Error: Unknown provider '$PROVIDER'. Available: $(ls "$REPO_ROOT/providers/"*.sh | xargs -n1 basename | sed 's/.sh//' | tr '\n' ' ')" >&2
    exit 1
fi

echo "=== team-wiki-compiler ==="
echo "Provider: $PROVIDER"

if [ -n "$PERSONAL_USER" ]; then
    # Personal wiki compilation
    PERSONAL_DIR="$REPO_ROOT/personal/$PERSONAL_USER"
    RAW_COUNT=$(find "$PERSONAL_DIR/raw" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    if [ "$RAW_COUNT" -eq 0 ]; then
        echo "Error: No markdown files in personal/$PERSONAL_USER/raw/. See CONTRIBUTING.md."
        exit 1
    fi
    echo "Compiling personal wiki for: $PERSONAL_USER ($RAW_COUNT source files)"
    PROMPT="$(cat "$REPO_ROOT/prompts/compile-personal.md")

Username: $PERSONAL_USER
Personal raw directory: personal/$PERSONAL_USER/raw/
Personal wiki directory: personal/$PERSONAL_USER/wiki/
Profile file: personal/$PERSONAL_USER/profile.md
Team wiki index: wiki/INDEX.md

Read all files in personal/$PERSONAL_USER/raw/ and compile the personal wiki."
    printf '%s' "$PROMPT" > /tmp/compile-personal-prompt.md
    bash "$PROVIDER_SCRIPT" /tmp/compile-personal-prompt.md "$REPO_ROOT"
    echo "Done. Check personal/$PERSONAL_USER/wiki/INDEX.md"
else
    # Team wiki compilation
    RAW_COUNT=$(find "$REPO_ROOT/raw" -name '*.md' | wc -l | tr -d ' ')
    if [ "$RAW_COUNT" -eq 0 ]; then
        echo "Error: No markdown files in raw/. See CONTRIBUTING.md."
        exit 1
    fi
    echo "Found $RAW_COUNT raw source files. Compiling..."
    PROMPT="Read prompts/compile.md, then compile the wiki. \
Read all files in raw/ and update wiki/ accordingly. \
Check wiki/INDEX.md first for existing state. \
After compiling, update wiki/MANIFEST.md (source→article map, orphans, backlink graph)."
    printf '%s' "$PROMPT" > /tmp/compile-prompt.md
    bash "$PROVIDER_SCRIPT" /tmp/compile-prompt.md "$REPO_ROOT"
    echo "Done. Check wiki/INDEX.md for results."
fi
