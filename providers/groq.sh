#!/usr/bin/env bash
# providers/groq.sh — Groq API provider (fast inference, free tier available)
# Usage: ./providers/groq.sh <prompt_file> <working_dir>
# Env: GROQ_API_KEY (required), GROQ_MODEL (default: llama-3.3-70b-versatile)
set -euo pipefail

PROMPT_FILE="${1:?Usage: groq.sh <prompt_file> <working_dir>}"
WORKING_DIR="${2:?Usage: groq.sh <prompt_file> <working_dir>}"
MODEL="${GROQ_MODEL:-llama-3.3-70b-versatile}"

if [ -z "${GROQ_API_KEY:-}" ]; then
    echo "Error: GROQ_API_KEY is not set. Get a free key at https://console.groq.com" >&2
    exit 1
fi

if ! command -v curl &>/dev/null; then
    echo "Error: curl is required." >&2
    exit 1
fi

PROMPT="$(cat "$PROMPT_FILE")"

RESPONSE=$(curl -sf https://api.groq.com/openai/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $GROQ_API_KEY" \
    -d "$(python3 -c "
import json, sys
prompt = sys.stdin.read()
print(json.dumps({'model': '$MODEL', 'messages': [{'role': 'user', 'content': prompt}]}))
" <<< "$PROMPT")")

echo "$RESPONSE" | python3 -c 'import json,sys; print(json.load(sys.stdin)["choices"][0]["message"]["content"])'
