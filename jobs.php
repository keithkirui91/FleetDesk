<?php
require_once __DIR__ . '/module_page.php';

function clip_text($text, $limit = 58)
{
    $text = (string)$text;
    return strlen($text) > $limit ? substr($text, 0, $limit - 3) . '...' : $text;
}

$page_title = 'Job Cards';
$page_heading = 'Job Cards';
$vehicles = vehicle_options();
$mechanics = mechanic_options();
$jobs = db_all("
    SELECT jc.*, v.fleet_number, v.registration, v.make, v.model,
           m.full_name AS mechanic_name,
           DATEDIFF(COALESCE(jc.date_closed, CURDATE()), jc.date_in) AS days_open,
           CASE WHEN jc.status <> 'closed'
                 AND jc.target_completion_date IS NOT NULL
                 AND jc.target_completion_date < CURDATE()
                THEN 1 ELSE 0 END AS is_overdue
    FROM job_cards jc
    JOIN vehicles v ON v.id = jc.vehicle_id
    LEFT JOIN mechanics m ON m.id = jc.mechanic_id
    ORDER BY FIELD(jc.status, 'in_progress', 'awaiting_parts', 'closed', 'open', 'on_hold'),
             is_overdue DESC,
             jc.date_in DESC
");

$groups = [
    'in_progress' => 'In Progress',
    'awaiting_parts' => 'Awaiting Parts',
    'closed' => 'Closed',
];

include __DIR__ . '/header.php';
include __DIR__ . '/sidebar.php';
?>
<div class="toolbar">
    <div>
        <h2 class="section-title">Long Running Jobs</h2>
        <div class="subtle">Grouped by progress, parts availability, and completed work.</div>
    </div>
    <div class="toolbar-left">
        <input class="input" id="tableSearch" placeholder="Search job cards">
        <button class="btn btn-primary" data-open-modal><?= fd_icon('plus') ?> Add Job Card</button>
    </div>
</div>

<div class="job-groups">
    <?php foreach ($groups as $status => $label): ?>
        <?php $groupJobs = array_filter($jobs, function ($job) use ($status) { return $job['status'] === $status || ($status === 'in_progress' && $job['status'] === 'open'); }); ?>
        <section class="panel job-group">
            <div class="panel-title-row">
                <h2><?= e($label) ?></h2>
                <span><?= count($groupJobs) ?> jobs</span>
            </div>
            <div class="table-wrap compact-table">
                <table id="dataTable">
                    <thead><tr><th>Ref</th><th>Vehicle</th><th>Fault</th><th>Days</th><th>Priority</th><th>Status</th><th></th></tr></thead>
                    <tbody>
                        <?php foreach ($groupJobs as $job): ?>
                            <tr data-record='<?= e(json_encode($job, JSON_UNESCAPED_SLASHES)) ?>'>
                                <td><?= e($job['job_reference']) ?></td>
                                <td><?= e($job['registration']) ?> <span class="muted"><?= e($job['fleet_number']) ?></span></td>
                                <td><?= e(clip_text($job['fault_description'], 58)) ?> <?= (int)$job['is_overdue'] === 1 ? '<span class="badge overdue">Overdue</span>' : '' ?></td>
                                <td><?= e($job['days_open']) ?></td>
                                <td><span class="badge <?= e($job['priority']) ?>"><?= e($job['priority']) ?></span></td>
                                <td><span class="badge <?= e($job['status']) ?>"><?= e(str_replace('_', ' ', $job['status'])) ?></span></td>
                                <td><button class="btn btn-small" type="button" data-job-view>View</button></td>
                            </tr>
                        <?php endforeach; ?>
                        <?php if (!$groupJobs): ?><tr><td colspan="7" class="empty">No <?= e(strtolower($label)) ?> jobs.</td></tr><?php endif; ?>
                    </tbody>
                </table>
            </div>
        </section>
    <?php endforeach; ?>
</div>

<div class="modal-backdrop" id="recordModal">
    <div class="modal">
        <header>
            <h2>Add Job Card</h2>
            <button class="btn btn-small" type="button" data-close-modal>Close</button>
        </header>
        <form data-module-form data-endpoint="api/jobs.php?action=create">
            <div class="form-grid">
                <div class="form-row">
                    <label>Vehicle</label>
                    <select class="select" name="vehicle_id" required>
                        <option value="">Select...</option>
                        <?php foreach ($vehicles as $id => $label): ?><option value="<?= e($id) ?>"><?= e($label) ?></option><?php endforeach; ?>
                    </select>
                </div>
                <div class="form-row">
                    <label>Mechanic</label>
                    <select class="select" name="mechanic_id">
                        <option value="">Unassigned</option>
                        <?php foreach ($mechanics as $id => $label): ?><option value="<?= e($id) ?>"><?= e($label) ?></option><?php endforeach; ?>
                    </select>
                </div>
                <div class="form-row">
                    <label>Job type</label>
                    <select class="select" name="job_type" required>
                        <option value="repair">Repair</option><option value="service">Service</option><option value="inspection">Inspection</option><option value="accident">Accident</option><option value="other">Other</option>
                    </select>
                </div>
                <div class="form-row">
                    <label>Priority</label>
                    <select class="select" name="priority" required>
                        <option value="normal">Normal</option><option value="low">Low</option><option value="high">High</option><option value="critical">Critical</option>
                    </select>
                </div>
                <div class="form-row">
                    <label>Part availability</label>
                    <select class="select" name="part_availability" required>
                        <option value="available">Available</option>
                        <option value="not_available">Not available</option>
                    </select>
                </div>
                <div class="form-row">
                    <label>Date in</label>
                    <input class="input" name="date_in" type="date" required>
                </div>
                <div class="form-row">
                    <label>Target completion</label>
                    <input class="input" name="target_completion_date" type="date" required>
                </div>
                <div class="form-row full">
                    <label>Fault description</label>
                    <textarea name="fault_description" required></textarea>
                </div>
            </div>
            <footer>
                <button class="btn" type="button" data-close-modal>Cancel</button>
                <button class="btn btn-primary" type="submit">Save Job Card</button>
            </footer>
        </form>
    </div>
</div>

<div class="modal-backdrop" id="jobModal">
    <div class="modal" style="max-width:900px;width:95vw;">
        <header>
            <h2>Job Details</h2>
            <button class="btn btn-small" type="button" data-close-job>
                Close
            </button>
        </header>

        <div class="detail-grid" data-job-detail></div>

        <hr style="margin:20px 0;border:none;border-top:1px solid #e5e7eb;">

        <form class="job-status-form" data-job-status-form>
            <input type="hidden" name="id">

            <div class="form-row">
                <label>Update Status</label>
                <select class="select" name="status" required>
                    <option value="in_progress">In Progress</option>
                    <option value="awaiting_parts">Awaiting Parts</option>
                    <option value="closed">Closed</option>
                </select>
            </div>

            <div class="form-row full" style="margin-top:20px;">
                <label>Resolution Notes</label>

                <textarea
                    id="notesHistory"
                    class="input"
                    rows="10"
                    readonly
                    style="
                        background:#f8fafc;
                        color:#475569;
                        font-family:monospace;
                        resize:vertical;
                        white-space:pre-wrap;
                    "
                ></textarea>

                <small class="subtle">
                    Workshop history and previous updates.
                </small>
            </div>

            <div class="form-row full" style="margin-top:20px;">
                <label>Add Update</label>

                <textarea
                    class="input"
                    name="new_note"
                    rows="4"
                    placeholder="Parts ordered, supplier contacted, repairs completed..."
                ></textarea>
            </div>

            <footer style="margin-top:20px;">
                <button
                    class="btn btn-danger"
                    type="button"
                    data-job-delete
                >
                    Delete Job
                </button>

                <button
                    class="btn btn-primary"
                    type="submit"
                >
                    Save Update
                </button>
            </footer>
        </form>
    </div>
</div>

<script>
let activeJob = null;

document.addEventListener('DOMContentLoaded', function () {
    const jobModal = document.getElementById('jobModal');
    const form = document.querySelector('[data-job-status-form]');

    document.querySelectorAll('[data-job-view]').forEach(function (button) {
        button.addEventListener('click', function () {
            const row = button.closest('tr');

            activeJob = JSON.parse(
                row.dataset.record || '{}'
            );

            form.elements.id.value =
                activeJob.id;

            form.elements.status.value =
                activeJob.status;

            document.getElementById(
                'notesHistory'
            ).value =
                activeJob.resolution_notes || '';

            form.elements.new_note.value = '';

            document.querySelector(
                '[data-job-detail]'
            ).innerHTML =
                Object.entries(activeJob)
                    .filter(function (entry) {
                        return ![
                            'id',
                            'resolution_notes'
                        ].includes(entry[0]);
                    })
                    .map(function (entry) {
                        return `
                            <div class="detail-item">
                                <span>${entry[0].replaceAll('_', ' ')}</span>
                                <strong>${entry[1] ?? ''}</strong>
                            </div>
                        `;
                    })
                    .join('');

            jobModal.classList.add('open');
        });
    });

    document.querySelectorAll(
        '[data-close-job]'
    ).forEach(function (button) {
        button.addEventListener(
            'click',
            function () {
                jobModal.classList.remove('open');
            }
        );
    });

    form.addEventListener(
        'submit',
        async function (event) {
            event.preventDefault();

            const payload = {
                id: this.elements.id.value,
                status: this.elements.status.value,
                new_note: this.elements.new_note.value.trim()
            };

            await fdFetch(
                'api/jobs.php?action=update',
                {
                    method: 'POST',
                    body: JSON.stringify(payload)
                }
            );

            window.location.reload();
        }
    );

    document.querySelector(
        '[data-job-delete]'
    ).addEventListener(
        'click',
        async function () {
            if (
                !activeJob ||
                !confirm(
                    'Delete this job card? This cannot be undone.'
                )
            ) {
                return;
            }

            await fdFetch(
                'api/jobs.php?action=delete',
                {
                    method: 'POST',
                    body: JSON.stringify({
                        id: activeJob.id
                    })
                }
            );

            window.location.reload();
        }
    );
});
</script>
<?php include __DIR__ . '/footer.php'; ?>
