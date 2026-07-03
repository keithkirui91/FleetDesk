<?php
require_once __DIR__ . '/module_page.php';

render_module_page([
    'title'           => 'Fuel',
    'singular'        => 'Fuel Log',
    'description'     => 'Fuel fills, litres, cost, stations, and vehicle odometer readings.',
    'endpoint'        => 'api/fuel.php?action=create',
    'delete_endpoint' => 'api/fuel.php?action=delete',
    'sql' => "SELECT fl.id, fl.log_date, v.fleet_number, v.registration,
                     fl.odometer_at_fill, fl.litres_filled, fl.fuel_type,
                     fl.station_location, fl.total_cost,
                     fl.issuer_name, fl.receiver_name
              FROM fuel_logs fl
              JOIN vehicles v ON v.id = fl.vehicle_id
              ORDER BY fl.log_date DESC, fl.id DESC",
    'columns' => [
        ['key' => 'log_date',         'label' => 'Date'],
        ['key' => 'fleet_number',     'label' => 'Fleet No.'],
        ['key' => 'registration',     'label' => 'Registration'],
        ['key' => 'odometer_at_fill', 'label' => 'Odometer'],
        ['key' => 'litres_filled',    'label' => 'Litres'],
        ['key' => 'fuel_type',        'label' => 'Fuel', 'badge' => true],
        ['key' => 'station_location', 'label' => 'Fueling Point'],
        ['key' => 'total_cost',       'label' => 'Cost'],
        ['key' => 'issuer_name',      'label' => 'Issued By'],
        ['key' => 'receiver_name',    'label' => 'Received By'],
    ],
    'fields' => [
        ['name' => 'vehicle_id',      'label' => 'Vehicle',          'type' => 'select',   'options' => vehicle_options(), 'required' => true],
        ['name' => 'log_date',        'label' => 'Date',             'type' => 'date',     'required' => true],
        ['name' => 'odometer_at_fill','label' => 'Odometer (km)',    'type' => 'number',   'required' => true],
        ['name' => 'litres_filled',   'label' => 'Litres',           'type' => 'number',   'required' => true],
        ['name' => 'fuel_type',       'label' => 'Fuel Type',        'type' => 'select',
            'options' => ['diesel'=>'Diesel','petrol'=>'Petrol','hybrid'=>'Hybrid',
                          'lpg'=>'LPG','kerosene'=>'Kerosene','other'=>'Other'],
            'required' => true],
        ['name' => 'station_location','label' => 'Fueling Point',    'type' => 'select',   'required' => true,
            'options' => ['Kamok Depot'=>'Kamok Depot','Control Depot'=>'Control Depot','External Fueling'=>'External Fueling']],
        ['name' => 'cost_per_litre',  'label' => 'Cost per Litre',   'type' => 'number',   'required' => true],
        ['name' => 'total_cost',      'label' => 'Total Cost',       'type' => 'number',   'required' => true, 'readonly' => true],
        ['name' => 'issuer_name',     'label' => 'Issued By',        'type' => 'text',     'required' => true],
        ['name' => 'receiver_name',   'label' => 'Received By',      'type' => 'text',     'required' => true],
        ['name' => 'notes',           'label' => 'Notes',            'type' => 'textarea'],
    ],
    'toolbar_links' => [
        ['href' => 'dip-readings', 'label' => 'Dip Reading Logs', 'class' => ''],
    ],
]);
?>
<script>
// Auto-calculate total cost
document.addEventListener('input', function(e) {
    if (e.target.name === 'cost_per_litre' || e.target.name === 'litres_filled') {
        const cpl  = parseFloat(document.querySelector('[name="cost_per_litre"]')?.value) || 0;
        const ltrs = parseFloat(document.querySelector('[name="litres_filled"]')?.value)  || 0;
        const tot  = document.querySelector('[name="total_cost"]');
        if (tot && cpl && ltrs) tot.value = (cpl * ltrs).toFixed(2);
    }
});
</script>
