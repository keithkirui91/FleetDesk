'use client';

import { useEffect, useMemo, useState } from 'react';
import AppShell from '@/components/AppShell';
import { Plus, X } from 'lucide-react';

const GROUPS = [
  { status: 'in_progress', label: 'In Progress' },
  { status: 'awaiting_parts', label: 'Awaiting Parts' },
  { status: 'closed', label: 'Closed' },
];

function clip(text, limit = 58) {
  const s = String(text || '');
  return s.length > limit ? `${s.slice(0, limit - 3)}...` : s;
}

export default function JobsPage() {
  const [jobs, setJobs] = useState([]);
  const [vehicles, setVehicles] = useState([]);
  const [mechanics, setMechanics] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [showAdd, setShowAdd] = useState(false);
  const [addForm, setAddForm] = useState({ job_type: 'repair', priority: 'normal', part_availability: 'available' });
  const [addError, setAddError] = useState('');
  const [saving, setSaving] = useState(false);

  const [activeJob, setActiveJob] = useState(null);
  const [statusForm, setStatusForm] = useState({ status: 'in_progress', new_note: '' });

  async function load() {
    setLoading(true);
    const [jobsRes, vRes, mRes] = await Promise.all([
      fetch('/api/jobs').then((r) => r.json()),
      fetch('/api/vehicles').then((r) => r.json()),
      fetch('/api/mechanics').then((r) => r.json()),
    ]);
    setJobs(jobsRes.data || []);
    setVehicles(vRes.data || []);
    setMechanics(mRes.data || []);
    setLoading(false);
  }

  useEffect(() => { load(); }, []);

  const filteredJobs = useMemo(() => {
    if (!search.trim()) return jobs;
    const q = search.toLowerCase();
    return jobs.filter((j) => Object.values(j).some((v) => v !== null && String(v).toLowerCase().includes(q)));
  }, [jobs, search]);

  async function submitAdd(e) {
    e.preventDefault();
    setSaving(true);
    setAddError('');
    try {
      const res = await fetch('/api/jobs', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(addForm),
      });
      const json = await res.json();
      if (!json.success) throw new Error(json.error);
      setShowAdd(false);
      setAddForm({ job_type: 'repair', priority: 'normal', part_availability: 'available' });
      await load();
    } catch (e) {
      setAddError(e.message);
    } finally {
      setSaving(false);
    }
  }

  function openJob(job) {
    setActiveJob(job);
    setStatusForm({ status: job.status, new_note: '' });
  }

  async function submitStatus(e) {
    e.preventDefault();
    setSaving(true);
    try {
      const res = await fetch(`/api/jobs/${activeJob.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: statusForm.status, new_note: statusForm.new_note.trim() }),
      });
      const json = await res.json();
      if (!json.success) throw new Error(json.error);
      setActiveJob(null);
      await load();
    } catch (e) {
      alert(e.message);
    } finally {
      setSaving(false);
    }
  }

  async function deleteJob() {
    if (!activeJob || !confirm('Delete this job card? This cannot be undone.')) return;
    setSaving(true);
    try {
      const res = await fetch(`/api/jobs/${activeJob.id}`, { method: 'DELETE' });
      const json = await res.json();
      if (!json.success) throw new Error(json.error);
      setActiveJob(null);
      await load();
    } catch (e) {
      alert(e.message);
    } finally {
      setSaving(false);
    }
  }

  return (
    <AppShell title="Job Cards">
      <div className="toolbar">
        <div>
          <h2 className="section-title">Long Running Jobs</h2>
          <div className="subtle">Grouped by progress, parts availability, and completed work.</div>
        </div>
        <div className="toolbar-left">
          <input className="input" placeholder="Search job cards" value={search} onChange={(e) => setSearch(e.target.value)} />
          <button className="btn btn-primary" type="button" onClick={() => setShowAdd(true)}><Plus className="icon" /> Add Job Card</button>
        </div>
      </div>

      <div className="job-groups">
        {GROUPS.map(({ status, label }) => {
          const groupJobs = filteredJobs.filter((j) => j.status === status || (status === 'in_progress' && j.status === 'open'));
          return (
            <section className="panel job-group" key={status}>
              <div className="panel-title-row">
                <h2>{label}</h2>
                <span>{groupJobs.length} jobs</span>
              </div>
              <div className="table-wrap compact-table">
                <table>
                  <thead><tr><th>Ref</th><th>Vehicle</th><th>Fault</th><th>Days</th><th>Priority</th><th>Status</th><th></th></tr></thead>
                  <tbody>
                    {loading && <tr><td className="empty" colSpan={7}>Loading…</td></tr>}
                    {!loading && groupJobs.length === 0 && <tr><td className="empty" colSpan={7}>No {label.toLowerCase()} jobs.</td></tr>}
                    {groupJobs.map((job) => (
                      <tr key={job.id}>
                        <td>{job.job_reference}</td>
                        <td>{job.registration} <span className="muted">{job.fleet_number}</span></td>
                        <td>{clip(job.fault_description)} {job.is_overdue ? <span className="badge overdue">Overdue</span> : null}</td>
                        <td>{job.days_open}</td>
                        <td><span className={`badge ${job.priority}`}>{job.priority}</span></td>
                        <td><span className={`badge ${job.status}`}>{String(job.status).replace(/_/g, ' ')}</span></td>
                        <td><button className="btn btn-small" type="button" onClick={() => openJob(job)}>View</button></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </section>
          );
        })}
      </div>

      {showAdd && (
        <div className="modal-backdrop open">
          <div className="modal">
            <header>
              <h2>Add Job Card</h2>
              <button className="btn btn-small" type="button" onClick={() => setShowAdd(false)}><X size={14} /></button>
            </header>
            <form onSubmit={submitAdd}>
              <div className="form-grid">
                <div className="form-row">
                  <label>Vehicle</label>
                  <select className="select" required value={addForm.vehicle_id || ''} onChange={(e) => setAddForm((f) => ({ ...f, vehicle_id: e.target.value }))}>
                    <option value="">Select...</option>
                    {vehicles.map((v) => <option key={v.id} value={v.id}>{v.fleet_number} — {v.registration}</option>)}
                  </select>
                </div>
                <div className="form-row">
                  <label>Mechanic</label>
                  <select className="select" value={addForm.mechanic_id || ''} onChange={(e) => setAddForm((f) => ({ ...f, mechanic_id: e.target.value }))}>
                    <option value="">Unassigned</option>
                    {mechanics.map((m) => <option key={m.id} value={m.id}>{m.full_name}</option>)}
                  </select>
                </div>
                <div className="form-row">
                  <label>Job type</label>
                  <select className="select" required value={addForm.job_type} onChange={(e) => setAddForm((f) => ({ ...f, job_type: e.target.value }))}>
                    <option value="repair">Repair</option><option value="service">Service</option><option value="inspection">Inspection</option><option value="accident">Accident</option><option value="other">Other</option>
                  </select>
                </div>
                <div className="form-row">
                  <label>Priority</label>
                  <select className="select" required value={addForm.priority} onChange={(e) => setAddForm((f) => ({ ...f, priority: e.target.value }))}>
                    <option value="normal">Normal</option><option value="low">Low</option><option value="high">High</option><option value="critical">Critical</option>
                  </select>
                </div>
                <div className="form-row">
                  <label>Part availability</label>
                  <select className="select" required value={addForm.part_availability} onChange={(e) => setAddForm((f) => ({ ...f, part_availability: e.target.value }))}>
                    <option value="available">Available</option>
                    <option value="not_available">Not available</option>
                  </select>
                </div>
                <div className="form-row">
                  <label>Date in</label>
                  <input className="input" type="date" required value={addForm.date_in || ''} onChange={(e) => setAddForm((f) => ({ ...f, date_in: e.target.value }))} />
                </div>
                <div className="form-row">
                  <label>Target completion</label>
                  <input className="input" type="date" required value={addForm.target_completion_date || ''} onChange={(e) => setAddForm((f) => ({ ...f, target_completion_date: e.target.value }))} />
                </div>
                <div className="form-row full">
                  <label>Fault description</label>
                  <textarea required value={addForm.fault_description || ''} onChange={(e) => setAddForm((f) => ({ ...f, fault_description: e.target.value }))} />
                </div>
              </div>
              {addError && <div className="alert alert-danger" style={{ margin: '0 13px 13px' }}>{addError}</div>}
              <footer>
                <button className="btn" type="button" onClick={() => setShowAdd(false)}>Cancel</button>
                <button className="btn btn-primary" type="submit" disabled={saving}>{saving ? 'Saving…' : 'Save Job Card'}</button>
              </footer>
            </form>
          </div>
        </div>
      )}

      {activeJob && (
        <div className="modal-backdrop open">
          <div className="modal" style={{ maxWidth: 900, width: '95vw' }}>
            <header>
              <h2>Job Details</h2>
              <button className="btn btn-small" type="button" onClick={() => setActiveJob(null)}>Close</button>
            </header>

            <div className="detail-grid">
              {Object.entries(activeJob).filter(([k]) => !['id', 'resolution_notes'].includes(k)).map(([k, v]) => (
                <div className="detail-item" key={k}>
                  <span>{k.replace(/_/g, ' ')}</span>
                  <strong>{v ?? ''}</strong>
                </div>
              ))}
            </div>

            <hr style={{ margin: '20px 0', border: 'none', borderTop: '1px solid #e5e7eb' }} />

            <form className="job-status-form" onSubmit={submitStatus}>
              <div className="form-row">
                <label>Update Status</label>
                <select className="select" required value={statusForm.status} onChange={(e) => setStatusForm((f) => ({ ...f, status: e.target.value }))}>
                  <option value="in_progress">In Progress</option>
                  <option value="awaiting_parts">Awaiting Parts</option>
                  <option value="closed">Closed</option>
                </select>
              </div>

              <div className="form-row full" style={{ marginTop: 20 }}>
                <label>Resolution Notes</label>
                <textarea
                  className="input"
                  rows={10}
                  readOnly
                  value={activeJob.resolution_notes || ''}
                  style={{ background: '#f8fafc', color: '#475569', fontFamily: 'monospace', resize: 'vertical', whiteSpace: 'pre-wrap' }}
                />
                <small className="subtle">Workshop history and previous updates.</small>
              </div>

              <div className="form-row full" style={{ marginTop: 20 }}>
                <label>Add Update</label>
                <textarea
                  className="input"
                  rows={4}
                  placeholder="Parts ordered, supplier contacted, repairs completed..."
                  value={statusForm.new_note}
                  onChange={(e) => setStatusForm((f) => ({ ...f, new_note: e.target.value }))}
                />
              </div>

              <footer style={{ marginTop: 20 }}>
                <button className="btn btn-danger" type="button" onClick={deleteJob}>Delete Job</button>
                <button className="btn btn-primary" type="submit" disabled={saving}>{saving ? 'Saving…' : 'Save Update'}</button>
              </footer>
            </form>
          </div>
        </div>
      )}
    </AppShell>
  );
}
