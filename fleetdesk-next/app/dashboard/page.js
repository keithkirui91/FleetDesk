'use client';

import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';
import { Truck, Wrench, Clock, PackageSearch } from 'lucide-react';

export default function DashboardPage() {
  const [data, setData] = useState(null);

  useEffect(() => {
    fetch('/api/dashboard').then((r) => r.json()).then((res) => setData(res.data));
  }, []);

  if (!data) {
    return <AppShell title="Dashboard"><div className="empty">Loading…</div></AppShell>;
  }

  const { kpis, fleetStatus, downtimeByDept, jobsTimeline, fuelMonthly, depotBalances, longestJobs, upcomingServices, expiringDocs } = data;
  const maxDowntime = Math.max(1, ...downtimeByDept.map((d) => Number(d.downtime_days)));
  const maxTimeline = Math.max(1, ...jobsTimeline.flatMap((m) => [Number(m.opened), Number(m.closed)]));
  const maxFuel = Math.max(1, ...fuelMonthly.map((m) => Number(m.total_litres)));

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

      <div className="dashboard-layout">
        <div className="panel">
          <div className="panel-title-row"><h2>Fleet Status</h2></div>
          <div className="mini-card-list">
            {fleetStatus.map((row) => (
              <div className={`mini-card status-card ${row.status}`} key={row.status}>
                <span>{String(row.status).replace(/_/g, ' ')}</span>
                <strong>{row.total}</strong>
              </div>
            ))}
          </div>
        </div>

        <div className="panel">
          <div className="panel-title-row"><h2>Downtime by Department</h2></div>
          <div className="bar-list">
            {downtimeByDept.length === 0 && <div className="subtle">No open jobs right now.</div>}
            {downtimeByDept.map((row) => (
              <div className="bar-row" key={row.department}>
                <span>{row.department}</span>
                <div><i style={{ width: `${(Number(row.downtime_days) / maxDowntime) * 100}%` }} /></div>
                <strong>{row.downtime_days}d</strong>
              </div>
            ))}
          </div>
        </div>

        <div className="panel wide">
          <div className="panel-title-row"><h2>Jobs Opened vs Closed (last 6 months)</h2></div>
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
          </div>
          <div className="chart-key">
            <span><i className="opened" style={{ background: 'var(--brand)' }} /> Opened</span>
            <span><i className="closed" style={{ background: '#16a34a' }} /> Closed</span>
          </div>
        </div>

        <div className="panel">
          <div className="panel-title-row"><h2>Fuel Drawn (litres, last 6 months)</h2></div>
          <div className="area-bars">
            {fuelMonthly.map((m) => (
              <div key={m.month_key} style={{ height: `${(Number(m.total_litres) / maxFuel) * 100}%` }} title={`${m.month_key}: ${m.total_litres}L`} />
            ))}
          </div>
        </div>

        <div className="panel">
          <div className="panel-title-row"><h2>Depot Balances</h2></div>
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
          <div className="panel-title-row"><h2>Longest Running Open Jobs</h2></div>
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
          <div className="panel-title-row"><h2>Upcoming Services</h2></div>
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
          <div className="panel-title-row"><h2>Insurance / Licence Expiring Soon</h2></div>
          <div className="table-wrap compact-table">
            <table>
              <thead><tr><th>Vehicle</th><th>Insurance</th><th>Licence</th></tr></thead>
              <tbody>
                {expiringDocs.map((row, i) => (
                  <tr key={i}>
                    <td>{row.fleet_number} <span className="muted">{row.registration}</span></td>
                    <td>{row.insurance_expiry || '—'}</td>
                    <td>{row.licence_expiry || '—'}</td>
                  </tr>
                ))}
                {expiringDocs.length === 0 && <tr><td className="empty" colSpan={3}>Nothing expiring soon.</td></tr>}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </AppShell>
  );
}
