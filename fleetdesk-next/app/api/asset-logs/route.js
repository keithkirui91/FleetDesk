import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbAll } from '@/lib/db';

export async function GET(request) {
  const { error } = requireApiSession(request);
  if (error) return error;
  try {
    const rows = await dbAll('SELECT * FROM asset_disposal_logs ORDER BY logged_at DESC, id DESC');
    return jsonSuccess(rows);
  } catch (e) {
    return jsonError(e.message, 500);
  }
}

export async function POST() {
  return jsonError('Asset logs are created automatically from fleet actions.');
}
