import { buildItemHandlers } from '@/lib/moduleApi';
import { TYRE_FIELDS } from '../route';

export const { GET, PUT, DELETE } = buildItemHandlers({
  table: 'tyre_change_logs',
  fields: TYRE_FIELDS,
});
