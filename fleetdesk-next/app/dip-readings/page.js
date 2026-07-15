'use client';

import Link from 'next/link';
import AppShell from '@/components/AppShell';
import ModulePage from '@/components/ModulePage';

const config = {
  title: 'Dip Reading Logs',
  singular: 'Dip Reading',
  description: 'Manual fuel depot dip readings and stock balance history.',
  endpoint: '/api/fuel-depot',
  listUrl: '/api/fuel-depot?type=dip_reading',
  fixedFields: { transaction_type: 'dip_reading' },
  columns: [
    { key: 'reading_date', label: 'Date' },
    { key: 'fuel_type', label: 'Fuel Type', badge: true },
    { key: 'dip_litres', label: 'Dip (Litres)' },
    { key: 'recorded_by', label: 'Recorded By' },
    { key: 'notes', label: 'Notes' },
  ],
  fields: [
    { name: 'reading_date', label: 'Date', type: 'date', required: true },
    { name: 'fuel_type', label: 'Fuel Type', type: 'select', required: true, options: [
      { value: 'diesel', label: 'Diesel' }, { value: 'petrol', label: 'Petrol' }, { value: 'kerosene', label: 'Kerosene' }, { value: 'other', label: 'Other' },
    ] },
    { name: 'dip_litres', label: 'Dip (Litres)', type: 'number', required: true },
    { name: 'recorded_by', label: 'Recorded By' },
    { name: 'notes', label: 'Notes', type: 'textarea' },
  ],
};

export default function DipReadingsPage() {
  return (
    <AppShell title="Dip Reading Logs">
      <ModulePage config={config} extraToolbarActions={() => <Link className="btn" href="/fuel-delivery">Fuel Delivery Logs</Link>} />
    </AppShell>
  );
}
