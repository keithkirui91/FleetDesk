<?php
require_once __DIR__ . '/auth_check.php';
require_once __DIR__ . '/db.php';

$page_title = 'Dashboard';
$page_heading = 'Dashboard';

function pct($value, $total)
{
    return $total > 0 ? (int)round(($value / $total) * 100) : 0;
}

function short_date($date)
{
    return $date ? date('d M Y', strtotime($date)) : '-';
}

function clip_text($text, $limit = 42)
{
    $text = (string)$text;
    return strlen($text) > $limit ? substr($text, 0, $limit - 3) . '...' : $text;
}

$totalFleet = (int)db_value('SELECT COUNT(*) FROM vehicles');
$activeFleet = (int)db_value("SELECT COUNT(*) FROM vehicles WHERE status = 'active'");
$inWorkshop = (int)db_value("SELECT COUNT(*) FROM vehicles WHERE status = 'in_workshop'");
$awaitingParts = (int)db_value("SELECT COUNT(*) FROM vehicles WHERE status = 'awaiting_parts'");
$openJobs = (int)db_value("SELECT COUNT(*) FROM job_cards WHERE status <> 'closed'");
$activeDowntimeDays = (int)db_value("SELECT COALESCE(SUM(DATEDIFF(CURDATE(), date_in)), 0) FROM job_cards WHERE status <> 'closed'");

