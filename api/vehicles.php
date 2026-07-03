<?php
require_once __DIR__ . '/common.php';

$action = $_GET['action'] ?? 'list';
$fields = [
    'fleet_number','registration','make','model','year','date_acquired',
    'new_gen_plates','colour','fuel_type','body_type','vehicle_type','fleet_type',
    'department','vin_chassis','engine_number','engine_size','engine_capacity','transmission',
    'drive_type','seating_capacity','payload_capacity_kg','tare_weight_kg',
    'gross_weight_kg','tyre_size_standard','logbook_status','odometer_status',
    'inspection_status','insurance_expiry','licence_expiry',
    'last_service_date','next_service_date','next_service_mileage',
    'primary_image_url','status','notes'
];

function vehicle_snapshot(int $id)
{
    $currentOdometer = current_odometer_sql('v');
    return db_one("
        SELECT v.*, $currentOdometer AS current_odometer
        FROM vehicles v
        WHERE v.id = ?
    ", 'i', [$id]);
}

function log_asset_action(array $vehicle, string $action, string $reason = ''): void
{
    $db = getDB();
    $snapshot = json_encode($vehicle, JSON_UNESCAPED_SLASHES);
    $stmt = $db->prepare("
        INSERT INTO asset_disposal_logs
            (vehicle_id, action_type, fleet_number, registration, make, model, department, current_odometer, reason, snapshot)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    $vehicleId = (int)$vehicle['id'];
    $currentOdometer = (int)($vehicle['current_odometer'] ?? 0);
    $fleetNumber = (string)$vehicle['fleet_number'];
    $registration = (string)$vehicle['registration'];
    $make = (string)$vehicle['make'];
    $model = (string)$vehicle['model'];
    $department = (string)($vehicle['department'] ?? '');
    $stmt->bind_param(
        'issssssiss',
        $vehicleId,
        $action,
        $fleetNumber,
        $registration,
        $make,
        $model,
        $department,
        $currentOdometer,
        $reason,
        $snapshot
    );
    $stmt->execute();
}

try {
    if ($action === 'list') {
        $currentOdometer = current_odometer_sql('v');
        json_success(db_all("
            SELECT v.*,
                   $currentOdometer AS current_odometer,
                   (SELECT COUNT(*) FROM job_cards jc WHERE jc.vehicle_id = v.id AND jc.status <> 'closed') AS open_jobs
            FROM vehicles v
            ORDER BY v.fleet_number
        "));
    }

    if ($action === 'get') {
        $id = (int)($_GET['id'] ?? 0);
        $vehicle = vehicle_snapshot($id);
        if (!$vehicle) {
            json_error('Vehicle not found.', 404);
        }
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
        $vehicle = vehicle_snapshot($id);
        if (!$vehicle) {
            json_error('Vehicle not found.', 404);
        }
        $db = getDB();
        $db->begin_transaction();
        log_asset_action($vehicle, 'deleted', $input['reason'] ?? 'Deleted from fleet modal');
        delete_row('vehicles', $id);
        $db->commit();
        json_success(['id' => $id]);
    }

    if ($action === 'dispose') {
        $input = request_json();
        $id = (int)($_GET['id'] ?? $input['id'] ?? 0);
        if (!$id) {
            json_error('Missing vehicle id.');
        }
        $vehicle = vehicle_snapshot($id);
        if (!$vehicle) {
            json_error('Vehicle not found.', 404);
        }
        $db = getDB();
        $db->begin_transaction();
        log_asset_action($vehicle, 'disposed', $input['reason'] ?? 'Disposed from fleet modal');
        $stmt = $db->prepare("UPDATE vehicles SET status = 'decommissioned', notes = CONCAT(COALESCE(notes, ''), ?) WHERE id = ?");
        $note = "\nDisposed on " . date('Y-m-d') . ".";
        $stmt->bind_param('si', $note, $id);
        $stmt->execute();
        $stmt = $db->prepare("UPDATE vehicle_driver_assignments SET is_active = 0, end_date = COALESCE(end_date, CURDATE()) WHERE vehicle_id = ? AND is_active = 1");
        $stmt->bind_param('i', $id);
        $stmt->execute();
        $db->commit();
        json_success(['id' => $id]);
    }

    json_error('Unknown action.');
} catch (Throwable $e) {
    if (isset($db) && $db instanceof mysqli) {
        $db->rollback();
    }
    if (stripos($e->getMessage(), 'Duplicate entry') !== false && stripos($e->getMessage(), 'registration') !== false) {
        json_error('A vehicle with this registration number already exists. Registration numbers must be unique — fleet numbers can repeat.', 409);
    }
    json_error($e->getMessage(), 500);
}
