-- FleetDesk schema (MySQL 8+ / MariaDB 10.4+)
-- Revision: adds registration normalization, placeholder ("UNKNOWN") vehicle
-- handling for fuel/service/odometer records, optional service odometer,
-- and merged in/out odometer + passenger logging.
SET FOREIGN_KEY_CHECKS = 0;

-- ============ users (admin logins) ============
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(30) NOT NULL DEFAULT 'admin',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============ vehicles ============
-- Registration rule: spacing is not part of a plate's identity. KDL797G and
-- "KDL 797G" are the same vehicle. `registration` stores whatever was
-- captured verbatim (for display/audit); `registration_normalized` strips
-- whitespace and upper-cases it, and is the column that is actually unique,
-- so re-imports with different spacing collapse onto the same vehicle
-- instead of creating a duplicate.
--
-- Placeholder rule: any record elsewhere (fuel log, service record,
-- odometer log, ...) that references a registration not yet in this table
-- causes a new vehicle row to be created on the fly with fleet_number,
-- make and model set to 'UNKNOWN' (is_placeholder = 1) so the referencing
-- record has somewhere valid to point. A single reserved vehicle with
-- registration 'UNKNOWN VEHICLE' / fleet_number 'UNKNOWN' absorbs every
-- record that has no registration at all (e.g. fuel logs with a blank
-- vehicle reg column). These placeholder rows are expected to be back-filled
-- with real fleet data later; is_placeholder simply flags "needs review".
CREATE TABLE IF NOT EXISTS vehicles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fleet_number VARCHAR(50) NOT NULL,
    registration VARCHAR(50) NOT NULL,
    registration_normalized VARCHAR(50)
        GENERATED ALWAYS AS (UPPER(REPLACE(registration, ' ', ''))) STORED,
    make VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INT NULL,
    date_acquired DATE NULL,
    new_gen_plates TINYINT(1) DEFAULT 0,
    colour VARCHAR(50) NULL,
    fuel_type VARCHAR(30) NULL,
    body_type VARCHAR(100) NULL,
    vehicle_type VARCHAR(30) NULL,
    fleet_type VARCHAR(100) NULL,
    department VARCHAR(100) NULL,
    vin_chassis VARCHAR(100) NULL,
    engine_number VARCHAR(100) NULL,
    engine_size VARCHAR(50) NULL,
    engine_capacity VARCHAR(50) NULL,
    transmission VARCHAR(30) NULL,
    drive_type VARCHAR(10) NULL,
    seating_capacity INT NULL,
    payload_capacity_kg INT NULL,
    tare_weight_kg INT NULL,
    gross_weight_kg INT NULL,
    tyre_size_standard VARCHAR(50) NULL,
    logbook_status VARCHAR(30) NULL,
    odometer_status VARCHAR(30) NULL,
    inspection_status VARCHAR(30) NULL,
    insurance_expiry DATE NULL,
    licence_expiry DATE NULL,
    last_service_date DATE NULL,
    next_service_date DATE NULL,
    next_service_mileage INT NULL,
    primary_image_url VARCHAR(255) NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'active',
    is_placeholder TINYINT(1) NOT NULL DEFAULT 0,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE INDEX idx_vehicles_registration_normalized (registration_normalized),
    INDEX idx_vehicles_status (status),
    INDEX idx_vehicles_fleet_number (fleet_number),
    INDEX idx_vehicles_is_placeholder (is_placeholder)
) ENGINE=InnoDB;

-- ============ drivers ============
CREATE TABLE IF NOT EXISTS drivers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    department VARCHAR(100) NOT NULL,
    dl_number VARCHAR(100) NULL,
    licence_type VARCHAR(255) NULL,
    licence_renewal_date DATE NULL,
    licence_expiry_date DATE NULL,
    photo_url VARCHAR(255) NULL,
    comments TEXT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    is_placeholder TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============ mechanics ============
CREATE TABLE IF NOT EXISTS mechanics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(50) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    department VARCHAR(100) NULL,
    phone VARCHAR(50) NULL,
    email VARCHAR(150) NULL,
    specialisations VARCHAR(255) NULL,
    date_joined DATE NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    photo_url VARCHAR(255) NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============ vehicle_driver_assignments ============
CREATE TABLE IF NOT EXISTS vehicle_driver_assignments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    driver_id INT NOT NULL,
    role ENUM('primary','reliever') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE,
    INDEX idx_vda_vehicle (vehicle_id),
    INDEX idx_vda_driver (driver_id)
) ENGINE=InnoDB;

-- ============ job_cards ============
CREATE TABLE IF NOT EXISTS job_cards (
    id INT AUTO_INCREMENT PRIMARY KEY,
    job_reference VARCHAR(50) NOT NULL,
    vehicle_id INT NOT NULL,
    mechanic_id INT NULL,
    job_type VARCHAR(30) NOT NULL DEFAULT 'repair',
    fault_description TEXT NOT NULL,
    priority VARCHAR(20) NOT NULL DEFAULT 'normal',
    part_availability VARCHAR(20) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'open',
    date_in DATE NOT NULL,
    target_completion_date DATE NULL,
    date_closed DATE NULL,
    resolution_notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (mechanic_id) REFERENCES mechanics(id) ON DELETE SET NULL,
    INDEX idx_jobcards_status (status),
    INDEX idx_jobcards_vehicle (vehicle_id)
) ENGINE=InnoDB;

