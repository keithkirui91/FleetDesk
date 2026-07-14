import { buildListCreateHandlers } from '@/lib/moduleApi';

export const MECHANIC_FIELDS = [
  'employee_id', 'full_name', 'department', 'phone', 'email',
  'specialisations', 'date_joined', 'is_active', 'photo_url', 'notes',
];

const handlers = buildListCreateHandlers({
  table: 'mechanics',
  fields: MECHANIC_FIELDS,
  listSql: `SELECT m.*,
      (SELECT COUNT(*) FROM job_cards jc WHERE jc.mechanic_id = m.id AND jc.status <> 'closed') AS active_jobs
    FROM mechanics m ORDER BY m.full_name`,
  requiredFields: ['employee_id', 'full_name'],
});

export const { GET, POST } = handlers;
