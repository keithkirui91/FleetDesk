<?php
require_once __DIR__ . '/auth_check.php';
require_once __DIR__ . '/db.php';

$page_title = 'Reports';
$page_heading = 'Reports';

$serviceByType = db_all('SELECT service_type, COUNT(*) AS total FROM service_records GROUP BY service_type ORDER BY total DESC');
$fuelByVehicle = db_all("SELECT v.fleet_number, SUM(fl.litres_filled) AS litres, SUM(fl.total_cost) AS cost FROM fuel_logs fl JOIN vehicles v ON v.id = fl.vehicle_id GROUP BY v.id, v.fleet_number ORDER BY litres DESC LIMIT 10");
$jobsByStatus = db_all('SELECT status, COUNT(*) AS total FROM job_cards GROUP BY status ORDER BY total DESC');

include __DIR__ . '/header.php';
include __DIR__ . '/sidebar.php';
?>
<div class="card-grid">
    <?php foreach ($jobsByStatus as $row): ?>
        <div class="stat"><span><?= e(str_replace('_', ' ', $row['status'])) ?></span><strong><?= e($row['total']) ?></strong></div>
    <?php endforeach; ?>
</div>
<div class="panel">
    <h2>Services by Type</h2>
    <div class="table-wrap"><table><tbody>
        <?php foreach ($serviceByType as $row): ?><tr><td><?= e($row['service_type']) ?></td><td class="text-right"><?= e($row['total']) ?></td></tr><?php endforeach; ?>
    </tbody></table></div>
</div>
<div class="panel">
    <h2>Top Fuel Usage</h2>
    <div class="table-wrap"><table><thead><tr><th>Vehicle</th><th>Litres</th><th>Cost</th></tr></thead><tbody>
        <?php foreach ($fuelByVehicle as $row): ?><tr><td><?= e($row['fleet_number']) ?></td><td><?= e($row['litres']) ?></td><td><?= e($row['cost']) ?></td></tr><?php endforeach; ?>
    </tbody></table></div>
</div>
<?php include __DIR__ . '/footer.php'; ?>
