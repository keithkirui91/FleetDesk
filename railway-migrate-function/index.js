import { Hono } from "hono@4";
import { cors } from 'hono/cors';
import mysql from "mysql2@3/promise";
import { readFile } from "node:fs/promises";
import path from "node:path";

const app = new Hono();
app.use("/*", cors());

app.get("/", (c) => c.text("Hello world!"));
app.get("/api/health", (c) => c.json({ status: "ok" }));

function getConnectionConfig() {
  return {
    host: Bun.env.FLEETDESK_DB_HOST || Bun.env.MYSQLHOST || "localhost",
    port: Number(Bun.env.FLEETDESK_DB_PORT || Bun.env.MYSQLPORT || 3306),
    user: Bun.env.FLEETDESK_DB_USER || Bun.env.MYSQLUSER || "root",
    password: Bun.env.FLEETDESK_DB_PASS || Bun.env.MYSQLPASSWORD || "",
    database: Bun.env.FLEETDESK_DB_NAME || Bun.env.MYSQLDATABASE || "fleetdesk",
    multipleStatements: true,
  };
}

async function alreadyMigrated(conn, database) {
  const [rows] = await conn.query(
    `SELECT COUNT(*) AS c FROM information_schema.tables WHERE table_schema = ? AND table_name = 'vehicles'`,
    [database]
  );
  return rows[0].c > 0;
}

function requireToken(c) {
  const expected = Bun.env.MIGRATE_TOKEN;
  if (!expected) return "MIGRATE_TOKEN is not set on this service — refusing all migration requests.";
  const given = c.req.header("x-migrate-token");
  if (given !== expected) return "Invalid or missing x-migrate-token header.";
  return null;
}

// GET /api/migrate/status -> tells you whether the schema looks applied yet
app.get("/api/migrate/status", async (c) => {
  const authError = requireToken(c);
  if (authError) return c.json({ success: false, error: authError }, 401);

  const config = getConnectionConfig();
  const conn = await mysql.createConnection(config);
  try {
    const done = await alreadyMigrated(conn, config.database);
    return c.json({ success: true, applied: done, database: config.database, host: config.host });
  } catch (e) {
    return c.json({ success: false, error: e.message }, 500);
  } finally {
    await conn.end();
  }
});

// POST /api/migrate
// Body (JSON): { "sql": "...", "force": false }
//   - sql:   raw SQL text to run (e.g. paste in schema.sql or a data export).
//            If omitted, falls back to reading ./schema.sql from this
//            service's own deploy (only works if this function is deployed
//            from within the same repo, at the repo root).
//   - force: if true, runs even if the `vehicles` table already exists.
// Header: x-migrate-token: <MIGRATE_TOKEN env var value>
app.post("/api/migrate", async (c) => {
  const authError = requireToken(c);
  if (authError) return c.json({ success: false, error: authError }, 401);

  const body = await c.req.json().catch(() => ({}));
  const force = body.force === true;

  let sql = body.sql;
  let source = "request body";
  if (!sql) {
    try {
      const filePath = path.join(process.cwd(), "schema.sql");
      sql = await readFile(filePath, "utf8");
      source = filePath;
    } catch {
      return c.json({
        success: false,
        error: "No `sql` provided in the request body, and no schema.sql found next to this function. Either POST { sql: \"...\" } or deploy this function from the repo root.",
      }, 400);
    }
  }

  const config = getConnectionConfig();
  const conn = await mysql.createConnection(config);
  try {
    if (!force) {
      const done = await alreadyMigrated(conn, config.database);
      if (done) {
        return c.json({
          success: true,
          skipped: true,
          message: "Schema already present (vehicles table found) — skipped. Pass force:true to override.",
        });
      }
    }
    await conn.query(sql);
    return c.json({ success: true, skipped: false, source });
  } catch (e) {
    return c.json({ success: false, error: e.message }, 500);
  } finally {
    await conn.end();
  }
});

Bun.serve({
  port: import.meta.env.PORT ?? 3000,
  fetch: app.fetch,
});
