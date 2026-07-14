'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import AppShell from '@/components/AppShell';
import ModulePage from '@/components/ModulePage';

export default function FuelPage() {
  const [vehicles, setVehicles] = useState(null);

  useEffect(() => {
    fetch('/api/vehicles').then((r) => r.json()).then((res) => {
      setVehicles((res.data || []).map((v) => ({ value: v.id, label: `${v.fleet_number} — ${v.registration}` })));
    });
  }, []);

  if (!vehicles) {
    return <AppShell title="Fuel"><div className="empty">Loading…</div></AppShell>;
  }

  const config = {
    title: 'Fuel',
    singular: 'Fuel Log',
    description: 'Fuel fills, litres, cost, stations, and vehicle odometer readings.',
    endpoint: '/api/fuel',
    columns: [
      { key: 'log_date', label: 'Date' },
      { key: 'fleet_number', label: 'Fleet No.' },
      { key: 'registration', label: 'Registration' },
      { key: 'odometer_at_fill', label: 'Odometer' },
      { key: 'litres_filled', label: 'Litres' },
      { key: 'fuel_type', label: 'Fuel', badge: true },
      { key: 'station_location', label: 'Fueling Point' },
      { key: 'total_cost', label: 'Cost' },
    ],
    fields: [
      { name: 'vehicle_id', label: 'Vehicle', type: 'select', options: vehicles, required: true },
      { name: 'log_date', label: 'Date', type: 'date', required: true },
      { name: 'odometer_at_fill', label: 'Odometer (km)', type: 'number', required: true },
      { name: 'litres_filled', label: 'Litres', type: 'number', required: true },
      { name: 'fuel_type', label: 'Fuel Type', type: 'select', required: true, options: [
        { value: 'diesel', label: 'Diesel' }, { value: 'petrol', label: 'Petrol' }, { value: 'hybrid', label: 'Hybrid' },
        { value: 'lpg', label: 'LPG' }, { value: 'kerosene', label: 'Kerosene' }, { value: 'other', label: 'Other' },
      ] },
      { name: 'station_location', label: 'Fueling Point', type: 'select', required: true, options: [
        { value: 'Kamok Depot', label: 'Kamok Depot' }, { value: 'Control Depot', label: 'Control Depot' }, { value: 'External Fueling', label: 'External Fueling' },
      ] },
      { name: 'cost_per_litre', label: 'Cost per Litre', type: 'number', required: true },
      { name: 'total_cost', label: 'Total Cost', type: 'number', required: true },
      { name: 'issuer_name', label: 'Issued By', required: true },
      { name: 'receiver_name', label: 'Received By', required: true },
      { name: 'notes', label: 'Notes', type: 'textarea' },
    ],
  };

  return (
    <AppShell title="Fuel">
      <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: 8 }}>
        <Link className="btn" href="/dip-readings">Dip Reading Logs</Link>
      </div>
      <ModulePage config={config} />
    </AppShell>
  );
}
