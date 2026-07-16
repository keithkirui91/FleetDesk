// scripts/migrate.js
//
// Two modes:
//
// 1) AUTOMATIC MODE (no arguments) — this is what runs on every deploy via
//    the "prestart" hook in package.json. It's fully self-tracking:
//      - Creates a `schema_migrations` table if it doesn't exist.
//      - Runs schema.sql if it hasn't been applied yet (safe to run even on
//        a database that already has tables from elsewhere — every CREATE
//        TABLE in schema.sql uses IF NOT EXISTS, so it only fills in
//        anything missing and never touches existing tables).
//      - Runs any new files in migrations/*.sql, in filename order, that
//        haven't been recorded yet.
//      - Records each one as it succeeds, so re-running (e.g. next deploy)
//        skips everything already applied — nothing gets re-run or
//        duplicated automatically.
//
//    To add a schema change in the future: drop a new numbered .sql file in
//    migrations/ (e.g. 003_something.sql) and it'll be picked up on the
//    next deploy automatically. No CLI step required.
//
// 2) EXPLICIT FILE MODE (node scripts/migrate.js path/to/file.sql) — for
//    one-off manual actions like importing a full data dump. This always
//    just runs the file directly; it is NOT tracked in schema_migrations
//    and is never run automatically. Use this once, by hand, when you want
//    to load a specific export.
//
// Usage:
//   node scripts/migrate.js                     -> automatic mode
//   node scripts/migrate.js FDExport.sql         -> run one specific file
//   node scripts/migrate.js path/to/dump.sql

const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');

// Locally, Next.js auto-loads .env.local for the app, but a plain Node
// script invoked via npm does not. Load it here (only if present) so this
// behaves the same locally as it does on Railway (where env vars are
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

async function ensureMigrationsTable(conn) {
  await conn.query(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      id INT AUTO_INCREMENT PRIMARY KEY,
      filename VARCHAR(255) NOT NULL UNIQUE,
      applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB
  `);
}

async function isApplied(conn, filename) {
  const [rows] = await conn.query('SELECT 1 FROM schema_migrations WHERE filename = ?', [filename]);
  return rows.length > 0;
}

async function markApplied(conn, filename) {
  await conn.query('INSERT INTO schema_migrations (filename) VALUES (?)', [filename]);
}

async function runFile(conn, filePath, label) {
  console.log(`[migrate] Running ${label}...`);
  const sql = fs.readFileSync(filePath, 'utf8');
  await conn.query(sql);
  console.log(`[migrate] ${label} applied.`);
}

async function runAutomatic(conn, repoRoot) {
  await ensureMigrationsTable(conn);

  // Base schema
  const schemaPath = path.join(repoRoot, 'schema.sql');
  if (fs.existsSync(schemaPath)) {
    if (await isApplied(conn, 'schema.sql')) {
      console.log('[migrate] schema.sql already applied — skipping.');
    } else {
      await runFile(conn, schemaPath, 'schema.sql');
      await markApplied(conn, 'schema.sql');
    }
  }

  // Incremental migrations, in filename order
  const migrationsDir = path.join(repoRoot, 'migrations');
  if (fs.existsSync(migrationsDir)) {
    const files = fs.readdirSync(migrationsDir).filter((f) => f.endsWith('.sql')).sort();
    for (const file of files) {
      if (await isApplied(conn, file)) {
        console.log(`[migrate] ${file} already applied — skipping.`);
        continue;
      }
      await runFile(conn, path.join(migrationsDir, file), file);
      await markApplied(conn, file);
    }
  }
}

async function runExplicitFile(conn, fileArg, repoRoot) {
  const filePath = path.isAbsolute(fileArg) ? fileArg : path.join(repoRoot, fileArg);
  if (!fs.existsSync(filePath)) {
    throw new Error(`SQL file not found: ${filePath}`);
  }
  await runFile(conn, filePath, fileArg);
}

async function main() {
  loadDotEnvLocal();

  const repoRoot = process.cwd();
  const fileArg = process.argv[2];

  const config = getConnectionConfig();
  console.log(`[migrate] Connecting to ${config.host}:${config.port}/${config.database} as ${config.user}...`);
  const conn = await mysql.createConnection(config);

  try {
    if (fileArg) {
      await runExplicitFile(conn, fileArg, repoRoot);
    } else {
      await runAutomatic(conn, repoRoot);
    }
    console.log('[migrate] Done.');
  } finally {
    await conn.end();
  }
}

main().catch((err) => {
  console.error('[migrate] Failed:', err.message);
  process.exit(1);
});
