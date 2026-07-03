<?php
require_once __DIR__ . '/common.php';

$action = $_GET['action'] ?? 'list';
$fields = ['vehicle_id','log_date','odometer_at_fill','litres_filled','fuel_type',
           'station_location','cost_per_litre','total_cost',
           'issuer_name','receiver_name','notes'];

// Depot locations — fuel drawn from dip balance
const DEPOT_LOCATIONS = ['Kamok Depot', 'Control Depot'];

function deductFromDepot(string $fuelType, float $litres, string $date, string $location): void
{
    $db = getDB();
    // Get current balance (latest dip reading)
    $latest = $db->query("
        SELECT dip_litres FROM fuel_depot_readings
        WHERE fuel_type = '" . $db->real_escape_string($fuelType) . "'
        ORDER BY reading_date DESC, id DESC LIMIT 1
    ")->fetch_assoc();

    $current = $latest ? (float)$latest['dip_litres'] : 0;
    $newBalance = max(0, $current - $litres);

    $stmt = $db->prepare("
        INSERT INTO fuel_depot_readings
            (reading_date, fuel_type, dip_litres, transaction_type, quantity_litres, notes, recorded_by)
        VALUES (?, ?, ?, 'fuel_dispensed', ?, ?, 'System — auto deduction')
    ");
    $note = "Auto-deducted {$litres}L for fuel log from {$location}";
    $stmt->bind_param('ssdds', $date, $fuelType, $newBalance, $litres, $note);
    $stmt->execute();
}

try {
    if ($action === 'list') {
        json_success(db_all("
            SELECT fl.*, v.fleet_number, v.registration, v.make, v.model
            FROM fuel_logs fl
            JOIN vehicles v ON v.id = fl.vehicle_id
            ORDER BY fl.log_date DESC, fl.id DESC
        "));
    }

    if ($action === 'get') {
        $id  = (int)($_GET['id'] ?? 0);
        $row = db_one('SELECT * FROM fuel_logs WHERE id = ?', 'i', [$id]);
        $row ? json_success($row) : json_error('Fuel log not found.', 404);
    }

    if ($action === 'create') {
        $input = request_json();
        foreach (['vehicle_id','log_date','odometer_at_fill','litres_filled','fuel_type','station_location'] as $f) {
            if (empty($input[$f])) json_error(str_replace('_',' ',$f) . ' is required.');
        }
        $id = insert_row('fuel_logs', $fields, $input);
        log_vehicle_mileage((int)$input['vehicle_id'], (int)$input['odometer_at_fill'], 'fuel', 'Fuel log #'.$id);

        // Deduct from depot if internal location
        if (in_array($input['station_location'], DEPOT_LOCATIONS)) {
            deductFromDepot(
                $input['fuel_type'],
                (float)$input['litres_filled'],
                $input['log_date'],
                $input['station_location']
            );
        }
        json_success(['id' => $id]);
    }

    if ($action === 'update') {
        $input = request_json();
        $id    = (int)($_GET['id'] ?? $input['id'] ?? 0);
        update_row('fuel_logs', $fields, $id, $input);
        if (!empty($input['vehicle_id']) && !empty($input['odometer_at_fill'])) {
            log_vehicle_mileage((int)$input['vehicle_id'], (int)$input['odometer_at_fill'], 'fuel', 'Fuel update #'.$id);
        }
        json_success(['id' => $id]);
    }

    if ($action === 'delete') {
        $input = request_json();
        $id    = (int)($_GET['id'] ?? $input['id'] ?? 0);
        delete_row('fuel_logs', $id);
        json_success(['id' => $id]);
    }

    json_error('Unknown action.');
} catch (Throwable $e) {
    json_error($e->getMessage(), 500);
}
