'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import AppShell from '@/components/AppShell';
import { Truck, Wrench, Clock, PackageSearch, Fuel } from 'lucide-react';

const MONTH_OPTIONS = [3, 6, 12];

export default function DashboardPage() {
  const [data, setData] = useState(null);
  const [months, setMonths] = useState(6);
  const [department, setDepartment] = useState('');
  const [drilldown, setDrilldown] = useState(null);

  useEffect(() => {
    const params = new URLSearchParams({ months: String(months) });
    if (department) params.set('department', department);
    fetch(`/api/dashboard?${params.toString()}`).then((r) => r.json()).then((res) => setData(res.data));
  }, [months, department]);

  if (!data) {
    return <AppShell title="Dashboard"><div className="empty">Loading…</div></AppShell>;
  }

  const { kpis, filters, fleetStatus, downtimeByDept, jobsTimeline, fuelMonthly, depotBalances, longestJobs, upcomingServices, expiringDocs, fleetStatusVehicles, downtimeVehicles } = data;
  const maxDowntime = Math.max(1, ...downtimeByDept.map((d) => Number(d.downtime_days)));
  const maxTimeline = Math.max(1, ...jobsTimeline.flatMap((m) => [Number(m.opened), Number(m.closed)]));
  const maxFuel = Math.max(1, ...fuelMonthly.map((m) => Number(m.total_litres)));
  const statusColours = ['#16a34a', '#f59e0b', '#7c3aed', '#94a3b8'];
  let cursor = 0;
  const donutStops = fleetStatus.map((row, i) => {
    const start = cursor;
    cursor += kpis.totalFleet ? (Number(row.total) / Number(kpis.totalFleet)) * 100 : 0;
    return `${statusColours[i % statusColours.length]} ${start}% ${cursor}%`;
  }).join(', ');
  const drilldownRows = drilldown?.type === 'status'
    ? (fleetStatusVehicles || []).filter((v) => v.status === drilldown.value)
    : drilldown?.type === 'department'
      ? (downtimeVehicles || []).filter((v) => (v.department || 'Unassigned') === drilldown.value)
      : [];

  return (
    <AppShell title="Dashboard">
      <div className="dash-grid">
        <div className="metric-card">
          <div className="metric-icon blue"><Truck className="icon" /></div>
          <div className="metric-copy">
            <strong>{kpis.totalFleet}</strong>
            <span>Total fleet</span>
            <small>{kpis.activeFleet} active</small>
          </div>
        </div>
        <div className="metric-card">
          <div className="metric-icon amber"><Wrench className="icon" /></div>
          <div className="metric-copy">
            <strong>{kpis.inWorkshop}</strong>
            <span>In workshop</span>
          </div>
        </div>
        <div className="metric-card">
          <div className="metric-icon violet"><PackageSearch className="icon" /></div>
          <div className="metric-copy">
            <strong>{kpis.awaitingParts}</strong>
            <span>Awaiting parts</span>
          </div>
        </div>
        <div className="metric-card">
          <div className="metric-icon rose"><Clock className="icon" /></div>
          <div className="metric-copy">
            <strong>{kpis.openJobs}</strong>
            <span>Open jobs</span>
            <small>{kpis.activeDowntimeDays} downtime days</small>
          </div>
        </div>
      </div>

      <div className="dash-filters">
        <div>
          <label>Time range</label>
          <select className="select dashboard-select" value={months} onChange={(e) => setMonths(Number(e.target.value))}>
            {MONTH_OPTIONS.map((m) => <option key={m} value={m}>Last {m} months</option>)}
          </select>
        </div>
        <div>
          <label>Department</label>
          <select className="select dashboard-select" value={department} onChange={(e) => setDepartment(e.target.value)}>
            <option value="">All departments</option>
            {(filters?.departments || []).map((d) => <option key={d} value={d}>{d}</option>)}
          </select>
        </div>
      </div>

      <div className="dashboard-layout">
        <div className="panel">
          <div className="panel-title-row"><h2>Fleet Status</h2><Link className="view-all-link" href="/fleet">View all</Link></div>
          <div className="fleet-status-chart">
            <button
              className="fleet-donut"
              type="button"
              style={{ background: `radial-gradient(circle, #fff 0 54%, transparent 55%), conic-gradient(${donutStops || '#e2e8f0 0 100%'})` }}
              onClick={() => setDrilldown(null)}
              title="Clear drilldown"
            >
              <strong>{kpis.totalFleet}</strong>
              <span>fleet</span>
            </button>
            <div className="legend">
              {fleetStatus.map((row, i) => (
                <button
                  className="legend-row"
                  type="button"
                  key={row.status}
                  onClick={() => setDrilldown({ type: 'status', value: row.status, label: String(row.status).replace(/_/g, ' ') })}
                >
                  <i className="dot" style={{ background: statusColours[i % statusColours.length] }} />
                  <span>{String(row.status).replace(/_/g, ' ')}</span>
                  <strong>{row.total}</strong>
                </button>
              ))}
            </div>
          </div>
        </div>

        <div className="panel">
          <div className="panel-title-row"><h2>Downtime by Department</h2></div>
          <div className="bar-list">
            {downtimeByDept.length === 0 && <div className="subtle">No open jobs right now.</div>}
            {downtimeByDept.map((row) => (
              <button className="bar-row bar-row-button" type="button" key={row.department} onClick={() => setDrilldown({ type: 'department', value: row.department, label: row.department })}>
                <span>{row.department}</span>
                <div><i style={{ width: `${(Number(row.downtime_days) / maxDowntime) * 100}%` }} /></div>
                <strong>{row.downtime_days}d</strong>
              </button>
            ))}
          </div>
        </div>

        {drilldown && (
          <div className="panel wide">
            <div className="panel-title-row">
              <h2>{drilldown.label} Vehicles</h2>
              <button className="view-all-link" type="button" onClick={() => setDrilldown(null)}>Clear</button>
            </div>
            <div className="table-wrap compact-table">
              <table>
                <thead><tr><th>Fleet</th><th>Registration</th><th>Vehicle</th><th>Department</th><th>Status</th><th>Downtime</th></tr></thead>
                <tbody>
                  {drilldownRows.map((row) => (
                    <tr key={row.id}>
                      <td>{row.fleet_number}</td>
                      <td>{row.registration}</td>
                      <td>{row.make} {row.model}</td>
                      <td>{row.department || 'Unassigned'}</td>
                      <td><span className={`badge ${row.status}`}>{String(row.status).replace(/_/g, ' ')}</span></td>
                      <td>{row.downtime_days ? `${row.downtime_days}d` : '—'}</td>
                    </tr>
                  ))}
                  {drilldownRows.length === 0 && <tr><td className="empty" colSpan={6}>No vehicles to show.</td></tr>}
                </tbody>
              </table>
            </div>
          </div>
        )}

        <div className="panel wide">
          <div className="panel-title-row"><h2>Jobs Opened vs Closed (last {months} months)</h2><Link className="view-all-link" href="/jobs">View all</Link></div>
          <div className="column-chart">
            {jobsTimeline.map((m) => (
              <div className="month-col" key={m.month_key}>
                <div className="pair-bars">
                  <i className="opened" style={{ height: `${(Number(m.opened) / maxTimeline) * 100}%` }} title={`Opened: ${m.opened}`} />
                  <i className="closed" style={{ height: `${(Number(m.closed) / maxTimeline) * 100}%` }} title={`Closed: ${m.closed}`} />
                </div>
                <small>{m.month_key}</small>
              </div>
            ))}
            {jobsTimeline.length === 0 && <div className="subtle">No job activity in this range.</div>}
          </div>
          <div className="chart-key">
            <span><i className="opened" style={{ background: 'var(--brand)' }} /> Opened</span>
            <span><i className="closed" style={{ background: '#16a34a' }} /> Closed</span>
          </div>
        </div>

        <div className="panel">
          <div className="panel-title-row"><h2>Fuel Drawn (litres, last {months} months)</h2><Link className="view-all-link" href="/fuel">View all</Link></div>
          <div className="area-bars">
            {fuelMonthly.map((m) => (
              <div key={m.month_key} style={{ height: `${(Number(m.total_litres) / maxFuel) * 100}%` }} title={`${m.month_key}: ${m.total_litres}L`} />
            ))}
            {fuelMonthly.length === 0 && <div className="subtle">No fuel logs in this range.</div>}
          </div>
        </div>

        <div className="panel">
          <div className="panel-title-row">
            <h2>Depot Balances</h2>
            <div className="panel-actions">
              <Link className="btn btn-primary btn-small" href="/fuel"><Fuel className="icon" /> Add Fuel Log</Link>
              <Link className="view-all-link" href="/dip-readings">View all</Link>
            </div>
          </div>
          <div className="table-wrap compact-table">
            <table>
              <thead><tr><th>Fuel Type</th><th>Balance (L)</th><th>As of</th></tr></thead>
              <tbody>
                {depotBalances.map((row) => (
                  <tr key={row.fuel_type}><td>{row.fuel_type}</td><td>{row.dip_litres}</td><td>{row.reading_date}</td></tr>
                ))}
                {depotBalances.length === 0 && <tr><td className="empty" colSpan={3}>No dip readings yet.</td></tr>}
              </tbody>
            </table>
          </div>
        </div>

        <div className="panel wide">
          <div className="panel-title-row"><h2>Longest Running Open Jobs</h2><Link className="view-all-link" href="/jobs">View all</Link></div>
          <div className="table-wrap compact-table">
            <table>
              <thead><tr><th>Vehicle</th><th>Fault</th><th>Status</th><th>Days Open</th></tr></thead>
              <tbody>
                {longestJobs.map((row, i) => (
                  <tr key={i}>
                    <td>{row.fleet_number} <span className="muted">{row.registration}</span></td>
                    <td>{row.fault_description}</td>
                    <td><span className={`badge ${row.status}`}>{String(row.status).replace(/_/g, ' ')}</span></td>
                    <td>{row.days_open}</td>
                  </tr>
                ))}
                {longestJobs.length === 0 && <tr><td className="empty" colSpan={4}>No open jobs.</td></tr>}
              </tbody>
            </table>
          </div>
        </div>

        <div className="panel">
          <div className="panel-title-row"><h2>Upcoming Services</h2><Link className="view-all-link" href="/services">View all</Link></div>
          <div className="table-wrap compact-table">
            <table>
              <thead><tr><th>Vehicle</th><th>Next Service</th></tr></thead>
              <tbody>
                {upcomingServices.map((row) => (
                  <tr key={row.id}><td>{row.fleet_number} <span className="muted">{row.registration}</span></td><td>{row.next_service_date || '—'}</td></tr>
                ))}
                {upcomingServices.length === 0 && <tr><td className="empty" colSpan={2}>Nothing due soon.</td></tr>}
              </tbody>
            </table>
          </div>
        </div>

        <div className="panel">
          <div className="panel-title-row"><h2>Licence Expiring Soon</h2><Link className="view-all-link" href="/fleet">View all</Link></div>
          <div className="table-wrap compact-table">
            <table>
              <thead><tr><th>Vehicle</th><th>Licence</th></tr></thead>
              <tbody>
                {expiringDocs.map((row, i) => (
                  <tr key={i}>
                    <td>{row.fleet_number} <span className="muted">{row.registration}</span></td>
                    <td>{row.licence_expiry || '—'}</td>
                  </tr>
                ))}
                {expiringDocs.length === 0 && <tr><td className="empty" colSpan={2}>Nothing expiring soon.</td></tr>}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </AppShell>
  );
}
