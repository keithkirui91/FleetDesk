<?php
declare(strict_types=1);

define('APP_NAME', 'FleetDesk');
define('APP_VERSION', '2.0.0');

$scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
$host = $_SERVER['HTTP_HOST'] ?? 'localhost';
$scriptName = str_replace('\\', '/', $_SERVER['SCRIPT_NAME'] ?? '');
$requestPath = parse_url($_SERVER['REQUEST_URI'] ?? $scriptName, PHP_URL_PATH) ?: $scriptName;
$basePath = rtrim(str_replace('\\', '/', dirname($scriptName)), '/');
$basePath = preg_replace('#/(api)$#', '', $basePath) ?: '';
if ($basePath === '' && preg_match('#^(.+?)/(?:index|dashboard|fleet|drivers|mechanics|jobs|services|fuel|mileage|reports|vehicle|vehicles|driver-allocations|disposed-assets|battery-logs|tyre-logs|dip-readings)(?:\.php)?/?$#', $requestPath, $matches)) {
    $basePath = rtrim($matches[1], '/');
}
define('BASE_URL', $scheme . '://' . $host . $basePath);

define('DB_HOST', getenv('FLEETDESK_DB_HOST') ?: 'sql113.infinityfree.com');
define('DB_NAME', getenv('FLEETDESK_DB_NAME') ?: 'if0_38642919_fleetdeskb');
define('DB_USER', getenv('FLEETDESK_DB_USER') ?: 'if0_38642919');
define('DB_PASS', getenv('FLEETDESK_DB_PASS') ?: 'KimKeiChaR69');
define('DB_PORT', (int)(getenv('FLEETDESK_DB_PORT') ?: 3306));

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
