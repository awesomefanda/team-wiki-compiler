#!/usr/bin/env bash
# providers/openai.sh — OpenAI API provider
# Usage: ./providers/openai.sh <prompt_file> <working_dir>
# Env: OPENAI_API_KEY (required), OPENAI_MODEL (default: gpt-4o)
set -euo pipefail

PROMPT_FILE="${1:?Usage: openai.sh <prompt_file> <working_dir>}"
WORKING_DIR="${2:?Usage: openai.sh <prompt_file> <working_dir>}"
MODEL="${OPENAI_MODEL:-gpt-4o}"

if [ -z "${OPENAI_API_KEY:-}" ]; then
    echo "Error: OPENAI_API_KEY is not set." >&2
    exit 1
fi

if ! command -v curl &>/dev/null; then
    echo "Error: curl is required." >&2
    exit 1
fi

PROMPT="$(cat "$PROMPT_FILE")"

RESPONSE=$(curl -sf https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "$(python3 -c "
import json, sys
prompt = sys.stdin.read()
print(json.dumps({'model': '$MODEL', 'messages': [{'role': 'user', 'content': prompt}]}))
" <<< "$PROMPT")")

echo "$RESPONSE" | python3 -c 'import json,sys; print(json.load(sys.stdin)["choices"][0]["message"]["content"])'
