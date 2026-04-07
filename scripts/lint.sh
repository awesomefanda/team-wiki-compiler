#!/usr/bin/env bash
# lint.sh — Run wiki health checks
# Output: wiki/_LINT_REPORT.md
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WIKI_COUNT=$(find "$REPO_ROOT/wiki" -name '*.md' ! -name '_*' | wc -l | tr -d ' ')
if [ "$WIKI_COUNT" -eq 0 ]; then
    echo "Error: Wiki is empty. Run compile.sh first."
    exit 1
fi
echo "=== wiki health check ==="
echo "Found $WIKI_COUNT wiki articles. Running checks..."
cd "$REPO_ROOT"
claude "Read prompts/lint.md, then audit all files in wiki/. Save report to wiki/_LINT_REPORT.md."
echo "Done. See wiki/_LINT_REPORT.md"
