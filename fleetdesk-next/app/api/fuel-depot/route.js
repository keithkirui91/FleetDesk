import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbAll, dbOne, insertRow } from '@/lib/db';

export async function GET(request) {
  const { error } = requireApiSession(request);
  if (error) return error;
  const { searchParams } = new URL(request.url);
  try {
    if (searchParams.get('action') === 'latest') {
      const rows = await dbAll(`
        SELECT fuel_type, dip_litres, reading_date, transaction_type
        FROM fuel_depot_readings fdr1
        WHERE id = (
          SELECT id FROM fuel_depot_readings fdr2
          WHERE fdr2.fuel_type = fdr1.fuel_type
          ORDER BY reading_date DESC, id DESC LIMIT 1
        )
      `);
      return jsonSuccess(rows);
    }
    const type = searchParams.get('type');
    if (type) {
      const rows = await dbAll(
        'SELECT * FROM fuel_depot_readings WHERE transaction_type = ? ORDER BY reading_date DESC, id DESC',
        [type]
      );
      return jsonSuccess(rows);
    }
    const rows = await dbAll('SELECT * FROM fuel_depot_readings ORDER BY reading_date DESC, id DESC');
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

    if (!input.reading_date || !input.fuel_type) {
      return jsonError('Date and fuel type are required.');
    }

    if (input.transaction_type === 'stock_received') {
      const fuelType = input.fuel_type || 'diesel';
      const received = Number(input.quantity_litres || input.dip_litres || 0);
      if (!received) return jsonError('quantity_litres is required for stock received.');

      const latest = await dbOne(
        'SELECT dip_litres FROM fuel_depot_readings WHERE fuel_type = ? ORDER BY reading_date DESC, id DESC LIMIT 1',
        [fuelType]
      );
      const current = latest ? Number(latest.dip_litres) : 0;
      input.dip_litres = current + received;
    } else if (input.dip_litres === undefined || input.dip_litres === null || input.dip_litres === '') {
      return jsonError('Dip reading (litres) is required.');
    }

    const fields = ['reading_date', 'fuel_type', 'dip_litres', 'transaction_type', 'quantity_litres', 'notes', 'recorded_by'];
    const id = await insertRow('fuel_depot_readings', fields, input);
    return jsonSuccess({ id, new_balance: input.dip_litres ?? null });
  } catch (e) {
    return jsonError(e.message, e.status || 500);
  }
}
