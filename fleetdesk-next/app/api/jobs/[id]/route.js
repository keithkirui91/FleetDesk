import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbOne, updateRow, deleteRow } from '@/lib/db';
import { JOB_FIELDS, syncVehicleStatusForJob } from '../route';

export async function GET(request, { params }) {
  const { error } = requireApiSession(request);
  if (error) return error;
  const row = await dbOne('SELECT * FROM job_cards WHERE id = ?', [Number(params.id)]);
  if (!row) return jsonError('Job card not found.', 404);
  return jsonSuccess(row);
}

export async function PUT(request, { params }) {
  const { error } = requireApiSession(request);
  if (error) return error;
  const id = Number(params.id);
  try {
    const input = await request.json();

    if (input.new_note) {
      const existing = await dbOne('SELECT resolution_notes FROM job_cards WHERE id = ?', [id]);
      const history = existing?.resolution_notes || '';
      const stamp = new Date().toLocaleString('en-GB', {
        day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: false,
      }).replace(',', '');
      const entry = `[${stamp}]\n${input.new_note.trim()}`;
      input.resolution_notes = history ? `${history}\n\n\n${entry}` : entry;
    }
    delete input.new_note;

    if (input.status === 'closed' && !input.date_closed) {
      input.date_closed = new Date().toISOString().slice(0, 10);
    }

    await updateRow('job_cards', JOB_FIELDS, id, input);

    const job = await dbOne('SELECT vehicle_id, status FROM job_cards WHERE id = ?', [id]);
    if (job) await syncVehicleStatusForJob(job.vehicle_id, job.status);

    return jsonSuccess({ id });
  } catch (e) {
    return jsonError(e.message, e.status || 500);
  }
}

export async function DELETE(request, { params }) {
  const { error } = requireApiSession(request);
  if (error) return error;
  await deleteRow('job_cards', Number(params.id));
  return jsonSuccess({ id: Number(params.id) });
}
