#!/usr/bin/env bash
# providers/claude.sh — Claude Code CLI provider
# Usage: ./providers/claude.sh <prompt_file> <working_dir>
set -euo pipefail

PROMPT_FILE="${1:?Usage: claude.sh <prompt_file> <working_dir>}"
WORKING_DIR="${2:?Usage: claude.sh <prompt_file> <working_dir>}"

if ! command -v claude &>/dev/null; then
    echo "Error: 'claude' CLI not found. Install Claude Code: https://claude.ai/code" >&2
    exit 1
fi

cd "$WORKING_DIR"
claude "$(cat "$PROMPT_FILE")"
