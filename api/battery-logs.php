<?php
require_once __DIR__ . '/common.php';

$fields = ['vehicle_id','service_record_id','change_date','odometer','quantity',
           'battery_size','battery_type','expected_lifespan_months','reason_for_removal','notes'];

route_simple_module('battery_change_logs', $fields,
    "SELECT bcl.*, v.fleet_number, v.registration
     FROM battery_change_logs bcl
     JOIN vehicles v ON v.id = bcl.vehicle_id
     ORDER BY bcl.change_date DESC, bcl.id DESC"
);
