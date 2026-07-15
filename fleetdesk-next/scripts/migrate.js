// scripts/migrate.js
//
// Runs a .sql file (schema and/or data) against the database.
// Safe to run on every deploy: it checks whether the schema already exists
// and skips if so, so it won't re-run (and re-INSERT/duplicate data) on
// every redeploy.
//
// Usage:
//   node scripts/migrate.js                -> runs schema.sql (default)
//   node scripts/migrate.js path/to/file.sql -> runs a specific file
//   FORCE_MIGRATE=1 node scripts/migrate.js  -> runs even if already applied
//
// Wired into package.json as "prestart", so `npm start` (what Railway runs)
// triggers it automatically before the server boots.

const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');

// Locally, Next.js auto-loads .env.local for the app, but a plain Node
// script invoked via npm does not. Load it here (only if present) so this
// works the same way locally as it does on Railway (where env vars are
// already injected into process.env).
function loadDotEnvLocal() {
  const envPath = path.join(process.cwd(), '.env.local');
  if (!fs.existsSync(envPath)) return;
  const lines = fs.readFileSync(envPath, 'utf8').split('\n');
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const eq = trimmed.indexOf('=');
    if (eq === -1) continue;
    const key = trimmed.slice(0, eq).trim();
    const value = trimmed.slice(eq + 1).trim();
    if (!(key in process.env)) process.env[key] = value;
  }
}

function getConnectionConfig() {
  return {
    host: process.env.FLEETDESK_DB_HOST || process.env.MYSQLHOST || 'localhost',
    port: Number(process.env.FLEETDESK_DB_PORT || process.env.MYSQLPORT || 3306),
    user: process.env.FLEETDESK_DB_USER || process.env.MYSQLUSER || 'root',
    password: process.env.FLEETDESK_DB_PASS || process.env.MYSQLPASSWORD || '',
    database: process.env.FLEETDESK_DB_NAME || process.env.MYSQLDATABASE || 'fleetdesk',
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

async function main() {
  loadDotEnvLocal();

  const fileArg = process.argv[2] || 'schema.sql';
  const filePath = path.isAbsolute(fileArg) ? fileArg : path.join(process.cwd(), fileArg);

  if (!fs.existsSync(filePath)) {
    console.error(`[migrate] SQL file not found: ${filePath}`);
    process.exit(1);
  }

  const config = getConnectionConfig();
  console.log(`[migrate] Connecting to ${config.host}:${config.port}/${config.database} as ${config.user}...`);

  const conn = await mysql.createConnection(config);

  try {
    if (!process.env.FORCE_MIGRATE) {
      const done = await alreadyMigrated(conn, config.database);
      if (done) {
        console.log('[migrate] Schema already present (vehicles table found) — skipping. Set FORCE_MIGRATE=1 to force a re-run.');
        return;
      }
    }

    console.log(`[migrate] Running ${filePath}...`);
    const sql = fs.readFileSync(filePath, 'utf8');
    await conn.query(sql);
    console.log('[migrate] Done.');
  } finally {
    await conn.end();
  }
}

main().catch((err) => {
  console.error('[migrate] Failed:', err.message);
  process.exit(1);
});
