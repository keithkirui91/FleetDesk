import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbOne, updateRow, deleteRow, logVehicleMileage } from '@/lib/db';
import { FUEL_FIELDS } from '../route';

export async function GET(request, { params }) {
  const { error } = requireApiSession(request);
  if (error) return error;
  const row = await dbOne('SELECT * FROM fuel_logs WHERE id = ?', [Number(params.id)]);
  if (!row) return jsonError('Fuel log not found.', 404);
  return jsonSuccess(row);
}

export async function PUT(request, { params }) {
  const { error } = requireApiSession(request);
  if (error) return error;
  const id = Number(params.id);
  try {
    const input = await request.json();
    await updateRow('fuel_logs', FUEL_FIELDS, id, input);
    if (input.vehicle_id && input.odometer_at_fill) {
      await logVehicleMileage(Number(input.vehicle_id), Number(input.odometer_at_fill), 'fuel', `Fuel update #${id}`);
    }
    return jsonSuccess({ id });
  } catch (e) {
    return jsonError(e.message, e.status || 500);
  }
}

export async function DELETE(request, { params }) {
  const { error } = requireApiSession(request);
  if (error) return error;
  await deleteRow('fuel_logs', Number(params.id));
  return jsonSuccess({ id: Number(params.id) });
}
