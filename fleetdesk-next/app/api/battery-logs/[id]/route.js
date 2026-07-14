import { buildItemHandlers } from '@/lib/moduleApi';
import { BATTERY_FIELDS } from '../route';

export const { GET, PUT, DELETE } = buildItemHandlers({
  table: 'battery_change_logs',
  fields: BATTERY_FIELDS,
});
