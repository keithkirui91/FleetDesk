'use client';

import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import ModulePage from '@/components/ModulePage';

export default function BatteryLogsPage() {
  const [vehicles, setVehicles] = useState(null);

  useEffect(() => {
    fetch('/api/vehicles').then((r) => r.json()).then((res) => {
      setVehicles((res.data || []).map((v) => ({ value: v.id, label: `${v.fleet_number} — ${v.registration}` })));
    });
  }, []);

  if (!vehicles) {
    return <AppShell title="Battery Change Logs"><div className="empty">Loading…</div></AppShell>;
  }

  const config = {
    title: 'Battery Change Logs',
    singular: 'Battery Change',
    description: 'Record of all battery replacements across the fleet.',
    endpoint: '/api/battery-logs',
    columns: [
      { key: 'change_date', label: 'Date' },
      { key: 'fleet_number', label: 'Fleet No.' },
      { key: 'registration', label: 'Registration' },
      { key: 'quantity', label: 'Qty' },
      { key: 'battery_size', label: 'Size' },
      { key: 'battery_type', label: 'Type' },
      { key: 'expected_lifespan_months', label: 'Expected Life (months)' },
      { key: 'reason_for_removal', label: 'Reason for Removal' },
    ],
    fields: [
      { name: 'vehicle_id', label: 'Vehicle', type: 'select', options: vehicles, required: true },
      { name: 'change_date', label: 'Date of Change', type: 'date', required: true },
      { name: 'odometer', label: 'Odometer (km)', type: 'number' },
      { name: 'quantity', label: 'Quantity', type: 'number', required: true },
      { name: 'battery_size', label: 'Battery Size (e.g. 12V/70Ah)', required: true },
      { name: 'battery_type', label: 'Battery Type', required: true },
      { name: 'expected_lifespan_months', label: 'Expected Lifespan (months)', type: 'number' },
      { name: 'reason_for_removal', label: 'Reason for Removal', type: 'textarea', required: true },
      { name: 'notes', label: 'Notes', type: 'textarea' },
    ],
  };

  return (
    <AppShell title="Battery Change Logs">
      <ModulePage config={config} />
    </AppShell>
  );
}
