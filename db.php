<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

function getDB(): mysqli
{
    static $db = null;

    if ($db instanceof mysqli) {
        return $db;
    }

    mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
    $db = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME, DB_PORT);
    $db->set_charset('utf8mb4');

    return $db;
}

function db_all(string $sql, string $types = '', array $params = []): array
{
    $db = getDB();
    if ($types === '') {
        return $db->query($sql)->fetch_all(MYSQLI_ASSOC);
    }

    $stmt = $db->prepare($sql);
    $stmt->bind_param($types, ...$params);
    $stmt->execute();
    return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
}

function db_one(string $sql, string $types = '', array $params = [])
{
    $rows = db_all($sql, $types, $params);
    return $rows[0] ?? null;
}

function db_value(string $sql, string $types = '', array $params = [])
{
    $row = db_one($sql, $types, $params);
    if (!$row) {
        return null;
    }
    return reset($row);
}
