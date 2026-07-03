<?php
require_once __DIR__ . '/common.php';

$action = $_GET['action'] ?? 'list';
$db     = getDB();

try {
    if ($action === 'list') {
        json_success(db_all(
            "SELECT * FROM fuel_depot_readings ORDER BY reading_date DESC, id DESC"
        ));
    }

    if ($action === 'latest') {
        $rows = db_all("
            SELECT fuel_type, dip_litres, reading_date, transaction_type
            FROM fuel_depot_readings fdr1
            WHERE id = (
                SELECT id FROM fuel_depot_readings fdr2
                WHERE fdr2.fuel_type = fdr1.fuel_type
                ORDER BY reading_date DESC, id DESC LIMIT 1
            )
        ");
        json_success($rows);
    }

    if ($action === 'create') {
        $input = request_json();
        // Stock received — add to current balance
        if (($input['transaction_type'] ?? '') === 'stock_received') {
            $fuelType = $db->real_escape_string($input['fuel_type'] ?? 'diesel');
            $received = (float)($input['quantity_litres'] ?? $input['dip_litres'] ?? 0);
            if (!$received) json_error('quantity_litres is required for stock received.');

            $latest = $db->query("
                SELECT dip_litres FROM fuel_depot_readings
                WHERE fuel_type = '$fuelType'
                ORDER BY reading_date DESC, id DESC LIMIT 1
            ")->fetch_assoc();
            $current    = $latest ? (float)$latest['dip_litres'] : 0;
            $newBalance = $current + $received;
            $input['dip_litres'] = $newBalance;
        }
        $fields = ['reading_date','fuel_type','dip_litres','transaction_type','quantity_litres','notes','recorded_by'];
        $id = insert_row('fuel_depot_readings', $fields, $input);
        json_success(['id' => $id, 'new_balance' => $input['dip_litres'] ?? null]);
    }

    if ($action === 'delete') {
        $input = request_json();
        $id    = (int)($_GET['id'] ?? $input['id'] ?? 0);
        if (!$id) json_error('Missing id.');
        delete_row('fuel_depot_readings', $id);
        json_success(['id' => $id]);
    }

    json_error('Unknown action.');
} catch (Throwable $e) {
    json_error($e->getMessage(), 500);
}
