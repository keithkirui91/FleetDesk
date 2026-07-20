import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbAll, dbOne, dbValue, insertRow, logVehicleMileage, getPool } from '@/lib/db';

export const FUEL_FIELDS = [
  'vehicle_id', 'log_date', 'odometer_at_fill', 'litres_filled', 'fuel_type',
  'station_location', 'cost_per_litre', 'total_cost', 'issuer_name', 'receiver_name', 'notes',
];

const DEPOT_LOCATIONS = ['Kamok Depot', 'Control Depot'];

async function deductFromDepot(fuelType, litres, date, location) {
  const latest = await dbOne(
    'SELECT dip_litres FROM fuel_depot_readings WHERE fuel_type = ? ORDER BY reading_date DESC, id DESC LIMIT 1',
    [fuelType]
  );
  const current = latest ? Number(latest.dip_litres) : 0;
  const newBalance = Math.max(0, current - litres);
  const note = `Auto-deducted ${litres}L for fuel log from ${location}`;
  await getPool().query(
    `INSERT INTO fuel_depot_readings (reading_date, fuel_type, dip_litres, transaction_type, quantity_litres, notes, recorded_by)
     VALUES (?, ?, ?, 'fuel_dispensed', ?, ?, 'System — auto deduction')`,
    [date, fuelType, newBalance, litres, note]
  );
}

export async function GET(request) {
  const { error } = requireApiSession(request);
  if (error) return error;
  const { searchParams } = new URL(request.url);
  const page = Math.max(1, Number(searchParams.get('page') || 1));
  const requestedPageSize = Number(searchParams.get('pageSize') || 0);
  const pageSize = requestedPageSize > 0 ? Math.min(100, Math.max(1, requestedPageSize)) : 0;
  const offset = (page - 1) * pageSize;
  try {
    const baseSql = `
      SELECT fl.*, v.fleet_number, v.registration, v.make, v.model
      FROM fuel_logs fl
      JOIN vehicles v ON v.id = fl.vehicle_id
      ORDER BY fl.log_date DESC, fl.id DESC
    `;
    const rows = pageSize
      ? await dbAll(`${baseSql} LIMIT ? OFFSET ?`, [pageSize, offset])
      : await dbAll(baseSql);
    if (pageSize) {
      const total = Number(await dbValue('SELECT COUNT(*) FROM fuel_logs'));
      return jsonSuccess({ rows, pagination: { page, pageSize, total, totalPages: Math.max(1, Math.ceil(total / pageSize)) } });
    }
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
    for (const field of ['vehicle_id', 'log_date', 'odometer_at_fill', 'litres_filled', 'fuel_type', 'station_location']) {
      if (input[field] === undefined || input[field] === null || input[field] === '') {
        return jsonError(`${field.replace(/_/g, ' ')} is required.`);
      }
    }
    const id = await insertRow('fuel_logs', FUEL_FIELDS, input);
    await logVehicleMileage(Number(input.vehicle_id), Number(input.odometer_at_fill), 'fuel', `Fuel log #${id}`);

    if (DEPOT_LOCATIONS.includes(input.station_location)) {
      await deductFromDepot(input.fuel_type, Number(input.litres_filled), input.log_date, input.station_location);
    }
    return jsonSuccess({ id });
  } catch (e) {
    return jsonError(e.message, e.status || 500);
  }
}
