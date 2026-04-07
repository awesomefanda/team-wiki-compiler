# Authentication

> **Summary:** The auth-service owns all authentication and authorization, issuing short-lived JWTs with refresh tokens and supporting OAuth2 SSO via Google and GitHub.

## Overview

The `auth-service` is the central authority for identity on the platform. It issues JWTs, manages refresh token lifecycle, handles OAuth2 flows, and exposes a token introspection endpoint. The [API gateway](api-gateway.md) validates JWTs on every request by checking the token's signature and consulting the revocation list in Redis.

The system uses short-lived JWTs (15-minute expiry) paired with long-lived refresh tokens (30-day expiry, stored in HttpOnly cookies). Short JWT lifetimes limit the blast radius of a stolen token — an attacker can use it for at most 15 minutes before it expires.

## JWT Structure

| Claim | Description |
|---|---|
| `sub` | User ID |
| `role` | `admin`, `member`, or `viewer` |
| `org_id` | Organization the user belongs to |
| `exp` | Expiry timestamp |
| `jti` | Unique token ID used for revocation |

## OAuth2 / SSO

Google and GitHub OAuth2 are supported. The flow:

1. Client redirects to `/auth/oauth/google` or `/auth/oauth/github`
2. auth-service redirects to the provider
3. Provider returns an authorization code to `/auth/oauth/callback`
4. auth-service exchanges the code for user info, upserts the user in the database, and issues a JWT + refresh token

## Token Revocation

JWTs cannot be invalidated before expiry by design. For immediate revocation (e.g., on password change or suspected compromise), a Redis-backed revocation list is maintained, keyed by `jti`. The gateway checks this list on each request.

**Important:** The revocation list shares a Redis instance with the gateway rate limiter. A Redis outage affects both — as seen in the [March 2026 Redis incident](../incidents/2026-03-22-redis-outage.md). Separating these Redis instances is tracked in PROJ-1152.

The gateway's safety default is to fail closed: if the revocation list is unreachable, tokens are treated as potentially revoked. This is correct but requires a fast recovery path.

## Dependencies

| Dependency | Use |
|---|---|
| PostgreSQL | User records, OAuth state, refresh token store |
| Redis | Revocation list, rate limit counters (shared with gateway) |
| Sendgrid | Magic link emails |

**Known issue:** Magic link emails can be delayed during Sendgrid outages. No retry queue is implemented yet.

## Related Articles

- [API Gateway](api-gateway.md)
- [Redis Infrastructure](redis-infrastructure.md)

## Sources

- `raw/docs/auth-service-design.md` — token strategy, OAuth2 flow, revocation, dependencies
- `raw/incidents/2026-03-22-redis-outage.md` — Redis outage impact on revocation list
