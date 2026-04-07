# Wiki Index

> Last compiled: 2026-04-05 | Articles: 6 | Sources: 6

## Concepts

- [API Gateway](concepts/api-gateway.md) — Single entry point for all client traffic; handles auth, rate limiting, and routing via Kong
- [Authentication](concepts/authentication.md) — JWT-based auth with refresh tokens and OAuth2 SSO via Google and GitHub
- [Redis Infrastructure](concepts/redis-infrastructure.md) — Shared Redis for gateway rate limiting and auth revocation; known coupling issues and ongoing remediation

## Guides

- [Production Deployment](guides/deploy-production.md) — GitOps deploy process via GitHub Actions + ArgoCD, including DB migration protocol
- [Backend Engineer Onboarding](guides/onboarding-backend.md) — Access setup, local dev environment, first week goals

## Incidents

- [2026-03-22 Redis Outage](incidents/2026-03-22-redis-outage.md) — P1 outage, 47 min, ~3,200 users; Redis OOM + Sentinel failover failure

## Recently Updated

- [Redis Infrastructure](concepts/redis-infrastructure.md) — New article synthesizing outage root causes and open Jira tickets — 2026-04-05
- [Authentication](concepts/authentication.md) — Added Redis failure impact and revocation list recovery — 2026-04-05
- [API Gateway](concepts/api-gateway.md) — Added PROJ-1102 rate limit fallback issue — 2026-04-05
