<?php
require_once __DIR__ . '/common.php';

$action = $_GET['action'] ?? 'list';
$fields = ['vehicle_id', 'mechanic_id', 'job_type', 'fault_description', 'priority', 'part_availability', 'status', 'date_in', 'target_completion_date', 'date_closed', 'resolution_notes'];

function sync_vehicle_status_for_job(int $vehicleId, string $jobStatus): void
{
    if ($vehicleId <= 0) {
        return;
    }

    $vehicleStatus = 'active';
    if ($jobStatus === 'awaiting_parts') {
        $vehicleStatus = 'awaiting_parts';
    } elseif ($jobStatus !== 'closed') {
        $vehicleStatus = 'in_workshop';
    }

    $stmt = getDB()->prepare('UPDATE vehicles SET status = ? WHERE id = ?');
    $stmt->bind_param('si', $vehicleStatus, $vehicleId);
    $stmt->execute();
}

try {
    if ($action === 'list') {
        json_success(db_all("
            SELECT jc.*, v.fleet_number, v.registration, v.make, v.model,
                   m.full_name AS mechanic_name,
                   DATEDIFF(COALESCE(jc.date_closed, CURDATE()), jc.date_in) AS days_open,
                   CASE
                       WHEN jc.status <> 'closed'
                        AND jc.target_completion_date IS NOT NULL
                        AND jc.target_completion_date < CURDATE()
                       THEN 1 ELSE 0
                   END AS is_overdue
            FROM job_cards jc
            JOIN vehicles v ON v.id = jc.vehicle_id
            LEFT JOIN mechanics m ON m.id = jc.mechanic_id
            ORDER BY FIELD(jc.status, 'in_progress', 'awaiting_parts', 'closed', 'open', 'on_hold'),
                     is_overdue DESC,
                     jc.date_in DESC,
                     jc.id DESC
        "));
    }

    if ($action === 'get') {
        $id = (int)($_GET['id'] ?? 0);
        $row = db_one('SELECT * FROM job_cards WHERE id = ?', 'i', [$id]);
        $row ? json_success($row) : json_error('Job card not found.', 404);
    }

    if ($action === 'create') {
        $input = request_json();
        if (empty($input['vehicle_id']) || empty($input['fault_description']) || empty($input['part_availability'])) {
            json_error('Vehicle, fault description, and part availability are required.');
        }
        if (empty($input['date_in'])) {
            $input['date_in'] = date('Y-m-d');
        }

        $input['status'] = $input['part_availability'] === 'available' ? 'in_progress' : 'awaiting_parts';
        $input['job_reference'] = 'JC-' . date('Y') . '-' . str_pad((string)((int)db_value('SELECT COUNT(*) + 1 FROM job_cards')), 4, '0', STR_PAD_LEFT);
        $id = insert_row('job_cards', array_merge(['job_reference'], $fields), $input);
        sync_vehicle_status_for_job((int)$input['vehicle_id'], $input['status']);
        json_success(['id' => $id, 'reference' => $input['job_reference']]);
    }

if ($action === 'update') {
    $input = request_json();
    $id = (int)($_GET['id'] ?? $input['id'] ?? 0);

    if (!$id) {
        json_error('Missing job id.');
    }

    // Append a new note to the history
    if (!empty($input['new_note'])) {
        $existing = db_one(
            'SELECT resolution_notes FROM job_cards WHERE id = ?',
            'i',
            [$id]
        );

        $history = $existing['resolution_notes'] ?? '';

        $stamp = date('d/m/Y H:i');

$entry =
    '[' . $stamp . ']' .
    "\n" .
    trim($input['new_note']);

        $input['resolution_notes'] =
            $history
                ? $history . "\n\n\n" . $entry
                : $entry;
    }

    unset($input['new_note']);

    if (
        !empty($input['status']) &&
        $input['status'] === 'closed' &&
        empty($input['date_closed'])
    ) {
        $input['date_closed'] = date('Y-m-d');
    }

    update_row('job_cards', $fields, $id, $input);

    $job = db_one(
        'SELECT vehicle_id, status FROM job_cards WHERE id = ?',
        'i',
        [$id]
    );

    if ($job) {
        sync_vehicle_status_for_job(
            (int)$job['vehicle_id'],
            $job['status']
        );
    }

    json_success(['id' => $id]);
}

    if ($action === 'delete') {
        $input = request_json();
        $id = (int)($_GET['id'] ?? $input['id'] ?? 0);
        delete_row('job_cards', $id);
        json_success(['id' => $id]);
    }

    json_error('Unknown action.');
} catch (Throwable $e) {
    json_error($e->getMessage(), 500);
}
