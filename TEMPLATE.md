# Budibase 4.1 Low-Code App Builder (CouchDB, Redis, LiteLLM, S3): composer spec

## Listing

| Field | Value |
|---|---|
| Name | **Budibase 4.1 Low-Code App Builder (CouchDB, Redis, LiteLLM, S3)** |
| Description | Low-code internal tools: apps, worker, CouchDB, AI gateway, file store. (71 chars) |
| Category | Other |
| Icon | `https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/budibase.svg` |
| Repo | `baranberkay96/budibase-railway`, roots `/services/proxy`, `/services/files`, `/services/litellm` |

## Base market templates (checked 2026-11-24)

| Code | Deploys | Notes |
|---|---|---|
| `FNZJ8t` | 317 | All-in-one `budibase/budibase:v3.45.0` (CouchDB, MinIO, Redis, LiteLLM + Postgres in one container), start command patches LiteLLM under pm2, no healthcheck |
| `budibase-latest` | 18 | All-in-one `:latest`, no healthcheck, admin claimable by first visitor |
| `budibase-low-code-platform` | 5 | All-in-one v4.0.1 by digest with a base64 start wrapper |

All three put every process in one container (1.2 GB compressed image, several GB of RAM under load), which cannot fit Trial's 1 GB per-service limit.

## Services

| Service | Source | Port | Healthcheck | Volume |
|---|---|---|---|---|
| Budibase (proxy) | repo `/services/proxy` (`FROM budibase/proxy:v4.1.0@sha256:ab4d98d9…`) | 10000 public | `/health` | — |
| Apps | `budibase/apps:v4.1.0@sha256:fb01af5c…` | 4002 private | `/health` (1200 s) | — |
| Worker | `budibase/worker:v4.1.0@sha256:6f6b8213…` | 4003 private | `/health` (1200 s) | — |
| CouchDB | `budibase/database:2.1.0@sha256:d90f6562…` | 5984 (+ SQS 4984) private | `/_up` | `/data` |
| Files | repo `/services/files` (SeaweedFS 4.53) | 8333 private | `/healthz` | `/data` |
| LiteLLM | repo `/services/litellm` (`litellm-database:v1.104.2` + config) | 4000 private | `/health/readiness` | — |
| Postgres | `postgres-ssl:18.6` | 5432 private | — | `/var/lib/postgresql/data` |
| Redis | `redis:8.2.11` | 6379 private | — | `/data` |

## Design

1. **Upstream's compose layout, one process per service**, so each fits 1 GB (STANDARD 8.31) instead of the all-in-one image.
2. **No MinIO:** Budibase's S3 client always uses path-style requests (`forcePathStyle: true`), which Railway Buckets reject; SeaweedFS with a single full-access identity replaces it. Budibase creates its buckets itself. Signed file URLs go through the proxy's `/files/signed/` route (signed for host `minio-service`, forwarded with that Host header). Railway's edge adds `X-Forwarded-Host/Port`, which SeaweedFS prefers for SigV4 host checks (first test: `SignatureDoesNotMatch`), so the proxy image clears both headers on that route.
3. **Proxy DNS:** upstream's nginx uses Docker's `127.0.0.11` resolver. A sourced `05-railway-resolver.envsh` sets `RESOLVER` from `/etc/resolv.conf` (bracketed for IPv6) before the config template is rendered. nginx keeps `ipv6=off`, i.e. it uses the IPv4 private addresses new Railway environments provide.
4. **Admin from variables:** `BB_ADMIN_USER_EMAIL` (required) / `BB_ADMIN_USER_PASSWORD` (generated); the apps service creates the account on start (`packages/server/src/startup`).
5. **LiteLLM** reuses our LiteLLM service (Postgres-backed model store, Redis router state); Budibase manages models with the master key.

## Improvements over market templates

- Multi-service production layout with healthchecks on every web service; pinned digests.
- No MinIO; no public CouchDB/Redis; admin created from variables.
- Fits Trial's per-service memory limit (see measurements).

## Resources

To be measured on the test deploy (see the report).

## Verification checklist

- [ ] All services SUCCESS; `/health` 200 on the public URL.
- [ ] Admin login; create an app with a table and a row; publish it; open the published app.
- [ ] Upload an attachment (Files), download through a signed URL.
- [ ] Odd values (bad admin e-mail) do not fail the deploy.

## Open questions

- AI features need a provider key; not tested beyond LiteLLM readiness.
