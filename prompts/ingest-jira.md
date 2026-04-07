# Jira Ingestion Prompt

You are processing exported Jira tickets for the team wiki. Jira data is noisy — extract the signal.

## Extract

- **Decision context** — Why was work started? What problem?
- **Key decisions** — Technical choices in descriptions/comments
- **Outcome** — Completed? What was delivered?
- **Timeline** — Dates for staleness tracking

## Map to Articles

- Epic summaries → project context articles
- Design decisions in comments → concept articles
- Bug patterns across tickets → pattern analysis
- Retrospective notes → lessons learned

## Discard

- Status updates with no info ("WIP", "in review")
- Bot-generated comments (CI notifications, auto-assignments)
- Duplicates of content already in `raw/docs/` or `raw/rfcs/`

## Attribution

Tag all Jira-sourced content with ticket IDs:

```markdown
## Sources
- `raw/jira/PROJ-1234.md` — Decision to use Redis for session caching
```
