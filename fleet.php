<?php
require_once __DIR__ . '/module_page.php';

$vehicles = db_all("
    SELECT v.*,
           COALESCE((SELECT odometer_reading FROM odometer_logs ol
                     WHERE ol.vehicle_id = v.id ORDER BY logged_at DESC, id DESC LIMIT 1), 0) AS current_odometer,
           (SELECT COUNT(*) FROM job_cards jc WHERE jc.vehicle_id = v.id AND jc.status <> 'closed') AS open_jobs
    FROM vehicles v
    ORDER BY v.fleet_number
");

$page_title   = 'Fleet';
$page_heading = 'Fleet';
include __DIR__ . '/header.php';
include __DIR__ . '/sidebar.php';
?>

<div class="toolbar">
    <div>
        <h2 class="section-title">Fleet</h2>
        <div class="subtle">Vehicles, departments, service status and odometer readings.</div>
    </div>
    <div class="toolbar-left">
        <select class="select" id="statusFilter" style="min-width:140px;">
            <option value="">All statuses</option>
            <option value="active">Active</option>
            <option value="in_workshop">In Workshop</option>
            <option value="awaiting_parts">Awaiting Parts</option>
            <option value="decommissioned">Decommissioned</option>
        </select>
        <input class="input" id="tableSearch" placeholder="Search fleet…">
        <button class="btn btn-primary" data-open-add><?= fd_icon('plus') ?> Add Vehicle</button>
    </div>
</div>

<div class="table-wrap">
    <table id="fleetTable">
        <thead>
            <tr>
                <th>Fleet No.</th>
                <th>Registration</th>
                <th>Vehicle</th>
                <th>Department</th>
                <th>Odometer</th>
                <th>Open Jobs</th>
                <th>Next Service</th>
                <th>Status</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <?php if (!$vehicles): ?>
                <tr><td class="empty" colspan="9">No vehicles yet. Add one to get started.</td></tr>
            <?php endif; ?>
            <?php foreach ($vehicles as $v): ?>
                <tr data-record='<?= e(json_encode($v, JSON_UNESCAPED_SLASHES)) ?>'
                    data-status="<?= e($v['status']) ?>">
                    <td><strong><?= e($v['fleet_number']) ?></strong></td>
                    <td><?= e($v['registration']) ?></td>
                    <td>
                        <?= e($v['make'] . ' ' . $v['model']) ?>
                        <?php if ($v['year']): ?>
                            <span class="muted">(<?= e($v['year']) ?>)</span>
                        <?php endif; ?>
                    </td>
                    <td><?= e($v['department'] ?? '—') ?></td>
                    <td><?= $v['current_odometer'] ? number_format((int)$v['current_odometer']) . ' km' : '—' ?></td>
                    <td>
                        <?php if ((int)$v['open_jobs'] > 0): ?>
                            <span class="badge in_workshop"><?= (int)$v['open_jobs'] ?> open</span>
                        <?php else: ?>
                            <span class="muted">—</span>
                        <?php endif; ?>
                    </td>
                    <td>
                        <?php if ($v['next_service_date']): ?>
                            <?php
                            $days = (int)((strtotime($v['next_service_date']) - time()) / 86400);
                            $cls  = $days < 0 ? 'critical' : ($days <= 30 ? 'high' : 'active');
                            $lbl  = $days < 0 ? abs($days) . 'd overdue' : ($days === 0 ? 'Today' : $days . 'd');
                            ?>
                            <span class="badge <?= $cls ?>"><?= $lbl ?></span>
                        <?php else: ?>
                            <span class="muted">—</span>
                        <?php endif; ?>
                    </td>
                    <td><span class="badge <?= e($v['status']) ?>"><?= e(str_replace('_', ' ', $v['status'])) ?></span></td>
                    <td class="actions">
                        <button class="btn btn-small" type="button" data-view-vehicle>View</button>
                    </td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</div>

<!-- ── ADD VEHICLE MODAL ────────────────────────────────── -->
<div class="modal-backdrop" id="addModal">
    <div class="modal">
        <header>
            <h2>Add Vehicle</h2>
            <button class="btn btn-small" type="button" data-close-add>Close</button>
        </header>
        <form data-add-form>
            <div class="form-grid">
                <div class="form-row">
                    <label>Fleet Number <span style="color:var(--red,#ef4444)">*</span></label>
                    <input class="input" name="fleet_number" type="text" required placeholder="e.g. FD-006">
                </div>
                <div class="form-row">
                    <label>Registration <span style="color:var(--red,#ef4444)">*</span></label>
                    <input class="input" name="registration" type="text" required placeholder="e.g. KCA 123A">
                </div>
                <div class="form-row">
                    <label>Make <span style="color:var(--red,#ef4444)">*</span></label>
                    <input class="input" name="make" type="text" required placeholder="e.g. Toyota">
                </div>
                <div class="form-row">
                    <label>Model <span style="color:var(--red,#ef4444)">*</span></label>
                    <input class="input" name="model" type="text" required placeholder="e.g. Land Cruiser">
                </div>
                <div class="form-row">
                    <label>Year</label>
                    <input class="input" name="year" type="number" min="1980" max="2030" placeholder="e.g. 2021">
                </div>
                <div class="form-row">
                    <label>Colour</label>
                    <input class="input" name="colour" type="text" placeholder="e.g. White">
                </div>
                <div class="form-row">
                    <label>Vehicle Type</label>
                    <select class="select" name="vehicle_type">
                        <option value="car">Car</option>
                        <option value="van">Van</option>
                        <option value="truck">Truck</option>
                        <option value="motorbike">Motorbike</option>
                        <option value="construction">Construction</option>
                    </select>
                </div>
                <div class="form-row">
                    <label>Fuel Type</label>
                    <select class="select" name="fuel_type">
                        <option value="diesel">Diesel</option>
                        <option value="petrol">Petrol</option>
                        <option value="hybrid">Hybrid</option>
                        <option value="electric">Electric</option>
                        <option value="lpg">LPG</option>
                        <option value="other">Other</option>
                    </select>
                </div>
                <div class="form-row">
                    <label>Body Type</label>
                    <input class="input" name="body_type" type="text" placeholder="e.g. SUV, Pickup, Bus">
                </div>
                <div class="form-row">
                    <label>Department</label>
                    <input class="input" name="department" type="text" placeholder="e.g. Operations">
                </div>
                <div class="form-row">
                    <label>Engine Size</label>
                    <input class="input" name="engine_size" type="text" placeholder="e.g. 2.8L D4D">
                </div>
                <div class="form-row">
                    <label>Transmission</label>
                    <select class="select" name="transmission">
                        <option value="">Select...</option>
                        <option value="manual">Manual</option>
                        <option value="automatic">Automatic</option>
                        <option value="cvt">CVT</option>
                        <option value="other">Other</option>
                    </select>
                </div>
                <div class="form-row">
                    <label>Drive Type</label>
                    <select class="select" name="drive_type">
                        <option value="">Select...</option>
                        <option value="2WD">2WD</option>
                        <option value="4WD">4WD</option>
                        <option value="AWD">AWD</option>
                    </select>
                </div>
                <div class="form-row">
                    <label>Seating Capacity</label>
                    <input class="input" name="seating_capacity" type="number" placeholder="e.g. 7">
                </div>
                <div class="form-row">
                    <label>Tyre Size</label>
                    <input class="input" name="tyre_size_standard" type="text" placeholder="e.g. 265/65R17">
                </div>
                <div class="form-row">
                    <label>VIN / Chassis</label>
                    <input class="input" name="vin_chassis" type="text" placeholder="17-char VIN">
                </div>
                <div class="form-row">
                    <label>Insurance Expiry</label>
                    <input class="input" name="insurance_expiry" type="date">
                </div>
                <div class="form-row">
                    <label>Licence Expiry</label>
                    <input class="input" name="licence_expiry" type="date">
                </div>
                <div class="form-row">
                    <label>Next Service Date</label>
                    <input class="input" name="next_service_date" type="date">
                </div>
                <div class="form-row">
                    <label>Next Service Mileage</label>
                    <input class="input" name="next_service_mileage" type="number" placeholder="e.g. 120000">
                </div>
                <div class="form-row">
                    <label>Current Odometer (km)</label>
                    <input class="input" name="odometer_current" type="number" placeholder="e.g. 85000">
                </div>
                <div class="form-row">
                    <label>Status</label>
                    <select class="select" name="status">
                        <option value="active">Active</option>
                        <option value="in_workshop">In Workshop</option>
                        <option value="awaiting_parts">Awaiting Parts</option>
                        <option value="decommissioned">Decommissioned</option>
                    </select>
                </div>
                <div class="form-row full">
                    <label>Notes</label>
                    <textarea name="notes" placeholder="Any additional notes..."></textarea>
                </div>
            </div>
            <footer>
                <button class="btn" type="button" data-close-add>Cancel</button>
                <button class="btn btn-primary" type="submit" id="addSubmitBtn">Save Vehicle</button>
            </footer>
        </form>
    </div>
</div>

<!-- ── VEHICLE DETAIL / EDIT MODAL ─────────────────────── -->
<div class="modal-backdrop" id="viewModal">
    <div class="modal">
        <header>
            <h2 id="viewModalTitle">Vehicle Details</h2>
            <div style="display:flex;gap:8px;align-items:center;">
                <button class="btn btn-small btn-primary" id="editToggleBtn" type="button">Edit</button>
                <button class="btn btn-small" type="button" data-close-view>Close</button>
            </div>
        </header>

        <!-- Read view -->
        <div id="viewPane" class="detail-grid"></div>

        <!-- Edit form -->
        <form id="editForm" style="display:none;">
            <div class="form-grid">
                <div class="form-row"><label>Fleet Number</label><input class="input" name="fleet_number" required></div>
                <div class="form-row"><label>Registration</label><input class="input" name="registration" required></div>
                <div class="form-row"><label>Make</label><input class="input" name="make" required></div>
                <div class="form-row"><label>Model</label><input class="input" name="model" required></div>
                <div class="form-row"><label>Year</label><input class="input" name="year" type="number"></div>
                <div class="form-row"><label>Colour</label><input class="input" name="colour"></div>
                <div class="form-row">
                    <label>Vehicle Type</label>
                    <select class="select" name="vehicle_type">
                        <option value="car">Car</option><option value="van">Van</option>
                        <option value="truck">Truck</option><option value="motorbike">Motorbike</option>
                        <option value="construction">Construction</option>
                    </select>
                </div>
                <div class="form-row">
                    <label>Fuel Type</label>
                    <select class="select" name="fuel_type">
                        <option value="diesel">Diesel</option><option value="petrol">Petrol</option>
                        <option value="hybrid">Hybrid</option><option value="electric">Electric</option>
                        <option value="lpg">LPG</option><option value="other">Other</option>
                    </select>
                </div>
                <div class="form-row"><label>Body Type</label><input class="input" name="body_type"></div>
                <div class="form-row"><label>Department</label><input class="input" name="department"></div>
                <div class="form-row"><label>Engine Size</label><input class="input" name="engine_size"></div>
                <div class="form-row">
                    <label>Transmission</label>
                    <select class="select" name="transmission">
                        <option value="">—</option><option value="manual">Manual</option>
                        <option value="automatic">Automatic</option><option value="cvt">CVT</option>
                    </select>
                </div>
                <div class="form-row">
                    <label>Drive Type</label>
                    <select class="select" name="drive_type">
                        <option value="">—</option><option value="2WD">2WD</option>
                        <option value="4WD">4WD</option><option value="AWD">AWD</option>
                    </select>
                </div>
                <div class="form-row"><label>Seating Capacity</label><input class="input" name="seating_capacity" type="number"></div>
                <div class="form-row"><label>Tyre Size</label><input class="input" name="tyre_size_standard"></div>
                <div class="form-row"><label>VIN / Chassis</label><input class="input" name="vin_chassis"></div>
                <div class="form-row"><label>Insurance Expiry</label><input class="input" name="insurance_expiry" type="date"></div>
                <div class="form-row"><label>Licence Expiry</label><input class="input" name="licence_expiry" type="date"></div>
                <div class="form-row"><label>Next Service Date</label><input class="input" name="next_service_date" type="date"></div>
                <div class="form-row"><label>Next Service Mileage</label><input class="input" name="next_service_mileage" type="number"></div>
                <div class="form-row">
                    <label>Status</label>
                    <select class="select" name="status">
                        <option value="active">Active</option>
                        <option value="in_workshop">In Workshop</option>
                        <option value="awaiting_parts">Awaiting Parts</option>
                        <option value="decommissioned">Decommissioned</option>
                    </select>
                </div>
                <div class="form-row full"><label>Notes</label><textarea name="notes"></textarea></div>
            </div>
            <footer>
                <button class="btn btn-danger" type="button" id="deleteVehicleBtn">Delete Vehicle</button>
                <button class="btn" type="button" id="cancelEditBtn">Cancel</button>
                <button class="btn btn-primary" type="submit" id="editSubmitBtn">Save Changes</button>
            </footer>
        </form>
    </div>
</div>

<script>
const SHOW_FIELDS = {
    fleet_number:'Fleet No.', registration:'Registration', make:'Make', model:'Model',
    year:'Year', colour:'Colour', vehicle_type:'Type', fuel_type:'Fuel', body_type:'Body',
    department:'Department', engine_size:'Engine', transmission:'Transmission',
    drive_type:'Drive', seating_capacity:'Seats', tyre_size_standard:'Tyre Size',
    vin_chassis:'VIN/Chassis', insurance_expiry:'Insurance Exp.', licence_expiry:'Licence Exp.',
    last_service_date:'Last Service', next_service_date:'Next Service',
    next_service_mileage:'Next Svc Mileage', status:'Status', current_odometer:'Odometer (km)',
    open_jobs:'Open Jobs', notes:'Notes'
};

let activeVehicle = null;
let editMode = false;

// ── Add modal ───────────────────────────────────────────
document.querySelectorAll('[data-open-add]').forEach(b =>
    b.addEventListener('click', () => document.getElementById('addModal').classList.add('open')));
document.querySelectorAll('[data-close-add]').forEach(b =>
    b.addEventListener('click', () => document.getElementById('addModal').classList.remove('open')));
document.getElementById('addModal').addEventListener('click', e => {
    if (e.target === document.getElementById('addModal'))
        document.getElementById('addModal').classList.remove('open');
});

document.querySelector('[data-add-form]').addEventListener('submit', async function(e) {
    e.preventDefault();
    const btn = document.getElementById('addSubmitBtn');
    btn.disabled = true;
    btn.textContent = 'Saving…';
    const payload = {};
    new FormData(this).forEach((v, k) => { if (v !== '') payload[k] = v; });
    try {
        await fdFetch('api/vehicles.php?action=create', { method: 'POST', body: JSON.stringify(payload) });
        showToast('Vehicle added successfully');
        setTimeout(() => location.reload(), 600);
    } catch(err) {
        showToast('Error: ' + err.message);
        btn.disabled = false;
        btn.textContent = 'Save Vehicle';
    }
});

// ── View / edit modal ───────────────────────────────────
function openViewModal(record) {
    activeVehicle = record;
    editMode = false;
    document.getElementById('viewModalTitle').textContent =
        record.fleet_number + ' — ' + record.make + ' ' + record.model;
    renderViewPane(record);
    document.getElementById('viewPane').style.display = '';
    document.getElementById('editForm').style.display = 'none';
    document.getElementById('editToggleBtn').textContent = 'Edit';
    document.getElementById('viewModal').classList.add('open');
}

function renderViewPane(v) {
    const pane = document.getElementById('viewPane');
    pane.innerHTML = Object.entries(SHOW_FIELDS).map(([key, label]) => {
        let val = v[key] ?? '—';
        if (val === '' || val === null) val = '—';
        if (key === 'status') val = `<span class="badge ${v[key]}">${String(v[key]).replace(/_/g,' ')}</span>`;
        if (key === 'current_odometer' && v[key]) val = Number(v[key]).toLocaleString() + ' km';
        if (key === 'next_service_mileage' && v[key]) val = Number(v[key]).toLocaleString() + ' km';
        return `<div class="detail-item"><span>${label}</span><strong>${val}</strong></div>`;
    }).join('');
}

function fillEditForm(v) {
    const form = document.getElementById('editForm');
    Object.keys(v).forEach(key => {
        const el = form.elements[key];
        if (el) el.value = v[key] ?? '';
    });
}

document.querySelectorAll('[data-close-view]').forEach(b =>
    b.addEventListener('click', () => document.getElementById('viewModal').classList.remove('open')));
document.getElementById('viewModal').addEventListener('click', e => {
    if (e.target === document.getElementById('viewModal'))
        document.getElementById('viewModal').classList.remove('open');
});

document.getElementById('editToggleBtn').addEventListener('click', () => {
    editMode = !editMode;
    document.getElementById('viewPane').style.display    = editMode ? 'none' : '';
    document.getElementById('editForm').style.display    = editMode ? '' : 'none';
    document.getElementById('editToggleBtn').textContent = editMode ? 'Cancel Edit' : 'Edit';
    if (editMode) fillEditForm(activeVehicle);
});

document.getElementById('cancelEditBtn').addEventListener('click', () => {
    editMode = false;
    document.getElementById('viewPane').style.display = '';
    document.getElementById('editForm').style.display = 'none';
    document.getElementById('editToggleBtn').textContent = 'Edit';
});

document.getElementById('editForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    const btn = document.getElementById('editSubmitBtn');
    btn.disabled = true;
    btn.textContent = 'Saving…';
    const payload = {};
    new FormData(this).forEach((v, k) => { payload[k] = v === '' ? null : v; });
    try {
        await fdFetch(`api/vehicles.php?action=update&id=${activeVehicle.id}`,
            { method: 'POST', body: JSON.stringify(payload) });
        showToast('Vehicle updated');
        setTimeout(() => location.reload(), 600);
    } catch(err) {
        showToast('Error: ' + err.message);
        btn.disabled = false;
        btn.textContent = 'Save Changes';
    }
});

