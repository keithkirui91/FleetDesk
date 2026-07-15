import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbAll, dbOne, insertRow } from '@/lib/db';

export const ODOMETER_FIELDS = ['vehicle_id', 'odometer_reading', 'driver_name', 'location', 'notes', 'logged_at'];

export async function GET(request) {
  const { error } = requireApiSession(request, { allowDataEntry: true });
  if (error) return error;
  try {
    const rows = await dbAll(`
      SELECT ol.*, v.fleet_number, v.registration, v.make, v.model
      FROM odometer_logs ol
      JOIN vehicles v ON v.id = ol.vehicle_id
      ORDER BY ol.logged_at DESC, ol.id DESC
    `);
    return jsonSuccess(rows);
  } catch (e) {
    return jsonError(e.message, 500);
  }
}

export async function POST(request) {
  const { error } = requireApiSession(request, { allowDataEntry: true });
  if (error) return error;
  try {
    const input = await request.json();
    if (!input.vehicle_id || !input.odometer_reading || !input.location) {
      return jsonError('Vehicle, mileage, and movement/location are required.');
    }
    const vehicle = await dbOne('SELECT status FROM vehicles WHERE id = ?', [Number(input.vehicle_id)]);
    if (!vehicle) return jsonError('Vehicle not found.', 404);
    if (vehicle.status !== 'active') return jsonError('Only active vehicles can receive mileage log updates.', 422);

    const id = await insertRow('odometer_logs', ODOMETER_FIELDS, input);
    return jsonSuccess({ id });
  } catch (e) {
    return jsonError(e.message, e.status || 500);
  }
}
