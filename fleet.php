<?php
require_once __DIR__ . '/module_page.php';

$currentOdometer = current_odometer_sql('v');

render_module_page([
    'title'           => 'Fleet',
    'singular'        => 'Vehicle',
    'description'     => 'Vehicles, departments, service status, and current odometer readings.',
    'endpoint'        => 'api/vehicles.php?action=create',
    'edit_endpoint'   => 'api/vehicles.php?action=update',
    'delete_endpoint' => 'api/vehicles.php?action=delete',
    'image_field'     => 'primary_image_url',
    'upload_type'     => 'vehicle',
    'completeness_fields' => [
        'fleet_number', 'registration', 'make', 'model', 'year', 'date_acquired',
        'colour', 'fuel_type', 'body_type', 'vehicle_type', 'fleet_type', 'department',
        'vin_chassis', 'engine_number', 'engine_size', 'engine_capacity', 'transmission',
        'drive_type', 'seating_capacity', 'payload_capacity_kg', 'tare_weight_kg',
        'gross_weight_kg', 'tyre_size_standard', 'logbook_status', 'odometer_status',
        'inspection_status', 'insurance_expiry', 'next_service_date', 'next_service_mileage',
    ],
    'toolbar_links'   => [
        ['href' => 'disposed-assets', 'label' => 'Disposed / Deleted Vehicles', 'icon' => 'archive'],
    ],
    'detail_actions'  => [
        ['label' => 'Dispose Asset', 'icon' => 'archive', 'class' => 'btn-warn',
         'attribute' => 'data-dispose-record', 'endpoint' => 'api/vehicles.php?action=dispose'],
    ],
    'sql' => "SELECT v.id, v.fleet_number, v.registration, v.make, v.model, v.department,
                     v.status, v.primary_image_url,
                     $currentOdometer AS current_odometer,
                     COALESCE((
                        SELECT d.full_name
                        FROM vehicle_driver_assignments vda
                        JOIN drivers d ON d.id = vda.driver_id
                        WHERE vda.vehicle_id = v.id AND vda.role = 'primary' AND vda.is_active = 1
                        ORDER BY vda.start_date DESC, vda.id DESC LIMIT 1
                     ), 'Unassigned') AS primary_driver,
                     COALESCE((
                        SELECT GROUP_CONCAT(d.full_name ORDER BY d.full_name SEPARATOR ', ')
                        FROM vehicle_driver_assignments vda
                        JOIN drivers d ON d.id = vda.driver_id
                        WHERE vda.vehicle_id = v.id AND vda.role = 'reliever' AND vda.is_active = 1
                     ), '-') AS reliever_drivers
              FROM vehicles v ORDER BY v.fleet_number",
    'columns' => [
        ['key' => 'fleet_number',    'label' => 'Fleet No.'],
        ['key' => 'registration',    'label' => 'Registration'],
        ['key' => 'make',            'label' => 'Make'],
        ['key' => 'model',           'label' => 'Model'],
        ['key' => 'department',      'label' => 'Department'],
        ['key' => 'current_odometer','label' => 'Odometer'],
        ['key' => 'primary_driver',  'label' => 'Primary Driver'],
        ['key' => 'reliever_drivers','label' => 'Relievers'],
        ['key' => 'status',          'label' => 'Status', 'badge' => true],
    ],
    'fields' => [
        // ── Identification ──────────────────────────────────
        ['name' => 'fleet_number',    'label' => 'Fleet Number',           'required' => true],
        ['name' => 'registration',    'label' => 'Registration',           'required' => true],
        ['name' => 'make',            'label' => 'Make',                   'required' => true],
        ['name' => 'model',           'label' => 'Model',                  'required' => true],
        ['name' => 'year',            'label' => 'Year of Manufacture',    'type' => 'number'],
        ['name' => 'date_acquired',   'label' => 'Date Acquired',          'type' => 'date'],
        ['name' => 'colour',          'label' => 'Colour'],
        ['name' => 'vin_chassis',     'label' => 'Chassis Number'],
        ['name' => 'engine_number',   'label' => 'Engine Number'],
        ['name' => 'new_gen_plates',  'label' => 'New Generation Plates',  'type' => 'select',
            'options' => ['0' => 'No', '1' => 'Yes']],
        ['name' => 'primary_image_url','label' => 'Vehicle Photo',         'type' => 'image'],

        // ── Classification ──────────────────────────────────
        ['name' => 'vehicle_type',    'label' => 'Vehicle Type',           'type' => 'select',
            'options' => ['car'=>'Car','van'=>'Van','truck'=>'Truck','motorbike'=>'Motorbike',
                          'construction'=>'Construction','trailer'=>'Trailer','small_engine'=>'Small Engine']],
        ['name' => 'fleet_type',      'label' => 'Fleet Type',            'type' => 'text'],
        ['name' => 'body_type',       'label' => 'Body Type'],
        ['name' => 'department',      'label' => 'Department'],
        ['name' => 'fuel_type',       'label' => 'Fuel Type',             'type' => 'select',
            'options' => ['diesel'=>'Diesel','petrol'=>'Petrol','hybrid'=>'Hybrid',
                          'electric'=>'Electric','lpg'=>'LPG','other'=>'Other']],

        // ── Technical Specs ─────────────────────────────────
        ['name' => 'engine_size',     'label' => 'Engine Size'],
        ['name' => 'engine_capacity', 'label' => 'Engine Capacity (cc)'],
        ['name' => 'transmission',    'label' => 'Transmission',          'type' => 'select',
            'options' => ['' => '— Select —','manual'=>'Manual','automatic'=>'Automatic','cvt'=>'CVT','other'=>'Other']],
        ['name' => 'drive_type',      'label' => 'Drive Type',            'type' => 'select',
            'options' => [''=>'— Select —','2WD'=>'2WD','4WD'=>'4WD','AWD'=>'AWD']],
        ['name' => 'seating_capacity','label' => 'Seating Capacity',      'type' => 'number'],
        ['name' => 'tyre_size_standard','label' => 'Standard Tyre Size'],

        // ── Weight & Capacity ───────────────────────────────
        ['name' => 'tare_weight_kg',  'label' => 'Tare Weight (kg)',       'type' => 'number'],
        ['name' => 'payload_capacity_kg','label' => 'Load Capacity (kg)',  'type' => 'number'],
        ['name' => 'gross_weight_kg', 'label' => 'Gross Weight (kg)',      'type' => 'number'],

        // ── Status & Compliance ─────────────────────────────
        ['name' => 'logbook_status',  'label' => 'Logbook Status',         'type' => 'select',
            'options' => [''=>'— Select —','available'=>'Available','missing'=>'Missing',
                          'with_bank'=>'With Bank','other'=>'Other']],
        ['name' => 'odometer_status', 'label' => 'Odometer Status',        'type' => 'select',
            'options' => ['working'=>'Working','not_working'=>'Not Working']],
        ['name' => 'inspection_status','label' => 'Inspection Status',     'type' => 'select',
            'options' => [''=>'— Select —','valid'=>'Valid','invalid'=>'Invalid']],
        ['name' => 'insurance_expiry','label' => 'Insurance Expiry',       'type' => 'date'],
        ['name' => 'licence_expiry',  'label' => 'Licence Expiry',         'type' => 'date', 'hide_on_add' => true],
        ['name' => 'status',          'label' => 'Status',                 'type' => 'select',
            'options' => ['active'=>'Active','in_workshop'=>'In Workshop',
                          'awaiting_parts'=>'Awaiting Parts','decommissioned'=>'Decommissioned']],

        // ── Service ─────────────────────────────────────────
        ['name' => 'odometer_current','label' => 'Current Odometer (km)', 'type' => 'number'],
        ['name' => 'next_service_date','label' => 'Next Service Date',     'type' => 'date'],
        ['name' => 'next_service_mileage','label' => 'Next Service Mileage','type' => 'number'],

        // ── Notes ───────────────────────────────────────────
        ['name' => 'notes',           'label' => 'Notes',                  'type' => 'textarea'],
    ],
]);
