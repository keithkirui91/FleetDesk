<?php
require_once __DIR__ . '/common.php';

$action = $_GET['action'] ?? 'list';
$fields = [
    'fleet_number', 'registration', 'make', 'model', 'year', 'colour',
    'fuel_type', 'body_type', 'vehicle_type', 'department', 'vin_chassis',
    'engine_size', 'transmission', 'drive_type', 'seating_capacity',
    'payload_capacity_kg', 'tyre_size_standard', 'insurance_expiry',
    'licence_expiry', 'last_service_date', 'next_service_date',
    'next_service_mileage', 'status', 'notes'
];

try {
    if ($action === 'list') {
        json_success(db_all("
            SELECT v.*,
                   COALESCE((SELECT odometer_reading FROM odometer_logs ol WHERE ol.vehicle_id = v.id ORDER BY logged_at DESC, id DESC LIMIT 1), 0) AS current_odometer,
                   (SELECT COUNT(*) FROM job_cards jc WHERE jc.vehicle_id = v.id AND jc.status <> 'closed') AS open_jobs
            FROM vehicles v
            ORDER BY v.fleet_number
        "));
    }

    if ($action === 'get') {
        $id = (int)($_GET['id'] ?? 0);
        $vehicle = db_one('SELECT * FROM vehicles WHERE id = ?', 'i', [$id]);
        if (!$vehicle) {
            json_error('Vehicle not found.', 404);
        }
        $vehicle['current_odometer'] = db_value('SELECT odometer_reading FROM odometer_logs WHERE vehicle_id = ? ORDER BY logged_at DESC, id DESC LIMIT 1', 'i', [$id]);
        json_success($vehicle);
    }

    if ($action === 'create') {
        $input = request_json();
        foreach (['fleet_number', 'registration', 'make', 'model'] as $required) {
            if (empty($input[$required])) {
                json_error("$required is required.");
            }
        }

        $db = getDB();
        $db->begin_transaction();
        $id = insert_row('vehicles', $fields, $input);
        if (!empty($input['odometer_current'])) {
            $stmt = $db->prepare('INSERT INTO odometer_logs (vehicle_id, odometer_reading, location, notes) VALUES (?, ?, "workshop", "Opening odometer")');
            $odo = (int)$input['odometer_current'];
            $stmt->bind_param('ii', $id, $odo);
            $stmt->execute();
        }
        $db->commit();
        json_success(['id' => $id]);
    }

    if ($action === 'update') {
        $input = request_json();
        $id = (int)($_GET['id'] ?? $input['id'] ?? 0);
        if (!$id) {
            json_error('Missing vehicle id.');
        }
        update_row('vehicles', $fields, $id, $input);
        if (!empty($input['odometer_current'])) {
            $stmt = getDB()->prepare('INSERT INTO odometer_logs (vehicle_id, odometer_reading, location, notes) VALUES (?, ?, "workshop", "Manual odometer update")');
            $odo = (int)$input['odometer_current'];
            $stmt->bind_param('ii', $id, $odo);
            $stmt->execute();
        }
        json_success(['id' => $id]);
    }

    if ($action === 'delete') {
        $input = request_json();
        $id = (int)($_GET['id'] ?? $input['id'] ?? 0);
        if (!$id) {
            json_error('Missing vehicle id.');
        }
        delete_row('vehicles', $id);
        json_success(['id' => $id]);
    }

    json_error('Unknown action.');
} catch (Throwable $e) {
    if (isset($db) && $db instanceof mysqli) {
        $db->rollback();
    }
    json_error($e->getMessage(), 500);
}
