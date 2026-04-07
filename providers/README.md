# Providers

Each provider script is an adapter that lets `compile.sh` and `lint.sh` work with different LLMs. This is the BYOAI layer.

## Interface

Every provider script accepts the same two arguments:

```
./providers/<name>.sh <prompt_file> <working_dir>
```

| Argument | Description |
|---|---|
| `prompt_file` | Path to the prompt markdown file to send |
| `working_dir` | Repo root — the LLM will read/write relative to this |

Output goes to stdout. Errors go to stderr.

## Available Providers

| Script | LLM | Requirement |
|---|---|---|
| `claude.sh` | Claude (via Claude Code CLI) | `claude` CLI installed |
| `ollama.sh` | Any local model via Ollama | Ollama running locally |
| `openai.sh` | GPT-4o (or any OpenAI model) | `OPENAI_API_KEY` env var |
| `groq.sh` | Llama 3.3 70B via Groq | `GROQ_API_KEY` env var (free tier available) |

## Adding a New Provider

1. Copy an existing script as a template: `cp providers/claude.sh providers/myprovider.sh`
2. Implement the two-argument interface: accept `<prompt_file>` and `<working_dir>`
3. Send the prompt to your LLM and print the result to stdout
4. Make it executable: `chmod +x providers/myprovider.sh`
5. Use it: `./scripts/compile.sh --provider myprovider`

## Environment Variables

| Variable | Provider | Default |
|---|---|---|
| `OLLAMA_MODEL` | ollama | `llama3.2` |
| `OLLAMA_HOST` | ollama | `http://localhost:11434` |
| `OPENAI_API_KEY` | openai | *(required)* |
| `OPENAI_MODEL` | openai | `gpt-4o` |
| `GROQ_API_KEY` | groq | *(required)* |
| `GROQ_MODEL` | groq | `llama-3.3-70b-versatile` |
