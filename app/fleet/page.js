'use client';

import { useState } from 'react';
import Link from 'next/link';
import AppShell from '@/components/AppShell';
import ModulePage from '@/components/ModulePage';

const config = {
  title: 'Fleet',
  singular: 'Vehicle',
  description: 'Vehicles, departments, service status, and current odometer readings.',
  endpoint: '/api/vehicles',
  imageField: 'primary_image_url',
  uploadType: 'vehicle',
  completenessFields: [
    'fleet_number', 'registration', 'make', 'model', 'year', 'date_acquired',
    'colour', 'fuel_type', 'body_type', 'vehicle_type', 'fleet_type', 'department',
    'vin_chassis', 'engine_number', 'engine_size', 'engine_capacity', 'transmission',
    'drive_type', 'seating_capacity', 'payload_capacity_kg', 'tare_weight_kg',
    'gross_weight_kg', 'tyre_size_standard', 'logbook_status', 'odometer_status',
    'inspection_status', 'next_service_date', 'next_service_mileage',
  ],
  columns: [
    { key: 'fleet_number', label: 'Fleet No.' },
    { key: 'registration', label: 'Registration' },
    { key: 'make', label: 'Make' },
    { key: 'model', label: 'Model' },
    { key: 'department', label: 'Department' },
    { key: 'current_odometer', label: 'Odometer' },
    { key: 'status', label: 'Status', badge: true },
  ],
  fields: [
    { name: 'fleet_number', label: 'Fleet Number', required: true },
    { name: 'registration', label: 'Registration', required: true },
    { name: 'make', label: 'Make', required: true },
    { name: 'model', label: 'Model', required: true },
    { name: 'year', label: 'Year of Manufacture', type: 'number' },
    { name: 'date_acquired', label: 'Date Acquired', type: 'date' },
    { name: 'colour', label: 'Colour' },
    { name: 'vin_chassis', label: 'Chassis Number' },
    { name: 'engine_number', label: 'Engine Number' },
    { name: 'new_gen_plates', label: 'New Generation Plates', type: 'select', options: [{ value: '0', label: 'No' }, { value: '1', label: 'Yes' }] },
    { name: 'primary_image_url', label: 'Vehicle Photo', type: 'image' },
    { name: 'vehicle_type', label: 'Vehicle Type', type: 'select', options: [
      { value: 'car', label: 'Car' }, { value: 'van', label: 'Van' }, { value: 'truck', label: 'Truck' },
      { value: 'motorbike', label: 'Motorbike' }, { value: 'construction', label: 'Construction' },
      { value: 'trailer', label: 'Trailer' }, { value: 'small_engine', label: 'Small Engine' },
    ] },
    { name: 'fleet_type', label: 'Fleet Type' },
    { name: 'body_type', label: 'Body Type' },
    { name: 'department', label: 'Department' },
    { name: 'fuel_type', label: 'Fuel Type', type: 'select', options: [
      { value: 'diesel', label: 'Diesel' }, { value: 'petrol', label: 'Petrol' }, { value: 'hybrid', label: 'Hybrid' },
      { value: 'electric', label: 'Electric' }, { value: 'lpg', label: 'LPG' }, { value: 'other', label: 'Other' },
    ] },
    { name: 'engine_size', label: 'Engine Size' },
    { name: 'engine_capacity', label: 'Engine Capacity (cc)' },
    { name: 'transmission', label: 'Transmission', type: 'select', options: [
      { value: 'manual', label: 'Manual' }, { value: 'automatic', label: 'Automatic' }, { value: 'cvt', label: 'CVT' }, { value: 'other', label: 'Other' },
    ] },
    { name: 'drive_type', label: 'Drive Type', type: 'select', options: [{ value: '2WD', label: '2WD' }, { value: '4WD', label: '4WD' }, { value: 'AWD', label: 'AWD' }] },
    { name: 'seating_capacity', label: 'Seating Capacity', type: 'number' },
    { name: 'tyre_size_standard', label: 'Standard Tyre Size' },
    { name: 'tare_weight_kg', label: 'Tare Weight (kg)', type: 'number' },
    { name: 'payload_capacity_kg', label: 'Load Capacity (kg)', type: 'number' },
    { name: 'gross_weight_kg', label: 'Gross Weight (kg)', type: 'number' },
    { name: 'logbook_status', label: 'Logbook Status', type: 'select', options: [
      { value: 'available', label: 'Available' }, { value: 'missing', label: 'Missing' }, { value: 'with_bank', label: 'With Bank' }, { value: 'other', label: 'Other' },
    ] },
    { name: 'odometer_status', label: 'Odometer Status', type: 'select', options: [{ value: 'working', label: 'Working' }, { value: 'not_working', label: 'Not Working' }] },
    { name: 'inspection_status', label: 'Inspection Status', type: 'select', options: [{ value: 'valid', label: 'Valid' }, { value: 'invalid', label: 'Invalid' }] },
    { name: 'licence_expiry', label: 'Licence Expiry', type: 'date', hideOnAdd: true },
    { name: 'status', label: 'Status', type: 'select', options: [
      { value: 'active', label: 'Active' }, { value: 'in_workshop', label: 'In Workshop' },
      { value: 'awaiting_parts', label: 'Awaiting Parts' }, { value: 'decommissioned', label: 'Decommissioned' },
    ] },
    { name: 'next_service_date', label: 'Next Service Date', type: 'date' },
    { name: 'next_service_mileage', label: 'Next Service Mileage', type: 'number' },
    { name: 'notes', label: 'Notes', type: 'textarea' },
  ],
};

export default function FleetPage() {
  return (
    <AppShell title="Fleet">
      <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: 8 }}>
        <Link className="btn" href="/disposed-assets">Disposed / Deleted Vehicles</Link>
      </div>
      <ModulePage config={config} extraDetailActions={DisposeAction} />
    </AppShell>
  );
}

function DisposeAction({ record, onDone }) {
  const [busy, setBusy] = useState(false);
  async function dispose() {
    const reason = prompt('Reason for disposing this vehicle (optional):') || '';
    if (!confirm('Mark this vehicle as disposed? This will remove it from active fleet operations.')) return;
    setBusy(true);
    try {
      const res = await fetch(`/api/vehicles/${record.id}/dispose`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action_type: 'disposed', reason }),
      });
      const json = await res.json();
      if (!json.success) throw new Error(json.error);
      onDone();
    } catch (e) {
      alert(e.message);
    } finally {
      setBusy(false);
    }
  }
  return <button className="btn btn-small btn-warn" type="button" onClick={dispose} disabled={busy}>Dispose Asset</button>;
}
