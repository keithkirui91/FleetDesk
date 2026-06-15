SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `fuel_logs`;
DROP TABLE IF EXISTS `service_records`;
DROP TABLE IF EXISTS `odometer_logs`;
DROP TABLE IF EXISTS `job_cards`;
DROP TABLE IF EXISTS `mechanics`;
DROP TABLE IF EXISTS `vehicles`;
DROP TABLE IF EXISTS `users`;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('admin') NOT NULL DEFAULT 'admin',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE `vehicles` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `fleet_number` varchar(30) NOT NULL,
  `registration` varchar(30) NOT NULL,
  `make` varchar(80) NOT NULL,
  `model` varchar(80) NOT NULL,
  `year` smallint(5) UNSIGNED DEFAULT NULL,
  `colour` varchar(40) DEFAULT NULL,
  `fuel_type` enum('petrol','diesel','hybrid','electric','lpg','other') NOT NULL DEFAULT 'diesel',
  `body_type` varchar(60) DEFAULT NULL,
  `vehicle_type` enum('car','van','truck','motorbike','construction') NOT NULL DEFAULT 'car',
  `department` varchar(100) DEFAULT NULL,
  `vin_chassis` varchar(80) DEFAULT NULL,
  `engine_size` varchar(40) DEFAULT NULL,
  `transmission` varchar(40) DEFAULT NULL,
  `drive_type` varchar(40) DEFAULT NULL,
  `seating_capacity` smallint(5) UNSIGNED DEFAULT NULL,
  `payload_capacity_kg` int(10) UNSIGNED DEFAULT NULL,
  `tyre_size_standard` varchar(60) DEFAULT NULL,
  `insurance_expiry` date DEFAULT NULL,
  `licence_expiry` date DEFAULT NULL,
  `last_service_date` date DEFAULT NULL,
  `next_service_date` date DEFAULT NULL,
  `next_service_mileage` int(10) UNSIGNED DEFAULT NULL,
  `status` enum('active','in_workshop','awaiting_parts','decommissioned') NOT NULL DEFAULT 'active',
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `fleet_number` (`fleet_number`),
  UNIQUE KEY `registration` (`registration`),
  KEY `idx_status` (`status`),
  KEY `idx_department` (`department`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE `mechanics` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `employee_id` varchar(30) NOT NULL,
  `full_name` varchar(120) NOT NULL,
  `phone` varchar(40) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `specialisations` text DEFAULT NULL,
  `date_joined` date DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `employee_id` (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE `job_cards` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `job_reference` varchar(40) NOT NULL,
  `vehicle_id` int(10) UNSIGNED NOT NULL,
  `mechanic_id` int(10) UNSIGNED DEFAULT NULL,
  `job_type` enum('repair','service','inspection','accident','other') NOT NULL DEFAULT 'repair',
  `fault_description` text NOT NULL,
  `priority` enum('critical','high','normal','low') NOT NULL DEFAULT 'normal',
  `part_availability` enum('available','not_available') NOT NULL DEFAULT 'available',
  `status` enum('open','in_progress','awaiting_parts','on_hold','closed') NOT NULL DEFAULT 'open',
  `date_in` date NOT NULL,
  `target_completion_date` date DEFAULT NULL,
  `date_closed` date DEFAULT NULL,
  `resolution_notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_reference` (`job_reference`),
  KEY `fk_job_mechanic` (`mechanic_id`),
  KEY `idx_job_status` (`status`),
  KEY `idx_job_vehicle` (`vehicle_id`),
  CONSTRAINT `fk_job_mechanic` FOREIGN KEY (`mechanic_id`) REFERENCES `mechanics` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_job_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE `odometer_logs` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `vehicle_id` int(10) UNSIGNED NOT NULL,
  `odometer_reading` int(10) UNSIGNED NOT NULL,
  `location` enum('gate_in','gate_out','workshop','service','fuel','other') NOT NULL DEFAULT 'workshop',
  `notes` text DEFAULT NULL,
  `logged_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_odo_vehicle_time` (`vehicle_id`,`logged_at`),
  CONSTRAINT `fk_odo_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE `service_records` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `vehicle_id` int(10) UNSIGNED NOT NULL,
  `mechanic_id` int(10) UNSIGNED DEFAULT NULL,
  `service_date` date NOT NULL,
  `odometer_at_service` int(10) UNSIGNED DEFAULT NULL,
  `service_type` enum('interim','full','major') NOT NULL DEFAULT 'full',
  `work_done` text DEFAULT NULL,
  `parts_replaced` text DEFAULT NULL,
  `next_service_date` date DEFAULT NULL,
  `next_service_mileage` int(10) UNSIGNED DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_service_vehicle` (`vehicle_id`),
  KEY `fk_service_mechanic` (`mechanic_id`),
  KEY `idx_service_date` (`service_date`),
  CONSTRAINT `fk_service_mechanic` FOREIGN KEY (`mechanic_id`) REFERENCES `mechanics` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_service_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE `fuel_logs` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `vehicle_id` int(10) UNSIGNED NOT NULL,
  `log_date` date NOT NULL,
  `odometer_at_fill` int(10) UNSIGNED NOT NULL,
  `litres_filled` decimal(8,2) NOT NULL,
  `fuel_type` enum('petrol','diesel','hybrid','lpg','kerosene','other') NOT NULL DEFAULT 'diesel',
  `station_location` varchar(120) DEFAULT NULL,
  `cost_per_litre` decimal(10,2) DEFAULT NULL,
  `total_cost` decimal(12,2) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_fuel_vehicle` (`vehicle_id`),
  KEY `idx_fuel_date` (`log_date`),
  CONSTRAINT `fk_fuel_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

INSERT INTO `mechanics` (`id`, `employee_id`, `full_name`, `phone`, `email`, `specialisations`, `date_joined`, `is_active`, `notes`, `created_at`) VALUES
(1, 'EMP-001', 'James Mwangi', '+254 712 345 678', 'james@fleetdesk.local', 'Diesel engines, brakes, diagnostics', '2019-03-10', 1, NULL, '2026-05-20 10:21:43'),
(2, 'EMP-002', 'Peter Otieno', '+254 722 456 789', 'peter@fleetdesk.local', 'Transmission, 4WD systems, suspension', '2020-07-01', 1, NULL, '2026-05-20 10:21:43'),
(3, 'EMP-003', 'Mary Wanjiku', '+254 733 567 890', 'mary@fleetdesk.local', 'Electrical, air conditioning, wiring', '2021-01-18', 1, NULL, '2026-05-20 10:21:43'),
(4, 'EMP-004', 'Grace Achieng', '+254 754 789 012', 'grace@fleetdesk.local', 'Service desk, parts procurement', '2020-11-08', 1, NULL, '2026-05-20 10:21:43'),
(5, 'A333', 'Keith Kirui', '0759018122', 'keith.kirui44@gmail.com', 'Software Diagnosis', '2026-05-29', 1, 'Software Specialist', '2026-05-28 23:27:08');

INSERT INTO `vehicles` (`id`, `fleet_number`, `registration`, `make`, `model`, `year`, `colour`, `fuel_type`, `body_type`, `vehicle_type`, `department`, `vin_chassis`, `engine_size`, `transmission`, `drive_type`, `seating_capacity`, `payload_capacity_kg`, `tyre_size_standard`, `insurance_expiry`, `licence_expiry`, `last_service_date`, `next_service_date`, `next_service_mileage`, `status`, `notes`, `created_at`, `updated_at`) VALUES
(1, 'FD-001', 'KCA 123A', 'Toyota', 'Land Cruiser 200', 2019, 'White', 'diesel', 'SUV', 'car', 'Management', 'JTMHV05J304123456', '4.5L V8', 'automatic', '4WD', 8, NULL, '285/60R18', '2026-08-15', '2026-06-30', '2026-03-16', '2026-09-16', 193500, 'active', 'Director vehicle', '2026-05-20 10:21:43', '2026-05-20 10:21:43'),
(2, 'FD-002', 'KCB 456B', 'Toyota', 'Hilux D/Cab', 2020, 'Silver', 'diesel', 'Pickup', 'truck', 'Operations', 'MR0FX8CD4L0034567', '2.8L', 'manual', '4WD', 5, NULL, '265/65R17', '2026-09-20', '2026-07-31', '2026-01-12', '2026-07-10', 115000, 'active', 'Site operations pickup', '2026-05-20 10:21:43', '2026-05-20 10:21:43'),
(3, 'FD-003', 'KCC 789C', 'Isuzu', 'NQR 400', 2018, 'Blue', 'diesel', 'Lorry', 'truck', 'Logistics', 'JALB6B1L6J7034501', '5.2L', 'manual', '2WD', 2, NULL, '7.50R16', '2026-07-10', '2026-05-31', '2025-12-05', '2026-06-05', 215000, 'in_workshop', 'Gearbox repair', '2026-05-20 10:21:43', '2026-05-20 10:21:43'),
(4, 'FD-004', 'KCD 234D', 'Nissan', 'Urvan NV350', 2019, 'White', 'diesel', 'Van', 'van', 'Transport', 'VSKJB40D0K3012678', '2.5L', 'manual', '2WD', 15, NULL, '215/65R16', '2026-08-28', '2026-06-30', '2025-11-20', '2026-05-20', 205000, 'awaiting_parts', 'AC compressor pending', '2026-05-20 10:21:43', '2026-05-20 10:21:43'),
(5, 'A0043', 'KCR 345V', 'Subaru ', 'Forester XT', 2018, NULL, 'petrol', NULL, 'car', 'Tech Lab', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'Turbo 2000 cc ', '2026-05-28 23:09:05', '2026-05-28 23:09:05');

INSERT INTO `job_cards` (`id`, `job_reference`, `vehicle_id`, `mechanic_id`, `job_type`, `fault_description`, `priority`, `part_availability`, `status`, `date_in`, `target_completion_date`, `date_closed`, `resolution_notes`, `created_at`, `updated_at`) VALUES
(1, 'JC-2026-0001', 3, 1, 'repair', 'Gearbox grinding noise when shifting gears 3 and 4.', 'critical', 'available', 'in_progress', '2026-04-01', '2026-04-10', NULL, NULL, '2026-05-20 10:21:43', '2026-05-20 10:21:43'),
(2, 'JC-2026-0002', 4, 3, 'repair', 'Air conditioning compressor seized.', 'high', 'not_available', 'awaiting_parts', '2026-05-03', '2026-05-15', NULL, NULL, '2026-05-20 10:21:43', '2026-05-20 10:21:43'),
(3, 'JC-2026-0003', 2, 1, 'service', 'Scheduled 100,000km major service.', 'normal', 'available', 'closed', '2026-01-10', '2026-01-12', NULL, 'Major service completed.', '2026-05-20 10:21:43', '2026-05-20 10:21:43'),
(4, 'JC-2026-0004', 5, 4, 'inspection', 'New vehicle Inspection', 'low', 'available', 'open', '2026-05-29', '2026-05-30', NULL, NULL, '2026-05-28 23:10:10', '2026-05-28 23:10:10'),
(5, 'JC-2026-0005', 5, 2, 'service', 'damage', 'high', 'available', 'open', '2026-06-03', '2026-06-04', NULL, NULL, '2026-06-02 22:47:57', '2026-06-02 22:47:57');

INSERT INTO `odometer_logs` (`id`, `vehicle_id`, `odometer_reading`, `location`, `notes`, `logged_at`) VALUES
(1, 1, 183500, 'service', 'Full service odometer', '2026-03-16 09:00:00'),
(2, 1, 185200, 'gate_in', 'Morning reading', '2026-05-01 07:30:00'),
(3, 2, 100000, 'service', 'Major service', '2026-01-12 10:00:00'),
(4, 2, 108600, 'gate_out', 'Site trip return', '2026-05-05 18:10:00'),
(5, 3, 205000, 'workshop', 'Workshop check-in', '2026-04-01 08:30:00'),
(6, 4, 198000, 'workshop', 'AC fault check-in', '2026-05-03 09:15:00'),
(7, 2, 109500, 'fuel', 'OK', '2026-05-29 09:06:00'),
(8, 5, 21000, 'workshop', 'Opening odometer', '2026-05-28 23:09:05'),
(9, 5, 26000, 'gate_in', 'ok', '2026-06-03 08:23:00');

INSERT INTO `service_records` (`id`, `vehicle_id`, `mechanic_id`, `service_date`, `odometer_at_service`, `service_type`, `work_done`, `parts_replaced`, `next_service_date`, `next_service_mileage`, `notes`, `created_at`) VALUES
(1, 1, 1, '2026-03-16', 183500, 'full', 'Oil, filters, belts checked, brake fluid changed', 'Oil filter, air filter, fuel filter, brake fluid', '2026-09-16', 193500, 'Vehicle in excellent condition', '2026-05-20 10:21:43'),
(2, 2, 1, '2026-01-12', 100000, 'major', 'Major 100k service', 'Filters, glow plugs, timing belt, water pump', '2026-07-10', 115000, 'Monitor clutch wear', '2026-05-20 10:21:43'),
(3, 5, 4, '2026-05-29', 21000, 'interim', 'Check Oil, Brakes and other fluids. Inspect the new vehicle before handover to the Tech lab\n', NULL, '2026-05-29', 25000, NULL, '2026-05-28 23:11:55'),
(4, 5, 5, '2026-05-29', 21100, 'interim', 'Software Checks and clearing error codes. Activating other systems features.', NULL, NULL, 24999, NULL, '2026-05-28 23:28:51'),
(5, 5, 4, '2026-06-03', 25000, 'interim', 'oil change', NULL, '2026-06-03', 30000, NULL, '2026-06-02 22:23:27'),
(6, 5, 2, '2026-06-03', 26000, 'major', 'oil change, bushing change etc\n', NULL, '2026-06-24', 30000, NULL, '2026-06-02 22:46:34'),
(7, 5, NULL, '2026-06-03', NULL, 'interim', NULL, NULL, NULL, NULL, NULL, '2026-06-03 04:18:16');

INSERT INTO `fuel_logs` (`id`, `vehicle_id`, `log_date`, `odometer_at_fill`, `litres_filled`, `fuel_type`, `station_location`, `cost_per_litre`, `total_cost`, `notes`, `created_at`) VALUES
(1, 1, '2026-05-01', 185200, '72.00', 'diesel', 'Total Westlands', '185.00', '13320.00', 'Full tank', '2026-05-20 10:21:43'),
(2, 2, '2026-05-05', 108600, '61.50', 'diesel', 'Shell Thika Road', '184.00', '11316.00', 'Site return fill', '2026-05-20 10:21:43'),
(3, 4, '2026-05-04', 198200, '54.00', 'diesel', 'Rubis Langata', '183.00', '9882.00', 'Workshop vehicle', '2026-05-20 10:21:43'),
(4, 2, '2026-05-29', 109501, '78.00', 'diesel', 'Kamok', '228.00', '18000.00', 'Min and Sub tank', '2026-05-28 23:05:44'),
(5, 5, '2026-05-29', 21000, '65.00', 'petrol', 'Kamok Depot', '218.00', '14000.00', 'Full tank', '2026-05-28 23:12:58'),
(6, 5, '2026-06-03', 25000, '55.00', 'petrol', 'Kamok Depot', '221.00', '15000.00', 'ok', '2026-06-02 22:27:47');

ALTER TABLE `mechanics` AUTO_INCREMENT = 6;
ALTER TABLE `vehicles` AUTO_INCREMENT = 6;
ALTER TABLE `job_cards` AUTO_INCREMENT = 6;
ALTER TABLE `odometer_logs` AUTO_INCREMENT = 10;
ALTER TABLE `service_records` AUTO_INCREMENT = 8;
ALTER TABLE `fuel_logs` AUTO_INCREMENT = 7;
ALTER TABLE `users` AUTO_INCREMENT = 1;
