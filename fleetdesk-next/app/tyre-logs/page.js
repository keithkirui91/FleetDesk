'use client';

import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import ModulePage from '@/components/ModulePage';

export default function TyreLogsPage() {
  const [vehicles, setVehicles] = useState(null);

  useEffect(() => {
    fetch('/api/vehicles').then((r) => r.json()).then((res) => {
      setVehicles((res.data || []).map((v) => ({ value: v.id, label: `${v.fleet_number} — ${v.registration}` })));
    });
  }, []);

  if (!vehicles) {
    return <AppShell title="Tyre Change Logs"><div className="empty">Loading…</div></AppShell>;
  }

  const config = {
    title: 'Tyre Change Logs',
    singular: 'Tyre Change',
    description: 'Record of all tyre replacements across the fleet.',
    endpoint: '/api/tyre-logs',
    columns: [
      { key: 'change_date', label: 'Date' },
      { key: 'fleet_number', label: 'Fleet No.' },
      { key: 'registration', label: 'Registration' },
      { key: 'quantity', label: 'Qty' },
      { key: 'tyre_name', label: 'Tyre Name' },
      { key: 'tyre_size', label: 'Size' },
      { key: 'tyre_type', label: 'Type', badge: true },
      { key: 'expected_lifespan_km', label: 'Expected Life (km)' },
      { key: 'quality_comment', label: 'Quality Assessment' },
    ],
    fields: [
      { name: 'vehicle_id', label: 'Vehicle', type: 'select', options: vehicles, required: true },
      { name: 'change_date', label: 'Date of Change', type: 'date', required: true },
      { name: 'odometer', label: 'Odometer (km)', type: 'number' },
      { name: 'quantity', label: 'Quantity', type: 'number', required: true },
      { name: 'tyre_name', label: 'Tyre Name / Brand' },
      { name: 'tyre_size', label: 'Tyre Size', required: true },
      { name: 'tyre_type', label: 'Tyre Type', type: 'select', required: true, options: [
        { value: 'Nylon', label: 'Nylon' }, { value: 'Radial', label: 'Radial' }, { value: 'Superlug', label: 'Superlug' },
      ] },
      { name: 'expected_lifespan_km', label: 'Expected Lifespan (km)', type: 'number' },
      { name: 'quality_comment', label: 'Quality Assessment', type: 'textarea' },
      { name: 'notes', label: 'Notes', type: 'textarea' },
    ],
  };

  return (
    <AppShell title="Tyre Change Logs">
      <ModulePage config={config} />
    </AppShell>
  );
}
