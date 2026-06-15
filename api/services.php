<?php
require_once __DIR__ . '/common.php';

$fields = ['vehicle_id', 'mechanic_id', 'service_date', 'odometer_at_service', 'service_type', 'work_done', 'parts_replaced', 'next_service_date', 'next_service_mileage', 'notes'];
$action = $_GET['action'] ?? 'list';

try {
    if ($action === 'list') {
        json_success(db_all("
            SELECT sr.*, v.fleet_number, v.registration, v.make, v.model, m.full_name AS mechanic_name
            FROM service_records sr
            JOIN vehicles v ON v.id = sr.vehicle_id
            LEFT JOIN mechanics m ON m.id = sr.mechanic_id
            ORDER BY sr.service_date DESC, sr.id DESC
        "));
    }

    if ($action === 'get') {
        $id = (int)($_GET['id'] ?? 0);
        $row = db_one('SELECT * FROM service_records WHERE id = ?', 'i', [$id]);
        $row ? json_success($row) : json_error('Service record not found.', 404);
    }

    if ($action === 'create') {
        $input = request_json();
        foreach ($fields as $field) {
            if (empty($input[$field])) {
                json_error(str_replace('_', ' ', $field) . ' is required.');
            }
        }
        $id = insert_row('service_records', $fields, $input);
        log_vehicle_mileage((int)$input['vehicle_id'], (int)$input['odometer_at_service'], 'service', 'Service record #' . $id);
        json_success(['id' => $id]);
    }

    if ($action === 'update') {
        $input = request_json();
        $id = (int)($_GET['id'] ?? $input['id'] ?? 0);
        update_row('service_records', $fields, $id, $input);
        if (!empty($input['vehicle_id']) && !empty($input['odometer_at_service'])) {
            log_vehicle_mileage((int)$input['vehicle_id'], (int)$input['odometer_at_service'], 'service', 'Service update #' . $id);
        }
        json_success(['id' => $id]);
    }

    if ($action === 'delete') {
        $input = request_json();
        $id = (int)($_GET['id'] ?? $input['id'] ?? 0);
        delete_row('service_records', $id);
        json_success(['id' => $id]);
    }

    json_error('Unknown action.');
} catch (Throwable $e) {
    json_error($e->getMessage(), 500);
}
