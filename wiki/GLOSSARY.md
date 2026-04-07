# Glossary

> Auto-maintained by the wiki compiler. Do not edit manually.

**ArgoCD** — GitOps continuous delivery tool. Watches `infra/k8s/` for changes and syncs Kubernetes cluster state to match. Self-heals: manual `kubectl` changes to production are reverted.

**ECR** — Amazon Elastic Container Registry. Stores Docker images built by CI. Images are tagged `sha-<commit>`.

**JWT (JSON Web Token)** — Signed token issued by auth-service. Contains claims: `sub`, `role`, `org_id`, `exp`, `jti`. Expires after 15 minutes.

**`jti`** — JWT ID claim. Unique identifier per token, used as the key in the Redis revocation list to support early token invalidation.

**Kong** — Open-source API gateway platform (v3.2). Handles routing, rate limiting, and plugin-based request processing. Config managed via Helm in `infra/helm/kong/`.

**OAuth2** — Authorization framework used for SSO. The platform supports Google and GitHub as identity providers.

**P1** — Highest severity incident level. Customer-impacting, requires immediate on-call response and a postmortem.

**Refresh Token** — Long-lived token (30-day expiry) stored in an HttpOnly cookie. Used to obtain new JWTs without requiring re-authentication. Stored in PostgreSQL.

**Redis Sentinel** — Redis high-availability mode that monitors primary/replica topology and promotes replicas on failure. Was misconfigured at the time of the 2026-03-22 outage.

**Revocation List** — Redis hash keyed by `jti`. Allows the gateway to immediately reject a JWT before its natural expiry. Checked on every authenticated request.
