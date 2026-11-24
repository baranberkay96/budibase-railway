# Notice

This repository is a Railway template package for Budibase. Our own files (`services/proxy/05-railway-resolver.envsh`, `services/files/railway-files.sh`, Dockerfiles, docs) are MIT-licensed. `services/litellm/` is reused from our own LiteLLM template (MIT).

| Component | License | Used as |
|---|---|---|
| Budibase apps, worker, proxy 4.1.0 | GPL-3.0 (server, worker), MPL-2.0 (client packages), BSL 1.1 (`packages/pro`, paid features gated by license key) | Official images `budibase/apps:v4.1.0@sha256:fb01af5c…`, `budibase/worker:v4.1.0@sha256:6f6b8213…`, `budibase/proxy:v4.1.0@sha256:ab4d98d9…` (proxy extended with a resolver hook) |
| Budibase CouchDB image 2.1.0 (Apache CouchDB 3.3.3, Clouseau, Structured Query Server by The Neighbourhoodie Software GmbH) | Apache-2.0 (CouchDB, Clouseau); SQS under its own license (`SQS_LICENSE` in the Budibase repository) | `budibase/database:2.1.0` pinned by digest, unmodified |
| SeaweedFS 4.53 | Apache-2.0 | `chrislusf/seaweedfs:4.53@sha256:ccad23e1…` with our start script |
| LiteLLM 1.104.2 | MIT (outside its `enterprise/` folder) | `ghcr.io/berriai/litellm-database:v1.104.2` with our config |
| PostgreSQL 18 | PostgreSQL License | `ghcr.io/railwayapp-templates/postgres-ssl:18.6` (Railway) |
| Redis 8.2 | RSALv2 / SSPLv1 / AGPLv3 | `redis:8.2.11` (official image, unmodified) |

## Upstream files checked

- `hosting/docker-compose.yaml`, `hosting/proxy/nginx.prod.conf`, `hosting/proxy/Dockerfile`, `hosting/couchdb/runner.sh` at tag `v4.1.0`
- `packages/backend-core/src/objectStore/objectStore.ts` (path-style S3, bucket creation), `packages/server/src/startup/index.ts` (admin from `BB_ADMIN_USER_*`), `packages/server/src/environment.ts`, `packages/server/src/api/index.ts`, `packages/worker/src/api/index.ts` (health routes)

Budibase is a trademark of Budibase Ltd. This community template is not affiliated with or endorsed by Budibase.
