import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbAll, getPool, insertRow, currentOdometerSql } from '@/lib/db';

export const VEHICLE_FIELDS = [
  'fleet_number', 'registration', 'make', 'model', 'year', 'date_acquired',
  'new_gen_plates', 'colour', 'fuel_type', 'body_type', 'vehicle_type', 'fleet_type',
  'department', 'vin_chassis', 'engine_number', 'engine_size', 'engine_capacity', 'transmission',
  'drive_type', 'seating_capacity', 'payload_capacity_kg', 'tare_weight_kg',
  'gross_weight_kg', 'tyre_size_standard', 'logbook_status', 'odometer_status',
  'inspection_status', 'insurance_expiry', 'licence_expiry',
  'last_service_date', 'next_service_date', 'next_service_mileage',
  'primary_image_url', 'status', 'notes',
];

export async function GET(request) {
  const { error } = requireApiSession(request, { allowDataEntry: true });
  if (error) return error;
  try {
    const currentOdometer = currentOdometerSql('v');
    const rows = await dbAll(`
      SELECT v.*,
             ${currentOdometer} AS current_odometer,
             (SELECT COUNT(*) FROM job_cards jc WHERE jc.vehicle_id = v.id AND jc.status <> 'closed') AS open_jobs
      FROM vehicles v
      ORDER BY v.fleet_number
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
    for (const required of ['fleet_number', 'registration', 'make', 'model']) {
      if (!input[required]) return jsonError(`${required} is required.`);
    }

    const pool = getPool();
    conn = await pool.getConnection();
    await conn.beginTransaction();

    const columns = VEHICLE_FIELDS.filter((f) => Object.prototype.hasOwnProperty.call(input, f));
    const values = columns.map((f) => (input[f] === '' ? null : input[f]));
    const [result] = await conn.query(
      `INSERT INTO vehicles (${columns.join(',')}) VALUES (${columns.map(() => '?').join(',')})`,
      values
    );
    const id = result.insertId;

    if (input.odometer_current) {
      await conn.query(
        'INSERT INTO odometer_logs (vehicle_id, odometer_reading, location, notes) VALUES (?, ?, "workshop", "Opening odometer")',
        [id, Number(input.odometer_current)]
      );
    }

    await conn.commit();
    return jsonSuccess({ id });
  } catch (e) {
    if (conn) await conn.rollback();
    if (String(e.message).includes('Duplicate entry') && String(e.message).includes('registration')) {
      return jsonError('A vehicle with this registration number already exists. Registration numbers must be unique — fleet numbers can repeat.', 409);
    }
    return jsonError(e.message, 500);
  } finally {
    if (conn) conn.release();
  }
}
