'use client';

import { useEffect, useState } from 'react';
import AppShell from '@/components/AppShell';

export default function ReportsPage() {
  const [data, setData] = useState(null);

  useEffect(() => {
    fetch('/api/reports').then((r) => r.json()).then((res) => setData(res.data));
  }, []);

  return (
    <AppShell title="Reports">
      {!data ? (
        <div className="empty">Loading…</div>
      ) : (
        <>
          <div className="card-grid">
            {data.jobsByStatus.map((row) => (
              <div className="stat" key={row.status}>
                <span>{String(row.status).replace(/_/g, ' ')}</span>
                <strong>{row.total}</strong>
              </div>
            ))}
          </div>

          <div className="panel">
            <h2>Services by Type</h2>
            <div className="table-wrap">
              <table>
                <tbody>
                  {data.serviceByType.map((row) => (
                    <tr key={row.service_type}>
                      <td>{row.service_type}</td>
                      <td className="text-right">{row.total}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          <div className="panel">
            <h2>Top Fuel Usage</h2>
            <div className="table-wrap">
              <table>
                <thead><tr><th>Vehicle</th><th>Litres</th><th>Cost</th></tr></thead>
                <tbody>
                  {data.fuelByVehicle.map((row) => (
                    <tr key={row.fleet_number}>
                      <td>{row.fleet_number}</td>
                      <td>{row.litres}</td>
                      <td>{row.cost}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </AppShell>
  );
}
