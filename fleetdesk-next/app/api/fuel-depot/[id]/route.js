import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { deleteRow } from '@/lib/db';

export async function DELETE(request, { params }) {
  const { error } = requireApiSession(request);
  if (error) return error;
  await deleteRow('fuel_depot_readings', Number(params.id));
  return jsonSuccess({ id: Number(params.id) });
}
