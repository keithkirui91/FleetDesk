<?php
require_once __DIR__ . '/module_page.php';

render_module_page([
    'title' => 'Drivers',
    'singular' => 'Driver',
    'description' => 'Driver profiles, departments, licence dates, and comments.',
    'endpoint' => 'api/drivers.php?action=create',
    'edit_endpoint' => 'api/drivers.php?action=update',
    'delete_endpoint' => 'api/drivers.php?action=delete',
    'image_field' => 'photo_url',
    'upload_type' => 'driver',
    'completeness_fields' => ['full_name', 'department', 'dl_number', 'licence_type', 'licence_renewal_date', 'licence_expiry_date'],
    'sql' => "SELECT d.id, d.full_name, d.department, d.dl_number, d.licence_type,
                     d.licence_renewal_date, d.licence_expiry_date, d.photo_url,
                     COUNT(vda.id) AS active_allocations,
                     d.is_active
              FROM drivers d
              LEFT JOIN vehicle_driver_assignments vda ON vda.driver_id = d.id AND vda.is_active = 1
              GROUP BY d.id
              ORDER BY d.full_name",
    'columns' => [
        ['key' => 'full_name', 'label' => 'Name'],
        ['key' => 'department', 'label' => 'Department'],
        ['key' => 'dl_number', 'label' => 'DL No.'],
        ['key' => 'licence_type', 'label' => 'Licence Type'],
        ['key' => 'licence_renewal_date', 'label' => 'Renewal Date'],
        ['key' => 'licence_expiry_date', 'label' => 'Expiry Date'],
        ['key' => 'active_allocations', 'label' => 'Allocations'],
        ['key' => 'is_active', 'label' => 'Active'],
    ],
    'fields' => [
        ['name' => 'full_name', 'label' => 'Full name', 'required' => true],
        ['name' => 'department', 'label' => 'Department', 'required' => true],
        ['name' => 'dl_number', 'label' => 'DL number'],
        ['name' => 'licence_type', 'label' => 'Licence Type(s)', 'type' => 'checklist', 'options' => [
            'Class A' => 'Class A', 'Class B' => 'Class B', 'Class C' => 'Class C',
            'Class D' => 'Class D', 'Class E' => 'Class E', 'Class F' => 'Class F',
            'Class G' => 'Class G', 'PSV' => 'PSV (Passenger Service Vehicle)',
            'HGV' => 'HGV (Heavy Goods Vehicle)', 'Interim' => 'Interim', 'Other' => 'Other',
        ]],
        ['name' => 'licence_renewal_date', 'label' => 'Licence renewal date', 'type' => 'date'],
        ['name' => 'licence_expiry_date', 'label' => 'Licence expiry date', 'type' => 'date'],
        ['name' => 'photo_url', 'label' => 'Photo', 'type' => 'image'],
        ['name' => 'comments', 'label' => 'Comments', 'type' => 'textarea'],
    ],
]);
