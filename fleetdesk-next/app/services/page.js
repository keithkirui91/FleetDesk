'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import AppShell from '@/components/AppShell';
import ModulePage from '@/components/ModulePage';

export default function ServicesPage() {
  const [options, setOptions] = useState(null);

  useEffect(() => {
    Promise.all([
      fetch('/api/vehicles').then((r) => r.json()),
      fetch('/api/mechanics').then((r) => r.json()),
    ]).then(([vehiclesRes, mechanicsRes]) => {
      setOptions({
        vehicles: (vehiclesRes.data || []).map((v) => ({ value: v.id, label: `${v.fleet_number} — ${v.registration}` })),
        mechanics: (mechanicsRes.data || []).map((m) => ({ value: m.id, label: m.full_name })),
      });
    });
  }, []);

  if (!options) {
    return <AppShell title="Service"><div className="empty">Loading…</div></AppShell>;
  }

  const config = {
    title: 'Service',
    singular: 'Service Record',
    description: 'Day jobs — short operations and routine service tracking.',
    endpoint: '/api/services',
    columns: [
      { key: 'service_date', label: 'Date' },
      { key: 'fleet_number', label: 'Fleet No.' },
      { key: 'registration', label: 'Registration' },
      { key: 'service_type', label: 'Type', badge: true },
      { key: 'odometer_at_service', label: 'Odometer' },
      { key: 'mechanic_name', label: 'Mechanic' },
      { key: 'next_service_date', label: 'Next Service' },
    ],
    fields: [
      { name: 'vehicle_id', label: 'Vehicle', type: 'select', options: options.vehicles, required: true },
      { name: 'mechanic_id', label: 'Mechanic', type: 'select', options: options.mechanics, required: true },
      { name: 'service_date', label: 'Service date', type: 'date', required: true },
      { name: 'odometer_at_service', label: 'Odometer', type: 'number', required: true },
      { name: 'service_type', label: 'Type', type: 'select', required: true, options: [{ value: 'interim', label: 'Interim' }, { value: 'full', label: 'Full' }, { value: 'major', label: 'Major' }] },
      { name: 'next_service_date', label: 'Next service date', type: 'date', required: true },
      { name: 'next_service_mileage', label: 'Next service mileage', type: 'number', required: true },
      { name: 'parts_replaced', label: 'Parts replaced', type: 'textarea', required: true },
      { name: 'work_done', label: 'Work done', type: 'textarea', required: true },
      { name: 'notes', label: 'Notes', type: 'textarea', required: true },
    ],
  };

  return (
    <AppShell title="Service">
      <ModulePage
        config={config}
        extraToolbarActions={() => (
          <>
            <Link className="btn" href="/battery-logs">Battery Change Logs</Link>
            <Link className="btn" href="/tyre-logs">Tyre Change Logs</Link>
          </>
        )}
      />
    </AppShell>
  );
}
