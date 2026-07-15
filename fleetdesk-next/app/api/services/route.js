import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbAll, insertRow, updateRow, logVehicleMileage } from '@/lib/db';

export const SERVICE_FIELDS = [
  'vehicle_id', 'mechanic_id', 'service_date', 'odometer_at_service', 'service_type',
  'work_done', 'parts_replaced', 'next_service_date', 'next_service_mileage', 'notes',
];

export async function GET(request) {
  const { error } = requireApiSession(request);
  if (error) return error;
  try {
    const rows = await dbAll(`
      SELECT sr.*, v.fleet_number, v.registration, v.make, v.model, m.full_name AS mechanic_name
      FROM service_records sr
      JOIN vehicles v ON v.id = sr.vehicle_id
      LEFT JOIN mechanics m ON m.id = sr.mechanic_id
      ORDER BY sr.service_date DESC, sr.id DESC
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
    for (const field of SERVICE_FIELDS.slice(0, 5)) {
      if (input[field] === undefined || input[field] === null || input[field] === '') {
        return jsonError(`${field.replace(/_/g, ' ')} is required.`);
      }
    }
    const id = await insertRow('service_records', SERVICE_FIELDS, input);
    await logVehicleMileage(Number(input.vehicle_id), Number(input.odometer_at_service), 'service', `Service record #${id}`);
    return jsonSuccess({ id });
  } catch (e) {
    return jsonError(e.message, e.status || 500);
  }
}
