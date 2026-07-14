import { buildItemHandlers } from '@/lib/moduleApi';
import { ALLOCATION_FIELDS } from '../route';

export const { GET, PUT, DELETE } = buildItemHandlers({
  table: 'vehicle_driver_assignments',
  fields: ALLOCATION_FIELDS,
});
