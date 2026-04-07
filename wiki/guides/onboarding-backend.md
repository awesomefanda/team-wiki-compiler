# Backend Engineer Onboarding

> **Summary:** Step-by-step guide for new backend engineers to get access, set up a local development environment, and make a first contribution.

## Overview

This guide covers day 1 for backend engineers. The goal is: access provisioned, local environment running, and a first ticket picked up by end of week 1. If anything is unclear, post in `#backend-eng` — the team is responsive.

## Access Checklist

Complete these on day 1:

- [ ] GitHub org access — ask your manager
- [ ] AWS SSO access — provisioned by IT (~2hr turnaround)
- [ ] Datadog — self-serve via Google SSO
- [ ] 1Password team vault — ask your manager
- [ ] PagerDuty — only needed if joining the on-call rotation; ask @platform

## Local Dev Setup

**Prerequisites:** Docker Desktop, Node.js 20+, `kubectl`, `helm`, AWS CLI.

```bash
git clone https://github.com/<org>/backend-services
cd backend-services
cp .env.example .env.local     # fill in secrets from 1Password "Dev Secrets" vault
docker compose up              # starts all services + local Postgres + Redis
```

The API gateway will be available at `localhost:3000`. Run tests with:

```bash
npm test                        # unit tests
npm run test:integration        # requires Docker Compose running
```

## First Week Goals

1. Local environment running end-to-end
2. Read the [API Gateway](../concepts/api-gateway.md) and [Authentication](../concepts/authentication.md) articles
3. Shadow a production deploy with a senior engineer (see [Production Deployment](deploy-production.md))
4. Pick up a "good first issue" ticket from Jira

## Key Contacts

| Role | Person | Slack |
|---|---|---|
| Engineering Manager | Sarah K. | @sarah-k |
| Backend Lead | Marcus W. | @marcus-w |
| Platform / Infra | — | #platform-team |
| General help | — | #backend-eng |

## Team Norms

- All deploys go through GitHub + ArgoCD. Never `kubectl apply` manually to production.
- Incidents get blameless postmortems. We fix systems, not people.
- PRs need one approval. Ping `#backend-eng` or the author's team for reviews.

## Related Articles

- [API Gateway](../concepts/api-gateway.md)
- [Authentication](../concepts/authentication.md)
- [Production Deployment](deploy-production.md)

## Sources

- `raw/onboarding/backend-engineer-day1.md` — access checklist, setup steps, first week goals, team norms
