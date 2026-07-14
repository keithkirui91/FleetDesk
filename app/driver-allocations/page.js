'use client';

import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import ModulePage from '@/components/ModulePage';

export default function DriverAllocationsPage() {
  const [options, setOptions] = useState(null);

  useEffect(() => {
    Promise.all([
      fetch('/api/vehicles').then((r) => r.json()),
      fetch('/api/drivers').then((r) => r.json()),
    ]).then(([vehiclesRes, driversRes]) => {
      setOptions({
        vehicles: (vehiclesRes.data || []).filter((v) => v.status !== 'decommissioned').map((v) => ({ value: v.id, label: `${v.fleet_number} — ${v.registration}` })),
        drivers: (driversRes.data || []).filter((d) => d.is_active).map((d) => ({ value: d.id, label: d.full_name })),
      });
    });
  }, []);

  if (!options) {
    return <AppShell title="Driver Allocations"><div className="empty">Loading…</div></AppShell>;
  }

  const config = {
    title: 'Driver Allocations',
    singular: 'Driver Allocation',
    description: 'Primary and reliever driver assignments with change history.',
    endpoint: '/api/driver-allocations',
    columns: [
      { key: 'fleet_number', label: 'Fleet No.' },
      { key: 'registration', label: 'Registration' },
      { key: 'driver_name', label: 'Driver' },
      { key: 'department', label: 'Department' },
      { key: 'role', label: 'Role', badge: true },
      { key: 'start_date', label: 'Start Date' },
      { key: 'end_date', label: 'End Date' },
      { key: 'is_active', label: 'Active' },
    ],
    fields: [
      { name: 'vehicle_id', label: 'Vehicle', type: 'select', options: options.vehicles, required: true },
      { name: 'driver_id', label: 'Driver', type: 'select', options: options.drivers, required: true },
      { name: 'role', label: 'Role', type: 'select', required: true, options: [{ value: 'primary', label: 'Primary' }, { value: 'reliever', label: 'Reliever' }] },
      { name: 'start_date', label: 'Start date', type: 'date', required: true },
      { name: 'end_date', label: 'End date', type: 'date' },
      { name: 'notes', label: 'Notes', type: 'textarea' },
    ],
  };

  return (
    <AppShell title="Driver Allocations">
      <ModulePage config={config} />
    </AppShell>
  );
}
