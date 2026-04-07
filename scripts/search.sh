#!/usr/bin/env bash
# search.sh — Full-text search over the wiki
# Usage:
#   ./scripts/search.sh "query"             full-text search
#   ./scripts/search.sh --titles "query"    search article titles only
#   ./scripts/search.sh --sources "query"   search by raw source reference
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WIKI_DIR="$REPO_ROOT/wiki"

MODE="fulltext"
QUERY=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --titles)
            MODE="titles"
            QUERY="${2:?--titles requires a query string}"
            shift 2
            ;;
        --sources)
            MODE="sources"
            QUERY="${2:?--sources requires a query string}"
            shift 2
            ;;
        -h|--help)
            echo "Usage:"
            echo "  search.sh \"query\"              full-text search"
            echo "  search.sh --titles \"query\"     search article titles only"
            echo "  search.sh --sources \"query\"    find articles by raw source reference"
            exit 0
            ;;
        *)
            QUERY="$1"
            shift
            ;;
    esac
done

if [ -z "$QUERY" ]; then
    echo "Error: No search query provided." >&2
    echo "Usage: search.sh \"query\"" >&2
    exit 1
fi

WIKI_COUNT=$(find "$WIKI_DIR" -name '*.md' ! -name '_*' | wc -l | tr -d ' ')
if [ "$WIKI_COUNT" -eq 0 ]; then
    echo "Error: Wiki is empty. Run compile.sh first." >&2
    exit 1
fi

# Color codes (skip if not a terminal)
if [ -t 1 ]; then
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
    MATCH='\033[33m'
else
    BOLD='' DIM='' RESET='' MATCH=''
fi

RESULTS=0

case "$MODE" in
    fulltext)
        echo -e "${BOLD}Searching wiki for: \"$QUERY\"${RESET}"
        echo ""
        while IFS= read -r file; do
            rel="${file#$WIKI_DIR/}"
            title=$(grep -m1 '^# ' "$file" | sed 's/^# //')
            # Find matching lines with context
            matches=$(grep -in "$QUERY" "$file" | head -5 || true)
            if [ -n "$matches" ]; then
                echo -e "${BOLD}$rel${RESET}${DIM} — $title${RESET}"
                while IFS= read -r line; do
                    lineno=$(echo "$line" | cut -d: -f1)
                    content=$(echo "$line" | cut -d: -f2-)
                    echo -e "  ${DIM}L${lineno}:${RESET} $(echo "$content" | sed "s/$QUERY/${MATCH}&${RESET}/Ig")"
                done <<< "$matches"
                echo ""
                RESULTS=$((RESULTS + 1))
            fi
        done < <(find "$WIKI_DIR" -name '*.md' ! -name '_*' | sort)
        ;;

    titles)
        echo -e "${BOLD}Searching article titles for: \"$QUERY\"${RESET}"
        echo ""
        while IFS= read -r file; do
            rel="${file#$WIKI_DIR/}"
            title=$(grep -m1 '^# ' "$file" | sed 's/^# //')
            if echo "$title" | grep -qi "$QUERY"; then
                summary=$(grep -A1 '^> \*\*Summary:\*\*' "$file" | tail -1 | sed 's/^> \*\*Summary:\*\* //' || echo "")
                echo -e "${BOLD}$title${RESET}"
                echo -e "  ${DIM}$rel${RESET}"
                [ -n "$summary" ] && echo -e "  $summary"
                echo ""
                RESULTS=$((RESULTS + 1))
            fi
        done < <(find "$WIKI_DIR" -name '*.md' ! -name '_*' | sort)
        ;;

    sources)
        echo -e "${BOLD}Searching articles by source reference: \"$QUERY\"${RESET}"
        echo ""
        while IFS= read -r file; do
            rel="${file#$WIKI_DIR/}"
            title=$(grep -m1 '^# ' "$file" | sed 's/^# //')
            if grep -qi "$QUERY" "$file"; then
                matching_sources=$(grep -i "raw/.*$QUERY" "$file" | sed 's/.*`\(raw\/[^`]*\)`.*/\1/' | sort -u || true)
                if [ -n "$matching_sources" ]; then
                    echo -e "${BOLD}$title${RESET}  ${DIM}($rel)${RESET}"
                    while IFS= read -r src; do
                        echo -e "  source: ${MATCH}$src${RESET}"
                    done <<< "$matching_sources"
                    echo ""
                    RESULTS=$((RESULTS + 1))
                fi
            fi
        done < <(find "$WIKI_DIR" -name '*.md' ! -name '_*' | sort)
        ;;
esac

if [ "$RESULTS" -eq 0 ]; then
    echo "No results found for \"$QUERY\"."
else
    echo -e "${DIM}$RESULTS article(s) matched.${RESET}"
fi
