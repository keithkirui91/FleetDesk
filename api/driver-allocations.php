<?php
require_once __DIR__ . '/common.php';

$action = $_GET['action'] ?? 'list';
$fields = ['vehicle_id', 'driver_id', 'role', 'start_date', 'end_date', 'is_active', 'notes'];

try {
    if ($action === 'list') {
        json_success(db_all("
            SELECT vda.*, v.fleet_number, v.registration, d.full_name AS driver_name, d.department
            FROM vehicle_driver_assignments vda
            JOIN vehicles v ON v.id = vda.vehicle_id
            JOIN drivers d ON d.id = vda.driver_id
            ORDER BY v.fleet_number, vda.is_active DESC, FIELD(vda.role, 'primary', 'reliever'), vda.start_date DESC, vda.id DESC
        "));
    }

    if ($action === 'get') {
        $id = (int)($_GET['id'] ?? 0);
        $row = db_one('SELECT * FROM vehicle_driver_assignments WHERE id = ?', 'i', [$id]);
        $row ? json_success($row) : json_error('Driver allocation not found.', 404);
    }

    if ($action === 'create') {
        $input = request_json();
        foreach (['vehicle_id', 'driver_id', 'role', 'start_date'] as $required) {
            if (empty($input[$required])) {
                json_error(str_replace('_', ' ', $required) . ' is required.');
            }
        }

        if (!in_array($input['role'], ['primary', 'reliever'], true)) {
            json_error('Role must be primary or reliever.');
        }

        $vehicle = db_one("SELECT status FROM vehicles WHERE id = ? AND status <> 'decommissioned'", 'i', [(int)$input['vehicle_id']]);
        if (!$vehicle) {
            json_error('Vehicle is not available for driver allocation.');
        }

        $driver = db_one("SELECT id FROM drivers WHERE id = ? AND is_active = 1", 'i', [(int)$input['driver_id']]);
        if (!$driver) {
            json_error('Driver is not active.');
        }

        $db = getDB();
        $db->begin_transaction();

        if ($input['role'] === 'primary') {
            $endDate = date('Y-m-d', strtotime($input['start_date'] . ' -1 day'));
            $stmt = $db->prepare("
                UPDATE vehicle_driver_assignments
                SET is_active = 0, end_date = COALESCE(end_date, ?)
                WHERE vehicle_id = ? AND role = 'primary' AND is_active = 1
            ");
            $vehicleId = (int)$input['vehicle_id'];
            $stmt->bind_param('si', $endDate, $vehicleId);
            $stmt->execute();
        }

        if (empty($input['is_active'])) {
            $input['is_active'] = 1;
        }

        $id = insert_row('vehicle_driver_assignments', $fields, $input);
        $db->commit();
        json_success(['id' => $id]);
    }

    if ($action === 'update') {
        $input = request_json();
        $id = (int)($_GET['id'] ?? $input['id'] ?? 0);
        if (!$id) {
            json_error('Missing allocation id.');
        }
        update_row('vehicle_driver_assignments', $fields, $id, $input);
        json_success(['id' => $id]);
    }

    if ($action === 'delete') {
        $input = request_json();
        $id = (int)($_GET['id'] ?? $input['id'] ?? 0);
        if (!$id) {
            json_error('Missing allocation id.');
        }
        delete_row('vehicle_driver_assignments', $id);
        json_success(['id' => $id]);
    }

    json_error('Unknown action.');
} catch (Throwable $e) {
    if (isset($db) && $db instanceof mysqli) {
        $db->rollback();
    }
    json_error($e->getMessage(), 500);
}
