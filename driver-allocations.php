<?php
require_once __DIR__ . '/module_page.php';

render_module_page([
    'title' => 'Driver Allocations',
    'singular' => 'Driver Allocation',
    'description' => 'Primary and reliever driver assignments with change history.',
    'endpoint' => 'api/driver-allocations.php?action=create',
    'delete_endpoint' => 'api/driver-allocations.php?action=delete',
    'display_images' => [
        ['field' => 'vehicle_photo', 'label' => 'Vehicle'],
        ['field' => 'driver_photo', 'label' => 'Driver'],
    ],
    'sql' => "SELECT vda.id, v.fleet_number, v.registration, v.primary_image_url AS vehicle_photo,
                     d.full_name AS driver_name, d.department, d.photo_url AS driver_photo,
                     vda.role, vda.start_date, vda.end_date, vda.is_active, vda.notes
              FROM vehicle_driver_assignments vda
              JOIN vehicles v ON v.id = vda.vehicle_id
              JOIN drivers d ON d.id = vda.driver_id
              ORDER BY v.fleet_number, vda.is_active DESC, FIELD(vda.role, 'primary', 'reliever'), vda.start_date DESC, vda.id DESC",
    'columns' => [
        ['key' => 'fleet_number', 'label' => 'Fleet No.'],
        ['key' => 'registration', 'label' => 'Registration'],
        ['key' => 'driver_name', 'label' => 'Driver'],
        ['key' => 'department', 'label' => 'Department'],
        ['key' => 'role', 'label' => 'Role', 'badge' => true],
        ['key' => 'start_date', 'label' => 'Start Date'],
        ['key' => 'end_date', 'label' => 'End Date'],
        ['key' => 'is_active', 'label' => 'Active'],
    ],
    'fields' => [
        ['name' => 'vehicle_id', 'label' => 'Vehicle', 'type' => 'select', 'options' => assignment_vehicle_options(), 'required' => true, 'lookup' => true],
        ['name' => 'driver_id', 'label' => 'Driver', 'type' => 'select', 'options' => driver_options(), 'required' => true],
        ['name' => 'role', 'label' => 'Role', 'type' => 'select', 'options' => ['primary' => 'Primary', 'reliever' => 'Reliever'], 'required' => true],
        ['name' => 'start_date', 'label' => 'Start date', 'type' => 'date', 'required' => true],
        ['name' => 'end_date', 'label' => 'End date', 'type' => 'date'],
        ['name' => 'notes', 'label' => 'Notes', 'type' => 'textarea'],
    ],
]);