document.getElementById('deleteVehicleBtn').addEventListener('click', async () => {
    if (!activeVehicle || !confirm(`Delete ${activeVehicle.fleet_number}? This cannot be undone.`)) return;
    try {
        await fdFetch(`api/vehicles.php?action=delete&id=${activeVehicle.id}`,
            { method: 'POST', body: JSON.stringify({ id: activeVehicle.id }) });
        showToast('Vehicle deleted');
        setTimeout(() => location.reload(), 600);
    } catch(err) {
        showToast('Error: ' + err.message);
    }
});

// ── Row clicks ──────────────────────────────────────────
document.querySelectorAll('[data-view-vehicle]').forEach(btn => {
    btn.addEventListener('click', () => {
        const record = JSON.parse(btn.closest('tr').dataset.record || '{}');
        openViewModal(record);
    });
});

// ── Search + status filter ──────────────────────────────
function applyFilters() {
    const q = document.getElementById('tableSearch').value.toLowerCase();
    const s = document.getElementById('statusFilter').value;
    document.querySelectorAll('#fleetTable tbody tr').forEach(row => {
        const matchQ = !q || row.textContent.toLowerCase().includes(q);
        const matchS = !s || row.dataset.status === s;
        row.hidden = !(matchQ && matchS);
    });
}
document.getElementById('tableSearch').addEventListener('input', applyFilters);
document.getElementById('statusFilter').addEventListener('change', applyFilters);
</script>

<?php include __DIR__ . '/footer.php'; ?>
