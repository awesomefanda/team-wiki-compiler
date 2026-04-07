# Backend Engineer Onboarding — Day 1 Guide

Welcome to the team! This guide gets you from zero to a running local environment and your first code contribution.

## Access & Accounts

By end of day 1, you should have:
- [ ] GitHub org access (ask your manager)
- [ ] AWS SSO access (IT will set up, ~2hr)
- [ ] Datadog access (self-serve: use Google SSO)
- [ ] PagerDuty account (only needed if you're on-call rotation — ask @platform)
- [ ] 1Password team vault access

## Local Dev Setup

### Prerequisites
- Docker Desktop
- Node.js 20+
- `kubectl` + `helm`
- `aws` CLI

### Clone and run

```bash
git clone https://github.com/<org>/backend-services
cd backend-services
cp .env.example .env.local     # fill in secrets from 1Password "Dev Secrets" vault
docker compose up              # starts all services + local Postgres + Redis
```

Services will be available at `localhost:3000` (API gateway).

### Running tests

```bash
npm test                        # unit tests
npm run test:integration        # requires Docker Compose running
```

## First Week Goals

1. Get local environment running
2. Read `raw/docs/api-gateway-overview.md` and `raw/docs/auth-service-design.md`
3. Shadow a deploy with a senior engineer
4. Pick up a "good first issue" label ticket from Jira

## Key Contacts

- **Engineering Manager:** Sarah K. (Slack: @sarah-k)
- **Platform Team (infra/on-call):** #platform-team channel
- **Backend Lead:** Marcus W. (@marcus-w)
- **Get unstuck:** Post in #backend-eng, anyone will help

## Important Norms

- All deploys go through GitHub + ArgoCD. Never kubectl apply manually to production.
- Incidents get postmortems. Blameless culture — we fix systems, not people.
- PRs need one approval. Add `#backend-eng` or ping the author's team for reviews.
