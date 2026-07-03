<?php
require_once __DIR__ . '/module_page.php';

render_module_page([
    'title' => 'Disposed Assets',
    'singular' => 'Asset Log',
    'description' => 'Vehicles that were disposed or deleted from the fleet, with saved audit snapshots.',
    'endpoint' => 'api/asset-logs.php?action=create',
    'delete_endpoint' => 'api/asset-logs.php?action=delete',
    'hide_add' => true,
    'sql' => "SELECT id, action_type, fleet_number, registration, make, model, department, current_odometer, reason, logged_at
              FROM asset_disposal_logs
              ORDER BY logged_at DESC, id DESC",
    'columns' => [
        ['key' => 'action_type', 'label' => 'Action', 'badge' => true],
        ['key' => 'fleet_number', 'label' => 'Fleet No.'],
        ['key' => 'registration', 'label' => 'Registration'],
        ['key' => 'make', 'label' => 'Make'],
        ['key' => 'model', 'label' => 'Model'],
        ['key' => 'department', 'label' => 'Department'],
        ['key' => 'current_odometer', 'label' => 'Odometer'],
        ['key' => 'logged_at', 'label' => 'Logged At'],
    ],
    'fields' => [
        ['name' => 'fleet_number', 'label' => 'Fleet number', 'readonly' => true],
    ],
]);
