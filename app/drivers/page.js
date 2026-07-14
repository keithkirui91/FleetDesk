'use client';

import AppShell from '@/components/AppShell';
import ModulePage from '@/components/ModulePage';

const LICENCE_TYPES = ['Class A', 'Class B', 'Class C', 'Class D', 'Class E', 'Class F', 'Class G', 'PSV', 'HGV', 'Interim', 'Other'];

const config = {
  title: 'Drivers',
  singular: 'Driver',
  description: 'Driver profiles, departments, licence dates, and comments.',
  endpoint: '/api/drivers',
  completenessFields: ['full_name', 'department', 'dl_number', 'licence_type', 'licence_renewal_date', 'licence_expiry_date'],
  columns: [
    { key: 'full_name', label: 'Name' },
    { key: 'department', label: 'Department' },
    { key: 'dl_number', label: 'DL No.' },
    { key: 'licence_type', label: 'Licence Type' },
    { key: 'licence_renewal_date', label: 'Renewal Date' },
    { key: 'licence_expiry_date', label: 'Expiry Date' },
    { key: 'is_active', label: 'Active' },
  ],
  fields: [
    { name: 'full_name', label: 'Full name', required: true },
    { name: 'department', label: 'Department', required: true },
    { name: 'dl_number', label: 'DL number' },
    { name: 'licence_type', label: 'Licence Type(s) — comma separated', type: 'text' },
    { name: 'licence_renewal_date', label: 'Licence renewal date', type: 'date' },
    { name: 'licence_expiry_date', label: 'Licence expiry date', type: 'date' },
    { name: 'is_active', label: 'Status', type: 'select', options: [{ value: '1', label: 'Active' }, { value: '0', label: 'Inactive' }] },
    { name: 'comments', label: 'Comments', type: 'textarea' },
  ],
};

export default function DriversPage() {
  return (
    <AppShell title="Drivers">
      <ModulePage config={config} />
    </AppShell>
  );
}
