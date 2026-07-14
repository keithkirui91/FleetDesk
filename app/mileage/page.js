'use client';

import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import ModulePage from '@/components/ModulePage';

export default function MileagePage() {
  const [vehicles, setVehicles] = useState(null);

  useEffect(() => {
    fetch('/api/vehicles').then((r) => r.json()).then((res) => {
      setVehicles((res.data || []).filter((v) => v.status === 'active').map((v) => ({ value: v.id, label: `${v.fleet_number} — ${v.registration}` })));
    });
  }, []);

  if (!vehicles) {
    return <AppShell title="Mileage"><div className="empty">Loading…</div></AppShell>;
  }

  const config = {
    title: 'Mileage',
    singular: 'Mileage Log',
    description: 'Odometer history for gate, workshop, service, and fuel readings.',
    endpoint: '/api/odometer',
    columns: [
      { key: 'logged_at', label: 'Logged At' },
      { key: 'fleet_number', label: 'Fleet No.' },
      { key: 'registration', label: 'Registration' },
      { key: 'odometer_reading', label: 'Odometer' },
      { key: 'location', label: 'Location', badge: true },
      { key: 'notes', label: 'Notes' },
    ],
    fields: [
      { name: 'vehicle_id', label: 'Vehicle', type: 'select', options: vehicles, required: true },
      { name: 'odometer_reading', label: 'Odometer', type: 'number', required: true },
      { name: 'location', label: 'Location', type: 'select', options: [
        { value: 'gate_in', label: 'Gate in' }, { value: 'gate_out', label: 'Gate out' }, { value: 'workshop', label: 'Workshop' },
        { value: 'service', label: 'Service' }, { value: 'fuel', label: 'Fuel' }, { value: 'other', label: 'Other' },
      ] },
      { name: 'notes', label: 'Notes', type: 'textarea' },
    ],
  };

  return (
    <AppShell title="Mileage">
      <ModulePage config={config} />
    </AppShell>
  );
}
