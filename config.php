<?php
declare(strict_types=1);

define('APP_NAME', 'FleetDesk');
define('APP_VERSION', '2.0.0');

$scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
$host = $_SERVER['HTTP_HOST'] ?? 'localhost';
$basePath = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');
$basePath = preg_replace('#/(api)$#', '', $basePath) ?: '';
define('BASE_URL', $scheme . '://' . $host . $basePath);

// PostgreSQL / Neon connection
// Set env var FLEETDESK_DB_URL, or fall back to the DSN parts below.
define('DB_URL', getenv('FLEETDESK_DB_URL') ?: '');

// Individual parts — used only when DB_URL is empty
define('DB_HOST', getenv('FLEETDESK_DB_HOST') ?: 'ep-quiet-poetry-ao2dbn2x-pooler.c-2.ap-southeast-1.aws.neon.tech');
define('DB_NAME', getenv('FLEETDESK_DB_NAME') ?: 'neondb');
define('DB_USER', getenv('FLEETDESK_DB_USER') ?: 'neondb_owner');
define('DB_PASS', getenv('FLEETDESK_DB_PASS') ?: '');
define('DB_PORT', (int)(getenv('FLEETDESK_DB_PORT') ?: 5432));

define('SESSION_TIMEOUT', 28800);

define('JOB_STATUS_COLOURS', [
    'open'           => '#ef4444',
    'in_progress'    => '#f59e0b',
    'awaiting_parts' => '#8b5cf6',
    'on_hold'        => '#64748b',
    'closed'         => '#16a34a',
]);

define('JOB_PRIORITY_COLOURS', [
    'critical' => '#dc2626',
    'high'     => '#ea580c',
    'normal'   => '#2563eb',
    'low'      => '#64748b',
]);
