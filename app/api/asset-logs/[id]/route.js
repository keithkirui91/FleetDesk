import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbOne, deleteRow } from '@/lib/db';

export async function GET(request, { params }) {
  const { error } = requireApiSession(request);
  if (error) return error;
  const row = await dbOne('SELECT * FROM asset_disposal_logs WHERE id = ?', [Number(params.id)]);
  if (!row) return jsonError('Asset log not found.', 404);
  return jsonSuccess(row);
}

export async function DELETE(request, { params }) {
  const { error } = requireApiSession(request);
  if (error) return error;
  await deleteRow('asset_disposal_logs', Number(params.id));
  return jsonSuccess({ id: Number(params.id) });
}
