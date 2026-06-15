<?php
declare(strict_types=1);

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../helpers.php';

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (empty($_SESSION['admin_id']) && empty($_SESSION['data_entry'])) {
    json_error('Authentication required.', 401);
}

if (!empty($_SESSION['data_entry']) && basename($_SERVER['SCRIPT_NAME']) !== 'odometer.php') {
    json_error('Data entry users can only log mileage.', 403);
}

function clean_nullable($value)
{
    return $value === '' ? null : $value;
}

function insert_row(string $table, array $fields, array $input): int
{
    $db = getDB();
    $columns = [];
    $values = [];
    foreach ($fields as $field) {
        if (array_key_exists($field, $input)) {
            $columns[] = $field;
            $values[] = clean_nullable($input[$field]);
        }
    }

    if (!$columns) {
        json_error('No fields supplied.');
    }

    $sql = 'INSERT INTO ' . $table . ' (' . implode(',', $columns) . ') VALUES (' . implode(',', array_fill(0, count($columns), '?')) . ')';
    $stmt = $db->prepare($sql);
    $types = str_repeat('s', count($values));
    $stmt->bind_param($types, ...$values);
    $stmt->execute();
    return (int)$db->insert_id;
}

function update_row(string $table, array $fields, int $id, array $input): void
{
    $db = getDB();
    $sets = [];
    $values = [];
    foreach ($fields as $field) {
        if (array_key_exists($field, $input)) {
            $sets[] = $field . ' = ?';
            $values[] = clean_nullable($input[$field]);
        }
    }

    if (!$sets) {
        json_error('No fields supplied.');
    }

    $values[] = $id;
    $sql = 'UPDATE ' . $table . ' SET ' . implode(',', $sets) . ' WHERE id = ?';
    $stmt = $db->prepare($sql);
    $types = str_repeat('s', count($values) - 1) . 'i';
    $stmt->bind_param($types, ...$values);
    $stmt->execute();
}

function delete_row(string $table, int $id): void
{
    $db = getDB();
    $stmt = $db->prepare('DELETE FROM ' . $table . ' WHERE id = ?');
    $stmt->bind_param('i', $id);
    $stmt->execute();
}

function log_vehicle_mileage(int $vehicleId, int $reading, string $location, string $notes = ''): void
{
    if ($vehicleId <= 0 || $reading <= 0) {
        return;
    }

    $db = getDB();
    $stmt = $db->prepare('INSERT INTO odometer_logs (vehicle_id, odometer_reading, location, notes) VALUES (?, ?, ?, ?)');
    $stmt->bind_param('iiss', $vehicleId, $reading, $location, $notes);
    $stmt->execute();
}

function route_simple_module(string $table, array $fields, string $listSql): void
{
    $action = $_GET['action'] ?? 'list';
    $input = request_json();

    try {
        if ($action === 'list') {
            json_success(db_all($listSql));
        }

        if ($action === 'get') {
            $id = (int)($_GET['id'] ?? 0);
            $row = db_one("SELECT * FROM $table WHERE id = ?", 'i', [$id]);
            $row ? json_success($row) : json_error('Record not found.', 404);
        }

        if ($action === 'create') {
            $id = insert_row($table, $fields, $input);
            json_success(['id' => $id]);
        }

        if ($action === 'update') {
            $id = (int)($_GET['id'] ?? $input['id'] ?? 0);
            if (!$id) {
                json_error('Missing record id.');
            }
            update_row($table, $fields, $id, $input);
            json_success(['id' => $id]);
        }

        if ($action === 'delete') {
            $id = (int)($_GET['id'] ?? $input['id'] ?? 0);
            if (!$id) {
                json_error('Missing record id.');
            }
            delete_row($table, $id);
            json_success(['id' => $id]);
        }

        json_error('Unknown action.');
    } catch (Throwable $e) {
        json_error($e->getMessage(), 500);
    }
}
