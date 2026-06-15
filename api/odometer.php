<?php
require_once __DIR__ . '/common.php';

$action = $_GET['action'] ?? 'list';
$fields = ['vehicle_id', 'odometer_reading', 'location', 'notes', 'logged_at'];

try {
    if ($action === 'list') {
        json_success(db_all("
            SELECT ol.*, v.fleet_number, v.registration, v.make, v.model
            FROM odometer_logs ol
            JOIN vehicles v ON v.id = ol.vehicle_id
            ORDER BY ol.logged_at DESC, ol.id DESC
        "));
    }

    if ($action === 'get') {
        $id = (int)($_GET['id'] ?? 0);
        $row = db_one('SELECT * FROM odometer_logs WHERE id = ?', 'i', [$id]);
        $row ? json_success($row) : json_error('Mileage log not found.', 404);
    }

    if ($action === 'create') {
        $input = request_json();
        if (empty($input['vehicle_id']) || empty($input['odometer_reading']) || empty($input['location'])) {
            json_error('Vehicle, mileage, and movement/location are required.');
        }
        $id = insert_row('odometer_logs', $fields, $input);
        json_success(['id' => $id]);
    }

    if ($action === 'delete') {
        if (empty($_SESSION['admin_id'])) {
            json_error('Only admins can delete mileage logs.', 403);
        }
        $input = request_json();
        $id = (int)($_GET['id'] ?? $input['id'] ?? 0);
        delete_row('odometer_logs', $id);
        json_success(['id' => $id]);
    }

    json_error('Unknown action.');
} catch (Throwable $e) {
    json_error($e->getMessage(), 500);
}
