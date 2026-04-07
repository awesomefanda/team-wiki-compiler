# PROJ-1102: Redis rate limit counters reset on gateway pod restart

**Status:** Open  
**Priority:** Medium  
**Reporter:** Alex T.  
**Assignee:** Unassigned  
**Created:** 2026-02-14  
**Labels:** gateway, redis, rate-limiting

## Description

When a Kong gateway pod restarts, the in-memory rate limit counters for that pod are lost. If the Redis connection is also temporarily unavailable during restart (e.g., during Redis failover), the pod falls back to local counters — which reset to zero. This allows users to exceed their rate limit during the restart window.

Observed during the Redis maintenance window on 2026-02-12: several users made 3x their normal request volume for ~5 minutes.

## Steps to Reproduce

1. Simulate Redis connection drop from a Kong pod
2. Send requests at > rate limit threshold
3. Observe requests succeeding

## Expected Behavior

Rate limit should be enforced even during Redis connection loss (use last-known counter as floor, or reject when Redis unavailable).

## Proposed Fix

Configure Kong to reject requests (503) rather than fall back to local counters when Redis is unreachable. Trade-off: brief unavailability vs. rate limit bypass. Team consensus: prefer unavailability.

## Related

- Incident 2026-03-22 (Redis outage) surfaced this as a related issue
- PROJ-1152: plan to separate Redis instances will reduce blast radius