-- ============ service_records ============
-- odometer_at_service is intentionally nullable: real-world entries are
-- frequently logged without a reading, and the record still needs to be
-- captured rather than rejected.
CREATE TABLE IF NOT EXISTS service_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    mechanic_id INT NULL,
    service_date DATE NOT NULL,
    odometer_at_service INT NULL,
    service_type VARCHAR(30) NOT NULL,
    work_done TEXT NULL,
    parts_replaced TEXT NULL,
    next_service_date DATE NULL,
    next_service_mileage INT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (mechanic_id) REFERENCES mechanics(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============ fuel_logs ============
-- issuer_name is required at the schema level: fuel logs captured with no
-- issuer on record are considered incomplete and should never be inserted
-- (they are dropped during import rather than stored with a blank issuer).
-- vehicle_id always points at a real row: either the actual fleet vehicle,
-- an auto-created placeholder vehicle (matched reg, not yet in `vehicles`),
-- or the single reserved 'UNKNOWN VEHICLE' row when no reg was captured.
CREATE TABLE IF NOT EXISTS fuel_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    log_date DATE NOT NULL,
    odometer_at_fill INT NOT NULL,
    litres_filled DECIMAL(10,2) NOT NULL,
    fuel_type VARCHAR(30) NOT NULL,
    station_location VARCHAR(100) NOT NULL,
    cost_per_litre DECIMAL(10,2) NULL,
    total_cost DECIMAL(12,2) NULL,
    issuer_name VARCHAR(150) NOT NULL,
    receiver_name VARCHAR(150) NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============ fuel_depot_readings ============
-- dip_litres is nullable to accommodate delivery-only entries (fuel
-- brought into the depot) that record a quantity delivered but no dip
-- level; transaction_type distinguishes 'dip_reading' from 'delivery'.
CREATE TABLE IF NOT EXISTS fuel_depot_readings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reading_date DATE NOT NULL,
    fuel_type VARCHAR(30) NOT NULL,
    dip_litres DECIMAL(12,2) NULL,
    transaction_type VARCHAR(30) NOT NULL DEFAULT 'dip_reading',
    quantity_litres DECIMAL(12,2) NULL,
    notes TEXT NULL,
    recorded_by VARCHAR(150) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============ odometer_logs ============
-- The source data logs a gate-out reading and a gate-in reading (and
-- passengers-out / passengers-in) as separate events in separate columns,
-- one populated per row depending on direction. Rather than carry parallel
-- in/out columns, each row here is a single directional event:
-- odometer_reading + passengers describe *that* reading, and `direction`
-- says whether it was recorded leaving or entering the gate.
CREATE TABLE IF NOT EXISTS odometer_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    odometer_reading INT NOT NULL,
    direction ENUM('gate_out','gate_in','other') NOT NULL DEFAULT 'other',
    driver_name VARCHAR(150) NULL,
    destination VARCHAR(150) NULL,
    passengers INT NULL,
    notes TEXT NULL,
    logged_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    INDEX idx_odometer_vehicle (vehicle_id)
) ENGINE=InnoDB;

-- ============ asset_disposal_logs ============
CREATE TABLE IF NOT EXISTS asset_disposal_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NULL,
    action_type VARCHAR(30) NOT NULL,
    fleet_number VARCHAR(50) NULL,
    registration VARCHAR(50) NULL,
    make VARCHAR(100) NULL,
    model VARCHAR(100) NULL,
    department VARCHAR(100) NULL,
    current_odometer INT NULL,
    reason TEXT NULL,
    snapshot JSON NULL,
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============ battery_change_logs ============
CREATE TABLE IF NOT EXISTS battery_change_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    service_record_id INT NULL,
    change_date DATE NOT NULL,
    odometer INT NULL,
    quantity INT NOT NULL DEFAULT 1,
    battery_size VARCHAR(50) NULL,
    battery_type VARCHAR(50) NULL,
    expected_lifespan_months INT NULL,
    reason_for_removal TEXT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (service_record_id) REFERENCES service_records(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============ tyre_change_logs ============
CREATE TABLE IF NOT EXISTS tyre_change_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    service_record_id INT NULL,
    change_date DATE NOT NULL,
    odometer INT NULL,
    quantity INT NOT NULL DEFAULT 1,
    tyre_name VARCHAR(100) NULL,
    tyre_size VARCHAR(50) NULL,
    tyre_type VARCHAR(30) NULL,
    expected_lifespan_km INT NULL,
    quality_comment TEXT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (service_record_id) REFERENCES service_records(id) ON DELETE SET NULL
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;
