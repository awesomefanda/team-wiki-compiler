# Architecture

Design decisions, trade-offs, and the path from wiki to RAG.

## Design Philosophy

Start with the simplest thing that works. Add complexity only when you hit a wall.

For most teams (< 500 articles, < 1M words), a structured markdown wiki navigated by an LLM is simpler, cheaper, and more auditable than a RAG pipeline.

## Personalization Design Principles

The personalization layer follows four principles articulated by Andrej Karpathy for LLM knowledge bases ([tweet](https://x.com/karpathy/status/2040572272944324650)):

1. **Explicit** — The knowledge artifact is a navigable wiki, not hidden AI memory. `wiki/MANIFEST.md` makes every source→article mapping visible. Users can inspect exactly what the system knows and what it doesn't.

2. **Yours** — Data lives in your git repo, not locked in an AI provider. Personal wikis live in `personal/<username>/` and can be kept on a private branch or gitignored entirely. Nothing leaves your machine unless you push it.

3. **File over app** — Everything is markdown. Any tool works: VS Code, Obsidian, GitHub's web UI, `grep`. No proprietary formats, no lock-in. ([File over App philosophy](https://stephango.com/file-over-app))

4. **BYOAI** — The wiki is the constant; the AI is swappable. `providers/` contains adapters for Claude, Ollama, OpenAI, and Groq. Add your own in minutes. The fine-tuning export (`scripts/export.sh jsonl`) is the long-term path: train a local model on the wiki so it knows your team's knowledge in its weights.

## Wiki vs RAG: Honest Comparison

### What RAG gives you
- Semantic search across massive corpora
- Fuzzy matching with different terminology
- Horizontal scalability
- Well-understood infrastructure

### What RAG costs you
- Vector DB + embedding pipeline + chunking logic + retrieval API
- Chunking is never right (too small loses context, too big adds noise)
- Embeddings are a black box — can't read, audit, or debug retrieval
- Maintenance burden on every model or schema change

### What the wiki gives you
- Zero infrastructure — it's a git repo
- Human-readable, auditable, traceable
- Near-zero contribution barrier
- Works with any LLM, no vendor lock-in
- Git history = free versioning

### What the wiki costs you
- Scale ceiling at ~500 articles / ~1M words
- No semantic search (terminology mismatch = missed results)
- Compilation quality depends on prompts
- Concurrent compilation needs coordination

## Scale Path

```
Stage 1: Wiki only (start here)
  └── raw/ → LLM compiler → wiki/
  └── Capacity: 1-200 articles, single team

Stage 2: Wiki + full-text search
  └── scripts/search.sh (grep-based, zero dependencies)
  └── Capacity: 200-500 articles

Stage 3: Wiki + RAG
  └── Embeddings for semantic search
  └── Wiki stays as human-readable layer
  └── RAG is fallback for precision retrieval
  └── Capacity: 500+ articles, cross-team

Stage 4: Wiki + RAG + fine-tuning
  └── scripts/export.sh jsonl → fine-tune a local model
  └── Model "knows" your knowledge in its weights
  └── Capacity: mature, stable domains
```

## Compilation Model

```
1. Read wiki/INDEX.md (existing state)
2. Scan raw/ for new or modified files
3. For each new file:
   a. Match to existing wiki articles
   b. Update or create articles
   c. Update INDEX.md, GLOSSARY.md, MANIFEST.md
   d. Add backlinks and cross-references
4. Output: updated wiki/
```

Compilation is idempotent — same raw/ state produces same wiki/.

When sources contradict, the compiler flags both versions with dates and adds to the lint report.

## Personal Wiki Architecture

Personal wikis mirror the team wiki structure but are isolated:

```
personal/<username>/
  raw/        ← personal source material (not shared with team compiler)
  wiki/       ← personal compiled wiki (cross-links to team wiki, read-only)
  profile.md  ← auto-generated expertise summary
```

Key isolation properties:
- The team compiler never reads `personal/`
- Personal wikis cross-link to `wiki/` but never modify it
- Privacy is controlled via gitignore or private branches

## Directory Design

Each `raw/` subdirectory maps to a knowledge type with different compilation rules:

| Directory | Compiles into |
|---|---|
| `docs/` | Concept articles |
| `rfcs/` | Decision records with status tracking |
| `runbooks/` | Step-by-step guides |
| `incidents/` | Pattern analysis + lessons learned |
| `onboarding/` | Sequential getting-started guides |
| `jira/` | Project timeline + decision context |
| `code-chunks/` | Module/service descriptions |

## Prompt Architecture

Prompts are separated by concern so each can be swapped or tuned independently:

- `compile.md` — main compiler (raw → team wiki)
- `compile-personal.md` — personal wiki compiler
- `lint.md` — health checker (find issues)
- `query.md` — Q&A against the wiki
- `ingest-jira.md` — specialized Jira processing

## Provider Architecture

`providers/` contains thin shell adapters. Each accepts `<prompt_file> <working_dir>` and returns LLM output on stdout. `compile.sh` dispatches to the right adapter via `--provider`. Adding a new LLM requires only a new shell script — no changes to compilation logic.

## Security

- No secrets in `raw/`. Reference secret stores, not values.
- No PII. Anonymize before committing.
- Personal wikis: use gitignore or a separate private repo for sensitive notes.
- Access control via git (private repo, branch protections).
- Audit trail via git blame on any wiki article.
