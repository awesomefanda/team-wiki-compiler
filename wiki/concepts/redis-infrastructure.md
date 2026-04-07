# Redis Infrastructure

> **Summary:** Redis is used as shared infrastructure for API gateway rate limiting and auth-service token revocation — a coupling that has caused cascading failures and is being addressed.

## Overview

Redis currently serves two critical functions for the platform, both pointing at the same instance:

1. **Rate limit counters** — used by the [API gateway](api-gateway.md) to enforce per-user request quotas
2. **Token revocation list** — used by the [auth-service](authentication.md) to invalidate JWTs before expiry

This shared deployment creates hidden coupling: a Redis failure simultaneously breaks rate limiting *and* authentication. This was the root cause of the [March 2026 P1 outage](../incidents/2026-03-22-redis-outage.md), during which ~3,200 users lost access for 47 minutes.

## Known Issues

### PROJ-1102: Rate limit counters reset on gateway pod restart

When a Kong pod restarts while Redis is unavailable, it falls back to local in-memory counters (which start at zero), allowing users to exceed their quota for the duration of the restart window. The fix is to have Kong return 503 rather than fall back to local counters.

**Status:** Open, Medium priority.

### PROJ-1152: Separate Redis instances for gateway and auth

The gateway rate limiter and auth revocation list should run on separate Redis instances to prevent cascading failure. Separating them also allows independent scaling and memory tuning.

**Status:** Planned, due 2026-04-12.

## Operational Notes

- Current Redis memory limit: 4GB (should be 8GB — see PROJ-1150)
- Redis Sentinel failover was misconfigured at the time of the March 2026 outage; the replica was in the wrong AZ
- Bulk export jobs must use a read replica, not the primary (PROJ-1153)

## Related Articles

- [API Gateway](api-gateway.md)
- [Authentication](authentication.md)
- [March 2026 Redis Outage](../incidents/2026-03-22-redis-outage.md)

## Sources

- `raw/docs/api-gateway-overview.md` — rate limiting, Redis dependency
- `raw/docs/auth-service-design.md` — revocation list Redis dependency
- `raw/incidents/2026-03-22-redis-outage.md` — outage root causes and action items
- `raw/jira/PROJ-1102-redis-rate-limit-bug.md` — rate limit fallback bug details
