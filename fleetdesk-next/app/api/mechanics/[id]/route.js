import { buildItemHandlers } from '@/lib/moduleApi';
import { MECHANIC_FIELDS } from '../route';

export const { GET, PUT, DELETE } = buildItemHandlers({
  table: 'mechanics',
  fields: MECHANIC_FIELDS,
});
