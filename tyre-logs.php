<?php
require_once __DIR__ . '/module_page.php';

render_module_page([
    'title'           => 'Tyre Change Logs',
    'singular'        => 'Tyre Change',
    'description'     => 'Record of all tyre replacements across the fleet.',
    'endpoint'        => 'api/tyre-logs.php?action=create',
    'delete_endpoint' => 'api/tyre-logs.php?action=delete',
    'sql'             => "SELECT tcl.id, tcl.change_date, v.fleet_number, v.registration,
                                 tcl.quantity, tcl.tyre_name, tcl.tyre_size, tcl.tyre_type,
                                 tcl.expected_lifespan_km, tcl.quality_comment
                          FROM tyre_change_logs tcl
                          JOIN vehicles v ON v.id = tcl.vehicle_id
                          ORDER BY tcl.change_date DESC, tcl.id DESC",
    'columns' => [
        ['key' => 'change_date',          'label' => 'Date'],
        ['key' => 'fleet_number',         'label' => 'Fleet No.'],
        ['key' => 'registration',         'label' => 'Registration'],
        ['key' => 'quantity',             'label' => 'Qty'],
        ['key' => 'tyre_name',            'label' => 'Tyre Name'],
        ['key' => 'tyre_size',            'label' => 'Size'],
        ['key' => 'tyre_type',            'label' => 'Type', 'badge' => true],
        ['key' => 'expected_lifespan_km', 'label' => 'Expected Life (km)'],
        ['key' => 'quality_comment',      'label' => 'Quality Assessment'],
    ],
    'fields' => [
        ['name' => 'vehicle_id',            'label' => 'Vehicle',             'type' => 'select', 'options' => vehicle_options(), 'required' => true],
        ['name' => 'change_date',           'label' => 'Date of Change',      'type' => 'date',   'required' => true],
        ['name' => 'odometer',              'label' => 'Odometer (km)',        'type' => 'number'],
        ['name' => 'quantity',              'label' => 'Quantity',             'type' => 'number', 'required' => true, 'value' => '1'],
        ['name' => 'tyre_name',             'label' => 'Tyre Name / Brand',   'type' => 'text'],
        ['name' => 'tyre_size',             'label' => 'Tyre Size',           'type' => 'text',   'required' => true],
        ['name' => 'tyre_type',             'label' => 'Tyre Type',           'type' => 'select', 'required' => true,
            'options' => ['Nylon' => 'Nylon', 'Radial' => 'Radial', 'Superlug' => 'Superlug']],
        ['name' => 'expected_lifespan_km',  'label' => 'Expected Lifespan (km)', 'type' => 'number'],
        ['name' => 'quality_comment',       'label' => 'Quality Assessment',  'type' => 'textarea'],
        ['name' => 'notes',                 'label' => 'Notes',               'type' => 'textarea'],
    ],
]);
