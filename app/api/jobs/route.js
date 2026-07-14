import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbAll, dbValue, insertRow, getPool } from '@/lib/db';

export const JOB_FIELDS = [
  'vehicle_id', 'mechanic_id', 'job_type', 'fault_description', 'priority', 'part_availability',
  'status', 'date_in', 'target_completion_date', 'date_closed', 'resolution_notes',
];

export async function syncVehicleStatusForJob(vehicleId, jobStatus) {
  if (!vehicleId) return;
  let vehicleStatus = 'active';
  if (jobStatus === 'awaiting_parts') vehicleStatus = 'awaiting_parts';
  else if (jobStatus !== 'closed') vehicleStatus = 'in_workshop';
  await getPool().query('UPDATE vehicles SET status = ? WHERE id = ?', [vehicleStatus, vehicleId]);
}

export async function GET(request) {
  const { error } = requireApiSession(request);
  if (error) return error;
  try {
    const rows = await dbAll(`
      SELECT jc.*, v.fleet_number, v.registration, v.make, v.model,
             m.full_name AS mechanic_name,
             DATEDIFF(COALESCE(jc.date_closed, CURDATE()), jc.date_in) AS days_open,
             CASE
                 WHEN jc.status <> 'closed'
                  AND jc.target_completion_date IS NOT NULL
                  AND jc.target_completion_date < CURDATE()
                 THEN 1 ELSE 0
             END AS is_overdue
      FROM job_cards jc
      JOIN vehicles v ON v.id = jc.vehicle_id
      LEFT JOIN mechanics m ON m.id = jc.mechanic_id
      ORDER BY FIELD(jc.status, 'in_progress', 'awaiting_parts', 'closed', 'open', 'on_hold'),
               is_overdue DESC,
               jc.date_in DESC,
               jc.id DESC
    `);
    return jsonSuccess(rows);
  } catch (e) {
    return jsonError(e.message, 500);
  }
}

export async function POST(request) {
  const { error } = requireApiSession(request);
  if (error) return error;
  try {
    const input = await request.json();
    if (!input.vehicle_id || !input.fault_description || !input.part_availability) {
      return jsonError('Vehicle, fault description, and part availability are required.');
    }
    if (!input.date_in) input.date_in = new Date().toISOString().slice(0, 10);

    input.status = input.part_availability === 'available' ? 'in_progress' : 'awaiting_parts';
    const count = Number(await dbValue('SELECT COUNT(*) + 1 FROM job_cards'));
    input.job_reference = `JC-${new Date().getFullYear()}-${String(count).padStart(4, '0')}`;

    const id = await insertRow('job_cards', ['job_reference', ...JOB_FIELDS], input);
    await syncVehicleStatusForJob(Number(input.vehicle_id), input.status);
    return jsonSuccess({ id, reference: input.job_reference });
  } catch (e) {
    return jsonError(e.message, e.status || 500);
  }
}
