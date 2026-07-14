import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbOne, getPool, currentOdometerSql } from '@/lib/db';

export async function POST(request, { params }) {
  const { error } = requireApiSession(request);
  if (error) return error;
  const id = Number(params.id);

  let conn;
  try {
    const { action_type, reason } = await request.json();
    if (!['disposed', 'written_off'].includes(action_type)) {
      return jsonError('action_type must be "disposed" or "written_off".');
    }

    const vehicle = await dbOne(
      `SELECT v.*, ${currentOdometerSql('v')} AS current_odometer FROM vehicles v WHERE v.id = ?`,
      [id]
    );
    if (!vehicle) return jsonError('Vehicle not found.', 404);

    const pool = getPool();
    conn = await pool.getConnection();
    await conn.beginTransaction();

    await conn.query(
      `INSERT INTO asset_disposal_logs
        (vehicle_id, action_type, fleet_number, registration, make, model, department, current_odometer, reason, snapshot)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        id, action_type, vehicle.fleet_number, vehicle.registration, vehicle.make, vehicle.model,
        vehicle.department, vehicle.current_odometer, reason || null, JSON.stringify(vehicle),
      ]
    );

    await conn.query('UPDATE vehicles SET status = ? WHERE id = ?', [action_type, id]);

    await conn.commit();
    return jsonSuccess({ id });
  } catch (e) {
    if (conn) await conn.rollback();
    return jsonError(e.message, 500);
  } finally {
    if (conn) conn.release();
  }
}
