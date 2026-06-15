<?php
require_once __DIR__ . '/gate_auth_check.php';
require_once __DIR__ . '/db.php';

$vehicles = db_all("SELECT id, fleet_number, registration, make, model FROM vehicles WHERE status <> 'decommissioned' ORDER BY fleet_number");
?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Gate Mileage - FleetDesk</title>
    <link rel="stylesheet" href="<?= e(BASE_URL) ?>/main.css">
</head>
<body class="login-page gate-page">
    <main class="login-card gate-card">
        <h1>Gate Mileage Log</h1>
        <p>Record vehicles coming into or leaving the compound.</p>
        <form data-gate-mileage-form>
            <div class="form-row">
                <label for="vehicle_id">Vehicle</label>
                <select class="select" id="vehicle_id" name="vehicle_id" required>
                    <option value="">Select vehicle...</option>
                    <?php foreach ($vehicles as $vehicle): ?>
                        <option value="<?= e($vehicle['id']) ?>"><?= e($vehicle['fleet_number'] . ' - ' . $vehicle['registration'] . ' (' . $vehicle['make'] . ' ' . $vehicle['model'] . ')') ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-row">
                <label for="location">Movement</label>
                <select class="select" id="location" name="location" required>
                    <option value="gate_in">Gate in</option>
                    <option value="gate_out">Gate out</option>
                </select>
            </div>
            <div class="form-row">
                <label for="odometer_reading">Current mileage</label>
                <input class="input" id="odometer_reading" name="odometer_reading" type="number" min="0" required>
            </div>
            <div class="form-row">
                <label for="notes">Notes</label>
                <textarea id="notes" name="notes" placeholder="Optional gate note"></textarea>
            </div>
            <button class="btn btn-primary" type="submit">Save mileage</button>
            <a class="btn" href="<?= e(BASE_URL) ?>/auth.php?action=logout">Logout</a>
        </form>
    </main>
    <div id="toast" class="toast" hidden></div>
    <script>window.FLEETDESK_BASE = <?= json_encode(BASE_URL) ?>;</script>
    <script src="<?= e(BASE_URL) ?>/app.js"></script>
</body>
</html>
