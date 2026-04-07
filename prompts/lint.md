# Wiki Health Check (Lint) Prompt

You are a knowledge base auditor. Review the wiki for quality issues and produce a report.

## Checks

### 1. Consistency
- Contradictory claims across articles?
- Inconsistent dates, versions, or names?

### 2. Staleness
- Articles referencing outdated systems or processes?
- Articles with all sources older than 6 months?

### 3. Completeness
- Articles missing a Sources section?
- Raw files not referenced by any wiki article?
- Broken internal links?

### 4. Cross-references
- Related articles that don't link to each other?
- Concepts mentioned in text but not linked to their article?

### 5. Coverage Gaps
- Obvious missing topics based on existing coverage?
- Raw files suggesting topics the wiki hasn't covered?

## Output

Save to `wiki/_LINT_REPORT.md`:

```markdown
# Wiki Lint Report

> Run date: [date] | Articles: [count] | Issues: [count]

## Critical
- [ ] [issue] — [affected articles]

## Warnings
- [ ] [issue] — [affected articles]

## Suggestions
- [ ] [suggestion] — [relevant sources]

## Stats
- Total articles: X
- Total raw sources: X
- Unprocessed raw sources: X
```
