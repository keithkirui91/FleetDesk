'use client';

import Link from 'next/link';
import AppShell from '@/components/AppShell';
import ModulePage from '@/components/ModulePage';

const config = {
  title: 'Fuel Delivery Logs',
  singular: 'Fuel Delivery',
  description: 'New fuel stock received at the depot. Each delivery automatically updates the tank balance as a new dip reading.',
  endpoint: '/api/fuel-depot',
  listUrl: '/api/fuel-depot?transaction_type=delivery',
  fixedFields: { transaction_type: 'stock_received' },
  canEdit: false,
  columns: [
    { key: 'reading_date', label: 'Date' },
    { key: 'fuel_type', label: 'Fuel Type', badge: true },
    { key: 'quantity_litres', label: 'Delivered (L)' },
    { key: 'dip_litres', label: 'New Balance (L)' },
    { key: 'recorded_by', label: 'Recorded By' },
    { key: 'notes', label: 'Notes' },
  ],
  fields: [
    { name: 'reading_date', label: 'Delivery date', type: 'date', required: true },
    { name: 'fuel_type', label: 'Fuel Type', type: 'select', required: true, options: [
      { value: 'diesel', label: 'Diesel' }, { value: 'petrol', label: 'Petrol' }, { value: 'kerosene', label: 'Kerosene' }, { value: 'other', label: 'Other' },
    ] },
    { name: 'quantity_litres', label: 'Quantity delivered (Litres)', type: 'number', required: true },
    { name: 'dip_litres', label: 'Tank balance after delivery (Litres)', hideOnAdd: true },
    { name: 'recorded_by', label: 'Recorded By' },
    { name: 'notes', label: 'Notes (supplier, delivery note no., etc.)', type: 'textarea' },
  ],
};

export default function FuelDeliveryPage() {
  return (
    <AppShell title="Fuel Delivery Logs">
      <ModulePage config={config} extraToolbarActions={() => <Link className="btn" href="/dip-readings">Dip Reading Logs</Link>} />
    </AppShell>
  );
}