$fleetStatus = db_all("
    SELECT status, COUNT(*) AS total
    FROM vehicles
    GROUP BY status
    ORDER BY FIELD(status, 'active', 'in_workshop', 'awaiting_parts', 'decommissioned')
");

$downtimeByDepartment = db_all("
    SELECT COALESCE(v.department, 'Unassigned') AS department,
           COALESCE(SUM(DATEDIFF(CURDATE(), jc.date_in)), 0) AS days
    FROM job_cards jc
    JOIN vehicles v ON v.id = jc.vehicle_id
    WHERE jc.status <> 'closed'
    GROUP BY COALESCE(v.department, 'Unassigned')
    ORDER BY days DESC
    LIMIT 6
");

$jobsTimelineRows = db_all("
    SELECT DATE_FORMAT(date_in, '%Y-%m') AS month_key, COUNT(*) AS opened, 0 AS closed
    FROM job_cards
    WHERE date_in >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    GROUP BY DATE_FORMAT(date_in, '%Y-%m')
    UNION ALL
    SELECT DATE_FORMAT(date_closed, '%Y-%m') AS month_key, 0 AS opened, COUNT(*) AS closed
    FROM job_cards
    WHERE date_closed IS NOT NULL AND date_closed >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    GROUP BY DATE_FORMAT(date_closed, '%Y-%m')
");

$jobsTimeline = [];
for ($i = 11; $i >= 0; $i--) {
    $key = date('Y-m', strtotime("-$i months"));
    $jobsTimeline[$key] = ['label' => date('M', strtotime($key . '-01')), 'opened' => 0, 'closed' => 0];
}
foreach ($jobsTimelineRows as $row) {
    if (isset($jobsTimeline[$row['month_key']])) {
        $jobsTimeline[$row['month_key']]['opened'] += (int)$row['opened'];
        $jobsTimeline[$row['month_key']]['closed'] += (int)$row['closed'];
    }
}
$maxJobs = 1;
foreach ($jobsTimeline as $month) {
    $maxJobs = max($maxJobs, (int)$month['opened'], (int)$month['closed']);
}

$odoRows = db_all("
    SELECT vehicle_id, odometer_reading, logged_at
    FROM odometer_logs
    WHERE logged_at >= DATE_SUB(CURDATE(), INTERVAL 14 WEEK)
    ORDER BY vehicle_id, logged_at, id
");
$vehicleRows = db_all("
    SELECT id, fleet_number, registration
    FROM vehicles
    WHERE status <> 'decommissioned'
    ORDER BY fleet_number
");
$weeklyKm = [];
for ($i = 11; $i >= 0; $i--) {
    $key = date('o-W', strtotime("-$i weeks"));
    $weeklyKm[$key] = ['label' => date('M d', strtotime("-$i weeks")), 'km' => 0];
}
$weeklyKmByVehicle = ['all' => $weeklyKm];
$weeklyVehicleOptions = ['all' => 'Fleet total'];
foreach ($vehicleRows as $vehicle) {
    $vehicleKey = (string)$vehicle['id'];
    $weeklyKmByVehicle[$vehicleKey] = $weeklyKm;
    $weeklyVehicleOptions[$vehicleKey] = $vehicle['registration'] . ' - ' . $vehicle['fleet_number'];
}
$lastOdo = [];
foreach ($odoRows as $row) {
    $vehicleId = (int)$row['vehicle_id'];
    $vehicleKey = (string)$vehicleId;
    $weekKey = date('o-W', strtotime($row['logged_at']));
    if (isset($lastOdo[$vehicleId]) && isset($weeklyKm[$weekKey])) {
        $delta = (int)$row['odometer_reading'] - $lastOdo[$vehicleId];
        if ($delta > 0 && $delta < 10000) {
            $weeklyKm[$weekKey]['km'] += $delta;
            $weeklyKmByVehicle['all'][$weekKey]['km'] += $delta;
            if (isset($weeklyKmByVehicle[$vehicleKey][$weekKey])) {
                $weeklyKmByVehicle[$vehicleKey][$weekKey]['km'] += $delta;
            }
        }
    }
    $lastOdo[$vehicleId] = (int)$row['odometer_reading'];
}
$maxKm = 1;
foreach ($weeklyKm as $week) {
    $maxKm = max($maxKm, (int)$week['km']);
}

$fuelConsumers = db_all("
    SELECT v.fleet_number, v.registration, SUM(fl.litres_filled) AS litres
    FROM fuel_logs fl
    JOIN vehicles v ON v.id = fl.vehicle_id
    WHERE YEAR(fl.log_date) = YEAR(CURDATE()) AND MONTH(fl.log_date) = MONTH(CURDATE())
    GROUP BY v.id, v.fleet_number, v.registration
    ORDER BY litres DESC
    LIMIT 6
");
$maxFuel = 1;
foreach ($fuelConsumers as $row) {
    $maxFuel = max($maxFuel, (float)$row['litres']);
}

$longestJobs = db_all("
    SELECT v.fleet_number, v.registration, jc.fault_description, jc.status,
           DATEDIFF(CURDATE(), jc.date_in) AS days_open
    FROM job_cards jc
    JOIN vehicles v ON v.id = jc.vehicle_id
    WHERE jc.status <> 'closed'
    ORDER BY days_open DESC
    LIMIT 6
");

$upcomingServices = db_all("
    SELECT fleet_number, registration, department, next_service_date,
           DATEDIFF(next_service_date, CURDATE()) AS due_in
    FROM vehicles
    WHERE status <> 'decommissioned' AND next_service_date IS NOT NULL
    ORDER BY next_service_date
    LIMIT 6
");

$fleetChartLabels = [];
$fleetChartData = [];
foreach ($fleetStatus as $row) {
    $fleetChartLabels[] = ucwords(str_replace('_', ' ', $row['status']));
    $fleetChartData[] = (int)$row['total'];
}

$downtimeLabels = [];
$downtimeData = [];
foreach ($downtimeByDepartment as $row) {
    $downtimeLabels[] = $row['department'];
    $downtimeData[] = (int)$row['days'];
}

$jobLabels = [];
$jobsOpenedData = [];
$jobsClosedData = [];
foreach ($jobsTimeline as $month) {
    $jobLabels[] = $month['label'];
    $jobsOpenedData[] = (int)$month['opened'];
    $jobsClosedData[] = (int)$month['closed'];
}

$weeklyKmLabels = [];
$weeklyKmData = [];
foreach ($weeklyKm as $week) {
    $weeklyKmLabels[] = $week['label'];
    $weeklyKmData[] = (int)$week['km'];
}

$weeklyKmDatasets = [];
foreach ($weeklyKmByVehicle as $key => $weeks) {
    $weeklyKmDatasets[$key] = [
        'label' => $weeklyVehicleOptions[$key] ?? 'Vehicle',
        'data' => array_map(function ($week) {
            return (int)$week['km'];
        }, array_values($weeks)),
    ];
}

$fuelLabels = [];
$fuelData = [];
foreach ($fuelConsumers as $row) {
    $fuelLabels[] = $row['registration'];
    $fuelData[] = round((float)$row['litres'], 1);
}

include __DIR__ . '/header.php';
include __DIR__ . '/sidebar.php';
?>
<div class="dash-grid" style="display:grid;grid-template-columns:repeat(4,minmax(220px,1fr));gap:22px;margin:0 0 24px;">
    <article class="metric-card" style="min-height:174px;display:grid;grid-template-columns:58px minmax(0,1fr);align-items:start;gap:22px;background:#fff;border:1px solid #dbe3ef;border-radius:18px;padding:30px 34px;box-shadow:0 1px 2px rgba(15,23,42,.05);">
        <div class="metric-icon blue" style="width:58px;height:58px;display:grid;place-items:center;border-radius:10px;background:#dbeafe;color:#3b82f6;"><?= fd_icon('truck') ?></div>
        <div class="metric-copy" style="display:grid;gap:12px;padding-top:8px;">
            <strong style="display:block;color:#020617;font-size:30px;line-height:.72;font-weight:900;letter-spacing:.02em;"><?= e($totalFleet) ?></strong>
            <span style="display:block;color:#53657f;font-size:15px;line-height:1.4;font-weight:500;">Total Fleet</span>
            <small style="display:block;color:#94a3b8;font-size:16px;line-height:1.3;font-weight:500;"><?= e($activeFleet) ?> active</small>
        </div>
    </article>
    <article class="metric-card" style="min-height:174px;display:grid;grid-template-columns:58px minmax(0,1fr);align-items:start;gap:22px;background:#fff;border:1px solid #dbe3ef;border-radius:18px;padding:30px 34px;box-shadow:0 1px 2px rgba(15,23,42,.05);">
        <div class="metric-icon amber" style="width:58px;height:58px;display:grid;place-items:center;border-radius:10px;background:#fef3c7;color:#f59e0b;"><?= fd_icon('tool') ?></div>
        <div class="metric-copy" style="display:grid;gap:12px;padding-top:8px;">
            <strong style="display:block;color:#020617;font-size:30px;line-height:.72;font-weight:900;letter-spacing:.02em;"><?= e($inWorkshop) ?></strong>
            <span style="display:block;color:#53657f;font-size:15px;line-height:1.4;font-weight:500;">In Workshop</span>
            <small style="display:block;color:#94a3b8;font-size:16px;line-height:1.3;font-weight:500;"><?= pct($inWorkshop, $totalFleet) ?>% of fleet</small>
        </div>
    </article>
    <article class="metric-card" style="min-height:174px;display:grid;grid-template-columns:58px minmax(0,1fr);align-items:start;gap:22px;background:#fff;border:1px solid #dbe3ef;border-radius:18px;padding:30px 34px;box-shadow:0 1px 2px rgba(15,23,42,.05);">
        <div class="metric-icon rose" style="width:58px;height:58px;display:grid;place-items:center;border-radius:10px;background:#fee2e2;color:#ef4444;"><?= fd_icon('clock') ?></div>
        <div class="metric-copy" style="display:grid;gap:12px;padding-top:8px;">
            <strong style="display:block;color:#020617;font-size:30px;line-height:.72;font-weight:900;letter-spacing:.02em;"><?= e($activeDowntimeDays) ?></strong>
            <span style="display:block;color:#53657f;font-size:15px;line-height:1.4;font-weight:500;">Active Downtime Days</span>
            <small style="display:block;color:#94a3b8;font-size:16px;line-height:1.3;font-weight:500;"><?= e($openJobs) ?> open jobs</small>
        </div>
    </article>
    <article class="metric-card" style="min-height:174px;display:grid;grid-template-columns:58px minmax(0,1fr);align-items:start;gap:22px;background:#fff;border:1px solid #dbe3ef;border-radius:18px;padding:30px 34px;box-shadow:0 1px 2px rgba(15,23,42,.05);">
        <div class="metric-icon violet" style="width:58px;height:58px;display:grid;place-items:center;border-radius:10px;background:#ede9fe;color:#8b5cf6;"><?= fd_icon('bar-chart') ?></div>
        <div class="metric-copy" style="display:grid;gap:12px;padding-top:8px;">
            <strong style="display:block;color:#020617;font-size:30px;line-height:.72;font-weight:900;letter-spacing:.02em;"><?= e($awaitingParts) ?></strong>
            <span style="display:block;color:#53657f;font-size:15px;line-height:1.4;font-weight:500;">Awaiting Parts</span>
            <small style="display:block;color:#94a3b8;font-size:16px;line-height:1.3;font-weight:500;"><?= e($awaitingParts) ?> alerts</small>
        </div>
    </article>
</div>

<div class="dashboard-layout">
    <section class="panel">
        <h2>Fleet Status</h2>
        <div class="chart-split">
            <div class="mini-card-list">
                <?php foreach ($fleetStatus as $row): ?>
                    <article class="mini-card status-card <?= e($row['status']) ?>">
                        <span><i class="dot <?= e($row['status']) ?>"></i><?= e(ucwords(str_replace('_', ' ', $row['status']))) ?></span>
                        <strong><?= e($row['total']) ?></strong>
                    </article>
                <?php endforeach; ?>
            </div>
            <div class="chart-box small"><canvas id="fleetStatusChart"></canvas></div>
        </div>
    </section>

    <section class="panel">
        <h2>Downtime by Department</h2>
        <div class="chart-box"><canvas id="downtimeChart"></canvas></div>
        <div class="mini-card-list chart-summary">
            <?php
            $maxDowntime = 1;
            foreach ($downtimeByDepartment as $item) {
                $maxDowntime = max($maxDowntime, (int)$item['days']);
            }
            ?>
            <?php foreach ($downtimeByDepartment as $row): ?>
                <article class="mini-card">
                    <span><?= e($row['department']) ?></span>
                    <strong><?= e($row['days']) ?>d</strong>
                    <div class="mini-meter"><i style="width:<?= pct((int)$row['days'], $maxDowntime) ?>%"></i></div>
                </article>
            <?php endforeach; ?>
            <?php if (!$downtimeByDepartment): ?><p class="empty">No active downtime.</p><?php endif; ?>
        </div>
    </section>

    <section class="panel wide">
        <div class="panel-title-row">
            <h2>Jobs Opened vs Closed</h2>
            <span>Last 12 months</span>
        </div>
        <div class="chart-box tall"><canvas id="jobsTimelineChart"></canvas></div>
    </section>

    <section class="panel wide">
        <div class="panel-title-row">
            <h2>Weekly KM Covered</h2>
            <select class="select dashboard-select" id="weeklyKmVehicle">
                <?php foreach ($weeklyVehicleOptions as $value => $label): ?>
                    <option value="<?= e($value) ?>"><?= e($label) ?></option>
                <?php endforeach; ?>
            </select>
        </div>
        <div class="chart-box tall"><canvas id="weeklyKmChart"></canvas></div>
    </section>

    <section class="panel">
        <div class="panel-title-row">
            <h2>Fuel - Top Consumers</h2>
            <span>This month (litres)</span>
        </div>
        <div class="chart-box"><canvas id="fuelConsumersChart"></canvas></div>
        <div class="mini-card-list chart-summary">
            <?php foreach ($fuelConsumers as $row): ?>
                <article class="mini-card">
                    <span><?= e($row['registration']) ?></span>
                    <strong><?= e(number_format((float)$row['litres'], 1)) ?>L</strong>
                    <div class="mini-meter fuel"><i style="width:<?= pct((float)$row['litres'], $maxFuel) ?>%"></i></div>
                </article>
            <?php endforeach; ?>
            <?php if (!$fuelConsumers): ?><p class="empty">No fuel logs this month.</p><?php endif; ?>
        </div>
    </section>

    <section class="panel">
        <div class="panel-title-row">
            <h2>Longest Running Open Jobs</h2>
            <a class="view-all-link" href="<?= e(BASE_URL) ?>/jobs.php">View all</a>
        </div>
        <div class="table-wrap compact-table">
            <table>
                <thead><tr><th>Vehicle</th><th>Fault</th><th>Days</th><th>Status</th></tr></thead>
                <tbody>
                    <?php foreach ($longestJobs as $job): ?>
                        <tr>
                            <td><?= e($job['fleet_number']) ?></td>
                            <td><?= e(clip_text($job['fault_description'])) ?></td>
                            <td><?= e($job['days_open']) ?></td>
                            <td><span class="badge <?= e($job['status']) ?>"><?= e(str_replace('_', ' ', $job['status'])) ?></span></td>
                        </tr>
                    <?php endforeach; ?>
                    <?php if (!$longestJobs): ?><tr><td colspan="4" class="empty">No open jobs.</td></tr><?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>

    <section class="panel wide">
        <div class="panel-title-row">
            <h2>Upcoming Services</h2>
            <a class="view-all-link" href="<?= e(BASE_URL) ?>/services.php">View all</a>
        </div>
        <div class="table-wrap compact-table">
            <table>
                <thead><tr><th>Vehicle</th><th>Department</th><th>Due Date</th><th>In</th></tr></thead>
                <tbody>
                    <?php foreach ($upcomingServices as $service): ?>
                        <tr>
                            <td><?= e($service['fleet_number']) ?> <span class="muted"><?= e($service['registration']) ?></span></td>
                            <td><?= e($service['department']) ?></td>
                            <td><?= e(short_date($service['next_service_date'])) ?></td>
                            <td><?= e((int)$service['due_in']) ?> days</td>
                        </tr>
                    <?php endforeach; ?>
                    <?php if (!$upcomingServices): ?><tr><td colspan="4" class="empty">No upcoming services.</td></tr><?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>
</div>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
const fleetLabels = <?= json_encode($fleetChartLabels) ?>;
const fleetData = <?= json_encode($fleetChartData) ?>;
const downtimeLabels = <?= json_encode($downtimeLabels) ?>;
const downtimeData = <?= json_encode($downtimeData) ?>;
const jobLabels = <?= json_encode($jobLabels) ?>;
const jobsOpenedData = <?= json_encode($jobsOpenedData) ?>;
const jobsClosedData = <?= json_encode($jobsClosedData) ?>;
const weeklyKmLabels = <?= json_encode($weeklyKmLabels) ?>;
const weeklyKmData = <?= json_encode($weeklyKmData) ?>;
const weeklyKmDatasets = <?= json_encode($weeklyKmDatasets) ?>;
const fuelLabels = <?= json_encode($fuelLabels) ?>;
const fuelData = <?= json_encode($fuelData) ?>;

function makeChart(id, config) {
    const el = document.getElementById(id);
    if (!el || typeof Chart === 'undefined') return;
    return new Chart(el, config);
}

const gridColour = '#e2e8f0';
const textColour = '#475569';

makeChart('fleetStatusChart', {
    type: 'doughnut',
    data: {
        labels: fleetLabels,
        datasets: [{
            data: fleetData,
            backgroundColor: ['#16a34a', '#f59e0b', '#7c3aed', '#94a3b8'],
            borderWidth: 0
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: '62%',
        plugins: { legend: { display: false } }
    }
});

makeChart('downtimeChart', {
    type: 'bar',
    data: {
        labels: downtimeLabels,
        datasets: [{ label: 'Days', data: downtimeData, backgroundColor: '#2563eb', borderRadius: 6 }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        indexAxis: 'y',
        scales: {
            x: { beginAtZero: true, grid: { color: gridColour }, ticks: { color: textColour, precision: 0 } },
            y: { grid: { display: false }, ticks: { color: textColour } }
        },
        plugins: { legend: { display: false } }
    }
});

makeChart('jobsTimelineChart', {
    type: 'bar',
    data: {
        labels: jobLabels,
        datasets: [
            { label: 'Opened', data: jobsOpenedData, backgroundColor: '#2563eb', borderRadius: 5 },
            { label: 'Closed', data: jobsClosedData, backgroundColor: '#16a34a', borderRadius: 5 }
        ]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
            x: { grid: { display: false }, ticks: { color: textColour } },
            y: { beginAtZero: true, grid: { color: gridColour }, ticks: { color: textColour, precision: 0 } }
        },
        plugins: { legend: { labels: { color: textColour, boxWidth: 10, boxHeight: 10 } } }
    }
});

const weeklyKmChart = makeChart('weeklyKmChart', {
    type: 'line',
    data: {
        labels: weeklyKmLabels,
        datasets: [{
            label: 'KM covered',
            data: weeklyKmData,
            borderColor: '#2563eb',
            backgroundColor: 'rgba(37, 99, 235, .14)',
            fill: true,
            tension: .35,
            pointRadius: 3
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
            x: { grid: { display: false }, ticks: { color: textColour } },
            y: { beginAtZero: true, grid: { color: gridColour }, ticks: { color: textColour, precision: 0 } }
        },
        plugins: { legend: { display: false } }
    }
});

const weeklyKmVehicle = document.getElementById('weeklyKmVehicle');
if (weeklyKmVehicle && weeklyKmChart) {
    weeklyKmVehicle.addEventListener('change', function () {
        const selected = weeklyKmDatasets[this.value] || weeklyKmDatasets.all;
        weeklyKmChart.data.datasets[0].label = selected.label;
        weeklyKmChart.data.datasets[0].data = selected.data;
        weeklyKmChart.update();
    });
}

makeChart('fuelConsumersChart', {
    type: 'bar',
    data: {
        labels: fuelLabels,
        datasets: [{ label: 'Litres', data: fuelData, backgroundColor: '#0f766e', borderRadius: 6 }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        indexAxis: 'y',
        scales: {
            x: { beginAtZero: true, grid: { color: gridColour }, ticks: { color: textColour } },
            y: { grid: { display: false }, ticks: { color: textColour } }
        },
        plugins: { legend: { display: false } }
    }
});
</script>
<?php include __DIR__ . '/footer.php'; ?>
