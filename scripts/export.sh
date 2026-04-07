#!/usr/bin/env bash
# export.sh — Export the wiki for portability
# Usage: ./scripts/export.sh <format> [--output <dir>]
# Formats: html, obsidian, jsonl
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FORMAT="${1:?Usage: export.sh <html|obsidian|jsonl> [--output <dir>]}"
OUTPUT_DIR=""

shift
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output)
            OUTPUT_DIR="${2:?--output requires a path}"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

WIKI_DIR="$REPO_ROOT/wiki"
WIKI_COUNT=$(find "$WIKI_DIR" -name '*.md' ! -name '_*' | wc -l | tr -d ' ')
if [ "$WIKI_COUNT" -eq 0 ]; then
    echo "Error: Wiki is empty. Run compile.sh first." >&2
    exit 1
fi

case "$FORMAT" in
    html)
        OUT="${OUTPUT_DIR:-$REPO_ROOT/export/html}"
        mkdir -p "$OUT"

        if ! command -v pandoc &>/dev/null; then
            echo "Error: pandoc is required for HTML export. Install: https://pandoc.org/installing.html" >&2
            exit 1
        fi

        echo "=== Exporting wiki to HTML ==="
        echo "Output: $OUT"

        # Write minimal CSS
        cat > "$OUT/style.css" << 'EOCSS'
body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; max-width: 800px; margin: 40px auto; padding: 0 20px; color: #1a1a1a; }
a { color: #0066cc; } code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; }
pre { background: #f4f4f4; padding: 16px; overflow-x: auto; border-radius: 4px; }
blockquote { border-left: 4px solid #ddd; margin: 0; padding-left: 16px; color: #555; }
table { border-collapse: collapse; width: 100%; } th, td { border: 1px solid #ddd; padding: 8px 12px; text-align: left; }
th { background: #f4f4f4; }
EOCSS

        find "$WIKI_DIR" -name '*.md' ! -name '_*' | while read -r mdfile; do
            rel="${mdfile#$WIKI_DIR/}"
            htmlfile="$OUT/${rel%.md}.html"
            mkdir -p "$(dirname "$htmlfile")"
            pandoc "$mdfile" \
                --from markdown \
                --to html5 \
                --standalone \
                --css style.css \
                --metadata title="$(head -1 "$mdfile" | sed 's/^# //')" \
                -o "$htmlfile"
        done

        echo "Done. Open $OUT/INDEX.html in a browser."
        ;;

    obsidian)
        OUT="${OUTPUT_DIR:-$REPO_ROOT/export/obsidian}"
        mkdir -p "$OUT/.obsidian"
        echo "=== Exporting wiki as Obsidian vault ==="
        echo "Output: $OUT"

        # Copy all wiki markdown files
        cp -r "$WIKI_DIR"/. "$OUT/"

        # Minimal Obsidian config
        cat > "$OUT/.obsidian/app.json" << 'EOJSON'
{
  "defaultViewMode": "preview",
  "foldHeading": true,
  "showLineNumber": false,
  "livePreview": true
}
EOJSON

        cat > "$OUT/.obsidian/appearance.json" << 'EOJSON'
{
  "theme": "obsidian"
}
EOJSON

        # Graph view config that surfaces all links
        cat > "$OUT/.obsidian/graph.json" << 'EOJSON'
{
  "collapse-filter": false,
  "search": "",
  "showTags": false,
  "showAttachments": false,
  "hideUnresolved": false,
  "showOrphans": true,
  "collapse-color-groups": false,
  "colorGroups": [],
  "collapse-display": false,
  "showArrow": true,
  "textFadeMultiplier": 0,
  "nodeSizeMultiplier": 1,
  "lineSizeMultiplier": 1,
  "collapse-forces": false,
  "repelStrength": 10,
  "linkStrength": 1,
  "linkDistance": 250,
  "scale": 1,
  "close": false
}
EOJSON

        echo "Done. Open $OUT as a vault in Obsidian."
        ;;

    jsonl)
        OUT="${OUTPUT_DIR:-$REPO_ROOT/export}"
        mkdir -p "$OUT"
        OUTFILE="$OUT/wiki-finetune.jsonl"
        echo "=== Exporting wiki as JSONL for fine-tuning ==="
        echo "Output: $OUTFILE"

        > "$OUTFILE"  # truncate

        # Collect article paths into a temp file to hand to Python
        TMPLIST=$(mktemp)
        find "$WIKI_DIR" -name '*.md' ! -name '_*' ! -name 'INDEX.md' ! -name 'GLOSSARY.md' ! -name 'MANIFEST.md' | sort > "$TMPLIST"

        python3 - "$TMPLIST" "$OUTFILE" << 'EOPY'
import json, sys, os

list_file = sys.argv[1]
out_file   = sys.argv[2]

with open(list_file) as f:
    paths = [p.strip() for p in f if p.strip()]

count = 0
with open(out_file, 'w') as out:
    for path in paths:
        # Resolve Git Bash /c/ paths on Windows
        if path.startswith('/') and len(path) > 2 and path[2] == '/':
            path = path[1].upper() + ':' + path[2:]
        try:
            content = open(path, encoding='utf-8').read()
        except FileNotFoundError:
            continue
        title = ''
        for line in content.splitlines():
            if line.startswith('# '):
                title = line[2:].strip()
                break
        if not title:
            continue
        example = {
            "messages": [
                {"role": "user",      "content": f"What is {title}?"},
                {"role": "assistant", "content": content}
            ]
        }
        out.write(json.dumps(example) + '\n')
        count += 1

print(count)
EOPY
        rm -f "$TMPLIST"

        echo "Done. See $OUTFILE"
        ;;

    *)
        echo "Unknown format: $FORMAT (supported: html, obsidian, jsonl)" >&2
        exit 1
        ;;
esac
