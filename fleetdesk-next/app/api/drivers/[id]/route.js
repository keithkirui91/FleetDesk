import { buildItemHandlers } from '@/lib/moduleApi';
import { DRIVER_FIELDS } from '../route';

export const { GET, PUT, DELETE } = buildItemHandlers({
  table: 'drivers',
  fields: DRIVER_FIELDS,
});
