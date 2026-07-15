import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbAll } from '@/lib/db';

// A minimal { vehicle_id: driver_name } map for active primary assignments —
// deliberately narrower than the full driver-allocations list (no notes,
// dates, etc.) so it's safe to expose to data_entry/gate sessions.
export async function GET(request) {
  const { error } = requireApiSession(request, { allowDataEntry: true });
  if (error) return error;
  try {
    const rows = await dbAll(`
      SELECT vda.vehicle_id, d.full_name AS driver_name
      FROM vehicle_driver_assignments vda
      JOIN drivers d ON d.id = vda.driver_id
      WHERE vda.role = 'primary' AND vda.is_active = 1
    `);
    const map = {};
    for (const row of rows) map[row.vehicle_id] = row.driver_name;
    return jsonSuccess(map);
  } catch (e) {
    return jsonError(e.message, 500);
  }
}
