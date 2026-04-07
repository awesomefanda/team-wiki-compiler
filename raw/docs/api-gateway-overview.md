# API Gateway Overview

Our API gateway is the single entry point for all client traffic. It handles authentication, rate limiting, and routing to downstream microservices.

## Architecture

The gateway runs on Kong (v3.2) deployed as a Kubernetes Deployment with 3 replicas behind a LoadBalancer service. It sits in front of all our backend services:

- **auth-service** — JWT validation, session management
- **user-service** — user profiles, preferences
- **billing-service** — subscriptions, invoices
- **notifications-service** — email and push notifications

## Key Responsibilities

1. **Authentication** — Validates JWT tokens on every request. Passes `X-User-ID` and `X-User-Role` headers to downstream services.
2. **Rate limiting** — 1000 req/min per authenticated user, 100 req/min for anonymous. Backed by Redis.
3. **Routing** — Path-based routing via Kong route rules. Config lives in `infra/kong/routes.yaml`.
4. **Request logging** — All requests logged to Datadog with trace IDs for distributed tracing.

## Known Limitations

- No response caching at gateway layer. Cache lives in individual services.
- Rate limit counters reset on Kong pod restart (Redis TTL issue, see PROJ-1102).
- WebSocket connections are routed directly to the notifications-service, bypassing the gateway auth check (intentional — handled at service level).

## Deployment

Gateway config is managed via Helm chart in `infra/helm/kong/`. Changes require a PR and go through the standard deploy pipeline. Rolling restarts take ~2 minutes.

## On-call Notes

If the gateway is down or degraded, all client traffic fails. Check Datadog dashboard "API Gateway Health" first. Common issues: Redis connection timeouts, cert expiry, upstream DNS failures.
