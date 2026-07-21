import { requireApiSession, jsonError, jsonSuccess } from '@/lib/auth';
import { dbAll, dbValue, currentOdometerSql } from '@/lib/db';

const EFFECTIVE_STATUS = `CASE
  WHEN EXISTS (SELECT 1 FROM job_cards open_parts WHERE open_parts.vehicle_id = v.id AND open_parts.status = 'awaiting_parts') THEN 'awaiting_parts'
  WHEN EXISTS (SELECT 1 FROM job_cards open_jobs WHERE open_jobs.vehicle_id = v.id AND open_jobs.status <> 'closed') THEN 'in_workshop'
  WHEN v.status = 'decommissioned' THEN 'decommissioned'
  ELSE 'active'
END`;

export async function GET(request) {
  const { error } = requireApiSession(request);
  if (error) return error;

  const { searchParams } = new URL(request.url);
  const months = Math.min(24, Math.max(1, Number(searchParams.get('months') || 12)));
  const mileageVehicle = searchParams.get('mileageVehicle') || '';
  const mileageDepartment = searchParams.get('mileageDepartment') || '';
  const mileageFilters = [];
  const mileageParams = [months];
  if (mileageVehicle) {
    mileageFilters.push('v.id = ?');
    mileageParams.push(Number(mileageVehicle));
  }
  if (mileageDepartment) {
    mileageFilters.push('v.department = ?');
    mileageParams.push(mileageDepartment);
  }
  const mileageWhere = mileageFilters.length ? `AND ${mileageFilters.join(' AND ')}` : '';

  try {
    const [
      totalFleet, openJobs, activeDowntime, fleetStatus, departments, mileageVehicles,
      downtimeByDept, jobsTimelineRaw, fuelMonthlyRaw, fuelRows, mileageWeeklyRaw, depotBalances,
      longestJobs, upcomingServices, upcomingTyres, upcomingBatteries, expiringDocs, fleetStatusVehicles, downtimeVehicles,
    ] = await Promise.all([
      dbValue('SELECT COUNT(*) FROM vehicles'),
      dbValue("SELECT COUNT(*) FROM job_cards WHERE status <> 'closed'"),
      dbValue("SELECT COALESCE(SUM(DATEDIFF(CURDATE(), date_in)), 0) FROM job_cards WHERE status <> 'closed'"),
      dbAll(`
        SELECT effective_status AS status, COUNT(*) AS total
        FROM (SELECT v.id, ${EFFECTIVE_STATUS} AS effective_status FROM vehicles v) status_rows
        GROUP BY effective_status
        ORDER BY FIELD(effective_status, 'active', 'in_workshop', 'awaiting_parts', 'decommissioned')
      `),
      dbAll("SELECT DISTINCT department FROM vehicles WHERE department IS NOT NULL AND department <> '' ORDER BY department"),
      dbAll("SELECT id, fleet_number, registration FROM vehicles WHERE status <> 'decommissioned' ORDER BY fleet_number, registration"),
      dbAll(`
        SELECT COALESCE(v.department,'Unassigned') AS department,
               COALESCE(SUM(DATEDIFF(CURDATE(), jc.date_in)), 0) AS downtime_days
        FROM job_cards jc
        JOIN vehicles v ON v.id = jc.vehicle_id
        WHERE jc.status <> 'closed'
        GROUP BY department ORDER BY downtime_days DESC
      `),
      dbAll(`
        SELECT DATE_FORMAT(jc.date_in,'%Y-%m') AS month_key, COUNT(*) AS opened, 0 AS closed
        FROM job_cards jc
        WHERE jc.date_in >= DATE_SUB(CURDATE(), INTERVAL ? MONTH)
        GROUP BY month_key
        UNION ALL
        SELECT DATE_FORMAT(jc.date_closed,'%Y-%m') AS month_key, 0 AS opened, COUNT(*) AS closed
        FROM job_cards jc
        WHERE jc.date_closed >= DATE_SUB(CURDATE(), INTERVAL ? MONTH)
        GROUP BY month_key
      `, [months, months]),
      dbAll(`
        SELECT DATE_FORMAT(fl.log_date,'%Y-%m') AS month_key, SUM(fl.litres_filled) AS total_litres
        FROM fuel_logs fl
        WHERE fl.log_date >= DATE_SUB(CURDATE(), INTERVAL ? MONTH)
        GROUP BY month_key ORDER BY month_key
      `, [months]),
      dbAll(`
        SELECT fl.id, fl.log_date, fl.litres_filled, fl.fuel_type, fl.station_location, fl.total_cost,
               v.fleet_number, v.registration, v.department
        FROM fuel_logs fl
        JOIN vehicles v ON v.id = fl.vehicle_id
        WHERE fl.log_date >= DATE_SUB(CURDATE(), INTERVAL ? MONTH)
        ORDER BY fl.log_date DESC, fl.id DESC
        LIMIT 250
      `, [months]),
      dbAll(`
        SELECT YEARWEEK(ol.logged_at, 3) AS week_key,
               DATE_FORMAT(MIN(ol.logged_at), '%b %d') AS week_label,
               SUM(GREATEST(0, ol.odometer_reading - COALESCE(prev.prev_reading, ol.odometer_reading))) AS kilometres
        FROM odometer_logs ol
        JOIN vehicles v ON v.id = ol.vehicle_id
        LEFT JOIN (
          SELECT cur.id, (
            SELECT prev.odometer_reading
            FROM odometer_logs prev
            WHERE prev.vehicle_id = cur.vehicle_id
              AND (prev.logged_at < cur.logged_at OR (prev.logged_at = cur.logged_at AND prev.id < cur.id))
            ORDER BY prev.logged_at DESC, prev.id DESC
            LIMIT 1
          ) AS prev_reading
          FROM odometer_logs cur
        ) prev ON prev.id = ol.id
        WHERE ol.logged_at >= DATE_SUB(CURDATE(), INTERVAL ? MONTH) ${mileageWhere}
        GROUP BY YEARWEEK(ol.logged_at, 3)
        ORDER BY week_key
      `, mileageParams),
      dbAll(`
        SELECT fuel_type, dip_litres, reading_date
        FROM fuel_depot_readings fdr1
        WHERE id = (SELECT id FROM fuel_depot_readings fdr2 WHERE fdr2.fuel_type = fdr1.fuel_type ORDER BY reading_date DESC, id DESC LIMIT 1)
      `),
      dbAll(`
        SELECT v.fleet_number, v.registration, jc.fault_description, jc.status,
               DATEDIFF(COALESCE(jc.date_closed, CURDATE()), jc.date_in) AS days_open
        FROM job_cards jc JOIN vehicles v ON v.id = jc.vehicle_id
        WHERE jc.status <> 'closed'
        ORDER BY days_open DESC LIMIT 5
      `),
      dbAll(`
        SELECT v.id, v.fleet_number, v.registration, v.department, v.next_service_date, v.next_service_mileage,
               ${currentOdometerSql('v')} AS current_odometer,
               CASE WHEN v.next_service_mileage IS NULL THEN NULL ELSE v.next_service_mileage - ${currentOdometerSql('v')} END AS km_remaining
        FROM vehicles v
        WHERE v.status <> 'decommissioned' AND (
             (v.next_service_date IS NOT NULL AND v.next_service_date <= DATE_ADD(CURDATE(), INTERVAL 45 DAY))
             OR (v.next_service_mileage IS NOT NULL AND v.next_service_mileage - ${currentOdometerSql('v')} <= 1000)
           )
        ORDER BY COALESCE(v.next_service_date,'9999-12-31'), km_remaining ASC
        LIMIT 10
      `),
      dbAll(`
        SELECT tcl.vehicle_id AS id, v.fleet_number, v.registration, v.department, tcl.change_date,
               tcl.tyre_name, tcl.tyre_size, tcl.expected_lifespan_km, tcl.odometer,
               ${currentOdometerSql('v')} AS current_odometer,
               (tcl.odometer + tcl.expected_lifespan_km - ${currentOdometerSql('v')}) AS km_remaining
        FROM tyre_change_logs tcl
        JOIN vehicles v ON v.id = tcl.vehicle_id
        WHERE tcl.expected_lifespan_km IS NOT NULL AND tcl.odometer IS NOT NULL
          AND tcl.id = (SELECT t2.id FROM tyre_change_logs t2 WHERE t2.vehicle_id = tcl.vehicle_id ORDER BY t2.change_date DESC, t2.id DESC LIMIT 1)
          AND (tcl.odometer + tcl.expected_lifespan_km - ${currentOdometerSql('v')}) <= 1000
        ORDER BY km_remaining ASC
        LIMIT 8
      `),
 dbAll(`
  SELECT bcl.vehicle_id AS id, v.fleet_number, v.registration, v.department, bcl.change_date,
         bcl.battery_size, bcl.battery_type, bcl.expected_lifespan_hours,
         DATE(DATE_ADD(bcl.change_date, INTERVAL bcl.expected_lifespan_hours HOUR)) AS due_date
  FROM battery_change_logs bcl
  JOIN vehicles v ON v.id = bcl.vehicle_id
  WHERE bcl.expected_lifespan_hours IS NOT NULL
    AND bcl.id = (SELECT b2.id FROM battery_change_logs b2 WHERE b2.vehicle_id = bcl.vehicle_id ORDER BY b2.change_date DESC, b2.id DESC LIMIT 1)
    AND DATE_ADD(bcl.change_date, INTERVAL bcl.expected_lifespan_hours HOUR) <= DATE_ADD(CURDATE(), INTERVAL 60 DAY)
  ORDER BY due_date ASC
  LIMIT 8
`),
      dbAll(`
        SELECT fleet_number, registration, department, licence_expiry
        FROM vehicles
        WHERE status <> 'decommissioned'
          AND licence_expiry <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
        ORDER BY COALESCE(licence_expiry,'9999-12-31') ASC
        LIMIT 10
      `),
      dbAll(`
        SELECT v.id, v.fleet_number, v.registration, v.make, v.model, v.department, v.status AS stored_status,
               ${EFFECTIVE_STATUS} AS status
        FROM vehicles v
        ORDER BY FIELD(status, 'active', 'in_workshop', 'awaiting_parts', 'decommissioned'), v.fleet_number
      `),
      dbAll(`
        SELECT DISTINCT v.id, v.fleet_number, v.registration, v.make, v.model, v.department,
               ${EFFECTIVE_STATUS} AS status,
               DATEDIFF(CURDATE(), jc.date_in) AS downtime_days
        FROM job_cards jc
        JOIN vehicles v ON v.id = jc.vehicle_id
        WHERE jc.status <> 'closed'
        ORDER BY v.department, downtime_days DESC, v.fleet_number
      `),
    ]);

    const timelineMap = new Map();
    for (const row of jobsTimelineRaw) {
      const cur = timelineMap.get(row.month_key) || { month_key: row.month_key, opened: 0, closed: 0 };
      cur.opened += Number(row.opened);
      cur.closed += Number(row.closed);
      timelineMap.set(row.month_key, cur);
    }

    const statusMap = new Map(fleetStatus.map((row) => [row.status, Number(row.total)]));

    return jsonSuccess({
      kpis: {
        totalFleet: Number(totalFleet),
        activeFleet: statusMap.get('active') || 0,
        inWorkshop: statusMap.get('in_workshop') || 0,
        awaitingParts: statusMap.get('awaiting_parts') || 0,
        openJobs: Number(openJobs),
        activeDowntimeDays: Number(activeDowntime),
      },
      filters: { months, departments: departments.map((d) => d.department), mileageVehicles },
      fleetStatus,
      downtimeByDept,
      jobsTimeline: Array.from(timelineMap.values()).sort((a, b) => a.month_key.localeCompare(b.month_key)),
      fuelMonthly: fuelMonthlyRaw,
      fuelRows,
      mileageWeekly: mileageWeeklyRaw,
      depotBalances,
      longestJobs,
      upcomingServices,
      upcomingTyres,
      upcomingBatteries,
      expiringDocs,
      fleetStatusVehicles,
      downtimeVehicles,
    });
  } catch (e) {
    return jsonError(e.message, 500);
  }
}
