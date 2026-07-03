<?php
declare(strict_types=1);

define('APP_NAME', 'FleetDesk');
define('APP_VERSION', '2.0.0');

// Simplified BASE_URL calculation for Railway
$scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
$host = $_SERVER['HTTP_HOST'] ?? 'localhost';
define('BASE_URL', $scheme . '://' . $host);

// Use Railway MySQL environment variables if available, otherwise fall back to external DB
define('DB_HOST', getenv('MYSQLHOST') ?: 'mysql.railway.internal');
define('DB_NAME', getenv('MYSQLDATABASE') ?: 'railway');
define('DB_USER', getenv('MYSQLUSER') ?: 'root');
define('DB_PASS', getenv('MYSQLPASSWORD') ?: 'WAJpXYscYXMPOSQoRThOSeLpKMYxFmEl');
define('DB_PORT', (int)(getenv('MYSQLPORT') ?: 3306));

define('SESSION_TIMEOUT', 28800);

define('JOB_STATUS_COLOURS', [
    'open' => '#ef4444',
    'in_progress' => '#f59e0b',
    'awaiting_parts' => '#8b5cf6',
    'on_hold' => '#64748b',
    'closed' => '#16a34a',
]);

define('JOB_PRIORITY_COLOURS', [
    'critical' => '#dc2626',
    'high' => '#ea580c',
    'normal' => '#2563eb',
    'low' => '#64748b',
]);

