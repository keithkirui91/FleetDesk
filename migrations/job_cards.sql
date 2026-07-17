-- phpMyAdmin SQL Dump
-- version 4.9.0.1
-- https://www.phpmyadmin.net/
--
-- Host: sql113.infinityfree.com
-- Generation Time: Jul 17, 2026 at 03:29 PM
-- Server version: 11.4.12-MariaDB
-- PHP Version: 7.2.22

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `if0_38642919_fleetdeskb`
--

-- --------------------------------------------------------

--
-- Table structure for table `job_cards`
--

CREATE TABLE IF NOT EXISTS `job_cards` (
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
  KEY `idx_job_vehicle` (`vehicle_id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `job_cards`
--

INSERT INTO `job_cards` (`id`, `job_reference`, `vehicle_id`, `mechanic_id`, `job_type`, `fault_description`, `priority`, `part_availability`, `status`, `date_in`, `target_completion_date`, `date_closed`, `resolution_notes`, `created_at`, `updated_at`) VALUES
(2, 'JC-2026-0001', 107, NULL, 'repair', 'Brakes wheel cylinder worn', 'normal', 'not_available', 'awaiting_parts', '2026-01-01', '2026-07-30', NULL, 'RQ 024512- Military jerricans', '2026-07-02 01:57:20', '2026-07-02 06:35:14'),
(3, 'JC-2026-0002', 108, NULL, 'repair', 'Radiator leaking', 'normal', 'not_available', 'awaiting_parts', '2026-01-01', '2026-07-30', NULL, 'RQ 024512- Military jerricans', '2026-07-02 01:57:20', '2026-07-02 06:35:25'),
(4, 'JC-2026-0003', 109, NULL, 'repair', 'Radiator leaking', 'normal', 'not_available', 'awaiting_parts', '2026-01-01', '2026-07-30', NULL, 'RQ 024512- Military jerricans', '2026-07-02 01:57:20', '2026-07-02 06:35:46'),
(5, 'JC-2026-0005', 2, NULL, 'repair', 'Cylinder head leak', 'low', 'not_available', 'awaiting_parts', '2026-03-02', '2026-07-30', NULL, 'Procurement with order  RQ024319- Re- ordered- Non Genuine parts rejected\n\n??????????????????\n7/2/2026, 2:54:59 PM\nOk\n\n??????????????????\n7/2/2026, 2:55:13 PM\nTest B\n\n??????????????????\n7/2/2026, 3:00:17 PM\nTest C\n\n??????????????????\n7/2/2026, 3:01:08 PM\ntest D\n\n??????????????????\n7/2/2026, 3:01:21 PM\ntest E\n\n\n[02/07/2026 08:07]\nTest F', '2026-07-02 01:57:20', '2026-07-02 06:35:50'),
(6, 'JC-2026-0006', 3, NULL, 'service', 'Engine Ovrhaul', 'high', 'not_available', 'awaiting_parts', '2026-03-02', '2026-07-30', NULL, 'Procurement with order  RQ024319- Re- ordered- Non Genuine parts rejected', '2026-07-02 01:57:20', '2026-07-02 06:35:57'),
(7, 'JC-2026-0007', 12, NULL, 'service', 'Engine Ovrhaul', 'high', 'not_available', 'awaiting_parts', '2026-03-02', '2026-07-30', NULL, 'Procurement with order  RQ024319- Re- ordered- Non Genuine parts rejected', '2026-07-02 01:57:20', '2026-07-02 06:36:01'),
(8, 'JC-2026-0008', 17, NULL, 'service', 'Engine Ovrhaul', 'high', 'not_available', 'awaiting_parts', '2026-03-02', '2026-07-30', NULL, 'Procurement with order  RQ024319- Re- ordered- Non Genuine parts rejected', '2026-07-02 01:57:20', '2026-07-02 06:36:08'),
(9, 'JC-2026-0009', 24, NULL, 'repair', 'Spikes broken', 'high', 'not_available', 'awaiting_parts', '2026-03-02', '2026-07-30', NULL, 'At Nanyuki Maina Machines Place  -Reffred by other users of Kibo- Awaiting Estimate', '2026-07-02 01:57:20', '2026-07-02 06:36:19'),
(10, 'JC-2026-0010', 64, NULL, 'inspection', 'Annual Inspection', 'normal', 'not_available', 'awaiting_parts', '2026-03-02', '2026-07-30', NULL, 'David Kinyua workmanship not very good- Reconsider subletting', '2026-07-02 01:57:20', '2026-07-02 06:36:25'),
(11, 'JC-2026-0011', 8, NULL, 'repair', 'Rim Damaged', 'high', 'not_available', 'awaiting_parts', '2026-03-23', '2026-07-30', NULL, 'Sent to Maina Machine Nanyuki- Awaiting Estimate', '2026-07-02 01:57:20', '2026-07-02 06:36:29'),
(12, 'JC-2026-000', 10, NULL, 'service', 'Engine Ovrhaul', 'normal', 'not_available', 'awaiting_parts', '2026-04-06', '2026-07-30', NULL, 'Engine overhaul', '2026-07-02 01:57:20', '2026-07-02 06:36:37'),
(13, 'JC-2026-0012', 92, NULL, 'repair', 'Leaks on the Articulation arm', 'high', 'available', 'in_progress', '2026-05-11', '2026-07-15', NULL, '[02/07/2026 08:28]\nOngoing', '2026-07-02 05:28:42', '2026-07-02 05:34:43'),
(30, 'JC-2026-0013', 67, NULL, 'accident', 'Accident', 'high', 'not_available', 'awaiting_parts', '2026-03-15', '2026-07-30', NULL, '[02/07/2026 08:35]\nAwaiting insurance Assessment for release on 13/05/2026', '2026-07-02 05:34:54', '2026-07-02 05:35:44'),
(31, 'JC-2026-0014', 44, NULL, 'repair', 'Rim Damaged', 'normal', 'available', 'in_progress', '2026-06-04', '2026-07-30', NULL, '[02/07/2026 08:39]\non going fixing on the 6/29/2026', '2026-07-02 05:38:02', '2026-07-02 05:39:08'),
(32, 'JC-2026-0015', 15, NULL, 'service', 'Engine Overhaul', 'normal', 'available', 'in_progress', '2026-06-04', '2026-07-30', NULL, NULL, '2026-07-02 05:40:40', '2026-07-02 05:40:40'),
(33, 'JC-2026-0016', 56, NULL, 'repair', 'Injector pipe leaks', 'normal', 'available', 'in_progress', '2026-05-11', '2026-07-31', NULL, NULL, '2026-07-02 05:55:13', '2026-07-02 05:55:13');

--
-- Constraints for dumped tables
--

--
-- Constraints for table `job_cards`
--
ALTER TABLE `job_cards`
  ADD CONSTRAINT `fk_job_mechanic` FOREIGN KEY (`mechanic_id`) REFERENCES `mechanics` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_job_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
