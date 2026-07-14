import { buildListCreateHandlers } from '@/lib/moduleApi';

export const BATTERY_FIELDS = [
  'vehicle_id', 'service_record_id', 'change_date', 'odometer', 'quantity',
  'battery_size', 'battery_type', 'expected_lifespan_months', 'reason_for_removal', 'notes',
];

const handlers = buildListCreateHandlers({
  table: 'battery_change_logs',
  fields: BATTERY_FIELDS,
  listSql: `SELECT bcl.*, v.fleet_number, v.registration
    FROM battery_change_logs bcl
    JOIN vehicles v ON v.id = bcl.vehicle_id
    ORDER BY bcl.change_date DESC, bcl.id DESC`,
  requiredFields: ['vehicle_id', 'change_date'],
});

export const { GET, POST } = handlers;
