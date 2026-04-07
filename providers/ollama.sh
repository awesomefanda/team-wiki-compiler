#!/usr/bin/env bash
# providers/ollama.sh — Ollama local model provider
# Usage: ./providers/ollama.sh <prompt_file> <working_dir>
# Env: OLLAMA_MODEL (default: llama3.2), OLLAMA_HOST (default: http://localhost:11434)
set -euo pipefail

PROMPT_FILE="${1:?Usage: ollama.sh <prompt_file> <working_dir>}"
WORKING_DIR="${2:?Usage: ollama.sh <prompt_file> <working_dir>}"
MODEL="${OLLAMA_MODEL:-llama3.2}"
HOST="${OLLAMA_HOST:-http://localhost:11434}"

if ! command -v curl &>/dev/null; then
    echo "Error: curl is required." >&2
    exit 1
fi

PROMPT="$(cat "$PROMPT_FILE")"

# Build context: append contents of key files from working dir
CONTEXT=""
if [ -f "$WORKING_DIR/wiki/INDEX.md" ]; then
    CONTEXT="$(printf '\n\n---\nwiki/INDEX.md:\n%s' "$(cat "$WORKING_DIR/wiki/INDEX.md")")"
fi

curl -sf "$HOST/api/generate" \
    -H "Content-Type: application/json" \
    -d "$(printf '{"model":"%s","prompt":%s,"stream":false}' \
        "$MODEL" \
        "$(printf '%s%s' "$PROMPT" "$CONTEXT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')")" \
    | python3 -c 'import json,sys; print(json.load(sys.stdin)["response"])'
