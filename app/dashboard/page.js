'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import AppShell from '@/components/AppShell';
import { Truck, Wrench, Clock, PackageSearch, Fuel } from 'lucide-react';

export default function DashboardPage() {
  const [data, setData] = useState(null);
  const [drilldown, setDrilldown] = useState(null);
  const [fuelDrilldown, setFuelDrilldown] = useState(null);
  const [mileageVehicle, setMileageVehicle] = useState('');
  const [mileageDepartment, setMileageDepartment] = useState('');

  useEffect(() => {
    const params = new URLSearchParams({ months: '12' });
    if (mileageVehicle) params.set('mileageVehicle', mileageVehicle);
    if (mileageDepartment) params.set('mileageDepartment', mileageDepartment);
    fetch(`/api/dashboard?${params.toString()}`).then((r) => r.json()).then((res) => setData(res.data));
  }, [mileageVehicle, mileageDepartment]);

  if (!data) {
    return <AppShell title="Dashboard"><div className="empty">Loading...</div></AppShell>;
  }

  const {
    kpis, filters, fleetStatus, downtimeByDept, jobsTimeline, fuelMonthly, fuelRows, mileageWeekly,
    depotBalances, longestJobs, upcomingServices, upcomingTyres, upcomingBatteries,
    expiringDocs, fleetStatusVehicles, downtimeVehicles,
  } = data;
  const maxDowntime = Math.max(1, ...downtimeByDept.map((d) => Number(d.downtime_days)));
  const maxTimeline = Math.max(1, ...jobsTimeline.flatMap((m) => [Number(m.opened), Number(m.closed)]));
  const maxFuel = Math.max(1, ...fuelMonthly.map((m) => Number(m.total_litres)));
  const maxMileage = Math.max(1, ...mileageWeekly.map((m) => Number(m.kilometres)));
  const maxDepot = Math.max(1, ...depotBalances.map((d) => Number(d.dip_litres)));
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
  const fuelRowsForMonth = fuelDrilldown
    ? (fuelRows || []).filter((row) => String(row.log_date || '').startsWith(fuelDrilldown))
    : [];

  return (
    <AppShell title="Dashboard">
      <div className="dash-grid">
        <div className="metric-card">
          <div className="metric-icon blue"><Truck className="icon" /></div>
          <div className="metric-copy"><strong>{kpis.totalFleet}</strong><span>Total fleet</span><small>{kpis.activeFleet} active</small></div>
        </div>
        <div className="metric-card">
          <div className="metric-icon amber"><Wrench className="icon" /></div>
          <div className="metric-copy"><strong>{kpis.inWorkshop}</strong><span>In workshop</span><small>From open jobs</small></div>
        </div>
        <div className="metric-card">
          <div className="metric-icon rose"><Clock className="icon" /></div>
          <div className="metric-copy"><strong>{kpis.activeDowntimeDays}</strong><span>Downtime days</span><small>{kpis.openJobs} open jobs</small></div>
        </div>
        <div className="metric-card">
          <div className="metric-icon violet"><PackageSearch className="icon" /></div>
          <div className="metric-copy"><strong>{kpis.awaitingParts}</strong><span>Awaiting parts</span><small>Job card driven</small></div>
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
                <button className="legend-row" type="button" key={row.status} onClick={() => setDrilldown({ type: 'status', value: row.status, label: String(row.status).replace(/_/g, ' ') })}>
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
            <VehicleTable rows={drilldownRows} />
          </div>
        )}

        <div className="panel wide">
          <div className="panel-title-row"><h2>Jobs Opened vs Closed</h2><Link className="view-all-link" href="/jobs">View all</Link></div>
          <div className="column-chart job-chart">
            {jobsTimeline.map((m) => (
              <div className="month-col" key={m.month_key}>
                <div className="pair-bars">
                  <i className="opened" style={{ height: `${Math.max(6, (Number(m.opened) / maxTimeline) * 100)}%` }} title={`Opened: ${m.opened}`} />
                  <i className="closed" style={{ height: `${Math.max(6, (Number(m.closed) / maxTimeline) * 100)}%` }} title={`Closed: ${m.closed}`} />
                </div>
                <small>{m.month_key}</small>
              </div>
            ))}
          </div>
          <div className="chart-key"><span><i className="opened" /> Opened</span><span><i className="closed" /> Closed</span></div>
        </div>

        <div className="panel">
          <div className="panel-title-row"><h2>Fuel Drawn</h2><Link className="view-all-link" href="/fuel">View all</Link></div>
          <div className="area-bars fuel-click-bars">
            {fuelMonthly.map((m) => (
              <button key={m.month_key} type="button" style={{ height: `${Math.max(4, (Number(m.total_litres) / maxFuel) * 100)}%` }} title={`${m.month_key}: ${m.total_litres}L`} onClick={() => setFuelDrilldown(m.month_key)} />
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
          <div className="tank-grid">
            {depotBalances.map((row) => (
              <div className="tank-card" key={row.fuel_type}>
                <div className="tank-visual"><i style={{ height: `${Math.max(8, (Number(row.dip_litres) / maxDepot) * 100)}%` }} /></div>
                <div><strong>{Number(row.dip_litres).toLocaleString()}L</strong><span>{row.fuel_type}</span><small>{row.reading_date}</small></div>
              </div>
            ))}
            {depotBalances.length === 0 && <div className="subtle">No dip readings yet.</div>}
          </div>
        </div>

        {fuelDrilldown && (
          <div className="panel wide">
            <div className="panel-title-row"><h2>Fuel Logs - {fuelDrilldown}</h2><button className="view-all-link" type="button" onClick={() => setFuelDrilldown(null)}>Clear</button></div>
            <div className="table-wrap compact-table"><table><thead><tr><th>Date</th><th>Vehicle</th><th>Department</th><th>Litres</th><th>Cost</th></tr></thead><tbody>
              {fuelRowsForMonth.map((row) => <tr key={row.id}><td>{row.log_date}</td><td>{row.fleet_number} <span className="muted">{row.registration}</span></td><td>{row.department || 'Unassigned'}</td><td>{row.litres_filled}</td><td>{row.total_cost || '-'}</td></tr>)}
              {fuelRowsForMonth.length === 0 && <tr><td className="empty" colSpan={5}>No fuel logs for this month.</td></tr>}
            </tbody></table></div>
          </div>
        )}

        <div className="panel wide">
          <div className="panel-title-row">
            <h2>Weekly Mileage</h2>
            <div className="panel-actions">
              <select className="select dashboard-select" value={mileageVehicle} onChange={(e) => { setMileageVehicle(e.target.value); if (e.target.value) setMileageDepartment(''); }}>
                <option value="">All vehicles</option>
                {(filters?.mileageVehicles || []).map((v) => <option key={v.id} value={v.id}>{v.fleet_number} - {v.registration}</option>)}
              </select>
              <select className="select dashboard-select" value={mileageDepartment} onChange={(e) => { setMileageDepartment(e.target.value); if (e.target.value) setMileageVehicle(''); }}>
                <option value="">All departments</option>
                {(filters?.departments || []).map((d) => <option key={d} value={d}>{d}</option>)}
              </select>
            </div>
          </div>
          <div className="area-bars mileage-bars">
            {mileageWeekly.map((m) => <div key={m.week_key} style={{ height: `${Math.max(4, (Number(m.kilometres) / maxMileage) * 100)}%` }} title={`${m.week_label}: ${Number(m.kilometres).toLocaleString()} km`} />)}
            {mileageWeekly.length === 0 && <div className="subtle">No mileage logs in this range.</div>}
          </div>
        </div>

        <div className="panel wide">
          <div className="panel-title-row"><h2>Upcoming Services</h2><Link className="view-all-link" href="/services">View all</Link></div>
          <div className="table-wrap compact-table"><table><thead><tr><th>Vehicle</th><th>Department</th><th>Service Date</th><th>Km Remaining</th></tr></thead><tbody>
            {upcomingServices.map((row) => <tr key={row.id}><td>{row.fleet_number} <span className="muted">{row.registration}</span></td><td>{row.department || 'Unassigned'}</td><td>{row.next_service_date || '-'}</td><td>{row.km_remaining ?? '-'}</td></tr>)}
            {upcomingServices.length === 0 && <tr><td className="empty" colSpan={4}>Nothing due soon.</td></tr>}
          </tbody></table></div>
        </div>

        <div className="panel">
          <div className="panel-title-row"><h2>Upcoming Tyre Changes</h2><Link className="view-all-link" href="/tyre-logs">View all</Link></div>
          <DueList rows={upcomingTyres} empty="No tyre changes due soon." value={(row) => `${row.km_remaining} km`} detail={(row) => row.tyre_name || row.tyre_size || 'Tyre change'} />
        </div>

        <div className="panel">
          <div className="panel-title-row"><h2>Upcoming Battery Changes</h2><Link className="view-all-link" href="/battery-logs">View all</Link></div>
          <DueList rows={upcomingBatteries} empty="No battery changes due soon." value={(row) => row.due_date || '-'} detail={(row) => row.battery_size || row.battery_type || 'Battery change'} />
        </div>

        <div className="panel wide">
          <div className="panel-title-row"><h2>Longest Running Open Jobs</h2><Link className="view-all-link" href="/jobs">View all</Link></div>
          <div className="table-wrap compact-table"><table><thead><tr><th>Vehicle</th><th>Fault</th><th>Status</th><th>Days Open</th></tr></thead><tbody>
            {longestJobs.map((row, i) => <tr key={i}><td>{row.fleet_number} <span className="muted">{row.registration}</span></td><td>{row.fault_description}</td><td><span className={`badge ${row.status}`}>{String(row.status).replace(/_/g, ' ')}</span></td><td>{row.days_open}</td></tr>)}
            {longestJobs.length === 0 && <tr><td className="empty" colSpan={4}>No open jobs.</td></tr>}
          </tbody></table></div>
        </div>

    
    </AppShell>
  );
}

function VehicleTable({ rows }) {
  return (
    <div className="table-wrap compact-table">
      <table><thead><tr><th>Fleet</th><th>Registration</th><th>Vehicle</th><th>Department</th><th>Status</th><th>Downtime</th></tr></thead><tbody>
        {rows.map((row) => <tr key={row.id}><td>{row.fleet_number}</td><td>{row.registration}</td><td>{row.make} {row.model}</td><td>{row.department || 'Unassigned'}</td><td><span className={`badge ${row.status}`}>{String(row.status).replace(/_/g, ' ')}</span></td><td>{row.downtime_days ? `${row.downtime_days}d` : '-'}</td></tr>)}
        {rows.length === 0 && <tr><td className="empty" colSpan={6}>No vehicles to show.</td></tr>}
      </tbody></table>
    </div>
  );
}

function DueList({ rows, empty, value, detail }) {
  if (!rows?.length) return <div className="subtle">{empty}</div>;
  return (
    <div className="due-list">
      {rows.map((row, i) => (
        <div className="due-item" key={`${row.id}-${i}`}>
          <div><strong>{row.fleet_number} <span className="muted">{row.registration}</span></strong><small>{row.department || 'Unassigned'} - {detail(row)}</small></div>
          <span>{value(row)}</span>
        </div>
      ))}
    </div>
  );
}
