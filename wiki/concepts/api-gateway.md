# API Gateway

> **Summary:** The single entry point for all client traffic, responsible for authentication, rate limiting, and routing to downstream microservices.

## Overview

The API gateway runs on Kong (v3.2) deployed as a Kubernetes Deployment with 3 replicas behind a LoadBalancer service. It is the first hop for every client request and enforces platform-wide policies before traffic reaches any backend service.

All downstream services receive enriched headers from the gateway: `X-User-ID` and `X-User-Role`, allowing them to trust identity claims without re-validating tokens. This means the gateway is a critical single point of failure — if it degrades, all client traffic fails.

The gateway configuration is managed via Helm chart in `infra/helm/kong/`, and route rules live in `infra/kong/routes.yaml`. Changes must go through a PR and the standard deploy pipeline.

## Downstream Services

| Service | Responsibility |
|---|---|
| `auth-service` | JWT validation, session management |
| `user-service` | User profiles and preferences |
| `billing-service` | Subscriptions and invoices |
| `notifications-service` | Email and push notifications |

WebSocket connections route directly to `notifications-service`, bypassing the gateway auth check — this is intentional, with auth handled at the service level.

## Rate Limiting

- Authenticated users: 1,000 req/min
- Anonymous users: 100 req/min
- Counters backed by a shared Redis instance

**Known issue:** During Redis connection loss, Kong falls back to local in-memory counters which reset on pod restart, allowing users to exceed their rate limit. The preferred fix is to return 503 when Redis is unreachable rather than falling back. See [PROJ-1102](../concepts/redis-infrastructure.md#proj-1102).

## Operational Notes

- Rolling restarts take ~2 minutes
- If the gateway is down, check the Datadog "API Gateway Health" dashboard first
- Common failure modes: Redis connection timeouts, TLS cert expiry, upstream DNS failures

## Related Articles

- [Authentication](authentication.md)
- [Redis Infrastructure](redis-infrastructure.md)
- [Production Deployment](../guides/deploy-production.md)

## Sources

- `raw/docs/api-gateway-overview.md` — architecture, responsibilities, rate limiting, operational notes
- `raw/jira/PROJ-1102-redis-rate-limit-bug.md` — rate limit Redis fallback bug
