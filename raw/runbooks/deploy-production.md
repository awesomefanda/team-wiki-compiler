# Production Deployment Runbook

## Overview

This runbook covers deploying any backend service to production. We use GitHub Actions + ArgoCD for GitOps-based deployments.

## Standard Deploy (No DB migrations)

1. **Merge PR to main** — CI runs tests, builds Docker image, pushes to ECR with tag `sha-<commit>`.
2. **Update image tag** — Edit `infra/k8s/<service>/deployment.yaml`, bump `image.tag` to new SHA.
3. **Open infra PR** — Get approval from one other engineer.
4. **ArgoCD syncs** — After merge, ArgoCD detects the change and rolls out the new image. Monitor in ArgoCD UI.
5. **Verify** — Check Datadog for error rate spike. Run smoke tests if available.

## Deploy With DB Migrations

**Never run migrations after deploying new code.** Always migrate first.

1. **Make code backwards-compatible** — New code must handle both old and new schema during rollout.
2. **Run migration job** — `kubectl apply -f infra/k8s/<service>/migration-job.yaml`. Wait for completion.
3. **Verify migration** — Connect to DB (see `scripts/db-shell.sh`) and confirm schema changes.
4. **Deploy service** — Follow standard deploy steps above.
5. **Cleanup** — After full rollout, remove backwards-compat code in follow-up PR.

## Rollback

If a deploy causes issues:

1. **Immediate rollback** — Revert the image tag in `infra/k8s/<service>/deployment.yaml` to previous SHA and merge.
2. **ArgoCD will roll back** within ~2 minutes.
3. **Post-mortem** — File an incident report in `raw/incidents/` if customer-impacting.

## Deployment Contacts

- Primary deploy approver: @platform-team
- DB migration approval: @backend-lead
- On-call: check PagerDuty

## Gotchas

- Never force-push to main. Branch protection is enforced.
- ArgoCD self-heals — manual kubectl changes will be reverted. Always go through git.
- If ArgoCD is stuck, check for a failed pre-sync hook first.
