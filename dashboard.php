<?php
require_once __DIR__ . '/auth_check.php';
require_once __DIR__ . '/db.php';

$page_title   = 'Dashboard';
$page_heading = 'Dashboard';

function pct($value, $total) { return $total > 0 ? (int)round(($value / $total) * 100) : 0; }
function short_date($date)   { return $date ? date('d M Y', strtotime($date)) : '-'; }
function clip_text($text, $limit = 42) {
    $text = (string)$text;
    return strlen($text) > $limit ? substr($text, 0, $limit - 3) . '...' : $text;
}

// ── KPIs ────────────────────────────────────────────────────
$totalFleet     = (int)db_value('SELECT COUNT(*) FROM vehicles');
$activeFleet    = (int)db_value("SELECT COUNT(*) FROM vehicles WHERE status = 'active'");
$inWorkshop     = (int)db_value("SELECT COUNT(*) FROM vehicles WHERE status = 'in_workshop'");
$awaitingParts  = (int)db_value("SELECT COUNT(*) FROM vehicles WHERE status = 'awaiting_parts'");
$openJobs       = (int)db_value("SELECT COUNT(*) FROM job_cards WHERE status <> 'closed'");
$activeDowntime = (int)db_value("SELECT COALESCE(SUM(DATEDIFF(CURDATE(), date_in)), 0) FROM job_cards WHERE status <> 'closed'");

