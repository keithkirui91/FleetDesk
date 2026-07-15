'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

export default function GateMileagePage() {
  const router = useRouter();
  const [vehicles, setVehicles] = useState([]);
  const [primaryDrivers, setPrimaryDrivers] = useState({});
  const [driverNames, setDriverNames] = useState([]);
  const [form, setForm] = useState({ vehicle_id: '', driver_name: '', location: 'gate_in', odometer_reading: '', notes: '' });
  const [toast, setToast] = useState('');
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    fetch('/api/vehicles').then((r) => r.json()).then((res) => {
      setVehicles((res.data || []).filter((v) => v.status === 'active'));
    }).catch(() => {});
    fetch('/api/driver-allocations/primary-map').then((r) => r.json()).then((res) => {
      setPrimaryDrivers(res.data || {});
    }).catch(() => {});
    fetch('/api/odometer/driver-names').then((r) => r.json()).then((res) => {
      setDriverNames(res.data || []);
    }).catch(() => {});
  }, []);

  function handleVehicleChange(vehicleId) {
    setForm((f) => ({
      ...f,
      vehicle_id: vehicleId,
      // Prefill the assigned primary driver, but stays fully editable.
      driver_name: primaryDrivers[vehicleId] || '',
    }));
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setSaving(true);
    setToast('');
    try {
      const res = await fetch('/api/odometer', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      });
      const json = await res.json();
      if (!json.success) {
        setToast(json.error || 'Save failed.');
        return;
      }
      setToast('Mileage saved.');
      setForm({ vehicle_id: '', driver_name: '', location: 'gate_in', odometer_reading: '', notes: '' });
    } catch {
      setToast('Something went wrong.');
    } finally {
      setSaving(false);
    }
  }

  async function handleLogout() {
    await fetch('/api/auth/logout', { method: 'POST' });
    router.push('/login');
  }

  return (
    <div className="login-page gate-page">
      <main className="login-card gate-card">
        <h1>Gate Mileage Log</h1>
        <p>Record vehicles coming into or leaving the compound.</p>
        {toast && <div className={`alert ${toast === 'Mileage saved.' ? 'alert-ok' : 'alert-danger'}`}>{toast}</div>}
        <form onSubmit={handleSubmit}>
          <div className="form-row-pair">
            <div className="form-row">
              <label htmlFor="vehicle_id">Vehicle</label>
              <select className="select" id="vehicle_id" required value={form.vehicle_id} onChange={(e) => handleVehicleChange(e.target.value)}>
                <option value="">Select vehicle...</option>
                {vehicles.map((v) => (
                  <option key={v.id} value={v.id}>{v.fleet_number} - {v.registration} ({v.make} {v.model})</option>
                ))}
              </select>
              <div className="vehicle-status-note">Only active vehicles can be logged.</div>
            </div>
            <div className="form-row">
              <label htmlFor="driver_name">Driver</label>
              <input
                className="input"
                id="driver_name"
                list="driver-name-options"
                placeholder="Driver name"
                autoComplete="off"
                value={form.driver_name}
                onChange={(e) => setForm((f) => ({ ...f, driver_name: e.target.value }))}
              />
              <datalist id="driver-name-options">
                {driverNames.map((name) => <option key={name} value={name} />)}
              </datalist>
              <div className="vehicle-status-note">Defaults to the assigned driver — editable if someone else is driving.</div>
            </div>
          </div>
          <div className="form-row">
            <label htmlFor="location">Movement</label>
            <select className="select" id="location" required value={form.location} onChange={(e) => setForm((f) => ({ ...f, location: e.target.value }))}>
              <option value="gate_in">Gate in</option>
              <option value="gate_out">Gate out</option>
            </select>
          </div>
          <div className="form-row">
            <label htmlFor="odometer_reading">Current mileage</label>
            <input className="input" id="odometer_reading" type="number" min="0" required value={form.odometer_reading} onChange={(e) => setForm((f) => ({ ...f, odometer_reading: e.target.value }))} />
          </div>
          <div className="form-row">
            <label htmlFor="notes">Notes</label>
            <textarea id="notes" placeholder="Optional gate note" value={form.notes} onChange={(e) => setForm((f) => ({ ...f, notes: e.target.value }))} />
          </div>
          <button className="btn btn-primary" type="submit" disabled={saving}>{saving ? 'Saving…' : 'Save mileage'}</button>
          <a className="btn" onClick={handleLogout} style={{ cursor: 'pointer' }}>Logout</a>
        </form>
      </main>
    </div>
  );
}
