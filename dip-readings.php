<?php
require_once __DIR__ . '/module_page.php';

render_module_page([
    'title'           => 'Dip Reading Logs',
    'singular'        => 'Dip Reading',
    'description'     => 'Fuel depot dip readings and stock balance history.',
    'endpoint'        => 'api/fuel-depot.php?action=create',
    'delete_endpoint' => 'api/fuel-depot.php?action=delete',
    'sql'             => "SELECT * FROM fuel_depot_readings ORDER BY reading_date DESC, id DESC",
    'columns' => [
        ['key' => 'reading_date', 'label' => 'Date'],
        ['key' => 'fuel_type',    'label' => 'Fuel Type', 'badge' => true],
        ['key' => 'dip_litres',   'label' => 'Dip (Litres)'],
        ['key' => 'recorded_by',  'label' => 'Recorded By'],
        ['key' => 'notes',        'label' => 'Notes'],
    ],
    'fields' => [
        ['name' => 'reading_date', 'label' => 'Date',         'type' => 'date',   'required' => true],
        ['name' => 'fuel_type',    'label' => 'Fuel Type',    'type' => 'select', 'required' => true,
            'options' => ['diesel' => 'Diesel', 'petrol' => 'Petrol', 'kerosene' => 'Kerosene', 'other' => 'Other']],
        ['name' => 'dip_litres',   'label' => 'Dip (Litres)', 'type' => 'number', 'required' => true],
        ['name' => 'recorded_by',  'label' => 'Recorded By',  'type' => 'text'],
        ['name' => 'notes',        'label' => 'Notes',        'type' => 'textarea'],
    ],
]);
