import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbOne, dbAll, updateRow, deleteRow, currentOdometerSql } from '@/lib/db';
import { VEHICLE_FIELDS } from '../route';

export async function GET(request, { params }) {
  const { error } = requireApiSession(request);
  if (error) return error;
  const id = Number(params.id);
  try {
    const vehicle = await dbOne(
      `SELECT v.*, ${currentOdometerSql('v')} AS current_odometer FROM vehicles v WHERE v.id = ?`,
      [id]
    );
    if (!vehicle) return jsonError('Vehicle not found.', 404);

    const [assignments, jobs, services, fuel, odometerLogs] = await Promise.all([
      dbAll(
        `SELECT vda.*, d.full_name AS driver_name
         FROM vehicle_driver_assignments vda
         JOIN drivers d ON d.id = vda.driver_id
         WHERE vda.vehicle_id = ? ORDER BY vda.is_active DESC, vda.start_date DESC`,
        [id]
      ),
      dbAll(
        `SELECT jc.*, m.full_name AS mechanic_name
         FROM job_cards jc LEFT JOIN mechanics m ON m.id = jc.mechanic_id
         WHERE jc.vehicle_id = ? ORDER BY jc.date_in DESC`,
        [id]
      ),
      dbAll(
        `SELECT sr.*, m.full_name AS mechanic_name
         FROM service_records sr LEFT JOIN mechanics m ON m.id = sr.mechanic_id
         WHERE sr.vehicle_id = ? ORDER BY sr.service_date DESC`,
        [id]
      ),
      dbAll('SELECT * FROM fuel_logs WHERE vehicle_id = ? ORDER BY log_date DESC LIMIT 50', [id]),
      dbAll('SELECT * FROM odometer_logs WHERE vehicle_id = ? ORDER BY logged_at DESC LIMIT 50', [id]),
    ]);

    return jsonSuccess({ vehicle, assignments, jobs, services, fuel, odometerLogs });
  } catch (e) {
    return jsonError(e.message, 500);
  }
}

export async function PUT(request, { params }) {
  const { error } = requireApiSession(request);
  if (error) return error;
  const id = Number(params.id);
  try {
    const input = await request.json();
    await updateRow('vehicles', VEHICLE_FIELDS, id, input);
    return jsonSuccess({ id });
  } catch (e) {
    if (String(e.message).includes('Duplicate entry') && String(e.message).includes('registration')) {
      return jsonError('A vehicle with this registration number already exists.', 409);
    }
    return jsonError(e.message, e.status || 500);
  }
}

export async function DELETE(request, { params }) {
  const { error } = requireApiSession(request);
  if (error) return error;
  const id = Number(params.id);
  try {
    await deleteRow('vehicles', id);
    return jsonSuccess({ id });
  } catch (e) {
    return jsonError(e.message, 500);
  }
}
