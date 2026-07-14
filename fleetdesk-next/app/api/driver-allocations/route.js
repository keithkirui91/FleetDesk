import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbAll, dbOne, getPool } from '@/lib/db';

export const ALLOCATION_FIELDS = ['vehicle_id', 'driver_id', 'role', 'start_date', 'end_date', 'is_active', 'notes'];

export async function GET(request) {
  const { error } = requireApiSession(request);
  if (error) return error;
  try {
    const rows = await dbAll(`
      SELECT vda.*, v.fleet_number, v.registration, d.full_name AS driver_name, d.department
      FROM vehicle_driver_assignments vda
      JOIN vehicles v ON v.id = vda.vehicle_id
      JOIN drivers d ON d.id = vda.driver_id
      ORDER BY v.fleet_number, vda.is_active DESC, FIELD(vda.role, 'primary', 'reliever'), vda.start_date DESC, vda.id DESC
    `);
    return jsonSuccess(rows);
  } catch (e) {
    return jsonError(e.message, 500);
  }
}

export async function POST(request) {
  const { error } = requireApiSession(request);
  if (error) return error;

  let conn;
  try {
    const input = await request.json();
    for (const required of ['vehicle_id', 'driver_id', 'role', 'start_date']) {
      if (!input[required]) return jsonError(`${required.replace(/_/g, ' ')} is required.`);
    }
    if (!['primary', 'reliever'].includes(input.role)) {
      return jsonError('Role must be primary or reliever.');
    }

    const vehicle = await dbOne(
      "SELECT status FROM vehicles WHERE id = ? AND status <> 'decommissioned'",
      [Number(input.vehicle_id)]
    );
    if (!vehicle) return jsonError('Vehicle is not available for driver allocation.');

    const driver = await dbOne('SELECT id FROM drivers WHERE id = ? AND is_active = 1', [Number(input.driver_id)]);
    if (!driver) return jsonError('Driver is not active.');

    const pool = getPool();
    conn = await pool.getConnection();
    await conn.beginTransaction();

    if (input.role === 'primary') {
      const startDate = new Date(input.start_date);
      startDate.setDate(startDate.getDate() - 1);
      const endDate = startDate.toISOString().slice(0, 10);
      await conn.query(
        `UPDATE vehicle_driver_assignments
         SET is_active = 0, end_date = COALESCE(end_date, ?)
         WHERE vehicle_id = ? AND role = 'primary' AND is_active = 1`,
        [endDate, Number(input.vehicle_id)]
      );
    }

    if (!input.is_active) input.is_active = 1;

    const columns = ALLOCATION_FIELDS.filter((f) => Object.prototype.hasOwnProperty.call(input, f));
    const values = columns.map((f) => (input[f] === '' ? null : input[f]));
    const [result] = await conn.query(
      `INSERT INTO vehicle_driver_assignments (${columns.join(',')}) VALUES (${columns.map(() => '?').join(',')})`,
      values
    );

    await conn.commit();
    return jsonSuccess({ id: result.insertId });
  } catch (e) {
    if (conn) await conn.rollback();
    return jsonError(e.message, e.status || 500);
  } finally {
    if (conn) conn.release();
  }
}
