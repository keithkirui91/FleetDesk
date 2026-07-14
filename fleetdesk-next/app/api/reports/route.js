import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbAll } from '@/lib/db';

export async function GET(request) {
  const { error } = requireApiSession(request);
  if (error) return error;
  try {
    const [serviceByType, fuelByVehicle, jobsByStatus] = await Promise.all([
      dbAll('SELECT service_type, COUNT(*) AS total FROM service_records GROUP BY service_type ORDER BY total DESC'),
      dbAll(`
        SELECT v.fleet_number, SUM(fl.litres_filled) AS litres, SUM(fl.total_cost) AS cost
        FROM fuel_logs fl JOIN vehicles v ON v.id = fl.vehicle_id
        GROUP BY v.id, v.fleet_number ORDER BY litres DESC LIMIT 10
      `),
      dbAll('SELECT status, COUNT(*) AS total FROM job_cards GROUP BY status ORDER BY total DESC'),
    ]);
    return jsonSuccess({ serviceByType, fuelByVehicle, jobsByStatus });
  } catch (e) {
    return jsonError(e.message, 500);
  }
}
