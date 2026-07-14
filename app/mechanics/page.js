'use client';

import AppShell from '@/components/AppShell';
import ModulePage from '@/components/ModulePage';

const config = {
  title: 'Mechanics',
  singular: 'Mechanic',
  description: 'Workshop staff, contacts, specialisations, and active job load.',
  endpoint: '/api/mechanics',
  completenessFields: ['employee_id', 'full_name', 'department', 'phone', 'email', 'specialisations', 'date_joined'],
  columns: [
    { key: 'employee_id', label: 'Employee ID' },
    { key: 'full_name', label: 'Name' },
    { key: 'department', label: 'Department' },
    { key: 'phone', label: 'Phone' },
    { key: 'email', label: 'Email' },
    { key: 'specialisations', label: 'Specialisations' },
    { key: 'active_jobs', label: 'Open Jobs' },
    { key: 'is_active', label: 'Active' },
  ],
  fields: [
    { name: 'employee_id', label: 'Employee ID', required: true },
    { name: 'full_name', label: 'Full name', required: true },
    { name: 'department', label: 'Department' },
    { name: 'phone', label: 'Phone' },
    { name: 'email', label: 'Email', type: 'email' },
    { name: 'specialisations', label: 'Specialisations' },
    { name: 'date_joined', label: 'Date joined', type: 'date' },
    { name: 'is_active', label: 'Status', type: 'select', options: [{ value: '1', label: 'Active' }, { value: '0', label: 'Inactive' }] },
    { name: 'notes', label: 'Notes', type: 'textarea' },
  ],
};

export default function MechanicsPage() {
  return (
    <AppShell title="Mechanics">
      <ModulePage config={config} />
    </AppShell>
  );
}
