
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
  const schemaPath = path.join(repoRoot, 'schemab.sql');
  if (fs.existsSync(schemaPath)) {
    if (await isApplied(conn, 'schemab.sql')) {
      console.log('[migrate] schemab.sql already applied — skipping.');
    } else {
      await runFile(conn, schemaPath, 'schemab.sql');
      await markApplied(conn, 'schemab.sql');
    }
  }

  // Seed data — runs once, right after the base schema and before any
  // incremental migrations, since later migrations may assume the seeded
  // rows (vehicles, drivers, etc.) already exist.
  const seedPath = path.join(repoRoot, 'seed_data.sql');
  if (fs.existsSync(seedPath)) {
    if (await isApplied(conn, 'seed_data.sql')) {
      console.log('[migrate] seed_data.sql already applied — skipping.');
    } else {
      await runFile(conn, seedPath, 'seed_data.sql');
      await markApplied(conn, 'seed_data.sql');
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
