import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbAll } from '@/lib/db';

// Distinct driver names typed into mileage logs before, used to power the
// autocomplete on the gate/admin mileage forms. Includes both drivers on
// file and any free-text names gate staff have typed in the past.
export async function GET(request) {
  const { error } = requireApiSession(request, { allowDataEntry: true });
  if (error) return error;
  try {
    const [fromLogs, fromDrivers] = await Promise.all([
      dbAll(`
        SELECT DISTINCT driver_name AS name
        FROM odometer_logs
        WHERE driver_name IS NOT NULL AND driver_name <> ''
      `),
      dbAll(`SELECT DISTINCT full_name AS name FROM drivers WHERE is_active = 1`),
    ]);
    const names = Array.from(new Set([...fromDrivers, ...fromLogs].map((r) => r.name))).sort();
    return jsonSuccess(names);
  } catch (e) {
    return jsonError(e.message, 500);
  }
}
