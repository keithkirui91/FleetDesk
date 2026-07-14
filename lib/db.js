import mysql from 'mysql2/promise';

let pool;

export function getPool() {
  if (!pool) {
    pool = mysql.createPool({
      host: process.env.FLEETDESK_DB_HOST || 'localhost',
      port: Number(process.env.FLEETDESK_DB_PORT || 3306),
      user: process.env.FLEETDESK_DB_USER || 'root',
      password: process.env.FLEETDESK_DB_PASS || '',
      database: process.env.FLEETDESK_DB_NAME || 'fleetdesk',
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
      dateStrings: true,
    });
  }
  return pool;
}

// Run a query and return all rows
export async function dbAll(sql, params = []) {
  const [rows] = await getPool().query(sql, params);
  return rows;
}

// Run a query and return the first row (or null)
export async function dbOne(sql, params = []) {
  const rows = await dbAll(sql, params);
  return rows[0] ?? null;
}

// Run a query and return a single scalar value
export async function dbValue(sql, params = []) {
  const row = await dbOne(sql, params);
  if (!row) return null;
  const values = Object.values(row);
  return values[0];
}

function cleanNullable(value) {
  return value === '' || value === undefined ? null : value;
}

// Insert a row, only using keys present in `fields` that also exist in `input`.
export async function insertRow(table, fields, input) {
  const columns = [];
  const values = [];
  for (const field of fields) {
    if (Object.prototype.hasOwnProperty.call(input, field)) {
      columns.push(field);
      values.push(cleanNullable(input[field]));
    }
  }
  if (!columns.length) {
    const err = new Error('No fields supplied.');
    err.status = 400;
    throw err;
  }
  const sql = `INSERT INTO ${table} (${columns.join(',')}) VALUES (${columns.map(() => '?').join(',')})`;
  const [result] = await getPool().query(sql, values);
  return result.insertId;
}

// Update a row. Empty-string/null values are skipped (matches original PHP behaviour).
export async function updateRow(table, fields, id, input) {
  const sets = [];
  const values = [];
  for (const field of fields) {
    if (Object.prototype.hasOwnProperty.call(input, field)) {
      if (input[field] === '' || input[field] === null || input[field] === undefined) continue;
      sets.push(`${field} = ?`);
      values.push(cleanNullable(input[field]));
    }
  }
  if (!sets.length) {
    const err = new Error('No fields supplied.');
    err.status = 400;
    throw err;
  }
  values.push(id);
  const sql = `UPDATE ${table} SET ${sets.join(',')} WHERE id = ?`;
  await getPool().query(sql, values);
}

export async function deleteRow(table, id) {
  await getPool().query(`DELETE FROM ${table} WHERE id = ?`, [id]);
}

export async function logVehicleMileage(vehicleId, reading, location, notes = '') {
  if (!vehicleId || !reading || reading <= 0) return;
  await getPool().query(
    'INSERT INTO odometer_logs (vehicle_id, odometer_reading, location, notes) VALUES (?, ?, ?, ?)',
    [vehicleId, reading, location, notes]
  );
}

// SQL fragment computing the latest known odometer reading for a vehicle,
// pulled from odometer logs, service records, and fuel logs (whichever is
// most recent). Mirrors current_odometer_sql() from the PHP app.
export function currentOdometerSql(vehicleAlias = 'v') {
  const vehicleId = `${vehicleAlias}.id`;
  return `COALESCE((
        SELECT reading
        FROM (
            SELECT ol.vehicle_id, ol.odometer_reading AS reading, ol.logged_at AS reading_at, ol.id AS source_id
            FROM odometer_logs ol
            UNION ALL
            SELECT sr.vehicle_id, sr.odometer_at_service AS reading, sr.created_at AS reading_at, sr.id AS source_id
            FROM service_records sr
            WHERE sr.odometer_at_service IS NOT NULL
            UNION ALL
            SELECT fl.vehicle_id, fl.odometer_at_fill AS reading, fl.created_at AS reading_at, fl.id AS source_id
            FROM fuel_logs fl
        ) odometer_sources
        WHERE odometer_sources.vehicle_id = ${vehicleId}
        ORDER BY reading_at DESC, source_id DESC
        LIMIT 1
    ), 0)`;
}
