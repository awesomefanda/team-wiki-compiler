# Contributing

## The 2-Minute Version

1. Create a markdown file describing what you know
2. Drop it into the right `raw/` subdirectory
3. Open a PR
4. The LLM compiler integrates it into the wiki

No special formatting required. Write like you're explaining something to a teammate.

## Where to Put Things

| You have... | Put it in... |
|---|---|
| Architecture doc, design doc, spec | `raw/docs/` |
| RFC, proposal, ADR | `raw/rfcs/` |
| Operational runbook, playbook | `raw/runbooks/` |
| Postmortem, incident report | `raw/incidents/` |
| Onboarding guide, FAQ, tutorial | `raw/onboarding/` |
| Jira ticket export, epic summary | `raw/jira/` |
| Code overview, module summary | `raw/code-chunks/` |
| Personal notes | `personal/<your-username>/raw/` |

Not sure? Use `raw/docs/`. The compiler will figure it out.

## File Naming

Use descriptive, kebab-case names:

```
raw/docs/api-gateway-auth-flow.md           ✓
raw/incidents/2026-03-15-db-failover.md     ✓
raw/rfcs/rfc-042-cache-invalidation.md      ✓

raw/docs/notes.md                           ✗
raw/docs/doc1.md                            ✗
```

## Writing Tips

- **Context > polish.** Why was a decision made? What was rejected?
- **Include dates.** Knowledge has a shelf life.
- **One topic per file.** Auth + deployment = two files.
- **Link external resources** (Jira, Slack, dashboards) where helpful.

### Optional Template

```markdown
# [Title]

## Summary
One paragraph: what is this and why does it matter?

## Details
The content. As much or as little as needed.

## Context
- Date: YYYY-MM-DD
- Author: [your name]
- Related: [links to Jira, other docs, etc.]
```

## What NOT to Do

- Don't edit files in `wiki/` — they get overwritten on compilation.
- Don't include secrets, credentials, or PII.
- Don't duplicate — check `wiki/INDEX.md` first.

## PR Convention

- Title: `raw: add [brief description]`
- Body: One sentence on what knowledge you're adding

---

## Setting Up a Personal Wiki

Personal wikis let you maintain private notes alongside the team wiki. Your personal wiki cross-links to team articles but stays separate from the shared compilation.

### 1. Create your directory

```bash
mkdir -p personal/<your-username>/raw
```

### 2. Add to .gitignore (if you want to keep notes private)

Add this to your local `.git/info/exclude` (not committed):
```
personal/<your-username>/
```

Or, for team-visible profiles only, commit `personal/<your-username>/profile.md` but gitignore `personal/<your-username>/raw/` and `personal/<your-username>/wiki/`.

### 3. Add personal notes

```bash
cat > personal/<your-username>/raw/my-auth-notes.md << 'EOF'
# Notes on Auth Service

Things I learned debugging the JWT refresh flow...
EOF
```

### 4. Compile your personal wiki

```bash
./scripts/compile.sh --personal <your-username>
```

This compiles `personal/<your-username>/raw/` → `personal/<your-username>/wiki/` and generates a `profile.md` summarizing your expertise and active projects.

### What Gets Generated

- `personal/<your-username>/wiki/` — structured articles from your notes
- `personal/<your-username>/profile.md` — auto-generated summary of your expertise, projects, and interests, with cross-links to relevant team wiki articles

### Privacy Options

| Approach | What's visible to team |
|---|---|
| Gitignore entire `personal/` | Nothing |
| Commit only `profile.md` | Your expertise summary |
| Commit everything | Full personal wiki |

The choice is yours. The compiler never reads `personal/` for team wiki compilation.
