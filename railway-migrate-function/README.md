# FleetDesk migrate function (optional)

A tiny standalone Bun + Hono HTTP service with one job: run a SQL file
(schema and/or data) against the FleetDesk MySQL database over HTTP,
protected by a token. Useful if you'd rather trigger a migration with a
`curl` call than SSH into anything.

This is **completely optional** — `scripts/migrate.js` in the main app
already does this automatically on every deploy via the `prestart` hook.
Use this function instead if you want to trigger migrations on demand,
from outside a deploy (e.g. loading a new data export later).

## Deploying on Railway

1. In your Railway project, add a **new service** → "Deploy from GitHub
   repo" → same repo, but set the service's **root directory** to
   `railway-migrate-function`.
2. Railway should detect Bun automatically (via `package.json`). If not,
   set the start command to `bun run index.js`.
3. Set environment variables on this service:
   - `FLEETDESK_DB_HOST` / `MYSQLHOST`, and the matching `_PORT`, `_USER`,
     `_PASS`/`PASSWORD`, `_NAME`/`DATABASE` — same values as your main app
     service (reference the MySQL service's variables the same way).
   - `MIGRATE_TOKEN` — any long random string. **Required** — the endpoint
     refuses every request if this isn't set, since it'll be reachable at a
     public Railway URL.
4. Deploy. Railway gives you a public URL like
   `https://fleetdesk-migrate-production.up.railway.app`.

## Using it

Check whether the schema looks applied yet:

```bash
curl https://<your-function-url>/api/migrate/status \
  -H "x-migrate-token: <MIGRATE_TOKEN>"
```

Run a migration — easiest with `jq` to safely JSON-escape the file:

```bash
jq -Rs '{sql: .}' schema.sql | curl -X POST https://<your-function-url>/api/migrate \
  -H "x-migrate-token: <MIGRATE_TOKEN>" \
  -H "Content-Type: application/json" \
  --data-binary @-
```

If this function is deployed **from the repo root** (not the
`railway-migrate-function` subdirectory) and `schema.sql` sits next to it,
you can omit `sql` entirely and it'll read `schema.sql` from disk instead:

```bash
curl -X POST https://<your-function-url>/api/migrate \
  -H "x-migrate-token: <MIGRATE_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{}'
```

Either way, it's **safe to call repeatedly** — it checks whether the
`vehicles` table already exists and skips (returning `skipped: true`)
unless you pass `"force": true` in the body.
