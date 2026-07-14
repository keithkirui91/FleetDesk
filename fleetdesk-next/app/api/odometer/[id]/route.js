import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { deleteRow } from '@/lib/db';

export async function DELETE(request, { params }) {
  const { session, error } = requireApiSession(request);
  if (error) return error; // admin-only: requireApiSession without allowDataEntry already blocks data_entry
  await deleteRow('odometer_logs', Number(params.id));
  return jsonSuccess({ id: Number(params.id) });
}
