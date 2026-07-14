import { buildListCreateHandlers } from '@/lib/moduleApi';

export const TYRE_FIELDS = [
  'vehicle_id', 'service_record_id', 'change_date', 'odometer', 'quantity',
  'tyre_name', 'tyre_size', 'tyre_type', 'expected_lifespan_km', 'quality_comment', 'notes',
];

const handlers = buildListCreateHandlers({
  table: 'tyre_change_logs',
  fields: TYRE_FIELDS,
  listSql: `SELECT tcl.*, v.fleet_number, v.registration
    FROM tyre_change_logs tcl
    JOIN vehicles v ON v.id = tcl.vehicle_id
    ORDER BY tcl.change_date DESC, tcl.id DESC`,
  requiredFields: ['vehicle_id', 'change_date'],
});

export const { GET, POST } = handlers;
