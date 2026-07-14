'use client';

import AppShell from '@/components/AppShell';
import ModulePage from '@/components/ModulePage';

const config = {
  title: 'Disposed Assets',
  singular: 'Asset Log',
  description: 'Vehicles that were disposed or written off, with saved audit snapshots.',
  endpoint: '/api/asset-logs',
  hideAdd: true,
  canEdit: false,
  columns: [
    { key: 'action_type', label: 'Action', badge: true },
    { key: 'fleet_number', label: 'Fleet No.' },
    { key: 'registration', label: 'Registration' },
    { key: 'make', label: 'Make' },
    { key: 'model', label: 'Model' },
    { key: 'department', label: 'Department' },
    { key: 'current_odometer', label: 'Odometer' },
    { key: 'logged_at', label: 'Logged At' },
  ],
  fields: [
    { name: 'action_type', label: 'Action' },
    { name: 'fleet_number', label: 'Fleet number' },
    { name: 'registration', label: 'Registration' },
    { name: 'make', label: 'Make' },
    { name: 'model', label: 'Model' },
    { name: 'department', label: 'Department' },
    { name: 'current_odometer', label: 'Odometer at disposal' },
    { name: 'reason', label: 'Reason', type: 'textarea' },
    { name: 'logged_at', label: 'Logged At' },
  ],
};

export default function DisposedAssetsPage() {
  return (
    <AppShell title="Disposed Assets">
      <ModulePage config={config} />
    </AppShell>
  );
}
