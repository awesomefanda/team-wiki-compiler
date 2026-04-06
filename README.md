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
├── runbooks/deploy.md    ──► ├── concepts/
├── incidents/2026-03-15.md   │   ├── authentication.md
├── jira/PROJ-1234.md         │   ├── deployment.md
└── onboarding/day1.md        │   └── monitoring.md
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
./scripts/compile.sh
```

### 4. Browse the wiki

Open `wiki/INDEX.md` in any markdown viewer (Obsidian recommended), or read it on GitHub.

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
│   ├── concepts/               #   Concept articles
│   └── guides/                 #   How-to guides compiled from runbooks
│
├── prompts/                    # LLM prompts (the "compiler instructions")
│   ├── compile.md              #   Main compilation prompt
│   ├── lint.md                 #   Health check / linting prompt
│   ├── query.md                #   Q&A prompt template
│   └── ingest-jira.md          #   Jira-specific ingestion prompt
│
├── scripts/                    # Automation scripts
│   ├── compile.sh              #   Run the compiler
│   └── lint.sh                 #   Run health checks
│
├── examples/                   # Example raw input → compiled output
│   ├── raw/                    #   Sample raw documents
│   └── wiki/                   #   What compiled output looks like
│
├── CONTRIBUTING.md             # How to contribute
└── ARCHITECTURE.md             # Design decisions, trade-offs, scale path
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

## Adapting to Your Team

**Add categories:** `mkdir raw/meeting-notes` and update `prompts/compile.md`.

**Use any LLM:** Prompts are LLM-agnostic — Claude Code, Codex CLI, Ollama, or any OpenAI-compatible API.

**Scale path:** Works up to ~500 articles / ~1M words. Beyond that, add full-text search, split into sub-wikis, or layer in RAG. See [ARCHITECTURE.md](ARCHITECTURE.md).

## License

MIT

---

Built by humans, compiled by LLMs.
