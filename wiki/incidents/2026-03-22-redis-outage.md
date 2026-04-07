# Incident: Redis Outage — 2026-03-22

> **Summary:** A P1 outage lasting 47 minutes took down authentication and API access for ~3,200 users due to Redis OOM failure and misconfigured Sentinel failover.

## Impact

- **Severity:** P1
- **Duration:** 47 minutes (14:03–14:50 UTC)
- **Users affected:** ~3,200
- **Services affected:** All authenticated API access; login unavailable

## Timeline

| Time (UTC) | Event |
|---|---|
| 14:03 | API gateway error rate spikes to 98%. PagerDuty pages on-call (Jamie R.). |
| 14:07 | Investigation begins. Gateway logs show Redis connection timeouts on rate limit check. |
| 14:12 | Redis primary OOM-killed due to memory spike. Sentinel failover did not trigger (misconfigured). |
| 14:18 | Decision to manually promote replica to primary. |
| 14:25 | Replica promoted. Gateway reconnects. Error rate drops. Auth still failing. |
| 14:31 | Second issue: auth-service revocation list also in same Redis. After failover, list empty — gateway fails closed. |
| 14:40 | Temporary fix: revocation list check disabled (~10-minute risk window, accepted). |
| 14:50 | Revocation list rebuilt from DB backup. Check re-enabled. Fully resolved. |

## Root Causes

1. **Redis memory limit too low** — set at 4GB; a bulk-export job scanned the full user keyspace, causing OOM.
2. **Sentinel failover misconfigured** — the replica was in the wrong AZ and did not auto-promote.
3. **Shared Redis instance** — gateway rate limiting and auth revocation list shared one Redis, so a single failure broke both subsystems.

## Action Items

| Ticket | Description | Owner | Due |
|---|---|---|---|
| PROJ-1150 | Increase Redis memory limit to 8GB | @platform | 2026-03-29 |
| PROJ-1151 | Fix Sentinel failover configuration | @platform | 2026-03-29 |
| PROJ-1152 | Separate Redis for gateway vs. auth | @backend | 2026-04-12 |
| PROJ-1153 | Bulk export jobs must use read replica | @data-eng | 2026-04-05 |

## Lessons Learned

- Shared infrastructure creates hidden coupling. The gateway and auth-service now have entangled failure modes because of shared Redis.
- Fail-closed defaults are correct, but require a fast recovery path — rebuilding the revocation list from DB was manual and slow.

## Related Articles

- [Redis Infrastructure](../concepts/redis-infrastructure.md)
- [API Gateway](../concepts/api-gateway.md)
- [Authentication](../concepts/authentication.md)

## Sources

- `raw/incidents/2026-03-22-redis-outage.md` — timeline, root causes, action items, lessons learned
