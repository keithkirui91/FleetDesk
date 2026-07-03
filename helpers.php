<?php
declare(strict_types=1);

function e($value): string
{
    return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
}

function redirect_to(string $path)
{
    header('Location: ' . BASE_URL . '/' . ltrim($path, '/'));
    exit;
}

function json_response(array $payload, int $status = 200)
{
    http_response_code($status);
    header('Content-Type: application/json');
    echo json_encode($payload, JSON_UNESCAPED_SLASHES);
    exit;
}

function json_success($data = null, array $extra = [])
{
    json_response(['success' => true, 'data' => $data] + $extra);
}

function json_error(string $message, int $status = 400)
{
    json_response(['success' => false, 'error' => $message], $status);
}

function request_json(): array
{
    $raw = file_get_contents('php://input') ?: '';
    if ($raw === '') {
        return $_POST;
    }

    $data = json_decode($raw, true);
    return is_array($data) ? $data : [];
}

function current_page(): string
{
    return basename($_SERVER['SCRIPT_NAME'] ?? '', '.php');
}

function current_odometer_sql(string $vehicleAlias = 'v'): string
{
    $vehicleId = $vehicleAlias . '.id';
    return "COALESCE((
        SELECT reading
        FROM (
            SELECT ol.vehicle_id, ol.odometer_reading AS reading, ol.logged_at AS reading_at, ol.id AS source_id
            FROM odometer_logs ol
            UNION ALL
            SELECT sr.vehicle_id, sr.odometer_at_service AS reading, sr.created_at AS reading_at, sr.id AS source_id
            FROM service_records sr
            WHERE sr.odometer_at_service IS NOT NULL
            UNION ALL
            SELECT fl.vehicle_id, fl.odometer_at_fill AS reading, fl.created_at AS reading_at, fl.id AS source_id
            FROM fuel_logs fl
        ) odometer_sources
        WHERE odometer_sources.vehicle_id = $vehicleId
        ORDER BY reading_at DESC, source_id DESC
        LIMIT 1
    ), 0)";
}

function fd_icon(string $name): string
{
    $icons = [
        'grid' => '<path d="M4 4h7v7H4zM13 4h7v7h-7zM4 13h7v7H4zM13 13h7v7h-7z"/>',
        'truck' => '<path d="M3 7h11v9H3z"/><path d="M14 10h4l3 3v3h-7z"/><circle cx="7" cy="18" r="2"/><circle cx="17" cy="18" r="2"/>',
        'tool' => '<path d="M14.7 6.3a4 4 0 0 0-5 5L4 17l3 3 5.7-5.7a4 4 0 0 0 5-5l-3 3-3-3z"/>',
        'calendar' => '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M16 3v4M8 3v4M3 11h18"/>',
        'droplet' => '<path d="M12 3s6 7 6 11a6 6 0 0 1-12 0c0-4 6-11 6-11z"/>',
        'users' => '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/>',
        'clock' => '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
        'bar-chart' => '<path d="M4 19V9M10 19V5M16 19v-7M22 19H2"/>',
        'plus' => '<path d="M12 5v14M5 12h14"/>',
        'search' => '<circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/>',
        'logout' => '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="M16 17l5-5-5-5M21 12H9"/>',
        'archive' => '<rect x="3" y="4" width="18" height="4" rx="1"/><path d="M5 8v12h14V8M10 12h4"/>',
    ];

    return '<svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' . ($icons[$name] ?? $icons['grid']) . '</svg>';
}
