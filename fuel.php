<?php
require_once __DIR__ . '/module_page.php';

render_module_page([
    'title' => 'Fuel',
    'singular' => 'Fuel Log',
    'description' => 'Fuel fills, litres, cost, stations, and vehicle odometer readings.',
    'endpoint' => 'api/fuel.php?action=create',
    'delete_endpoint' => 'api/fuel.php?action=delete',
    'sql' => "SELECT fl.id, fl.log_date, v.fleet_number, v.registration, fl.odometer_at_fill, fl.litres_filled, fl.fuel_type, fl.station_location, fl.total_cost
              FROM fuel_logs fl
              JOIN vehicles v ON v.id = fl.vehicle_id
              ORDER BY fl.log_date DESC, fl.id DESC",
    'columns' => [
        ['key' => 'log_date', 'label' => 'Date'],
        ['key' => 'fleet_number', 'label' => 'Fleet No.'],
        ['key' => 'registration', 'label' => 'Registration'],
        ['key' => 'odometer_at_fill', 'label' => 'Odometer'],
        ['key' => 'litres_filled', 'label' => 'Litres'],
        ['key' => 'fuel_type', 'label' => 'Fuel', 'badge' => true],
        ['key' => 'station_location', 'label' => 'Station'],
        ['key' => 'total_cost', 'label' => 'Cost'],
    ],
    'fields' => [
        ['name' => 'vehicle_id', 'label' => 'Vehicle', 'type' => 'select', 'options' => vehicle_options(), 'required' => true],
        ['name' => 'log_date', 'label' => 'Date', 'type' => 'date', 'required' => true],
        ['name' => 'odometer_at_fill', 'label' => 'Odometer', 'type' => 'number', 'required' => true],
        ['name' => 'litres_filled', 'label' => 'Litres', 'type' => 'number', 'required' => true],
        ['name' => 'fuel_type', 'label' => 'Fuel type', 'type' => 'select', 'options' => ['diesel' => 'Diesel', 'petrol' => 'Petrol', 'hybrid' => 'Hybrid', 'lpg' => 'LPG', 'kerosene' => 'Kerosene', 'other' => 'Other'], 'required' => true],
        ['name' => 'station_location', 'label' => 'Station'],
        ['name' => 'cost_per_litre', 'label' => 'Cost per litre', 'type' => 'number', 'required' => true],
        ['name' => 'total_cost', 'label' => 'Total cost', 'type' => 'number', 'required' => true, 'readonly' => true],
        ['name' => 'notes', 'label' => 'Notes', 'type' => 'textarea'],
    ],
]);
