'use client';

import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import ModulePage from '@/components/ModulePage';
import { Plus, X } from 'lucide-react';

const LOCATION_OPTIONS = [
  { value: 'gate_in', label: 'Gate in' }, { value: 'gate_out', label: 'Gate out' }, { value: 'workshop', label: 'Workshop' },
  { value: 'service', label: 'Service' }, { value: 'fuel', label: 'Fuel' }, { value: 'other', label: 'Other' },
];

export default function MileagePage() {
  const [vehicles, setVehicles] = useState(null);
  const [primaryDrivers, setPrimaryDrivers] = useState({});
  const [driverNames, setDriverNames] = useState([]);
  const [refreshKey, setRefreshKey] = useState(0);

  const [showAdd, setShowAdd] = useState(false);
  const [form, setForm] = useState({ vehicle_id: '', driver_name: '', location: 'gate_in', odometer_reading: '', notes: '' });
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState('');

  useEffect(() => {
    fetch('/api/vehicles').then((r) => r.json()).then((res) => {
      setVehicles((res.data || []).filter((v) => v.status === 'active').map((v) => ({ id: v.id, label: `${v.fleet_number} — ${v.registration}` })));
    });
    fetch('/api/driver-allocations/primary-map').then((r) => r.json()).then((res) => setPrimaryDrivers(res.data || {}));
    fetch('/api/odometer/driver-names').then((r) => r.json()).then((res) => setDriverNames(res.data || []));
  }, [refreshKey]);

  function handleVehicleChange(vehicleId) {
    setForm((f) => ({ ...f, vehicle_id: vehicleId, driver_name: primaryDrivers[vehicleId] || '' }));
  }

  const selectedVehicle = vehicles?.find((v) => String(v.id) === String(form.vehicle_id));
  const selectedVehicleStatus = selectedVehicle?.status || (selectedVehicle ? 'active' : '');

  async function submitAdd(e) {
    e.preventDefault();
    setSaving(true);
    setSaveError('');
    try {
      const res = await fetch('/api/odometer', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      });
      const json = await res.json();
      if (!json.success) throw new Error(json.error || 'Save failed.');
      setShowAdd(false);
      setForm({ vehicle_id: '', driver_name: '', location: 'gate_in', odometer_reading: '', notes: '' });
      setRefreshKey((k) => k + 1);
    } catch (e) {
      setSaveError(e.message);
    } finally {
      setSaving(false);
    }
  }

  if (!vehicles) {
    return <AppShell title="Mileage"><div className="empty">Loading…</div></AppShell>;
  }

  const config = {
    title: 'Mileage',
    singular: 'Mileage Log',
    description: 'Odometer history for gate, workshop, service, and fuel readings.',
    endpoint: '/api/odometer',
    pageSize: 30,
    hideAdd: true,
    columns: [
      { key: 'logged_at', label: 'Logged At' },
      { key: 'fleet_number', label: 'Fleet No.' },
      { key: 'registration', label: 'Registration' },
      { key: 'driver_name', label: 'Driver' },
      { key: 'odometer_reading', label: 'Odometer' },
      { key: 'location', label: 'Location', badge: true },
      { key: 'notes', label: 'Notes' },
    ],
    fields: [
      { name: 'driver_name', label: 'Driver' },
      { name: 'odometer_reading', label: 'Odometer', type: 'number', required: true },
      { name: 'location', label: 'Location', type: 'select', options: LOCATION_OPTIONS },
      { name: 'notes', label: 'Notes', type: 'textarea' },
    ],
  };

  return (
    <AppShell title="Mileage">
      <ModulePage
        key={refreshKey}
        config={config}
        extraToolbarActions={() => (
          <button className="btn btn-primary" type="button" onClick={() => setShowAdd(true)}>
            <Plus className="icon" /> Add Mileage Log
          </button>
        )}
      />

      {showAdd && (
        <div className="modal-backdrop open">
          <div className="modal">
            <header>
              <h2>Add Mileage Log</h2>
              <button className="btn btn-small" type="button" onClick={() => setShowAdd(false)}><X size={14} /></button>
            </header>
            <form onSubmit={submitAdd}>
              <div className="form-grid">
                <div className="form-row">
                  <label>Vehicle</label>
                  <select className="select" required value={form.vehicle_id} onChange={(e) => handleVehicleChange(e.target.value)}>
                    <option value="">Select...</option>
                    {vehicles.map((v) => <option key={v.id} value={v.id}>{v.label}</option>)}
                  </select>
                  <div className={`vehicle-status-note ${selectedVehicleStatus}`}>
                    {selectedVehicle ? `Status: ${selectedVehicleStatus.replace(/_/g, ' ')}` : 'Select a vehicle to see status.'}
                  </div>
                </div>
                <div className="form-row">
                  <label>Driver</label>
                  <input
                    className="input"
                    list="driver-name-options-admin"
                    placeholder="Driver name"
                    autoComplete="off"
                    value={form.driver_name}
                    onChange={(e) => setForm((f) => ({ ...f, driver_name: e.target.value }))}
                  />
                  <datalist id="driver-name-options-admin">
                    {driverNames.map((name) => <option key={name} value={name} />)}
                  </datalist>
                </div>
                <div className="form-row">
                  <label>Odometer</label>
                  <input className="input" type="number" required value={form.odometer_reading} onChange={(e) => setForm((f) => ({ ...f, odometer_reading: e.target.value }))} />
                </div>
                <div className="form-row">
                  <label>Location</label>
                  <select className="select" required value={form.location} onChange={(e) => setForm((f) => ({ ...f, location: e.target.value }))}>
                    {LOCATION_OPTIONS.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
                  </select>
                </div>
                <div className="form-row full">
                  <label>Notes</label>
                  <textarea value={form.notes} onChange={(e) => setForm((f) => ({ ...f, notes: e.target.value }))} />
                </div>
              </div>
              {saveError && <div className="alert alert-danger" style={{ margin: '0 13px 13px' }}>{saveError}</div>}
              <footer>
                <button className="btn" type="button" onClick={() => setShowAdd(false)}>Cancel</button>
                <button className="btn btn-primary" type="submit" disabled={saving}>{saving ? 'Saving…' : 'Save Mileage Log'}</button>
              </footer>
            </form>
          </div>
        </div>
      )}
    </AppShell>
  );
}
