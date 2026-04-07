# Auth Service Design

## Purpose

The auth-service owns all authentication and authorization logic for the platform. It issues JWTs, manages refresh tokens, handles OAuth2 flows, and provides a token introspection endpoint.

## Token Strategy

We use short-lived JWTs (15-minute expiry) with long-lived refresh tokens (30 days, stored in HttpOnly cookies). This limits blast radius if a JWT is intercepted.

JWT claims:
- `sub` — user ID
- `role` — one of: `admin`, `member`, `viewer`
- `org_id` — organization the user belongs to
- `exp` — expiry timestamp
- `jti` — unique token ID (used for revocation checks)

## OAuth2 / SSO

We support Google and GitHub OAuth2. The flow:
1. Client redirects to `/auth/oauth/google` or `/auth/oauth/github`
2. auth-service redirects to provider
3. Provider returns code to `/auth/oauth/callback`
4. auth-service exchanges code for user info, upserts user in DB, issues JWT + refresh token

## Token Revocation

JWTs can't be invalidated before expiry (by design). For immediate revocation (e.g., on password change, suspected compromise), we maintain a Redis-backed revocation list keyed by `jti`. The gateway checks this list on each request.

## Dependencies

- PostgreSQL: user records, OAuth state, refresh token store
- Redis: revocation list, rate limit counters (shared with gateway)
- Sendgrid: magic link emails

## Known Issues

- PROJ-1102: Rate limit Redis counters shared with gateway can cause cross-contamination during Redis restarts.
- Magic link emails occasionally delayed during Sendgrid outages. No retry queue implemented yet.
