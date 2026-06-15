<?php
require_once __DIR__ . '/module_page.php';

render_module_page([
    'title' => 'Service',
    'singular' => 'Service Record',
    'description' => 'Day jobs - short operations and routine service tracking.',
    'endpoint' => 'api/services.php?action=create',
    'delete_endpoint' => 'api/services.php?action=delete',
    'sql' => "SELECT sr.id, sr.service_date, v.fleet_number, v.registration, sr.service_type, sr.odometer_at_service, m.full_name AS mechanic_name, sr.next_service_date
              FROM service_records sr
              JOIN vehicles v ON v.id = sr.vehicle_id
              LEFT JOIN mechanics m ON m.id = sr.mechanic_id
              ORDER BY sr.service_date DESC, sr.id DESC",
    'columns' => [
        ['key' => 'service_date', 'label' => 'Date'],
        ['key' => 'fleet_number', 'label' => 'Fleet No.'],
        ['key' => 'registration', 'label' => 'Registration'],
        ['key' => 'service_type', 'label' => 'Type', 'badge' => true],
        ['key' => 'odometer_at_service', 'label' => 'Odometer'],
        ['key' => 'mechanic_name', 'label' => 'Mechanic'],
        ['key' => 'next_service_date', 'label' => 'Next Service'],
    ],
    'fields' => [
        ['name' => 'vehicle_id', 'label' => 'Vehicle', 'type' => 'select', 'options' => vehicle_options(), 'required' => true],
        ['name' => 'mechanic_id', 'label' => 'Mechanic', 'type' => 'select', 'options' => mechanic_options(), 'required' => true],
        ['name' => 'service_date', 'label' => 'Service date', 'type' => 'date', 'required' => true],
        ['name' => 'odometer_at_service', 'label' => 'Odometer', 'type' => 'number', 'required' => true],
        ['name' => 'service_type', 'label' => 'Type', 'type' => 'select', 'options' => ['interim' => 'Interim', 'full' => 'Full', 'major' => 'Major'], 'required' => true],
        ['name' => 'next_service_date', 'label' => 'Next service date', 'type' => 'date', 'required' => true],
        ['name' => 'next_service_mileage', 'label' => 'Next service mileage', 'type' => 'number', 'required' => true],
        ['name' => 'parts_replaced', 'label' => 'Parts replaced', 'type' => 'textarea', 'required' => true],
        ['name' => 'work_done', 'label' => 'Work done', 'type' => 'checklist', 'required' => true, 'options' => ['Oil and filter service' => 'Oil and filter service', 'Brake inspection' => 'Brake inspection', 'Tyre pressure and tread check' => 'Tyre pressure and tread check', 'Fluid top-up' => 'Fluid top-up', 'Road test' => 'Road test', 'Diagnostics scan' => 'Diagnostics scan']],
        ['name' => 'notes', 'label' => 'Notes', 'type' => 'textarea', 'required' => true],
    ],
]);
