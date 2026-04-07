# team-wiki-compiler

An LLM-compiled team knowledge base. Drop raw docs in, get a structured, interlinked wiki out. No vector DB. No embeddings pipeline. Just markdown, git, and an LLM.

> **Inspiration:** This project implements the [LLM Knowledge Bases](https://x.com/karpathy/status/2039805659525644595) approach shared by [Andrej Karpathy](https://x.com/karpathy), adapted for team use. He also published an [idea file](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) encouraging others to build their own version. This is ours.

## Why This Exists

Most team knowledge lives in scattered docs, stale wikis, Jira tickets, and Slack threads that nobody can find. Traditional RAG pipelines (vector DB + embeddings + chunking) solve this at scale but add infrastructure complexity that most teams don't need.

This project takes a simpler approach: an LLM reads your raw source material and **compiles** it into a structured, interlinked markdown wiki — like a compiler turning source code into an executable. The wiki is human-readable, git-versioned, and auditable. Every claim traces back to a source file.

**Start here. Add RAG later if you outgrow it.**

## How It Works

```
raw/                          wiki/
├── docs/arch-v2.md           ├── INDEX.md  ◄── master table of contents
├── rfcs/auth-redesign.md     ├── GLOSSARY.md
├── runbooks/deploy.md    ──► ├── MANIFEST.md  ◄── source→article map
├── incidents/2026-03-15.md   ├── concepts/
├── jira/PROJ-1234.md         │   ├── authentication.md
└── onboarding/day1.md        │   └── deployment.md
                              └── guides/
        Human writes ──►          LLM compiles ──►  Team reads
```

1. **You contribute** raw knowledge to `raw/` — design docs, runbooks, postmortems, Jira exports, code summaries
2. **The LLM compiles** it into `wiki/` — structured articles with summaries, backlinks, cross-references, and an auto-maintained index
3. **Your team queries** the wiki directly or via an LLM for complex Q&A

## Quick Start

### 1. Clone and explore

```bash
git clone https://github.com/<your-org>/team-wiki-compiler.git
cd team-wiki-compiler
```

### 2. Add your first raw document

```bash
cp ~/my-design-doc.md raw/docs/

# Or create one inline
cat > raw/docs/api-gateway-overview.md << 'EOF'
# API Gateway Overview
Our API gateway handles auth, rate limiting, and routing...
EOF
```

### 3. Run the compiler

```bash
./scripts/compile.sh                        # uses Claude (default)
./scripts/compile.sh --provider ollama      # use a local model
./scripts/compile.sh --provider groq        # use Groq (free tier)
```

### 4. Browse the wiki

```bash
./scripts/search.sh "authentication"        # full-text search
./scripts/search.sh --titles "deploy"       # title search
open wiki/INDEX.md                          # or open in Obsidian
```

## Project Structure

```
team-wiki-compiler/
│
├── raw/                        # Human-contributed source material
│   ├── docs/                   #   Architecture docs, design docs, specs
│   ├── rfcs/                   #   RFCs, proposals, ADRs
│   ├── runbooks/               #   Operational runbooks, playbooks
│   ├── incidents/              #   Postmortems, incident reports
│   ├── onboarding/             #   Onboarding guides, FAQs, tutorials
│   ├── jira/                   #   Exported Jira tickets, epic summaries
│   └── code-chunks/            #   Code summaries, module overviews
│
├── wiki/                       # LLM-compiled output (auto-generated)
│   ├── INDEX.md                #   Master table of contents
│   ├── GLOSSARY.md             #   Team/project glossary
│   ├── MANIFEST.md             #   Source→article map, orphans, backlinks
│   ├── concepts/               #   Concept articles
│   └── guides/                 #   How-to guides compiled from runbooks
│
├── personal/                   # Personal wikis (one per team member)
│   └── <username>/
│       ├── raw/                #   Personal raw notes
│       ├── wiki/               #   Personal compiled wiki
│       └── profile.md          #   Auto-generated expertise summary
│
├── providers/                  # LLM provider adapters (BYOAI)
│   ├── claude.sh               #   Claude Code CLI
│   ├── ollama.sh               #   Ollama (local models)
│   ├── openai.sh               #   OpenAI API
│   ├── groq.sh                 #   Groq API (free tier)
│   └── README.md               #   How to add a new provider
│
├── prompts/                    # LLM prompts (the "compiler instructions")
│   ├── compile.md              #   Main compilation prompt
│   ├── compile-personal.md     #   Personal wiki compilation prompt
│   ├── lint.md                 #   Health check / linting prompt
│   ├── query.md                #   Q&A prompt template
│   └── ingest-jira.md          #   Jira-specific ingestion prompt
│
├── scripts/                    # Automation scripts
│   ├── compile.sh              #   Run the compiler (team or personal)
│   ├── lint.sh                 #   Run health checks
│   ├── manifest.sh             #   Rebuild wiki/MANIFEST.md
│   ├── search.sh               #   Search the wiki
│   └── export.sh               #   Export wiki (html/obsidian/jsonl)
│
└── examples/                   # Example raw input → compiled output
```

## Key Concepts

| | `raw/` | `wiki/` |
|---|---|---|
| **Who writes** | Humans | LLM |
| **Format** | Any structure, informal OK | Structured, interlinked articles |
| **Editing** | Edit freely | Don't hand-edit (gets overwritten) |
| **Purpose** | Source of truth | Compiled knowledge |

### Incremental Compilation

The LLM doesn't reprocess everything from scratch. It reads `wiki/INDEX.md` to understand what's already compiled, identifies new or changed files in `raw/`, and integrates them. Fast and token-efficient.

### Health Checks

Periodic LLM passes to find inconsistent info, stale content, missing cross-references, and candidates for new articles. Think `lint` for your knowledge base.

```bash
./scripts/lint.sh
```

## Personal Wikis

Each team member can maintain a personal wiki alongside the team wiki. Personal wikis follow the same raw/ → wiki/ pattern but stay private.

```bash
# Set up your personal wiki
mkdir -p personal/<your-username>/raw

# Add personal notes
cp ~/my-notes.md personal/<your-username>/raw/

# Compile your personal wiki
./scripts/compile.sh --personal <your-username>
```

The compiler auto-generates a `profile.md` summarizing your expertise, active projects, and interests — and cross-links to relevant team wiki articles.

See [CONTRIBUTING.md](CONTRIBUTING.md) for details on personal wiki setup and gitignore patterns.

## BYOAI: Bring Your Own AI

Prompts are LLM-agnostic. Switch providers with `--provider`:

```bash
./scripts/compile.sh --provider claude    # Claude Code CLI (default)
./scripts/compile.sh --provider ollama    # local model via Ollama
./scripts/compile.sh --provider openai    # GPT-4o (needs OPENAI_API_KEY)
./scripts/compile.sh --provider groq      # Llama 3.3 via Groq (free tier, needs GROQ_API_KEY)
```

Each provider is a small shell script in `providers/`. Add your own by copying an existing one and implementing the two-argument interface. See [providers/README.md](providers/README.md).

**Fine-tuning path:** Export the wiki as JSONL and fine-tune a local model on it. The model learns your team's knowledge in its weights.

```bash
./scripts/export.sh jsonl   # → export/wiki-finetune.jsonl
```

## Export & Portability

Export the wiki in any format:

```bash
./scripts/export.sh html       # static HTML site (requires pandoc)
./scripts/export.sh obsidian   # Obsidian vault with graph config
./scripts/export.sh jsonl      # JSONL for fine-tuning
```

All exports go to `export/` by default. Use `--output <dir>` to change the destination.

## Search

```bash
./scripts/search.sh "redis"              # full-text search
./scripts/search.sh --titles "deploy"    # search titles only
./scripts/search.sh --sources "PROJ-"    # find articles by Jira source
```

## Adapting to Your Team

**Add categories:** `mkdir raw/meeting-notes` and update `prompts/compile.md`.

**Scale path:** Works up to ~500 articles / ~1M words. Beyond that, add full-text search, split into sub-wikis, or layer in RAG. See [ARCHITECTURE.md](ARCHITECTURE.md).

## License

MIT

---

Built by humans, compiled by LLMs.
