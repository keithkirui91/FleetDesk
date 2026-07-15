import { buildListCreateHandlers } from '@/lib/moduleApi';

export const DRIVER_FIELDS = [
  'full_name', 'department', 'dl_number', 'licence_type',
  'licence_renewal_date', 'licence_expiry_date', 'photo_url', 'comments', 'is_active',
];

const handlers = buildListCreateHandlers({
  table: 'drivers',
  fields: DRIVER_FIELDS,
  listSql: `SELECT d.*,
      (SELECT vda.vehicle_id FROM vehicle_driver_assignments vda WHERE vda.driver_id = d.id AND vda.is_active = 1 AND vda.role = 'primary' LIMIT 1) AS current_vehicle_id
    FROM drivers d ORDER BY d.full_name`,
  requiredFields: ['full_name', 'department'],
});

export const { GET, POST } = handlers;
