<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

function getDB(): PDO
{
    static $db = null;

    if ($db instanceof PDO) {
        return $db;
    }

    // Build DSN — prefer a full URL if provided, otherwise use individual constants
    if (DB_URL !== '') {
        $parts = parse_url(DB_URL);
        $dsn = sprintf(
            'pgsql:host=%s;port=%d;dbname=%s;sslmode=require',
            $parts['host'],
            $parts['port'] ?? 5432,
            ltrim($parts['path'] ?? '/neondb', '/')
        );
        $user = $parts['user'] ?? DB_USER;
        $pass = $parts['pass'] ?? DB_PASS;
    } else {
        $dsn  = sprintf('pgsql:host=%s;port=%d;dbname=%s;sslmode=require', DB_HOST, DB_PORT, DB_NAME);
        $user = DB_USER;
        $pass = DB_PASS;
    }

    $db = new PDO($dsn, $user, $pass, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,   // use real prepared statements
    ]);

    return $db;
}

/**
 * Return all rows as an associative array.
 *
 * Usage (positional):  db_all('SELECT * FROM vehicles WHERE status = ?', ['active'])
 * Usage (named):       db_all('SELECT * FROM vehicles WHERE status = :s', [':s' => 'active'])
 * Usage (no params):   db_all('SELECT * FROM vehicles')
 */
function db_all(string $sql, array $params = []): array
{
    $stmt = getDB()->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetchAll();
}

/**
 * Return the first row, or null.
 */
function db_one(string $sql, array $params = []): ?array
{
    $rows = db_all($sql, $params);
    return $rows[0] ?? null;
}

/**
 * Return a single scalar value from the first column of the first row, or null.
 */
function db_value(string $sql, array $params = []): mixed
{
    $row = db_one($sql, $params);
    return $row ? reset($row) : null;
}

/**
 * Run an INSERT / UPDATE / DELETE and return the number of affected rows.
 */
function db_execute(string $sql, array $params = []): int
{
    $stmt = getDB()->prepare($sql);
    $stmt->execute($params);
    return $stmt->rowCount();
}

/**
 * INSERT a row and return the new ID.
 * PostgreSQL requires RETURNING id in the query — add it if missing.
 */
function db_insert(string $sql, array $params = []): string|false
{
    if (!str_contains(strtoupper($sql), 'RETURNING')) {
        $sql = rtrim($sql, '; ') . ' RETURNING id';
    }
    $stmt = getDB()->prepare($sql);
    $stmt->execute($params);
    $row = $stmt->fetch();
    return $row['id'] ?? false;
}
