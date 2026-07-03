<?php
require_once __DIR__ . '/common.php';

$action = $_GET['action'] ?? 'list';

try {
    if ($action === 'list') {
        json_success(db_all("
            SELECT *
            FROM asset_disposal_logs
            ORDER BY logged_at DESC, id DESC
        "));
    }

    if ($action === 'get') {
        $id = (int)($_GET['id'] ?? 0);
        $row = db_one('SELECT * FROM asset_disposal_logs WHERE id = ?', 'i', [$id]);
        $row ? json_success($row) : json_error('Asset log not found.', 404);
    }

    if ($action === 'delete') {
        $input = request_json();
        $id = (int)($_GET['id'] ?? $input['id'] ?? 0);
        if (!$id) {
            json_error('Missing asset log id.');
        }
        delete_row('asset_disposal_logs', $id);
        json_success(['id' => $id]);
    }

    json_error('Asset logs are created automatically from fleet actions.');
} catch (Throwable $e) {
    json_error($e->getMessage(), 500);
}
