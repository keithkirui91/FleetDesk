<?php
require_once __DIR__ . '/module_page.php';

render_module_page([
    'title'           => 'Battery Change Logs',
    'singular'        => 'Battery Change',
    'description'     => 'Record of all battery replacements across the fleet.',
    'endpoint'        => 'api/battery-logs.php?action=create',
    'delete_endpoint' => 'api/battery-logs.php?action=delete',
    'sql'             => "SELECT bcl.id, bcl.change_date, v.fleet_number, v.registration,
                                 bcl.quantity, bcl.battery_size, bcl.battery_type,
                                 bcl.expected_lifespan_months, bcl.reason_for_removal
                          FROM battery_change_logs bcl
                          JOIN vehicles v ON v.id = bcl.vehicle_id
                          ORDER BY bcl.change_date DESC, bcl.id DESC",
    'columns' => [
        ['key' => 'change_date',               'label' => 'Date'],
        ['key' => 'fleet_number',              'label' => 'Fleet No.'],
        ['key' => 'registration',              'label' => 'Registration'],
        ['key' => 'quantity',                  'label' => 'Qty'],
        ['key' => 'battery_size',              'label' => 'Size'],
        ['key' => 'battery_type',              'label' => 'Type'],
        ['key' => 'expected_lifespan_months',  'label' => 'Expected Life (months)'],
        ['key' => 'reason_for_removal',        'label' => 'Reason for Removal'],
    ],
    'fields' => [
        ['name' => 'vehicle_id',              'label' => 'Vehicle',                'type' => 'select', 'options' => vehicle_options(), 'required' => true],
        ['name' => 'change_date',             'label' => 'Date of Change',         'type' => 'date',   'required' => true],
        ['name' => 'odometer',                'label' => 'Odometer (km)',           'type' => 'number'],
        ['name' => 'quantity',                'label' => 'Quantity',               'type' => 'number', 'required' => true, 'value' => '1'],
        ['name' => 'battery_size',            'label' => 'Battery Size (e.g. 12V/70Ah)', 'type' => 'text', 'required' => true],
        ['name' => 'battery_type',            'label' => 'Battery Type',           'type' => 'text',   'required' => true],
        ['name' => 'expected_lifespan_months','label' => 'Expected Lifespan (months)', 'type' => 'number'],
        ['name' => 'reason_for_removal',      'label' => 'Reason for Removal',     'type' => 'textarea', 'required' => true],
        ['name' => 'notes',                   'label' => 'Notes',                  'type' => 'textarea'],
    ],
]);
