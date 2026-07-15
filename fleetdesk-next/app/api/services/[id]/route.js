import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbOne, updateRow, deleteRow, logVehicleMileage } from '@/lib/db';
import { SERVICE_FIELDS } from '../route';

export async function GET(request, { params }) {
  const { error } = requireApiSession(request);
  if (error) return error;
  const row = await dbOne('SELECT * FROM service_records WHERE id = ?', [Number(params.id)]);
  if (!row) return jsonError('Service record not found.', 404);
  return jsonSuccess(row);
}

export async function PUT(request, { params }) {
  const { error } = requireApiSession(request);
  if (error) return error;
  const id = Number(params.id);
  try {
    const input = await request.json();
    await updateRow('service_records', SERVICE_FIELDS, id, input);
    if (input.vehicle_id && input.odometer_at_service) {
      await logVehicleMileage(Number(input.vehicle_id), Number(input.odometer_at_service), 'service', `Service update #${id}`);
    }
    return jsonSuccess({ id });
  } catch (e) {
    return jsonError(e.message, e.status || 500);
  }
}

export async function DELETE(request, { params }) {
  const { error } = requireApiSession(request);
  if (error) return error;
  await deleteRow('service_records', Number(params.id));
  return jsonSuccess({ id: Number(params.id) });
}
