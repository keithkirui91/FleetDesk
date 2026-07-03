<?php
require_once __DIR__ . '/common.php';

$fields = ['vehicle_id','service_record_id','change_date','odometer','quantity',
           'tyre_name','tyre_size','tyre_type','expected_lifespan_km','quality_comment','notes'];

route_simple_module('tyre_change_logs', $fields,
    "SELECT tcl.*, v.fleet_number, v.registration
     FROM tyre_change_logs tcl
     JOIN vehicles v ON v.id = tcl.vehicle_id
     ORDER BY tcl.change_date DESC, tcl.id DESC"
);
