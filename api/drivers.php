<?php
require_once __DIR__ . '/common.php';

$action = $_GET['action'] ?? 'list';
$fields = ['full_name', 'department', 'dl_number', 'licence_type', 'licence_renewal_date', 'licence_expiry_date', 'photo_url', 'comments', 'is_active'];

try {
    if ($action === 'list') {
        json_success(db_all("
            SELECT d.*, COUNT(vda.id) AS active_allocations
            FROM drivers d
            LEFT JOIN vehicle_driver_assignments vda ON vda.driver_id = d.id AND vda.is_active = 1
            GROUP BY d.id
            ORDER BY d.full_name
        "));
    }

    if ($action === 'get') {
        $id = (int)($_GET['id'] ?? 0);
        $row = db_one('SELECT * FROM drivers WHERE id = ?', 'i', [$id]);
        $row ? json_success($row) : json_error('Driver not found.', 404);
    }

    if ($action === 'create') {
        $input = request_json();
        foreach (['full_name', 'department'] as $required) {
            if (empty($input[$required])) {
                json_error(str_replace('_', ' ', $required) . ' is required.');
            }
        }
        if (empty($input['is_active'])) {
            $input['is_active'] = 1;
        }
        $id = insert_row('drivers', $fields, $input);
        json_success(['id' => $id]);
    }

    if ($action === 'update') {
        $input = request_json();
        $id = (int)($_GET['id'] ?? $input['id'] ?? 0);
        if (!$id) {
            json_error('Missing driver id.');
        }
        update_row('drivers', $fields, $id, $input);
        json_success(['id' => $id]);
    }

    if ($action === 'delete') {
        $input = request_json();
        $id = (int)($_GET['id'] ?? $input['id'] ?? 0);
        if (!$id) {
            json_error('Missing driver id.');
        }
        delete_row('drivers', $id);
        json_success(['id' => $id]);
    }

    json_error('Unknown action.');
} catch (Throwable $e) {
    json_error($e->getMessage(), 500);
}
