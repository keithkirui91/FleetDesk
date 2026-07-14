import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbAll, dbValue, currentOdometerSql } from '@/lib/db';

export async function GET(request) {
  const { error } = requireApiSession(request);
  if (error) return error;

  try {
    const [
      totalFleet, activeFleet, inWorkshop, awaitingParts, openJobs, activeDowntime,
      fleetStatus, downtimeByDept, jobsTimelineRaw, fuelMonthlyRaw, depotBalances,
      longestJobs, upcomingServices, expiringDocs,
    ] = await Promise.all([
      dbValue('SELECT COUNT(*) FROM vehicles'),
      dbValue("SELECT COUNT(*) FROM vehicles WHERE status = 'active'"),
      dbValue("SELECT COUNT(*) FROM vehicles WHERE status = 'in_workshop'"),
      dbValue("SELECT COUNT(*) FROM vehicles WHERE status = 'awaiting_parts'"),
      dbValue("SELECT COUNT(*) FROM job_cards WHERE status <> 'closed'"),
      dbValue("SELECT COALESCE(SUM(DATEDIFF(CURDATE(), date_in)), 0) FROM job_cards WHERE status <> 'closed'"),
      dbAll('SELECT status, COUNT(*) AS total FROM vehicles GROUP BY status'),
      dbAll(`
        SELECT COALESCE(v.department,'Unassigned') AS department,
               COALESCE(SUM(DATEDIFF(CURDATE(), jc.date_in)), 0) AS downtime_days
        FROM job_cards jc
        JOIN vehicles v ON v.id = jc.vehicle_id
        WHERE jc.status <> 'closed'
        GROUP BY department ORDER BY downtime_days DESC
      `),
      dbAll(`
        SELECT DATE_FORMAT(date_in,'%Y-%m') AS month_key, COUNT(*) AS opened, 0 AS closed
        FROM job_cards WHERE date_in >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) GROUP BY month_key
        UNION ALL
        SELECT DATE_FORMAT(date_closed,'%Y-%m') AS month_key, 0 AS opened, COUNT(*) AS closed
        FROM job_cards WHERE date_closed >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) GROUP BY month_key
      `),
      dbAll(`
        SELECT DATE_FORMAT(log_date,'%Y-%m') AS month_key, SUM(litres_filled) AS total_litres
        FROM fuel_logs WHERE log_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
        GROUP BY month_key ORDER BY month_key
      `),
      dbAll(`
        SELECT fuel_type, dip_litres, reading_date
        FROM fuel_depot_readings fdr1
        WHERE id = (SELECT id FROM fuel_depot_readings fdr2 WHERE fdr2.fuel_type = fdr1.fuel_type ORDER BY reading_date DESC, id DESC LIMIT 1)
      `),
      dbAll(`
        SELECT v.fleet_number, v.registration, jc.fault_description, jc.status,
               DATEDIFF(COALESCE(jc.date_closed, CURDATE()), jc.date_in) AS days_open
        FROM job_cards jc JOIN vehicles v ON v.id = jc.vehicle_id
        WHERE jc.status <> 'closed' ORDER BY days_open DESC LIMIT 5
      `),
      dbAll(`
        SELECT v.id, v.fleet_number, v.registration, v.department, v.next_service_date, v.next_service_mileage,
               ${currentOdometerSql('v')} AS current_odometer
        FROM v_upcoming_placeholder
      `.replace('v_upcoming_placeholder', 'vehicles v')
       + ` WHERE v.status <> 'decommissioned' AND (
             (v.next_service_date IS NOT NULL AND v.next_service_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY))
             OR v.next_service_mileage IS NOT NULL
           )
           ORDER BY v.next_service_date ASC LIMIT 10`),
      dbAll(`
        SELECT fleet_number, registration, department, insurance_expiry, licence_expiry
        FROM vehicles
        WHERE status <> 'decommissioned'
          AND (insurance_expiry <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
               OR licence_expiry <= DATE_ADD(CURDATE(), INTERVAL 30 DAY))
        ORDER BY LEAST(COALESCE(insurance_expiry,'9999-12-31'), COALESCE(licence_expiry,'9999-12-31')) ASC
        LIMIT 10
      `),
    ]);

    // Merge jobs timeline months (opened/closed rows into one per month)
    const timelineMap = new Map();
    for (const row of jobsTimelineRaw) {
      const cur = timelineMap.get(row.month_key) || { month_key: row.month_key, opened: 0, closed: 0 };
      cur.opened += Number(row.opened);
      cur.closed += Number(row.closed);
      timelineMap.set(row.month_key, cur);
    }

    return jsonSuccess({
      kpis: {
        totalFleet: Number(totalFleet),
        activeFleet: Number(activeFleet),
        inWorkshop: Number(inWorkshop),
        awaitingParts: Number(awaitingParts),
        openJobs: Number(openJobs),
        activeDowntimeDays: Number(activeDowntime),
      },
      fleetStatus,
      downtimeByDept,
      jobsTimeline: Array.from(timelineMap.values()).sort((a, b) => a.month_key.localeCompare(b.month_key)),
      fuelMonthly: fuelMonthlyRaw,
      depotBalances,
      longestJobs,
      upcomingServices,
      expiringDocs,
    });
  } catch (e) {
    return jsonError(e.message, 500);
  }
}
