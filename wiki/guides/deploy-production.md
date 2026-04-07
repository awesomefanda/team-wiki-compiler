# Production Deployment

> **Summary:** How to deploy backend services to production using GitHub Actions + ArgoCD, including the migration-first protocol for database changes.

## Overview

Deploys use a GitOps model: merge to `main` triggers CI, which builds and pushes a Docker image to ECR. Updating the image tag in `infra/k8s/` via a separate infra PR triggers ArgoCD to roll out the change. **Never apply changes directly with kubectl** — ArgoCD self-heals and will revert manual changes.

## Standard Deploy (No DB Migrations)

1. **Merge PR to `main`** — CI builds the Docker image and pushes it to ECR tagged `sha-<commit>`.
2. **Update image tag** — Edit `infra/k8s/<service>/deployment.yaml`, bump `image.tag` to the new SHA.
3. **Open infra PR** — Get approval from one other engineer.
4. **ArgoCD syncs** — After merge, ArgoCD detects the change and rolls out. Monitor in the ArgoCD UI.
5. **Verify** — Check Datadog for error rate spikes. Run smoke tests if available.

## Deploy With DB Migrations

Always run migrations **before** deploying new code, and write backwards-compatible code that handles both old and new schema during rollout.

1. Make code backwards-compatible with both old and new schema.
2. Run the migration job: `kubectl apply -f infra/k8s/<service>/migration-job.yaml` and wait for completion.
3. Verify the migration via `scripts/db-shell.sh`.
4. Deploy the service using the standard steps above.
5. In a follow-up PR, remove the backwards-compat code.

## Rollback

1. Revert the image tag in `infra/k8s/<service>/deployment.yaml` to the previous SHA and merge.
2. ArgoCD will roll back within ~2 minutes.
3. If the issue is customer-impacting, file an incident report in `raw/incidents/`.

## Approval Matrix

| Action | Approver |
|---|---|
| Standard deploy | @platform-team (any) |
| DB migration | @backend-lead |
| On-call escalation | PagerDuty rotation |

## Gotchas

- Branch protection is enforced — never force-push to `main`.
- ArgoCD self-heals. Manual `kubectl` changes to production will be reverted.
- If ArgoCD is stuck, check for a failed pre-sync hook first.

## Related Articles

- [API Gateway](../concepts/api-gateway.md)
- [New Engineer Onboarding](onboarding-backend.md)

## Sources

- `raw/runbooks/deploy-production.md` — full deploy procedure, rollback, contacts, gotchas
