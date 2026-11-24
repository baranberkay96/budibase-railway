# Deploy and Host Budibase with Railway

Budibase is a low-code platform for internal tools: build forms, dashboards, portals and approval apps on top of its built-in database or your own SQL, REST and Google Sheets sources, then add automations and AI agents. This template runs Budibase 4.1 as upstream's multi-service stack: proxy, apps service, worker, CouchDB with search and SQL, Redis, an S3 file store and the LiteLLM AI gateway.

## About Hosting Budibase

Budibase splits work between an apps service (builder, app runtime, automations), a worker (users, authentication, tenancy, e-mail) and an nginx proxy that routes the public URL to both. Apps and data live in CouchDB, which upstream ships with Lucene search and an SQL layer; Redis holds sessions and queues, and uploaded files and app assets go to an S3-compatible store. Budibase 4 talks to AI providers through a LiteLLM gateway with its own Postgres database.

Each process runs as its own Railway service, as in upstream's compose file, so services can be sized and scaled independently. Budibase forces path-style S3 requests, which Railway Buckets reject, so SeaweedFS replaces upstream's MinIO. The admin account is created from your variables on the first start.

## Common Use Cases

- Admin panels and CRUD apps over PostgreSQL, MySQL, MongoDB or REST APIs
- Approval workflows, request forms and internal portals
- Dashboards and reports for operations teams
- Automations triggered by rows, webhooks or schedules
- AI agents and AI columns backed by your own model provider keys

## Dependencies for Budibase Hosting

- Budibase 4.1.0 apps, worker and proxy images; Budibase CouchDB 3.3.3 image (with Clouseau search and SQS)
- Redis 8.2
- SeaweedFS 4.53 (S3 API) for files
- LiteLLM 1.104 with PostgreSQL 18

### Deployment Dependencies

- Budibase source: https://github.com/Budibase/budibase
- Docker Compose self-hosting: https://docs.budibase.com/docs/docker-compose
- Environment variables: https://docs.budibase.com/docs/environment-variables
- LiteLLM: https://docs.litellm.ai

### Implementation Details

| Service | What it does | Public |
|---|---|---|
| Budibase | nginx proxy: routes the public URL to Apps, Worker and signed file URLs | yes |
| Apps | Builder, app runtime, automations; creates the admin on first start | no |
| Worker | Users, auth, settings, e-mail | no |
| CouchDB | Apps and data (with search and SQL) | no |
| Files | S3-compatible file store (SeaweedFS) | no |
| LiteLLM | AI gateway for Budibase AI features | no |
| Postgres | LiteLLM's database | no |
| Redis | Sessions, cache, queues | no |

**First login**

1. Enter your e-mail in `BB_ADMIN_USER_EMAIL` (Apps service) when you deploy.
2. Wait until all services are green (CouchDB and the apps service take a few minutes on the first start), then open the **Budibase** URL.
3. Log in with `BB_ADMIN_USER_EMAIL` and the generated `BB_ADMIN_USER_PASSWORD` from the Apps service's Variables tab.

**AI.** Add model provider keys in Budibase's AI settings; Budibase stores the models in LiteLLM. Nothing is sent to an AI provider until you configure one.

**E-mail.** Invitations and password resets need SMTP, configured in Budibase's settings; Railway allows outbound SMTP only on the Pro plan.

**Custom domain.** Add it to the Budibase service and set `PLATFORM_URL` on Apps to `https://{your-domain}`; Worker references it. Redeploy both.

**Scaling and versions.** Apps and Worker are stateless and can get replicas. Images are pinned by digest in the template and in `services/*/Dockerfile`. To upgrade, move Apps, Worker and Proxy to the same new 4.x release together, back up the CouchDB volume and redeploy.

**Resources.** Measured idle on Railway: Apps 1.4–1.6 GB, LiteLLM 0.6 GB, CouchDB 0.7–0.8 GB, Worker 0.3 GB, the rest under 0.2 GB each; about 3.7 GB in total, roughly $37–50 per month. The apps service needs more than the Trial plan's 1 GB per service, so use the Hobby plan or higher.

**License.** Budibase's server and worker are GPL-3.0 and its client packages MPL-2.0; paid features in `packages/pro` are under the Business Source License and need a Budibase license key. LiteLLM is MIT (enterprise folder excepted), SeaweedFS Apache-2.0. This is a community template; it is not affiliated with Budibase.

### Why Deploy Budibase on Railway?

Railway runs every Budibase process, CouchDB, Redis, the file store and the AI gateway in one project with private networking, HTTPS and volumes. You get upstream's production layout in one click, sized so each service fits small plans, with the admin account ready.