// ── Fleet status chart data ──────────────────────────────────
$fleetStatus = db_all("
    SELECT status, COUNT(*) AS total
    FROM vehicles GROUP BY status
    ORDER BY FIELD(status,'active','in_workshop','awaiting_parts','decommissioned')
");

// ── Vehicles by status (for drill-down) ─────────────────────
$vehiclesByStatus = [];
foreach (db_all("SELECT id, fleet_number, registration, make, model, department, status FROM vehicles ORDER BY fleet_number") as $v) {
    $vehiclesByStatus[$v['status']][] = $v;
}

// ── Downtime by dept ─────────────────────────────────────────
$downtimeByDept = db_all("
    SELECT COALESCE(v.department,'Unassigned') AS department,
           COALESCE(SUM(DATEDIFF(CURDATE(), jc.date_in)),0) AS days,
           COUNT(jc.id) AS job_count
    FROM job_cards jc
    JOIN vehicles v ON v.id = jc.vehicle_id
    WHERE jc.status <> 'closed'
    GROUP BY COALESCE(v.department,'Unassigned')
    ORDER BY days DESC LIMIT 6
");

// ── Vehicles by dept (for drill-down) ───────────────────────
$vehiclesByDept = [];
foreach (db_all("
    SELECT COALESCE(v.department,'Unassigned') AS department,
           v.fleet_number, v.registration, v.make, v.model, v.status,
           DATEDIFF(CURDATE(), jc.date_in) AS days_open,
           jc.fault_description
    FROM job_cards jc
    JOIN vehicles v ON v.id = jc.vehicle_id
    WHERE jc.status <> 'closed'
    ORDER BY days_open DESC
") as $r) {
    $vehiclesByDept[$r['department']][] = $r;
}

// ── Jobs timeline ────────────────────────────────────────────
$jobsTimelineRows = db_all("
    SELECT DATE_FORMAT(date_in,'%Y-%m') AS month_key, COUNT(*) AS opened, 0 AS closed
    FROM job_cards WHERE date_in >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    GROUP BY DATE_FORMAT(date_in,'%Y-%m')
    UNION ALL
    SELECT DATE_FORMAT(date_closed,'%Y-%m') AS month_key, 0 AS opened, COUNT(*) AS closed
    FROM job_cards WHERE date_closed IS NOT NULL AND date_closed >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    GROUP BY DATE_FORMAT(date_closed,'%Y-%m')
");
$jobsTimeline = [];
for ($i = 11; $i >= 0; $i--) {
    $key = date('Y-m', strtotime("-$i months"));
    $jobsTimeline[$key] = ['label' => date('M y', strtotime($key.'-01')), 'opened' => 0, 'closed' => 0];
}
foreach ($jobsTimelineRows as $row) {
    if (isset($jobsTimeline[$row['month_key']])) {
        $jobsTimeline[$row['month_key']]['opened'] += (int)$row['opened'];
        $jobsTimeline[$row['month_key']]['closed'] += (int)$row['closed'];
    }
}

// ── Weekly KM ────────────────────────────────────────────────
$odoRows = db_all("SELECT vehicle_id, odometer_reading, logged_at FROM odometer_logs WHERE logged_at >= DATE_SUB(CURDATE(), INTERVAL 14 WEEK) ORDER BY vehicle_id, logged_at, id");
$vehicleRows = db_all("SELECT id, fleet_number, registration FROM vehicles WHERE status <> 'decommissioned' ORDER BY fleet_number");
$weeklyKm = [];
for ($i = 11; $i >= 0; $i--) {
    $key = date('o-W', strtotime("-$i weeks"));
    $weeklyKm[$key] = ['label' => date('M d', strtotime("-$i weeks")), 'km' => 0];
}
$weeklyKmByVehicle = ['all' => $weeklyKm];
$weeklyVehicleOptions = ['all' => 'Fleet total'];
foreach ($vehicleRows as $v) {
    $weeklyKmByVehicle[(string)$v['id']] = $weeklyKm;
    $weeklyVehicleOptions[(string)$v['id']] = $v['registration'].' - '.$v['fleet_number'];
}
$lastOdo = [];
foreach ($odoRows as $row) {
    $vid = (int)$row['vehicle_id']; $vk = (string)$vid;
    $wk  = date('o-W', strtotime($row['logged_at']));
    if (isset($lastOdo[$vid]) && isset($weeklyKm[$wk])) {
        $delta = (int)$row['odometer_reading'] - $lastOdo[$vid];
        if ($delta > 0 && $delta < 10000) {
            $weeklyKmByVehicle['all'][$wk]['km'] += $delta;
            if (isset($weeklyKmByVehicle[$vk][$wk])) $weeklyKmByVehicle[$vk][$wk]['km'] += $delta;
        }
    }
    $lastOdo[$vid] = (int)$row['odometer_reading'];
}

// ── Fuel monthly totals (last 12 months) ────────────────────
$fuelMonthlyRows = db_all("
    SELECT DATE_FORMAT(log_date,'%Y-%m') AS month_key, SUM(litres_filled) AS total_litres
    FROM fuel_logs
    WHERE log_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    GROUP BY DATE_FORMAT(log_date,'%Y-%m')
    ORDER BY month_key ASC
");
$fuelMonthly = [];
for ($i = 11; $i >= 0; $i--) {
    $key = date('Y-m', strtotime("-$i months"));
    $fuelMonthly[$key] = ['label' => date('M y', strtotime($key.'-01')), 'litres' => 0];
}
foreach ($fuelMonthlyRows as $row) {
    if (isset($fuelMonthly[$row['month_key']])) {
        $fuelMonthly[$row['month_key']]['litres'] = round((float)$row['total_litres'], 1);
    }
}

// Per-vehicle monthly fuel (for the "Monthly Fuel" vehicle filter dropdown)
$fuelByVehicle = ['all' => array_values(array_column($fuelMonthly, 'litres'))];
foreach ($vehicleRows as $vr) {
    $vid = (int)$vr['id'];
    $vm  = array_fill_keys(array_keys($fuelMonthly), 0);
    $rows2 = db_all("
        SELECT DATE_FORMAT(log_date,'%Y-%m') AS mk, SUM(litres_filled) AS total
        FROM fuel_logs
        WHERE vehicle_id = ? AND log_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
        GROUP BY mk
    ", 'i', [$vid]);
    foreach ($rows2 as $r) {
        if (isset($vm[$r['mk']])) $vm[$r['mk']] = round((float)$r['total'], 1);
    }
    $fuelByVehicle[(string)$vid] = array_values($vm);
}

// ── Fuel depot balance ───────────────────────────────────────
$depotBalances = [];
try {
    $depotBalances = db_all("
        SELECT fuel_type, dip_litres, reading_date
        FROM fuel_depot_readings fdr1
        WHERE id = (
            SELECT id FROM fuel_depot_readings fdr2
            WHERE fdr2.fuel_type = fdr1.fuel_type
            ORDER BY reading_date DESC, id DESC LIMIT 1
        )
    ");
} catch (Throwable $e) {
    $depotBalances = [];
}
$depotByType = [];
foreach ($depotBalances as $d) $depotByType[$d['fuel_type']] = $d;

// ── Longest jobs + upcoming services ─────────────────────────
$longestJobs = db_all("
    SELECT v.fleet_number, v.registration, jc.fault_description, jc.status,
           DATEDIFF(CURDATE(), jc.date_in) AS days_open
    FROM job_cards jc JOIN vehicles v ON v.id = jc.vehicle_id
    WHERE jc.status <> 'closed' ORDER BY days_open DESC LIMIT 6
");
$upcomingServices = db_all("
    SELECT due.* FROM (
        SELECT v.id, v.fleet_number, v.registration, v.department, v.next_service_date, v.next_service_mileage,
               COALESCE((SELECT x.odometer_reading FROM (
                   SELECT ol.vehicle_id, ol.odometer_reading, ol.logged_at AS ra, ol.id AS si FROM odometer_logs ol
                   UNION ALL SELECT sr.vehicle_id, sr.odometer_at_service, CONCAT(sr.service_date,' 12:00:00'), sr.id FROM service_records sr WHERE sr.odometer_at_service IS NOT NULL
                   UNION ALL SELECT fl.vehicle_id, fl.odometer_at_fill, CONCAT(fl.log_date,' 12:00:00'), fl.id FROM fuel_logs fl
               ) x WHERE x.vehicle_id = v.id ORDER BY x.ra DESC, x.si DESC LIMIT 1), 0) AS current_odometer,
               DATEDIFF(v.next_service_date, CURDATE()) AS due_in,
               CASE WHEN v.next_service_mileage IS NULL THEN NULL
                    ELSE v.next_service_mileage - COALESCE((SELECT x.odometer_reading FROM (
                        SELECT ol.vehicle_id, ol.odometer_reading, ol.logged_at AS ra, ol.id AS si FROM odometer_logs ol
                        UNION ALL SELECT sr.vehicle_id, sr.odometer_at_service, CONCAT(sr.service_date,' 12:00:00'), sr.id FROM service_records sr WHERE sr.odometer_at_service IS NOT NULL
                        UNION ALL SELECT fl.vehicle_id, fl.odometer_at_fill, CONCAT(fl.log_date,' 12:00:00'), fl.id FROM fuel_logs fl
                    ) x WHERE x.vehicle_id = v.id ORDER BY x.ra DESC, x.si DESC LIMIT 1), 0) END AS km_remaining
        FROM vehicles v WHERE v.status <> 'decommissioned'
    ) due
    WHERE (due.next_service_date IS NOT NULL AND due.next_service_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY))
       OR (due.next_service_mileage IS NOT NULL AND due.current_odometer > 0 AND due.km_remaining <= 1000)
    ORDER BY CASE WHEN due.km_remaining IS NOT NULL AND due.km_remaining < 0 THEN 0
                  WHEN due.due_in IS NOT NULL AND due.due_in < 0 THEN 1
                  WHEN due.km_remaining IS NOT NULL AND due.km_remaining <= 1000 THEN 2 ELSE 3 END,
             due.due_in ASC, due.km_remaining ASC LIMIT 8
");

// ── Upcoming tyre changes ───────────────────────────────────
$upcomingTyres = db_all("
    SELECT v.fleet_number, v.registration, v.department,
           tcl.change_date AS last_change, tcl.expected_lifespan_km,
           COALESCE((SELECT x.odometer_reading FROM (
               SELECT ol.vehicle_id, ol.odometer_reading, ol.logged_at AS ra FROM odometer_logs ol
               UNION ALL SELECT fl.vehicle_id, fl.odometer_at_fill, CONCAT(fl.log_date,' 12:00:00') FROM fuel_logs fl
           ) x WHERE x.vehicle_id = v.id ORDER BY x.ra DESC LIMIT 1), 0) AS current_odometer,
           tcl.tyre_type, tcl.tyre_size
    FROM tyre_change_logs tcl
    JOIN vehicles v ON v.id = tcl.vehicle_id
    WHERE tcl.expected_lifespan_km IS NOT NULL
    ORDER BY (
        COALESCE((SELECT x.odometer_reading FROM (
            SELECT ol.vehicle_id, ol.odometer_reading, ol.logged_at AS ra FROM odometer_logs ol
            UNION ALL SELECT fl.vehicle_id, fl.odometer_at_fill, CONCAT(fl.log_date,' 12:00:00') FROM fuel_logs fl
        ) x WHERE x.vehicle_id = v.id ORDER BY x.ra DESC LIMIT 1), 0) -
        tcl.odometer - tcl.expected_lifespan_km
    ) DESC LIMIT 6
");

// ── Upcoming battery changes ─────────────────────────────────
$upcomingBatteries = db_all("
    SELECT v.fleet_number, v.registration, v.department,
           bcl.change_date AS last_change, bcl.expected_lifespan_months,
           bcl.battery_size, bcl.battery_type,
           PERIOD_DIFF(DATE_FORMAT(CURDATE(),'%Y%m'), DATE_FORMAT(bcl.change_date,'%Y%m')) AS months_used
    FROM battery_change_logs bcl
    JOIN vehicles v ON v.id = bcl.vehicle_id
    WHERE bcl.expected_lifespan_months IS NOT NULL
      AND PERIOD_DIFF(DATE_FORMAT(CURDATE(),'%Y%m'), DATE_FORMAT(bcl.change_date,'%Y%m')) >= (bcl.expected_lifespan_months - 2)
    ORDER BY months_used DESC LIMIT 6
");

// ── PHP → JS data ────────────────────────────────────────────
$fleetLabels   = array_map(fn($r) => ucwords(str_replace('_',' ',$r['status'])), $fleetStatus);
$fleetData     = array_map(fn($r) => (int)$r['total'], $fleetStatus);
$fleetStatuses = array_column($fleetStatus, 'status');
$downtimeLbls  = array_column($downtimeByDept, 'department');
$downtimeData  = array_map(fn($r) => (int)$r['days'], $downtimeByDept);
$jobLabels     = array_map(fn($m) => $m['label'], array_values($jobsTimeline));
$jobsOpened    = array_map(fn($m) => (int)$m['opened'], array_values($jobsTimeline));
$jobsClosed    = array_map(fn($m) => (int)$m['closed'], array_values($jobsTimeline));
$weeklyLabels  = array_map(fn($w) => $w['label'], array_values(reset($weeklyKmByVehicle)));
$weeklyDatasets = [];
foreach ($weeklyKmByVehicle as $key => $weeks) {
    $weeklyDatasets[$key] = ['label' => $weeklyVehicleOptions[$key] ?? 'Vehicle', 'data' => array_map(fn($w) => (int)$w['km'], array_values($weeks))];
}
$fuelLabels    = array_map(fn($m) => $m['label'], array_values($fuelMonthly));
$fuelLitres    = array_map(fn($m) => $m['litres'], array_values($fuelMonthly));

include __DIR__ . '/header.php';
include __DIR__ . '/sidebar.php';
?>
<meta name="google-site-verification" content="TyPxQjuEjnElCKSS-ABW195LVWh0cGYLsJqPi6hlxng" />
<!-- ── KPI Cards ─────────────────────────────────────────── -->
<div class="dash-grid" style="display:grid;grid-template-columns:repeat(4,minmax(220px,1fr));gap:22px;margin:0 0 24px;">
    <?php
    $kpis = [
        ['blue',   'truck',     $totalFleet,     'Total Fleet',           $activeFleet . ' active'],
        ['amber',  'tool',      $inWorkshop,     'In Workshop',           pct($inWorkshop,$totalFleet) . '% of fleet'],
        ['rose',   'clock',     $activeDowntime, 'Active Downtime Days',  $openJobs . ' open jobs'],
        ['violet', 'bar-chart', $awaitingParts,  'Awaiting Parts',        $awaitingParts . ' alerts'],
    ];
    foreach ($kpis as [$colour,$icon,$val,$label,$sub]):
    ?>
    <article style="min-height:174px;display:grid;grid-template-columns:58px minmax(0,1fr);align-items:start;gap:22px;background:#fff;border:1px solid #dbe3ef;border-radius:18px;padding:30px 34px;box-shadow:0 1px 2px rgba(15,23,42,.05);">
        <div style="width:58px;height:58px;display:grid;place-items:center;border-radius:10px;background:var(--<?=e($colour)?>-light,#dbeafe);color:var(--<?=e($colour)?>,#3b82f6);"><?= fd_icon($icon) ?></div>
        <div style="display:grid;gap:12px;padding-top:8px;">
            <strong style="font-size:30px;line-height:.72;font-weight:900;color:#020617;"><?= e($val) ?></strong>
            <span style="color:#53657f;font-size:15px;font-weight:500;"><?= e($label) ?></span>
            <small style="color:#94a3b8;font-size:14px;"><?= e($sub) ?></small>
        </div>
    </article>
    <?php endforeach; ?>
</div>

<div class="dashboard-layout">

    <!-- ── Fleet Status (with drill-down) ──────────────────── -->
    <section class="panel" id="fleetStatusPanel">
        <div class="panel-title-row">
            <h2>Fleet Status</h2>
            <button class="btn btn-small" id="fleetDrillBack" style="display:none;">← Back</button>
        </div>
        <!-- Donut centered, legend below -->
        <div id="fleetStatusView">
            <div style="width:180px;height:180px;position:relative;margin:0 auto 16px;">
                <canvas id="fleetStatusChart"></canvas>
                <div style="position:absolute;inset:0;display:grid;place-items:center;pointer-events:none;">
                    <span id="fleetDonutTotal" style="font-size:24px;font-weight:800;color:#020617;"><?= $totalFleet ?></span>
                </div>
            </div>
            <div style="display:grid;gap:4px;">
                <?php
                $statusColours = ['active'=>'#16a34a','in_workshop'=>'#f59e0b','awaiting_parts'=>'#7c3aed','decommissioned'=>'#94a3b8'];
                foreach ($fleetStatus as $row):
                    $col = $statusColours[$row['status']] ?? '#94a3b8';
                    $pct = pct((int)$row['total'], $totalFleet);
                ?>
                <div class="fleet-legend-item" data-status="<?= e($row['status']) ?>"
                     style="display:flex;align-items:center;gap:10px;padding:7px 10px;border-radius:8px;cursor:pointer;margin-bottom:4px;transition:background .15s;"
                     onmouseover="this.style.background='#f1f5f9'" onmouseout="this.style.background=''">
                    <span style="width:12px;height:12px;border-radius:50%;background:<?= e($col) ?>;flex-shrink:0;"></span>
                    <span style="flex:1;font-size:13px;color:#374151;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"><?= e(ucwords(str_replace('_',' ',$row['status']))) ?></span>
                    <strong style="font-size:14px;color:#020617;"><?= e($row['total']) ?></strong>
                    <span style="font-size:12px;color:#94a3b8;width:34px;text-align:right;"><?= $pct ?>%</span>
                </div>
                <?php endforeach; ?>
            </div>
        </div>
        <!-- Drill-down list (hidden initially) -->
        <div id="fleetDrillView" style="display:none;">
            <div id="fleetDrillList" style="max-height:280px;overflow-y:auto;"></div>
        </div>
    </section>

    <!-- ── Downtime by Department (with drill-down) ─────────── -->
    <section class="panel" id="downtimePanel">
        <div class="panel-title-row">
            <h2 id="downtimeTitle">Downtime by Department</h2>
            <button class="btn btn-small" id="downtimeDrillBack" style="display:none;">← Back</button>
        </div>
        <div id="downtimeChartView">
            <div class="chart-box"><canvas id="downtimeChart"></canvas></div>
        </div>
        <div id="downtimeDrillView" style="display:none;">
            <div id="downtimeDrillList" style="max-height:320px;overflow-y:auto;"></div>
        </div>
    </section>

    <!-- ── Jobs Opened vs Closed ─────────────────────────────── -->
    <section class="panel wide">
        <div class="panel-title-row"><h2>Jobs Opened vs Closed</h2><span>Last 12 months</span></div>
        <div class="chart-box tall"><canvas id="jobsTimelineChart"></canvas></div>
    </section>

    <!-- ── Weekly KM ─────────────────────────────────────────── -->
    <section class="panel wide">
        <div class="panel-title-row">
            <h2>Weekly KM Covered</h2>
            <select class="select dashboard-select" id="weeklyKmVehicle">
                <?php foreach ($weeklyVehicleOptions as $v => $l): ?>
                    <option value="<?= e($v) ?>"><?= e($l) ?></option>
                <?php endforeach; ?>
            </select>
        </div>
        <div class="chart-box tall"><canvas id="weeklyKmChart"></canvas></div>
    </section>

    <!-- ── Fuel Monthly Totals ───────────────────────────────── -->
    <section class="panel">
        <div class="panel-title-row">
            <h2>Monthly Fuel (Litres)</h2>
            <select class="select dashboard-select" id="fuelVehicleFilter" style="font-size:12px;min-width:150px;">
                <option value="">All vehicles</option>
                <?php foreach ($vehicleRows as $vr): ?>
                <option value="<?= e($vr['id']) ?>"><?= e($vr['fleet_number']) ?> — <?= e($vr['registration']) ?></option>
                <?php endforeach; ?>
            </select>
        </div>
        <div class="chart-box"><canvas id="fuelMonthlyChart"></canvas></div>
    </section>

    <!-- ── Fuel Depot Tank Visualisation (redesigned) ────────── -->
    <section class="panel">
        <div class="panel-title-row">
            <h2>Depot Fuel Balance</h2>
            <div style="display:flex;gap:10px;align-items:center;">
                <button class="btn btn-small" type="button" id="openFuelBalanceBtn"><?= fd_icon('plus') ?> Log Balance</button>
                <a class="view-all-link" href="<?= e(BASE_URL) ?>/fuel">Fuel Log</a>
            </div>
        </div>
        <div style="display:flex;gap:16px;justify-content:center;align-items:stretch;padding:14px 0 6px;flex-wrap:wrap;" id="tankContainer">
            <?php
            $tankCapacity = 6000; // adjust to your depot capacity
            $tankTypes = ['diesel' => ['label'=>'Diesel','colour'=>'#2563eb'], 'petrol' => ['label'=>'Petrol','colour'=>'#f59e0b']];
            $bodyTop = 12; $bodyHeight = 96; $bodyBottom = $bodyTop + $bodyHeight;
            foreach ($tankTypes as $ftype => $meta):
                $balance = isset($depotByType[$ftype]) ? (float)$depotByType[$ftype]['dip_litres'] : 0;
                $date    = isset($depotByType[$ftype]) ? $depotByType[$ftype]['reading_date'] : null;
                $fillPct = min(100, max(0, round(($balance / $tankCapacity) * 100)));
                $tankColour = $fillPct < 20 ? '#ef4444' : ($fillPct < 40 ? '#f59e0b' : $meta['colour']);
                $fillH = round(($fillPct / 100) * $bodyHeight);
                $fillY = $bodyBottom - $fillH;
            ?>
            <div class="tank-card" style="display:flex;flex-direction:column;align-items:center;gap:10px;background:#f8fafc;border:1px solid #e7ecf3;border-radius:14px;padding:16px 20px;min-width:118px;">
                <strong style="font-size:12px;font-weight:700;color:#374151;letter-spacing:.02em;text-transform:uppercase;"><?= e($meta['label']) ?></strong>
                <svg width="60" height="116" viewBox="0 0 60 116" xmlns="http://www.w3.org/2000/svg" style="display:block;">
                    <defs>
                        <clipPath id="tankClip-<?= e($ftype) ?>">
                            <rect x="5" y="<?= $bodyTop ?>" width="50" height="<?= $bodyHeight ?>" rx="11"/>
                        </clipPath>
                    </defs>
                    <rect x="5" y="<?= $bodyTop ?>" width="50" height="<?= $bodyHeight ?>" rx="11" fill="#eef2f7"/>
                    <rect class="tank-fill" data-base-y="<?= $fillY ?>" data-base-h="<?= $fillH ?>"
                          x="5" y="<?= $fillY ?>" width="50" height="<?= $fillH ?>"
                          clip-path="url(#tankClip-<?= e($ftype) ?>)" fill="<?= e($tankColour) ?>"></rect>
                    <?php foreach ([25,50,75] as $mark): $my = $bodyBottom - round(($mark / 100) * $bodyHeight); ?>
                    <line x1="5" y1="<?= $my ?>" x2="11" y2="<?= $my ?>" stroke="#cbd5e1" stroke-width="1.5"/>
                    <?php endforeach; ?>
                    <rect x="5" y="<?= $bodyTop ?>" width="50" height="<?= $bodyHeight ?>" rx="11" fill="none" stroke="#dde4ee" stroke-width="2"/>
                    <rect x="22" y="<?= $bodyTop - 6 ?>" width="16" height="6" rx="3" fill="#cbd5e1"/>
                </svg>
                <div style="text-align:center;">
                    <strong style="font-size:17px;color:<?= e($tankColour) ?>;"><?= number_format($balance, 0) ?>L</strong>
                    <div style="font-size:11px;color:#94a3b8;"><?= $fillPct ?>% full</div>
                    <?php if ($date): ?><div style="font-size:10px;color:#cbd5e1;"><?= short_date($date) ?></div><?php endif; ?>
                </div>
            </div>
            <?php endforeach; ?>
            <?php if (!$depotBalances): ?>
                <p style="color:#94a3b8;font-size:13px;text-align:center;padding:20px;">No dip readings recorded yet.<br>Use “Log Balance” above to record one.</p>
            <?php endif; ?>
        </div>
    </section>

    <!-- ── Longest Jobs ──────────────────────────────────────── -->
    <section class="panel wide">
        <div class="panel-title-row">
            <h2>Longest Running Open Jobs</h2>
            <a class="view-all-link" href="<?= e(BASE_URL) ?>/jobs">View all</a>
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
                        <td><span class="badge <?= e($job['status']) ?>"><?= e(str_replace('_',' ',$job['status'])) ?></span></td>
                    </tr>
                    <?php endforeach; ?>
                    <?php if (!$longestJobs): ?><tr><td colspan="4" class="empty">No open jobs.</td></tr><?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>

    <!-- ── Upcoming Services ─────────────────────────────────── -->
    <section class="panel wide">
        <div class="panel-title-row">
            <h2>Upcoming Services</h2>
            <a class="view-all-link" href="<?= e(BASE_URL) ?>/services">View all</a>
        </div>
        <div class="table-wrap compact-table">
            <table>
                <thead><tr><th>Vehicle</th><th>Department</th><th>Due Date</th><th>Current KM</th><th>Next KM</th><th>Due</th></tr></thead>
                <tbody>
                    <?php foreach ($upcomingServices as $svc):
                        $kmRem  = $svc['km_remaining'] === null ? null : (int)$svc['km_remaining'];
                        $daysRem= $svc['due_in'] === null ? null : (int)$svc['due_in'];
                        $dueLabel = 'Scheduled'; $dueClass = 'active';
                        if ($kmRem !== null && $kmRem < 0)          { $dueLabel = abs($kmRem).' km overdue';    $dueClass = 'critical'; }
                        elseif ($daysRem !== null && $daysRem < 0)  { $dueLabel = abs($daysRem).' days overdue';$dueClass = 'critical'; }
                        elseif ($kmRem !== null && $kmRem <= 1000)  { $dueLabel = $kmRem.' km left';            $dueClass = 'high'; }
                        elseif ($daysRem !== null)                  { $dueLabel = $daysRem===0?'Today':$daysRem.' days'; $dueClass = $daysRem<=7?'high':'active'; }
                    ?>
                    <tr>
                        <td><?= e($svc['fleet_number']) ?> <span class="muted"><?= e($svc['registration']) ?></span></td>
                        <td><?= e($svc['department']) ?></td>
                        <td><?= e(short_date($svc['next_service_date'])) ?></td>
                        <td><?= e(number_format((int)$svc['current_odometer'])) ?></td>
                        <td><?= $svc['next_service_mileage'] ? e(number_format((int)$svc['next_service_mileage'])) : '<span class="muted">-</span>' ?></td>
                        <td><span class="badge <?= e($dueClass) ?>"><?= e($dueLabel) ?></span></td>
                    </tr>
                    <?php endforeach; ?>
                    <?php if (!$upcomingServices): ?><tr><td colspan="6" class="empty">No upcoming services.</td></tr><?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>

    <!-- ── Upcoming Tyre Changes ─────────────────────────────── -->
    <section class="panel">
        <div class="panel-title-row">
            <h2>Upcoming Tyre Changes</h2>
            <a class="view-all-link" href="<?= e(BASE_URL) ?>/tyre-logs">View all</a>
        </div>
        <div class="table-wrap compact-table">
            <table>
                <thead><tr><th>Vehicle</th><th>Last Changed</th><th>Size / Type</th><th>Expected Life</th><th>Status</th></tr></thead>
                <tbody>
                    <?php foreach ($upcomingTyres as $t):
                        $odoUsed = (int)$t['current_odometer'] - 0; // relative calc approximation
                        $lifePct = $t['expected_lifespan_km'] ? min(100, round($odoUsed / $t['expected_lifespan_km'] * 100)) : null;
                        $cls = ($lifePct !== null && $lifePct >= 90) ? 'critical' : (($lifePct !== null && $lifePct >= 75) ? 'high' : 'active');
                    ?>
                    <tr>
                        <td><strong><?= e($t['fleet_number']) ?></strong> <span class="muted"><?= e($t['registration']) ?></span></td>
                        <td><?= e(short_date($t['last_change'])) ?></td>
                        <td><?= e($t['tyre_size'] ?? '—') ?> <span class="muted"><?= e($t['tyre_type'] ?? '') ?></span></td>
                        <td><?= e(number_format((int)$t['expected_lifespan_km'])) ?> km</td>
                        <td><span class="badge <?= e($cls) ?>"><?= $cls === 'critical' ? 'Due soon' : ($cls === 'high' ? 'Monitor' : 'OK') ?></span></td>
                    </tr>
                    <?php endforeach; ?>
                    <?php if (!$upcomingTyres): ?><tr><td colspan="5" class="empty">No tyre change records.</td></tr><?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>

    <!-- ── Upcoming Battery Changes ──────────────────────────── -->
    <section class="panel">
        <div class="panel-title-row">
            <h2>Upcoming Battery Changes</h2>
            <a class="view-all-link" href="<?= e(BASE_URL) ?>/battery-logs">View all</a>
        </div>
        <div class="table-wrap compact-table">
            <table>
                <thead><tr><th>Vehicle</th><th>Last Changed</th><th>Battery</th><th>Life (months)</th><th>Status</th></tr></thead>
                <tbody>
                    <?php foreach ($upcomingBatteries as $b):
                        $remaining = (int)$b['expected_lifespan_months'] - (int)$b['months_used'];
                        $cls = $remaining <= 0 ? 'critical' : ($remaining <= 2 ? 'high' : 'active');
                    ?>
                    <tr>
                        <td><strong><?= e($b['fleet_number']) ?></strong> <span class="muted"><?= e($b['registration']) ?></span></td>
                        <td><?= e(short_date($b['last_change'])) ?></td>
                        <td><?= e($b['battery_size'] ?? '—') ?> <span class="muted"><?= e($b['battery_type'] ?? '') ?></span></td>
                        <td><?= e($b['expected_lifespan_months']) ?> months</td>
                        <td><span class="badge <?= e($cls) ?>"><?= $remaining <= 0 ? 'Overdue' : $remaining . ' months left' ?></span></td>
                    </tr>
                    <?php endforeach; ?>
                    <?php if (!$upcomingBatteries): ?><tr><td colspan="5" class="empty">No battery records due soon.</td></tr><?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>

</div>

<!-- ── Fuel Balance Modal ────────────────────────────────── -->
<div class="modal-backdrop" id="fuelBalanceModal">
    <div class="modal" style="max-width:420px;">
        <header>
            <h2>Log Fuel Depot Balance</h2>
            <button class="btn btn-small" type="button" id="closeFuelBalance">Close</button>
        </header>
        <form id="fuelBalanceForm">
            <div class="form-grid">
                <div class="form-row">
                    <label>Date <span style="color:#ef4444">*</span></label>
                    <input class="input" name="reading_date" type="date" required id="balanceDate">
                </div>
                <div class="form-row">
                    <label>Fuel Type <span style="color:#ef4444">*</span></label>
                    <select class="select" name="fuel_type" required>
                        <option value="diesel">Diesel</option>
                        <option value="petrol">Petrol</option>
                        <option value="kerosene">Kerosene</option>
                        <option value="other">Other</option>
                    </select>
                </div>
                <div class="form-row">
                    <label>Dip Reading (Litres) <span style="color:#ef4444">*</span></label>
                    <input class="input" name="dip_litres" type="number" step="0.01" min="0" required placeholder="e.g. 4500">
                </div>
                <div class="form-row">
                    <label>Recorded By</label>
                    <input class="input" name="recorded_by" type="text" placeholder="Name of person taking reading">
                </div>
                <div class="form-row full">
                    <label>Notes</label>
                    <textarea name="notes" placeholder="e.g. Post-refill reading, mid-month dip…"></textarea>
                </div>
            </div>
            <footer>
                <button class="btn" type="button" id="cancelFuelBalance">Cancel</button>
                <button class="btn btn-primary" type="submit" id="saveFuelBalance">Save Reading</button>
            </footer>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
// ── Data from PHP ──────────────────────────────────────────
const fleetLabels    = <?= json_encode(array_values($fleetLabels)) ?>;
const fleetData      = <?= json_encode(array_values($fleetData)) ?>;
const fleetStatuses  = <?= json_encode(array_values($fleetStatuses)) ?>;
const downtimeLabels = <?= json_encode($downtimeLbls) ?>;
const downtimeData   = <?= json_encode($downtimeData) ?>;
const jobLabels      = <?= json_encode($jobLabels) ?>;
const jobsOpenedData = <?= json_encode($jobsOpened) ?>;
const jobsClosedData = <?= json_encode($jobsClosed) ?>;
const weeklyKmLabels = <?= json_encode($weeklyLabels) ?>;
const weeklyDatasets = <?= json_encode($weeklyDatasets) ?>;
const fuelLabels     = <?= json_encode($fuelLabels) ?>;
const fuelLitresData = <?= json_encode($fuelLitres) ?>;
const fuelByVehicle  = <?= json_encode($fuelByVehicle) ?>;

// Drill-down data
const vehiclesByStatus = <?= json_encode($vehiclesByStatus) ?>;
const vehiclesByDept   = <?= json_encode($vehiclesByDept) ?>;

const gc = '#e2e8f0', tc = '#475569';
const statusColours = { active:'#16a34a', in_workshop:'#f59e0b', awaiting_parts:'#7c3aed', decommissioned:'#94a3b8' };

function makeChart(id, cfg) {
    const el = document.getElementById(id);
    if (!el || typeof Chart === 'undefined') return null;
    return new Chart(el, cfg);
}

// ── Fleet Status Donut ─────────────────────────────────────
const fleetDonutChart = makeChart('fleetStatusChart', {
    type: 'doughnut',
    data: {
        labels: fleetLabels,
        datasets: [{ data: fleetData, backgroundColor: fleetStatuses.map(s => statusColours[s] || '#94a3b8'), borderWidth: 3, borderColor: '#fff' }]
    },
    options: {
        responsive: true, maintainAspectRatio: false, cutout: '65%',
        plugins: { legend: { display: false }, tooltip: { callbacks: {
            label: ctx => ` ${ctx.label}: ${ctx.raw} vehicles`
        }}},
        onClick: (e, elements) => {
            if (elements.length) drillFleet(fleetStatuses[elements[0].index]);
        }
    }
});

// Make legend items also clickable
document.querySelectorAll('.fleet-legend-item').forEach(item => {
    item.addEventListener('click', () => drillFleet(item.dataset.status));
});

function drillFleet(status) {
    const vehicles = vehiclesByStatus[status] || [];
    const label = status.replace(/_/g,' ').replace(/\b\w/g, c => c.toUpperCase());
    document.getElementById('fleetStatusView').style.display = 'none';
    document.getElementById('fleetDrillView').style.display  = '';
    document.getElementById('fleetDrillBack').style.display  = '';
    document.querySelector('#fleetStatusPanel h2').textContent = label + ' — ' + vehicles.length + ' vehicle' + (vehicles.length !== 1 ? 's' : '');

    document.getElementById('fleetDrillList').innerHTML = vehicles.length
        ? vehicles.map(v => `
            <div style="display:flex;align-items:center;justify-content:space-between;padding:10px 12px;border-bottom:1px solid #f1f5f9;">
                <div>
                    <strong style="color:#020617;">${v.fleet_number}</strong>
                    <span style="color:#94a3b8;margin:0 6px;">·</span>
                    <span style="color:#374151;">${v.registration}</span>
                    <span style="color:#94a3b8;font-size:12px;margin-left:6px;">${v.make} ${v.model}</span>
                </div>
                <span style="font-size:12px;color:#94a3b8;">${v.department || '—'}</span>
            </div>`).join('')
        : '<p style="padding:20px;color:#94a3b8;text-align:center;">No vehicles in this status.</p>';
}

document.getElementById('fleetDrillBack').addEventListener('click', () => {
    document.getElementById('fleetStatusView').style.display = '';
    document.getElementById('fleetDrillView').style.display  = 'none';
    document.getElementById('fleetDrillBack').style.display  = 'none';
    document.querySelector('#fleetStatusPanel h2').textContent = 'Fleet Status';
});

// ── Downtime Bar Chart ─────────────────────────────────────
const downtimeChart = makeChart('downtimeChart', {
    type: 'bar',
    data: {
        labels: downtimeLabels,
        datasets: [{ label: 'Days', data: downtimeData, backgroundColor: '#2563eb', borderRadius: 6 }]
    },
    options: {
        responsive: true, maintainAspectRatio: false, indexAxis: 'y',
        scales: {
            x: { beginAtZero: true, grid: { color: gc }, ticks: { color: tc, precision: 0 } },
            y: { grid: { display: false }, ticks: { color: tc } }
        },
        plugins: { legend: { display: false } },
        onClick: (e, elements) => {
            if (elements.length) drillDowntime(downtimeLabels[elements[0].index]);
        }
    }
});

function drillDowntime(dept) {
    const jobs = vehiclesByDept[dept] || [];
    document.getElementById('downtimeChartView').style.display = 'none';
    document.getElementById('downtimeDrillView').style.display  = '';
    document.getElementById('downtimeDrillBack').style.display  = '';
    document.getElementById('downtimeTitle').textContent = dept + ' — Active Downtime';

    document.getElementById('downtimeDrillList').innerHTML = jobs.length
        ? jobs.map(j => `
            <div style="display:flex;align-items:center;justify-content:space-between;padding:10px 12px;border-bottom:1px solid #f1f5f9;">
                <div>
                    <strong style="color:#020617;">${j.fleet_number}</strong>
                    <span style="color:#94a3b8;margin:0 6px;">·</span>
                    <span style="color:#374151;font-size:13px;">${j.fault_description ? j.fault_description.substring(0,50) + (j.fault_description.length > 50 ? '…' : '') : '—'}</span>
                </div>
                <span style="font-size:12px;background:#fef3c7;color:#92400e;padding:3px 8px;border-radius:99px;">${j.days_open}d</span>
            </div>`).join('')
        : '<p style="padding:20px;color:#94a3b8;text-align:center;">No active downtime for this department.</p>';
}

document.getElementById('downtimeDrillBack').addEventListener('click', () => {
    document.getElementById('downtimeChartView').style.display = '';
    document.getElementById('downtimeDrillView').style.display  = 'none';
    document.getElementById('downtimeDrillBack').style.display  = 'none';
    document.getElementById('downtimeTitle').textContent = 'Downtime by Department';
});

// ── Jobs Timeline ──────────────────────────────────────────
makeChart('jobsTimelineChart', {
    type: 'bar',
    data: { labels: jobLabels, datasets: [
        { label: 'Opened', data: jobsOpenedData, backgroundColor: '#2563eb', borderRadius: 5 },
        { label: 'Closed', data: jobsClosedData, backgroundColor: '#16a34a', borderRadius: 5 }
    ]},
    options: { responsive: true, maintainAspectRatio: false,
        scales: { x: { grid: { display: false }, ticks: { color: tc } }, y: { beginAtZero: true, grid: { color: gc }, ticks: { color: tc, precision: 0 } } },
        plugins: { legend: { labels: { color: tc, boxWidth: 10, boxHeight: 10 } } }
    }
});

// ── Weekly KM ──────────────────────────────────────────────
const weeklyKmChart = makeChart('weeklyKmChart', {
    type: 'line',
    data: { labels: weeklyKmLabels, datasets: [{
        label: 'KM covered', data: weeklyDatasets.all?.data || [],
        borderColor: '#2563eb', backgroundColor: 'rgba(37,99,235,.14)', fill: true, tension: .35, pointRadius: 3
    }]},
    options: { responsive: true, maintainAspectRatio: false,
        scales: { x: { grid: { display: false }, ticks: { color: tc } }, y: { beginAtZero: true, grid: { color: gc }, ticks: { color: tc, precision: 0 } } },
        plugins: { legend: { display: false } }
    }
});
document.getElementById('weeklyKmVehicle')?.addEventListener('change', function () {
    const sel = weeklyDatasets[this.value] || weeklyDatasets.all;
    weeklyKmChart.data.datasets[0].label = sel.label;
    weeklyKmChart.data.datasets[0].data  = sel.data;
    weeklyKmChart.update();
});

// ── Fuel Monthly Totals ────────────────────────────────────
const fuelMonthChart = makeChart('fuelMonthlyChart', {
    type: 'bar',
    data: { labels: fuelLabels, datasets: [{
        label: 'Litres', data: fuelLitresData, backgroundColor: '#0f766e', borderRadius: 6
    }]},
    options: { responsive: true, maintainAspectRatio: false,
        scales: { x: { grid: { display: false }, ticks: { color: tc } }, y: { beginAtZero: true, grid: { color: gc }, ticks: { color: tc } } },
        plugins: { legend: { display: false } }
    }
});
document.getElementById('fuelVehicleFilter')?.addEventListener('change', function() {
    const key = this.value || 'all';
    fuelMonthChart.data.datasets[0].data = fuelByVehicle[key] || fuelByVehicle.all;
    fuelMonthChart.update();
});

// ── Fuel tank slosh effect — flat, minimal, smooth ─────────
// Each tank's fill level eases toward a hover/idle target amplitude, then
// oscillates with a simple sine wave. No skeuomorphic shading — just a
// gentle, smooth bob of the flat-coloured fill rectangle.
document.querySelectorAll('.tank-fill').forEach(rect => {
    const baseY = parseFloat(rect.dataset.baseY);
    const baseH = parseFloat(rect.dataset.baseH);
    const card  = rect.closest('.tank-card');
    if (!card || Number.isNaN(baseY) || Number.isNaN(baseH)) return;

    let phase = 0;
    let amp = 0;
    let targetAmp = 0;
    let raf = null;

    function frame() {
        amp += (targetAmp - amp) * 0.1;
        phase += 0.09;
        const offset = Math.sin(phase) * amp;

        if (Math.abs(targetAmp - amp) < 0.03 && Math.abs(amp) < 0.03) {
            rect.setAttribute('y', baseY);
            rect.setAttribute('height', baseH);
            raf = null;
            return;
        }
        rect.setAttribute('y', (baseY - offset).toFixed(2));
        rect.setAttribute('height', (baseH + offset).toFixed(2));
        raf = requestAnimationFrame(frame);
    }

    function ensureRunning() {
        if (!raf) raf = requestAnimationFrame(frame);
    }

    card.addEventListener('mouseenter', () => { targetAmp = 3; phase = 0; ensureRunning(); });
    card.addEventListener('mouseleave', () => { targetAmp = 0; ensureRunning(); });
});

// ── Fuel Balance Modal ─────────────────────────────────────
document.getElementById('balanceDate').value = new Date().toISOString().split('T')[0];

function openFuelBalance() {
    document.getElementById('fuelBalanceModal').classList.add('open');
}
function closeFuelBalance() {
    document.getElementById('fuelBalanceModal').classList.remove('open');
}
document.getElementById('openFuelBalanceBtn')?.addEventListener('click', openFuelBalance);
document.getElementById('closeFuelBalance').addEventListener('click', closeFuelBalance);
document.getElementById('cancelFuelBalance').addEventListener('click', closeFuelBalance);
document.getElementById('fuelBalanceModal').addEventListener('click', e => {
    if (e.target === document.getElementById('fuelBalanceModal')) closeFuelBalance();
});

document.getElementById('fuelBalanceForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    const btn = document.getElementById('saveFuelBalance');
    btn.disabled = true; btn.textContent = 'Saving…';
    const payload = {};
    new FormData(this).forEach((v, k) => { if (v !== '') payload[k] = v; });
    try {
        const res = await fetch('api/fuel-depot.php?action=create', {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(payload)
        });
        const data = await res.json();
        if (data.success) {
            closeFuelBalance();
            location.reload();
        } else {
            alert(data.error || 'Save failed');
            btn.disabled = false; btn.textContent = 'Save Reading';
        }
    } catch(err) {
        alert('Error: ' + err.message);
        btn.disabled = false; btn.textContent = 'Save Reading';
    }
});
</script>
<?php include __DIR__ . '/footer.php'; ?>
