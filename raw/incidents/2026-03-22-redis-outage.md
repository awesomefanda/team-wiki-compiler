# Incident Report: Redis Outage — 2026-03-22

**Severity:** P1  
**Duration:** 47 minutes (14:03–14:50 UTC)  
**Impact:** All authenticated users could not make API requests. Login was unavailable. ~3,200 users affected.  
**On-call:** Jamie R.

## Timeline

- **14:03** — Alerts fire: API gateway error rate spikes to 98%. PagerDuty pages on-call.
- **14:07** — Jamie investigates. Gateway logs show Redis connection timeout on rate limit check.
- **14:12** — Confirmed: Redis primary node OOM-killed due to memory spike. Replica did not auto-promote (failover misconfigured).
- **14:18** — Decision: manually promote replica to primary.
- **14:25** — Replica promoted. Gateway reconnects. Error rate drops but auth still failing.
- **14:31** — Second issue found: auth-service token revocation list also stored in same Redis. After failover, revocation list empty — gateway treating all tokens as potentially revoked (safety default).
- **14:40** — Temporary fix: disabled revocation list check (risk-accepted for ~10 min window).
- **14:50** — Revocation list rebuilt from DB backup. Check re-enabled. Fully resolved.

## Root Causes

1. Redis memory limit set too low (4GB, should be 8GB). Memory spike caused by a bulk-export job that scanned the full user keyspace.
2. Redis Sentinel failover not configured correctly — replica was in wrong AZ.
3. auth-service and gateway sharing a single Redis instance — failure of one affects both.

## Action Items

- [ ] PROJ-1150: Increase Redis memory limit to 8GB. (Owner: @platform, Due: 2026-03-29)
- [ ] PROJ-1151: Fix Sentinel failover config. (Owner: @platform, Due: 2026-03-29)
- [ ] PROJ-1152: Separate Redis instances for gateway rate limiting and auth revocation list. (Owner: @backend, Due: 2026-04-12)
- [ ] PROJ-1153: Bulk export jobs must use a read replica, not primary. (Owner: @data-eng, Due: 2026-04-05)

## Lessons Learned

- Shared infrastructure creates hidden coupling. The gateway and auth-service failure modes are now intertwined because of shared Redis.
- Safety defaults (fail closed on missing revocation list) are correct in theory but need a faster recovery path.
