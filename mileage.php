<?php
require_once __DIR__ . '/module_page.php';

render_module_page([
    'title' => 'Mileage',
    'singular' => 'Mileage Log',
    'description' => 'Odometer history for gate, workshop, service, and fuel readings.',
    'endpoint' => 'api/odometer.php?action=create',
    'delete_endpoint' => 'api/odometer.php?action=delete',
    'sql' => "SELECT ol.id, ol.logged_at, v.fleet_number, v.registration, ol.odometer_reading, ol.location, ol.notes
              FROM odometer_logs ol
              JOIN vehicles v ON v.id = ol.vehicle_id
              ORDER BY ol.logged_at DESC, ol.id DESC",
    'columns' => [
        ['key' => 'logged_at', 'label' => 'Logged At'],
        ['key' => 'fleet_number', 'label' => 'Fleet No.'],
        ['key' => 'registration', 'label' => 'Registration'],
        ['key' => 'odometer_reading', 'label' => 'Odometer'],
        ['key' => 'location', 'label' => 'Location', 'badge' => true],
        ['key' => 'notes', 'label' => 'Notes'],
    ],
    'fields' => [
        ['name' => 'vehicle_id', 'label' => 'Vehicle', 'type' => 'select', 'options' => active_vehicle_options(), 'required' => true, 'lookup' => true],
        ['name' => 'odometer_reading', 'label' => 'Odometer', 'type' => 'number', 'required' => true],
        ['name' => 'location', 'label' => 'Location', 'type' => 'select', 'options' => ['gate_in' => 'Gate in', 'gate_out' => 'Gate out', 'workshop' => 'Workshop', 'service' => 'Service', 'fuel' => 'Fuel', 'other' => 'Other']],
        ['name' => 'logged_at', 'label' => 'Logged at', 'type' => 'datetime-local'],
        ['name' => 'notes', 'label' => 'Notes', 'type' => 'textarea'],
    ],
]);
