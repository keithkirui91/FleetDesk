-- phpMyAdmin SQL Dump
-- version 4.9.0.1
-- https://www.phpmyadmin.net/
--
-- Host: sql113.infinityfree.com
-- Generation Time: Jul 03, 2026 at 07:21 AM
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
-- Table structure for table `asset_disposal_logs`
--

CREATE TABLE `asset_disposal_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `vehicle_id` int(10) UNSIGNED DEFAULT NULL,
  `action_type` enum('disposed','deleted') NOT NULL,
  `fleet_number` varchar(30) NOT NULL,
  `registration` varchar(30) NOT NULL,
  `make` varchar(80) DEFAULT NULL,
  `model` varchar(80) DEFAULT NULL,
  `department` varchar(100) DEFAULT NULL,
  `current_odometer` int(10) UNSIGNED DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `snapshot` longtext DEFAULT NULL,
  `logged_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `battery_change_logs`
--

CREATE TABLE `battery_change_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `vehicle_id` int(10) UNSIGNED NOT NULL,
  `service_record_id` int(10) UNSIGNED DEFAULT NULL,
  `change_date` date NOT NULL,
  `odometer` int(10) UNSIGNED DEFAULT NULL,
  `quantity` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `battery_size` varchar(60) DEFAULT NULL COMMENT 'e.g. 12V/70Ah',
  `battery_type` varchar(80) DEFAULT NULL COMMENT 'e.g. AGM, Lead-acid, Lithium',
  `expected_lifespan_months` smallint(5) UNSIGNED DEFAULT NULL,
  `reason_for_removal` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `drivers`
--

CREATE TABLE `drivers` (
  `id` int(10) UNSIGNED NOT NULL,
  `full_name` varchar(120) NOT NULL,
  `department` varchar(100) NOT NULL,
  `dl_number` varchar(80) DEFAULT NULL,
  `licence_type` varchar(255) DEFAULT NULL,
  `licence_renewal_date` date DEFAULT NULL,
  `licence_expiry_date` date DEFAULT NULL,
  `comments` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `photo_url` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `drivers`
--

INSERT INTO `drivers` (`id`, `full_name`, `department`, `dl_number`, `licence_type`, `licence_renewal_date`, `licence_expiry_date`, `comments`, `is_active`, `photo_url`, `created_at`, `updated_at`) VALUES
(1, 'Jacob Maina', 'Technical Operations', NULL, NULL, '2025-10-09', '2026-04-09', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(2, 'Simon Macharia', 'Technical Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(3, 'Weldon Simale Ponoto', 'Technical Operations', 'INTERIM', 'INTERIM', '2025-08-22', '2026-02-22', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(4, 'Paul Ewaton', 'Livestock', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(5, 'Richard Gathogo', 'Technical Operations', 'INTERIM', '3x', '2025-10-09', '2026-04-09', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(6, 'David Ngare', 'Technical Operations', NULL, NULL, '2025-10-06', '2026-10-06', NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(7, 'Alfred Karuri', 'Technical Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(8, 'Stephen Wakaba', 'Wildlife Operations', NULL, NULL, '2025-12-09', '2025-12-09', NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(9, 'Richard Bob Mwangi', 'Wildlife Operations', 'INTERIM', 'A2', '2024-10-09', '2026-04-09', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(10, 'Kelvin Gitau', 'Community Development', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(11, 'Stephen Munene', 'Tourism', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(12, 'Felix Lejore', 'Community Development', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(13, 'Paul Ndonga', 'Community Development', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(14, 'Erick Ndungu', 'Livestock', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(15, 'Peter Njau', 'Technical Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(16, 'Peter Martim', 'Technical Operations', NULL, 'B,C1,C2', '2024-01-11', '2025-01-11', 'B,C1,C2', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(17, 'Lucas Sanya', 'Wildlife Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(18, 'Joseph Epongon', 'Wildlife Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(19, 'Moses Lotikoi', 'Wildlife Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(20, 'Isaac Kipkoech', 'Wildlife Operations', NULL, NULL, NULL, NULL, '10 Years expiry', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(21, 'Joseph Ndiritu', 'Wildlife Operations', NULL, NULL, '2024-07-11', '2026-07-11', NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(22, 'William Okoth', 'Wildlife Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(23, 'Kupano Lemeshami', 'Technical Operations', 'IDL-BM2052', 'A1,A2,A3', '2016-10-27', '2026-02-04', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(24, 'Paul Waweru', 'Community Development', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(25, 'Benard Kariuki Mwangi', 'Community Development', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(26, 'George Gitonga', 'Technical Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(27, 'Stephen Karithi', 'Technical Operations', NULL, NULL, NULL, NULL, 'Waiting for Interim DL from AA', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(28, 'Alfred Karuri', 'Technical Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(29, 'Mark Sakwa', 'Technical Operations', NULL, NULL, '2024-12-02', '2025-12-02', NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(30, 'James Olepere Nephatao', 'Livestock', 'INTERIM', 'INTERIM', '2025-10-06', '2026-04-06', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(31, 'Fredrick Omondi', 'Livestock', 'IDL-AACCU9', 'A2,', '2025-03-14', '2028-03-14', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(32, 'Wesly Koech', 'Technical Operations', 'INTERIM', 'INTERIM', '2025-08-22', '2026-02-22', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(33, 'Martin Muriira', 'Technical Operations', NULL, 'A1,A2,A3,B', '2016-12-02', '2025-11-29', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(34, 'Ken Kimani', 'Tourism', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(35, 'Esther Chege', 'Finance', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(36, 'William Njoroge', 'Shared Services', 'SMT066', NULL, '2010-07-01', '2026-02-28', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(37, 'Patrick Wanjau', 'Tourism', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(38, 'Solomon Ndirangu', 'Technical Operations', 'SRF021', 'B,C1,C,D1,G,PSV', '2010-04-20', '2026-07-22', 'ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(39, 'Paul Karambu', 'Livestock', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(40, 'Josphat Kimaiyo', 'Technical Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(41, 'Douglas Mutuma', 'Wildlife Operations', 'HTN72', 'B,C1,C', '1998-03-10', '2026-03-27', NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(42, 'Francis Eponga', 'Technical Operations', 'IDL-ABDFS3', 'A2,B', '2019-04-04', '2026-09-09', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(43, 'Stephen Kalokalo', 'Wildlife Operations', 'ZUKOO30000', 'B,C1,C', '2024-07-01', '2027-07-01', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(44, 'Josphat Koskei', 'Wildlife Operations', NULL, NULL, '2024-12-27', '2025-12-27', NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(45, 'Paul Kiptoo', 'Wildlife Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(46, 'Patrick Wanjau', 'Tourism', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(47, 'Charles Kinyua', 'Technical Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(48, 'Stephen ElimLim', 'Technical Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(49, 'Isaac Kinyua', 'Livestock', 'HLK50', 'B,C1,C', '1997-08-12', '2026-02-14', 'OK', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(50, 'Johnstone Mwangi', 'Technical Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(51, 'Paul Some', 'Chimpanzee', NULL, NULL, '2024-12-30', '2027-12-30', NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(52, 'Hussein Matula Samo', 'Security', 'VRZ001', 'B,C1,C,G', '2012-10-03', '2026-06-04', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(53, 'Ndeki Kaparo', 'Security', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(54, 'Joseph Makhasen', 'Security', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(55, 'John Kobia', 'Community Development', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(56, 'Emmanuel Lochakol', 'Tourism', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(57, 'Samuel Ekiru Achilinyang', 'Technical Operations', 'YXL190', 'B,C1,C', '2014-08-29', '2026-04-06', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(58, 'Geoff Wahungu', 'CPO', 'QPE041', 'B,C1,C', '2014-09-28', '2026-04-12', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(59, 'James Elgoi', 'Livestock', 'PHH103', 'B,C1,C2', '2007-12-14', '2025-11-19', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(60, 'Josphat Kipruto', 'Livestock', 'QYZ123', 'B,C1,C', '2009-05-04', '2025-12-06', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(61, 'Patrick Malakwen', 'Technical Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(62, 'John Mumo', 'Technical Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(63, 'Peter Mathenge', 'Wildlife Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(64, 'John Kihiu', 'Technical Operations', 'SVC1640000', 'B,C1,C,G', '2021-01-23', '2026-01-23', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(65, 'David Karia', 'Technical Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(66, 'Benjamin Suge', 'Tourism', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(67, 'Lokitoi Nabwel', 'Livestock', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(68, 'Philip Namashar', 'Livestock', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(69, 'Charles Theuri', 'Technical Operations', NULL, NULL, '2007-03-01', '2026-01-10', NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(70, 'Galgalo Bonaya', 'Technical Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(71, 'Peter Lowoi', 'Technical Operations', NULL, 'B,C1,C,D1,D2,D3,G', '2021-08-18', '2027-07-03', NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(72, 'Brian Njuguna', 'Technical Operations', 'INTERIM', 'INTERIM', '2025-10-09', '2026-04-09', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(73, 'David Kiprono', 'Wildlife Operations', NULL, NULL, '2025-10-09', '2026-04-09', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(74, 'Martin Njogu', 'Technical Operations', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(75, 'Bernard Bundi', 'Technical Operations', 'INTERIM', 'INTERIM', '2025-08-22', '2026-02-22', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(76, 'Patrick Lomelo', 'Technical Operations', 'INTERIM', 'INTERIM', '2025-10-09', '2026-04-09', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(77, 'James Eluwan', 'Technical Operations', 'INTERIM', 'INTERIM', '2025-10-09', '2026-04-09', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(78, 'Brian Kagiri Muhoro', 'Technical Operations', 'INTERIM', 'INTERIM', '2025-10-09', '2026-04-09', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(79, 'John Kariton Lekarsia', 'Technical Operations', 'INTERIM', 'INTERIM', '2025-08-22', '2026-02-22', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(80, 'Ikamucii Lesanga Ranario', 'Wildlife Operations', 'INTERIM', 'INTERIM', '2025-10-09', '2026-04-09', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(81, 'Joseph Muriithi Wanjohi', 'Technical Operations', 'INTERIM', 'INTERIM', '2025-10-09', '2026-04-09', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(82, 'Athony Mwangi Murugi', 'Wildlife Operations', 'INTERIM', 'INTERIM', '2025-10-09', '2026-04-09', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(83, 'Samuel Apetet', 'Wildlife Operations', 'INTERIM', 'INTERIM', '2025-10-09', '2026-04-09', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(84, 'Leasho Safuru Sanguua', 'Wildlife Operations', 'INTERIM', 'INTERIM', '2025-10-09', '2026-04-09', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(85, 'Paul Muthee Tanui', 'Technical Operations', 'INTERIM', 'INTERIM', '2025-10-09', '2026-04-09', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(86, 'William Sigui Lesigel', 'Wildlife Operations', 'INTERIM', 'INTERIM', '2025-10-09', '2026-04-09', 'Interim DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(87, 'Kinyaga ole Saningo', 'Security', 'IDL-AAZXM0', 'C1', '2003-02-02', '2026-02-02', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(88, 'Anthony maina kibet', 'Wildlife Operations', 'XXL83', 'B,C1,C,CE', '2013-12-09', '2026-07-08', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(89, 'Chris Waigwa', 'REMU', 'LIQ178', 'B,C1,C,D1', '2004-10-07', NULL, 'Expired; Licence expiry date in source was invalid (\'2/30/2025\') - needs verification', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(90, 'Nicholus Ruto Enyagan', 'Technical operations', 'IDL-ABDEH4', 'A2,B,G', '2016-01-21', '2026-10-13', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(91, 'Thomas omolo omedo', 'Tourism', 'DL-ASOLO5Q', 'B', '2025-01-14', '2028-01-14', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(92, 'Wilson kipchirchir kiptogom', 'Livestock', 'LUH1940000', 'B,C1,C,D1,D2,D3,G', '2025-01-27', '2028-01-21', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(93, 'Collins karani njogu', 'Community Development', 'INTERIM', 'B,A2', '2025-04-17', '2025-10-17', 'INTERIM DL', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(94, 'Perenges Lepirikine Letagata', 'Security', 'IDL-ACATH7', 'A2', '2023-10-24', '2028-09-15', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(95, 'Apollo Thuku Kimani', 'Tourism', 'MCE9', 'B,C1,C,D1,D2,D3', '2014-09-28', '2025-10-12', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(96, 'Marcel Chelule', 'Livestock', 'KXC024', 'A1,A2,A3,B,C1,C', '2004-03-23', '2026-05-04', 'Ok', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(97, 'Ken Kimani', 'CCO', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(98, 'Stanley  Mwandime', 'Technology', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(99, 'Brian Wanjohi', 'Technology', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(100, 'Nickson Ndiema', 'Technology', NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(101, 'Thomas Bungei', 'Unassigned', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(102, 'Bob Mwangi', 'Wildlife', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(103, 'John Kariton', 'TechOps', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(104, 'Erustus Muirigi', 'TechOps', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(105, 'David', 'Wildlife', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(106, 'Sikoi', 'Wildlife', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(107, 'Joseph Muriithi', 'TechOps', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(108, 'Lucy Wangari', 'Wildlife', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(109, 'James Lepere', 'Livestock', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(110, 'Joel', 'Wildlife', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(111, 'Perenges Lepirkine', 'Security', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(112, 'Martin Mwaniki', 'Technology&Innovations', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(113, 'Guyo Adhi', 'Marketting', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(114, 'James Elogoi', 'Livestock', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(115, 'Stephen Kalu', 'Wildlife', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(116, 'Wilson Kipchirchir', 'Livestock', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(117, 'Hussein Samo', 'Security', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(118, 'Paul Thuku', 'Tourism', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(119, 'Michael Ekai', 'Security', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(120, 'Joseph Makesen', 'Security', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(121, 'Japan', 'Security', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(122, 'Samuel Songok', 'Ecological Monitoring', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(123, 'Christoper Waigwa', 'Ecological Monitoring', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(124, 'Josphat Maina', 'Community', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(125, 'Thomas Omollo', 'Tourism', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(126, 'Samuel Ekiru', 'TechOps', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(127, 'Peter Aboton', 'Livestock', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(128, 'Anthony Maina', 'C-suite', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(129, 'Tabitha Kiarie', 'TechOps', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(130, 'Paul Tanui', 'TechOps', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(131, 'Peter Lowoi/Charles Theuri', 'Security', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(132, 'Nicholus Ruto', 'TechOps', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(133, 'Stephen Kariuki', 'TechOps', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(134, 'Samuel Narieo', 'TechOps', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(135, 'Galgalo Godana', 'Tourism', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(136, 'Lokotoi Nabwel', 'Livestock', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(137, 'Pul Ntanywa', 'TechOps', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(138, 'KENNEDY ETELENG', 'TechOps', NULL, NULL, NULL, NULL, 'Auto-created from vehicle allocation sheet; not present in driver roster.', 1, NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53');

-- --------------------------------------------------------

--
-- Table structure for table `fuel_depot_readings`
--

CREATE TABLE `fuel_depot_readings` (
  `id` int(10) UNSIGNED NOT NULL,
  `reading_date` date NOT NULL,
  `fuel_type` enum('petrol','diesel','kerosene','other') NOT NULL DEFAULT 'diesel',
  `dip_litres` decimal(10,2) NOT NULL,
  `transaction_type` enum('dip_reading','stock_received','fuel_dispensed') NOT NULL DEFAULT 'dip_reading',
  `quantity_litres` decimal(10,2) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `recorded_by` varchar(100) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fuel_logs`
--

CREATE TABLE `fuel_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `vehicle_id` int(10) UNSIGNED NOT NULL,
  `log_date` date NOT NULL,
  `odometer_at_fill` int(10) UNSIGNED NOT NULL,
  `litres_filled` decimal(8,2) NOT NULL,
  `fuel_type` enum('petrol','diesel','hybrid','lpg','kerosene','other') NOT NULL DEFAULT 'diesel',
  `station_location` varchar(120) DEFAULT NULL,
  `cost_per_litre` decimal(10,2) DEFAULT NULL,
  `total_cost` decimal(12,2) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `issuer_name` varchar(100) DEFAULT NULL,
  `receiver_name` varchar(100) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_cards`
--

CREATE TABLE `job_cards` (
  `id` int(10) UNSIGNED NOT NULL,
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
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

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

-- --------------------------------------------------------

--
-- Table structure for table `mechanics`
--

CREATE TABLE `mechanics` (
  `id` int(10) UNSIGNED NOT NULL,
  `employee_id` varchar(30) NOT NULL,
  `full_name` varchar(120) NOT NULL,
  `department` varchar(100) DEFAULT NULL,
  `phone` varchar(40) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `specialisations` text DEFAULT NULL,
  `date_joined` date DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `photo_url` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `odometer_logs`
--

CREATE TABLE `odometer_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `vehicle_id` int(10) UNSIGNED NOT NULL,
  `odometer_reading` int(10) UNSIGNED NOT NULL,
  `location` enum('gate_in','gate_out','workshop','service','fuel','other') NOT NULL DEFAULT 'workshop',
  `notes` text DEFAULT NULL,
  `logged_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `service_records`
--

CREATE TABLE `service_records` (
  `id` int(10) UNSIGNED NOT NULL,
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
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tyre_change_logs`
--

CREATE TABLE `tyre_change_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `vehicle_id` int(10) UNSIGNED NOT NULL,
  `service_record_id` int(10) UNSIGNED DEFAULT NULL,
  `change_date` date NOT NULL,
  `odometer` int(10) UNSIGNED DEFAULT NULL,
  `quantity` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `tyre_name` varchar(100) DEFAULT NULL,
  `tyre_size` varchar(60) DEFAULT NULL,
  `tyre_type` enum('Nylon','Radial','Superlug') NOT NULL DEFAULT 'Radial',
  `expected_lifespan_km` int(10) UNSIGNED DEFAULT NULL,
  `quality_comment` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('admin') NOT NULL DEFAULT 'admin',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password_hash`, `role`, `created_at`) VALUES
(1, 'tabitha', 'tabitha@admin.com', '$2y$10$SXx0B/fpLY/RxNBpPAZjv..4w4xc52P3840yN4E.sV34JYxhdO74a', 'admin', '2026-07-02 04:30:47');

-- --------------------------------------------------------

--
-- Table structure for table `vehicles`
--

CREATE TABLE `vehicles` (
  `id` int(10) UNSIGNED NOT NULL,
  `fleet_number` varchar(30) NOT NULL,
  `registration` varchar(30) NOT NULL,
  `make` varchar(80) NOT NULL,
  `model` varchar(80) NOT NULL,
  `year` smallint(5) UNSIGNED DEFAULT NULL,
  `date_acquired` date DEFAULT NULL,
  `new_gen_plates` tinyint(1) NOT NULL DEFAULT 0,
  `colour` varchar(40) DEFAULT NULL,
  `fuel_type` enum('petrol','diesel','hybrid','electric','lpg','other') NOT NULL DEFAULT 'diesel',
  `body_type` varchar(60) DEFAULT NULL,
  `vehicle_type` enum('car','van','truck','motorbike','construction','trailer','small_engine') NOT NULL DEFAULT 'car',
  `fleet_type` varchar(80) DEFAULT NULL,
  `department` varchar(100) DEFAULT NULL,
  `vin_chassis` varchar(80) DEFAULT NULL,
  `engine_number` varchar(80) DEFAULT NULL,
  `engine_size` varchar(40) DEFAULT NULL,
  `engine_capacity` varchar(40) DEFAULT NULL,
  `transmission` varchar(40) DEFAULT NULL,
  `drive_type` varchar(40) DEFAULT NULL,
  `seating_capacity` smallint(5) UNSIGNED DEFAULT NULL,
  `payload_capacity_kg` int(10) UNSIGNED DEFAULT NULL,
  `tare_weight_kg` int(10) UNSIGNED DEFAULT NULL,
  `gross_weight_kg` int(10) UNSIGNED DEFAULT NULL,
  `logbook_status` enum('available','missing','with_bank','other') DEFAULT NULL,
  `odometer_status` enum('working','not_working') DEFAULT 'working',
  `inspection_status` enum('valid','invalid') DEFAULT NULL,
  `primary_image_url` varchar(255) DEFAULT NULL,
  `tyre_size_standard` varchar(60) DEFAULT NULL,
  `licence_expiry` date DEFAULT NULL,
  `last_service_date` date DEFAULT NULL,
  `next_service_date` date DEFAULT NULL,
  `next_service_mileage` int(10) UNSIGNED DEFAULT NULL,
  `status` enum('active','in_workshop','awaiting_parts','decommissioned') NOT NULL DEFAULT 'active',
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `vehicles`
--

INSERT INTO `vehicles` (`id`, `fleet_number`, `registration`, `make`, `model`, `year`, `date_acquired`, `new_gen_plates`, `colour`, `fuel_type`, `body_type`, `vehicle_type`, `fleet_type`, `department`, `vin_chassis`, `engine_number`, `engine_size`, `engine_capacity`, `transmission`, `drive_type`, `seating_capacity`, `payload_capacity_kg`, `tare_weight_kg`, `gross_weight_kg`, `logbook_status`, `odometer_status`, `inspection_status`, `primary_image_url`, `tyre_size_standard`, `licence_expiry`, `last_service_date`, `next_service_date`, `next_service_mileage`, `status`, `notes`, `created_at`, `updated_at`) VALUES
(1, 'A04', 'KMCB 717M', 'Yamaha', 'XTZ125E', 1997, '1997-11-03', 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Tourism', '3TT-062825', '3TT-062547', NULL, '125', NULL, NULL, 2, 0, 98, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(2, 'A06', 'KMCB715M', 'Yamaha', 'XTZ125E', 1998, '1999-02-16', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', '3TT-0092515', '3TT-0092030', NULL, '125', NULL, NULL, 2, 0, 99, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'awaiting_parts', 'Parked awaiting allocation', '2026-07-02 01:07:53', '2026-07-02 01:12:50'),
(3, 'A09', 'KMCB720M', 'Yamaha', 'DT125', 2004, '2004-12-17', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Wildlife Operations', 'DE02X-0020571', '3TT-0143320', NULL, '125', NULL, NULL, 2, 0, 98, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(4, 'A10', 'KMCB721M', 'Yamaha', 'DT125', 2005, '2005-11-09', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'DE02X-027699', '3TT-150448', NULL, '125', NULL, NULL, 2, 0, 98, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(5, 'A11', 'KMCB723M', 'Yamaha', 'XTZ125', 2005, '2005-11-09', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'DE02X-027506', '3TT-150258', NULL, '125', NULL, NULL, 2, 0, 98, 0, 'available', 'not_working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(6, 'A13', 'KMCB725M', 'Yamaha', 'DT125', 2005, '2005-11-09', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'DEO2X-027709', '3TT-150459', NULL, '125', NULL, NULL, 2, 0, 98, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(7, 'A14', 'KMCB722M', 'Yamaha', 'DT125', 2005, '2005-11-09', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Livestock', 'DE02X-027707', '3TT-150450', NULL, '125', NULL, NULL, 2, 0, 98, 98, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(8, 'A15', 'KMCB727M', 'Yamaha', 'XTZ125E', 2005, '2005-11-09', 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'DE02X-027702', '3TT-150458', NULL, '125', NULL, NULL, 2, 0, 98, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(9, 'A17', 'KMCB716M', 'Yamaha', 'XTZ125E', 2005, '2005-11-09', 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'DE02X-027703', '3TT-150455', NULL, '125', NULL, NULL, 2, 0, 98, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(10, 'A18', 'KMCB726M', 'Yamaha', 'DT125', 2007, '2008-06-04', 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'DE02X-044202', '3TT-166974', NULL, '125', NULL, NULL, 2, 0, 98, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(11, 'A28', 'KMDQ708D', 'Yamaha', 'XTZ125E', 2014, '2015-08-13', 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Wildlife Operations', 'LBPKE179000015439', 'E3N2E-031470', NULL, '125', NULL, NULL, 2, 0, 117, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(12, 'A29', 'KMDQ709D', 'Yamaha', 'XTZ125E', 2014, '2015-08-13', 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Wildlife Operations', 'LBPKE179000005873', 'E3N2E-022822', NULL, '125', NULL, NULL, 2, 0, 117, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(13, 'A30', 'KMDQ710D', 'Yamaha', 'XTZ125E', 2014, '2015-08-15', 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Wildlife Operations', 'LBPKE179000015436', 'E3N2E-031473', NULL, '125', NULL, NULL, 2, 0, 117, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(14, 'A32', 'KMDY736E', 'Yamaha', 'XTZ125E', 2015, '2015-08-10', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Community Develop', 'LBPKE179000020292', 'E3N2E-054018', NULL, '125', NULL, NULL, 2, 0, 117, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(15, 'A33', 'KMDY 729N', 'Yamaha', 'XTZ125E', 2015, '2016-09-14', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Tourism', 'LBPKE179000019540', 'E3N2E-049506', NULL, '125', NULL, NULL, 2, 125, 117, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'in_workshop', 'OK', '2026-07-02 01:07:53', '2026-07-02 05:40:40'),
(16, 'A34', 'KMEE724H', 'Yamaha', 'XTZ125E', 2016, '2017-06-27', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Community Develop', 'LBPKE179000021351', 'E3N2E-057722', NULL, '125', NULL, NULL, 2, 125, 130, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(17, 'A35', 'KMEH677K', 'Yamaha', 'XTZ125E', 2016, '2017-11-20', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Community Develop', 'LBPKE179000021239', 'E3N2E-057456', NULL, '125', NULL, NULL, 2, 125, 130, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(18, 'A36', 'KMCR330V', 'Yamaha', 'XTZ125E', NULL, NULL, 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Community Develop', 'DG01X-032571', '3T5-113540', NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL, 'other', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(19, 'A37', 'KMCA406R', 'Yamaha', 'XTZ125E', 2007, NULL, 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Community Develop', 'DG01X-020602', '3TS-101578', NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL, 'other', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(20, 'A38', 'KMCA408A', 'Yamaha', 'XTZ125E', NULL, NULL, 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Community Develop', 'DG01X-020606', '3TS-101582', NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL, 'other', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(21, 'A39', 'KMEW836S', 'Yamaha', 'XTZ125E', 2018, '2019-07-08', 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'LBPKE179000030383', 'E3N2E-089016', NULL, '125', NULL, NULL, 2, 125, 111, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(22, 'A40', 'KMEX978V', 'Yamaha', 'XTZ125E', 2018, '2019-08-20', 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Wildlife Operations', 'LBPKE179000029410', 'E3N2E-084628', NULL, '125', NULL, NULL, 2, 125, 133, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(23, 'A41', 'KMFB402C', 'KIBO', 'K160', 2019, '2020-01-30', 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'BF9KC3RT1KE003085', 'LC162KIBOKK80900091', NULL, '160', NULL, NULL, 2, 160, 148, 0, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(24, 'A42', 'KMFB403C', 'KIBO', 'K160', 2019, '2020-01-30', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'BF9KC3RT1KE003090', 'LC162KIBOKK80900096', NULL, '160', NULL, NULL, 2, 160, 148, 0, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(25, 'A43', 'KMFN290E', 'Yamaha', 'XTZ125E', 2019, NULL, 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Mutara', 'LBPKE179000032092', 'E3N2E-097988', NULL, '125', NULL, NULL, 2, NULL, 109, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(26, 'A44', 'KMFN291E', 'Yamaha', 'XTZ125E', 2019, '2021-02-04', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Mutara', 'LBPKE179000032071', 'E3N2E-097969', NULL, '125', NULL, NULL, 2, 125, 109, 0, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(27, 'A45', 'KMFV321E', 'Yamaha', 'XTZ125E', 2019, NULL, 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Mutara', 'LBPKE179000003625', 'E3N2E-016056', NULL, '125', NULL, NULL, 2, NULL, 109, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(28, 'A46', 'KMGB728G', 'Yamaha', 'XTZ125E', 2023, '2023-01-19', 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Wildlife Operations', 'LBPKE179000035989', 'E3N2E-116667', NULL, '125', NULL, NULL, 2, 0, 109, 0, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(29, 'A47', 'KMGK589N', 'Yamaha', 'XTZ125E', 2023, NULL, 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Livestock', 'LBPKE179000043270', 'E3N2E-148089', NULL, '125', NULL, NULL, 2, NULL, 109, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(30, 'A48', 'KMGN222L', 'Yamaha', 'XTZ125E', 2024, NULL, 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Wildlife Operations', 'LBPKE179000044419', 'E3N2E-155077', NULL, '125', NULL, NULL, 2, NULL, 109, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(31, 'A49', 'KMGN994S', 'Yamaha', 'XTZ125E', 2024, NULL, 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Wildlife Operations', 'LBPKE179000044248', 'E3N2E-155223', NULL, '125', NULL, NULL, 2, NULL, 109, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(32, 'A50', 'KMGN995S', 'Yamaha', 'XTZ125E', 2024, NULL, 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Wildlife Operations', 'LBPKE179000044251', 'E3N2E-155204', NULL, '125', NULL, NULL, 2, NULL, 109, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(33, 'A51', 'KMGP686Q', 'Yamaha', 'XTZ125', 2024, '2025-01-11', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'LBPKE179000045274', 'E3N2E-160919', NULL, '125', NULL, NULL, 2, 130, 109, 239, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(34, 'A52', 'KMGP692Q', 'Yamaha', 'XTZ125', 2024, '2025-01-11', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Community Development', 'LBPKE179000045268', 'E3N2E-160930', NULL, '125', NULL, NULL, 2, 130, 109, 239, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(35, 'A53', 'KMGP684Q', 'Yamaha', 'XTZ125', 2024, '2025-01-11', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Community Development', 'LBPKE179000045265', 'E3N2E-160932', NULL, '125', NULL, NULL, 2, 130, 109, 239, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(36, 'A54', 'KMGP682Q', 'Yamaha', 'XTZ125', 2024, '2025-01-11', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'LBPKE179000045269', 'E3N2E-160934', NULL, '125', NULL, NULL, 2, 130, 109, 239, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(37, 'A55', 'KMGP678Q', 'Yamaha', 'XTZ125', 2024, '2025-01-11', 0, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'LBPKE179000045272', 'E3N2E-160935', NULL, '125', NULL, NULL, 2, 130, 109, 239, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(38, 'A56', 'KMGP688Q', 'Yamaha', 'XTZ125', 2024, '2025-01-11', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'LBPKE179000045282', 'E3N2E-160942', NULL, '125', NULL, NULL, 2, 130, 109, 239, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(39, 'A57', 'KMGP690Q', 'Yamaha', 'XTZ125', 2024, '2025-01-11', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'LBPKE179000045277', 'E3N2E-160943', NULL, '125', NULL, NULL, 2, 130, 109, 239, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(40, 'A58', 'KMGP693Q', 'Yamaha', 'XTZ125', 2024, '2025-01-11', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Wildlife Operations', 'LBPKE179000045281', 'E3N2E-160945', NULL, '125', NULL, NULL, 2, 130, 109, 239, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(41, 'A59', 'KMGP687Q', 'Yamaha', 'XTZ125E', 2024, '2025-01-11', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Wildlife Operations', 'LBPKE179000045284', 'E3N2E-160946', NULL, '125', NULL, NULL, 2, 130, 109, 239, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(42, 'A60', 'KMGP691Q', 'Yamaha', 'XTZ125', 2024, '2025-01-11', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'LBPKE179000045306', 'E3N2E-160966', NULL, '125', NULL, NULL, 2, 130, 109, 239, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(43, 'A61', 'KMGP681Q', 'Yamaha', 'XTZ125', 2024, '2025-01-11', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Livestock', 'LBPKE179000044441', 'E3N2E-160981', NULL, '125', NULL, NULL, 2, 130, 109, 239, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(44, 'A62', 'KMGP685Q', 'Yamaha', 'XTZ125', 2024, '2025-01-11', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Livestock', 'LBPKE179000045327', 'E3N2E-160992', NULL, '125', NULL, NULL, 2, 130, 109, 239, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'in_workshop', 'OK', '2026-07-02 01:07:53', '2026-07-02 05:38:02'),
(45, 'A63', 'KMGP689Q', 'Yamaha', 'XTZ125', 2024, '2025-01-11', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'LBPKE179000045332', 'E3N2E-160994', NULL, '125', NULL, NULL, 2, 130, 109, 239, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(46, 'A64', 'KMGP683Q', 'Yamaha', 'XTZ125', 2024, '2025-01-11', 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Technical Operations', 'LBPKE179000045348', 'E3N2E-161008', NULL, '125', NULL, NULL, 2, 130, 109, 239, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'Ok', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(47, 'A65', 'KMGU 766Y', 'Yamaha', 'DT175', NULL, NULL, 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Wildlife Operations', 'JYADG01X000068923', '3TS-149973', NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(48, 'A66', 'KMGU 767Y', 'Yamaha', 'DT175', NULL, NULL, 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', 'Wildlife Operations', 'JTADG01X000068925', '3TS-149977', NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'Ok', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(49, 'A67', 'Awaiting from dealer', 'TVS', 'TVS125', NULL, NULL, 1, NULL, 'petrol', 'Motorcycle', 'motorbike', '2 Wheels', NULL, 'DF4KS1521789', NULL, NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(50, 'B06', 'KCL 697W', 'Subaru Forrestor', 'SHJ', 2011, '2017-06-02', 1, NULL, 'petrol', 'Passenger', 'car', 'Light vehicle', 'Tourism', 'SHJ-004179', 'FB20-R042782', NULL, '1990', NULL, NULL, 5, 275, 1450, 1725, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(51, 'B07', 'KCR 056L', 'Subaru Forrestor', 'SHJ', 2018, NULL, 0, NULL, 'petrol', 'Passenger', 'car', 'Light vehicle', 'Technology', 'SHJ-007157', 'FB20-R082657', '4 Cylinder', NULL, NULL, 'AWD', 5, NULL, NULL, NULL, 'other', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(52, 'B08', 'KDR 091M', 'Subaru Forrestor', 'SJ5', 2023, '2025-10-07', 1, NULL, 'petrol', 'Passenger', 'car', 'Light vehicle', 'Finance', 'SJ5_108834', 'FB20-YA30878', '4 Cylinder', '1990', NULL, 'AWD', 5, 275, 1510, 1785, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(53, 'B09', 'KDR 097M', 'Subaru Forrestor', 'SJ5', 2023, '2025-10-07', 1, NULL, 'petrol', 'Passenger', 'car', 'Light vehicle', 'Shared Services', 'SJ5-102630', 'FB20-Y680125', '4 Cylinder', '1190', NULL, 'AWD', 5, 275, 1510, 1785, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(54, 'B10', 'KDU234X', 'Suzuki  Jimny', 'Jimny Sierra', 2019, '2025-08-08', 1, NULL, 'petrol', 'Passenger', 'car', 'Light vehicle', 'Fundraising', 'JB74W-104387', 'K15B-1017523', '4 Cylinder', '1460', NULL, '4WD', 5, 220, 1090, 1310, 'available', 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(55, 'B11', 'KDW883A', 'Suzuki  Jimny', 'Jimny  Maruti', 2025, NULL, 1, NULL, 'petrol', 'Small van', 'van', 'Small van', 'Marketting', 'MA3JJC74W00233689', 'K15BN-4461009', '4 Cylinder', '1460', NULL, '4WD', 5, 1460, NULL, 1440, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(56, 'D09', 'KAT198Q', 'Toyota Land Cruiser', 'HZJ79', 2004, '2005-03-23', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Technical Operations', 'HZJ79-7044007', '1HZ0468951', '8 Cylinder', '4146', NULL, '4WD', 2, 0, 2170, 2170, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'in_workshop', 'OK', '2026-07-02 01:07:53', '2026-07-02 05:55:13'),
(57, 'D12', 'KAT 202Q', 'Toyota Land Cruiser', 'H2579', 2004, '2005-03-24', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Livestock', 'HZJ79-7044092', '1HZ0469204', '8 Cylinder', '4164', NULL, '4WD', 2, 1100, 2100, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(58, 'D14', 'KAT 204Q', 'Toyota Land Cruiser', 'H2579', 2004, '2005-03-24', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Technical Operations', 'HZJ79-7044094', 'IHZ0469255', '8 Cylinder', '4164', NULL, '4WD', 2, 1100, 2100, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(59, 'D15', 'KAU 056G', 'Toyota Land Cruiser', 'H2J79', 2005, '2005-07-29', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Wildlife Operations', 'JTELB71J10-7047418', '1HZ-0482174', '8 Cylinder', '4164', NULL, '4WD', 2, 1030, 2170, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(60, 'D24', 'KCE 659V', 'Toyota Land Cruiser', 'HZJ79R', 2014, '2015-09-15', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Wildlife Operations', 'JTELB71J90-7724750', '1HZ-0802671', '8 Cylinder', '4164', NULL, '4WD', 2, 1050, 1600, 2650, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(61, 'D26', 'KCN 464N', 'Toyota Land Cruiser', 'HZJ79R', 2017, '2017-11-22', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Wildlife Operations', 'JTELB71J70-7726125', '1HZ-0882029', '8 Cylinder', '4164', NULL, '4WD', 2, 1030, 2170, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(62, 'D27', 'KCN 470N', 'Toyota Land Cruiser', 'HZJ79R', 2017, '2017-11-22', 1, NULL, 'diesel', 'Passenger', 'truck', 'Light vehicle', 'Wildlife Operations', 'JTELB71J70-7725976', '1HZ-0878806', '8 Cylinder', '4164', NULL, '4WD', 5, 2170, 1030, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(63, 'D32', 'KCR 584W', 'Toyota Land Cruiser', 'HZJ79R', 2018, '2018-09-20', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Livestock', 'JTELB71J80-7727378', '1HZ-0903530', '8 Cylinder', '4164', NULL, '4WD', 2, 1030, 2170, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(64, 'D33', 'KCR 585W', 'Toyota Land Cruiser', 'HZJ79R', 2018, '2018-09-20', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Technical Operations', 'JTELB71J60-7727377', '1HZ-0903529', '8 Cylinder', '4164', NULL, '4WD', 2, 1030, 2170, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(65, 'D34', 'KCR 730T', 'Toyota Land Cruiser', 'LANDCRUISER', 2018, '2018-09-05', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'CHIMPS', 'JTELB71J50-7727435', '1HZ-0904542', '8 Cylinder', '4164', NULL, '4WD', 2, 1030, 2170, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(66, 'D35', 'KCR738T', 'Toyota Land Cruiser', 'LANDCRUISER', 2018, '2018-09-05', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Security', 'JTELB71J30-7727434', '1HZ-0904541', '8 Cylinder', '4164', NULL, '4WD', 2, 1030, 2170, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(67, 'D36', 'KBU 548Q', 'Toyota Land Cruiser', 'HZJ79', 2012, '2013-04-08', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Tourism', 'JTELB71J20-7722600', '1HZ_0725905', '8 Cylinder', '4164', NULL, NULL, 2, 600, 2600, 0, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'awaiting_parts', 'OK', '2026-07-02 01:07:53', '2026-07-02 05:34:54'),
(68, 'D37', 'KDB 096U', 'Toyota Land Cruiser', 'LANDCRUISER', 2019, '2021-02-05', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Security', 'JTELB71J207740854', '1HZ-0940758', '8 Cylinder', '4164', NULL, '4WD', 2, 1030, 2170, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(69, 'D38', 'KDB 201Y', 'Toyota Land Cruiser', 'LANDCRUISER', 2020, '2021-02-24', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Security', 'JTELB71J907741001', '1HZ-0946535', '8 Cylinder', '4164', NULL, '4WD', 2, 1030, 2170, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(70, 'D39', 'KDE 450C', 'Toyota Land Cruiser', 'Landcruiser', 2021, '2021-09-23', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'REMU', 'JTELB71JX07741301', '1HZ-0976929', '8 Cylinder', '4164', NULL, '4WD', 2, 1030, 2170, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(71, 'D40', 'KDN019H', 'Toyota Land Cruiser', 'LANDCRUISER', 2023, '2023-10-09', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Community Develop', 'JTELV73J407740343', '1VD-0632116', '8 Cylinder', '4461', NULL, '4WD', 2, 1030, 2092, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(72, 'D41', 'KDN120J', 'Toyota Land Cruiser', 'LANDCRUISER', 2023, '2023-10-18', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Technical Operations', 'JTELV73J607740375', '1VD-0632852', '8 Cylinder', '4461', NULL, '4WD', 2, 1030, 2092, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(73, 'D42', 'KDN279K', 'Toyota Land Cruiser', 'LANDCRUISER', 2023, '2023-10-25', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Tourism', 'JTELV73J707740336', '1VD-0632072', '8 Cylinder', '4461', NULL, '4WD', 2, 1030, 2092, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(74, 'D43', 'KDP 403Y', 'Toyota Land Cruiser', 'LANDCRUISER', 2024, NULL, 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Tourism', 'JTELV73J807740636', '1VD0645655', '8 Cylinder', '4461', NULL, '4WD', 2, 1030, 2170, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(75, 'D44', 'KDQ 249C', 'Toyota Land Cruiser', 'LANDCRUISER', 2024, NULL, 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Technical Operations', 'JTELV73J907740578', '1VD0644838', '8 Cylinder', '4461', NULL, '4WD', 2, 1030, 2170, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(76, 'D45', 'KAU 580J', 'Toyota Land Cruiser', 'LANDCRUISER', 2005, '2024-07-01', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Livestock', 'JTELB7115900-7047618', 'IHZ-0482957', '8 Cylinder', '4164', NULL, '4WD', 2, 1000, 2200, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(77, 'D46', 'KDR 810E', 'Toyota Land Cruiser', 'LANDCRUISER', 2023, '2024-08-01', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Wildlife Operations', 'JTELV73JX07740833', '1VD0649088', '8 Cylinder', '4461', NULL, '4WD', 2, 1030, 2170, 3200, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(78, 'D47', 'KDV551Q', 'Toyota Land Cruiser', 'LANDCRUISER', 2025, NULL, 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Technical Operations', 'JTELR71J007740413', '1GD-9546816', '8 Cylinder', '2800', NULL, '4WD', 2, 1030, 2150, 3180, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(79, 'D48', 'KDV547Q', 'Toyota Land Cruiser', 'LANDCRUISER', NULL, NULL, 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Technical Operations', 'JTELR71J307740406', '1GD-9548096', '8 Cylinder', '2800', NULL, '4WD', 2, 1030, 2150, 3180, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(80, 'D49', 'KDW405T', 'I+C83:S90suzu D-MAX', 'Isuzu', 2026, '2026-03-27', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Technical Operations', 'MPATFS87JRL009172', 'FJW729', '4 Cylinder', '1900', NULL, '4WD', 2, 1200, 1600, 2800, 'with_bank', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(81, 'D50', 'KDW406T', 'Isuzu D-MAX', 'Isuzu', 2026, '2026-03-27', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Supply Chain', 'MPATFS87JRL009173', 'FJW730', '4 Cylinder', '1900', NULL, '4WD', 2, 1200, 1600, 2800, 'with_bank', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(82, 'D51', 'KDW407T', 'Isuzu D-MAX', 'Isuzu', 2026, '2026-03-27', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Technology', 'MPATFS87JRL009174', 'FJW731', '4 Cylinder', '1900', NULL, '4WD', 2, 1200, 1600, 2800, 'with_bank', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(83, 'D52', 'KDW408T', 'Isuzu D-MAX', 'Isuzu', 2026, '2026-03-27', 1, NULL, 'diesel', 'Pickup', 'truck', 'Light vehicle', 'Community Department', 'MPATFS87JRL009175', 'FJW732', '4 Cylinder', '1900', NULL, '4WD', 2, 1200, 1600, 2800, 'with_bank', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(84, 'G02', 'KAV 964Q', 'Isuzu', 'NQR66', 2005, '2006-05-30', 1, NULL, 'diesel', 'Insulated body', 'truck', 'Truck', 'Livestock', 'JAAN1R66R47100201', '220409', NULL, '4300', NULL, NULL, 2, 3900, 4100, 8000, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(85, 'G04', 'KDP814E', 'Isuzu', 'NQR81K', 2023, '2024-01-25', 1, NULL, 'diesel', 'Insulated body', 'truck', 'Truck', 'Livestock', 'JAAN1R81KN7100810', 'OTG285', NULL, '4778', NULL, NULL, 2, 6000, 2000, 8000, 'available', 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(86, 'K03', 'KAU 426V', 'Tata', 'TIPPER', 2005, '2005-11-25', 1, NULL, 'diesel', 'Tipper', 'truck', 'Truck', 'Earthworks', 'TATA-07661', '8346', NULL, '5883', NULL, NULL, NULL, 6900, 5300, 12200, 'available', 'working', 'invalid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(87, 'K08', 'KAU 460S', 'Tata', 'TIPPER', 2005, '2005-11-18', 1, NULL, 'diesel', 'Tipper', 'truck', 'Truck', 'Earthworks', 'MAT42409252R07692', '8128', NULL, '5883', NULL, NULL, NULL, 6900, 5300, 12200, 'available', 'working', 'invalid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(88, 'K11', 'FN520VL', 'MAN', 'MAN', NULL, NULL, 0, NULL, 'diesel', 'Capture truck', 'truck', 'Truck', 'Wildlife Operations', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'other', 'working', 'invalid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(89, 'K12', 'KDP124C', 'Tata', 'Tipper', 2023, '2005-09-18', 1, NULL, 'diesel', 'Tipper', 'truck', 'Truck', 'Technical Operations (Buildings)', NULL, 'Cummins ISBE', NULL, '5883', NULL, NULL, NULL, 15000, 10000, 25000, NULL, 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(90, 'M01', 'KHMA 869B', 'CAT', '140H', 1991, '2012-12-21', 1, NULL, 'diesel', 'Motor Grader', 'construction', 'Heavy Plant', 'Earthworks', '2ZK04630', '6NC17180', NULL, '10500', NULL, NULL, NULL, 0, 17237, 0, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'in_workshop', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(91, 'M02', 'KHMA887B', 'CAT', '320BL', 1998, '1998-01-10', 1, NULL, 'diesel', 'Tracked BH Excavator', 'construction', 'Heavy Plant', 'Earthworks', '7JR01355', '4TF46923', NULL, '6400', NULL, NULL, NULL, 0, 21380, 0, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(92, 'M04', 'KHMA 886B', 'CAT', '428C', 2013, '2013-01-10', 0, NULL, 'diesel', 'Backhoe Loader', 'construction', 'Heavy Plant', 'Earthworks', '2CR04800', '1HZ-0482193', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'in_workshop', 'OK', '2026-07-02 01:07:53', '2026-07-02 05:28:42'),
(93, 'M05', 'KHMA 888B', 'CAT', '953C', 1998, '1998-01-10', 1, NULL, 'diesel', 'Tracked Front End Loader', 'construction', 'Heavy Plant', 'Earthworks', '2ZN02048', '4TF46753', NULL, '7200', NULL, NULL, NULL, 0, 14000, 0, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(94, 'M06', 'CAT D06H', 'CAT', 'D6H', NULL, NULL, 0, NULL, 'diesel', 'Dozer', 'construction', 'Heavy Plant', 'Earthworks', 'IKD00472', '1HZ-0482195', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(95, 'M07', 'KMHA885B', 'CAT', '533E', NULL, NULL, 0, NULL, 'diesel', 'Vibro Drum Roller', 'construction', 'Heavy Plant', 'Earthworks', 'ASL00723', '1HZ-0482196', NULL, '6600', NULL, NULL, NULL, 0, 12000, 0, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(96, 'P06', 'KTCB 249U', 'Valtra', 'VALTRA', 2006, '2017-07-06', 0, NULL, 'diesel', 'Tractor', 'construction', 'Tractor', 'Livestock', 'V950435882', 'GMD162039', NULL, '4400', NULL, NULL, NULL, 4400, 3590, 0, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(97, 'P07', 'KTCB 545N', 'Case', '10727000_JX90', NULL, NULL, 0, NULL, 'diesel', 'Tractor', 'construction', 'Tractor', 'Livestock', 'HFA117862', '284269', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(98, 'P08', 'KTCC360A', 'Kubota', 'Kubota', 2018, '2020-09-14', 1, NULL, 'diesel', 'Tractor', 'construction', 'Tractor', 'Livestock', '15620', '2JS3302', NULL, '3769', NULL, NULL, NULL, 10000, 3313, 13313, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(99, 'P09', 'KTCC 685L', 'Case', 'JXM90', 2024, NULL, 1, NULL, 'diesel', 'Tractor', 'construction', 'Tractor', 'Technical Operations', 'FR1675811', NULL, NULL, '3908', NULL, NULL, NULL, 3908, 3600, 7508, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(100, 'P10', 'KTCC 686L', 'Case', 'JXM90', 2024, NULL, 1, NULL, 'diesel', 'Tractor', 'construction', 'Tractor', 'Technical Operations', 'FR1675813', NULL, NULL, '3908', NULL, NULL, NULL, 3908, 3600, 7508, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'To check', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(101, 'P11', 'KTCC336N', 'Kubota', 'JXM90', 2025, NULL, 1, NULL, 'diesel', 'Tractor', 'construction', 'Tractor', 'Technical Operations', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(102, 'P12', 'KTCC337N', 'Kubota', 'JXM90', 2025, NULL, 0, NULL, 'diesel', NULL, 'car', NULL, 'Livestock', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(103, 'T01', 'KAN 336V', 'Isuzu', 'NKR66L', 2001, '2001-10-22', 1, NULL, 'diesel', 'Bus', 'van', 'Bus', 'Technical Operations', '7100563', '844855', NULL, '3250', NULL, NULL, NULL, 0, 2750, 0, NULL, 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(104, 'T03', 'KCJ 464L', 'Isuzu', 'FRR', 2016, '2016-09-28', 1, NULL, 'diesel', 'Bus', 'van', 'Bus', 'Technical Operations', 'JALFRR33LF7001583', '483249', NULL, '8226', NULL, NULL, NULL, 5400, 5000, 10400, NULL, 'working', 'valid', NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(105, 'T04', 'KDX801L', 'Isuzu', 'FVR34', 2026, '2026-04-04', 1, NULL, 'diesel', 'Bus', 'van', 'Bus', 'Technical Operations', 'JALFVR34SR7000076', 'AA6474', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(106, 'W13', 'KTWB395B', 'DAYUN', 'DY 200ZH', 2015, NULL, 0, NULL, 'petrol', 'Carrier', 'small_engine', 'Tuk Tuk', NULL, 'L7GSCMZY8F308837', 'DY163FMLF6547299', NULL, '150', NULL, NULL, NULL, 416, 434, 850, NULL, 'not_working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'decommissioned', NULL, '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(107, 'W15', 'KTCW144X', 'DAYUN', 'DY250HZ', NULL, NULL, 0, NULL, 'petrol', 'Carrier', 'small_engine', 'Tuk Tuk', NULL, 'L7G5DNZY7N', 'L7G5DNZY7N1516766', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(108, 'W16', 'KTCW153X', 'DAYUN', 'DY250HZ', NULL, NULL, 0, NULL, 'petrol', 'Carrier', 'small_engine', 'Tuk Tuk', NULL, 'L7G5DNZY7N', 'L7G5DNZY7N1516767', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(109, 'W17', 'KTCW193X', 'DAYUN', 'DY250HZ', NULL, NULL, 0, NULL, 'petrol', 'Carrier', 'small_engine', 'Tuk Tuk', NULL, 'L7G5DNZY7N', 'L7G5DNZY7N1516768', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'not_working', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'active', 'OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53');

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_change_logs`
--

CREATE TABLE `vehicle_change_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `vehicle_id` int(10) UNSIGNED NOT NULL,
  `changed_by` varchar(100) NOT NULL DEFAULT 'admin',
  `field_name` varchar(80) NOT NULL,
  `old_value` text DEFAULT NULL,
  `new_value` text DEFAULT NULL,
  `changed_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_driver_assignments`
--

CREATE TABLE `vehicle_driver_assignments` (
  `id` int(10) UNSIGNED NOT NULL,
  `vehicle_id` int(10) UNSIGNED NOT NULL,
  `driver_id` int(10) UNSIGNED NOT NULL,
  `role` enum('primary','reliever') NOT NULL DEFAULT 'primary',
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `vehicle_driver_assignments`
--

INSERT INTO `vehicle_driver_assignments` (`id`, `vehicle_id`, `driver_id`, `role`, `start_date`, `end_date`, `is_active`, `notes`, `created_at`, `updated_at`) VALUES
(1, 1, 101, 'primary', '2026-07-02', NULL, 1, 'Designation: Plumber; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(2, 3, 102, 'primary', '2026-07-02', NULL, 1, 'Designation: Armed Ranger; Allocation-sheet status: UNDER REPAIR; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(3, 4, 74, 'primary', '2026-07-02', NULL, 1, 'Designation: Fencer; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(4, 5, 103, 'primary', '2026-07-02', NULL, 1, 'Designation: Fencer; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(5, 6, 2, 'primary', '2026-07-02', NULL, 1, 'Designation: Fencer; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(6, 8, 5, 'primary', '2026-07-02', NULL, 1, 'Designation: Carpenter; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(7, 9, 6, 'primary', '2026-07-02', NULL, 1, 'Designation: Electrician; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(8, 10, 1, 'primary', '2026-07-02', NULL, 1, 'Designation: Fence Supervisor; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(9, 11, 8, 'primary', '2026-07-02', NULL, 1, 'Designation: Sector-head; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(10, 12, 102, 'primary', '2026-07-02', NULL, 1, 'Designation: Armed patrol man; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(11, 14, 10, 'primary', '2026-07-02', NULL, 1, 'Designation: Teacher Support Officer; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(12, 15, 11, 'primary', '2026-07-02', NULL, 1, 'Designation: Airstrip Attendant; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(13, 16, 12, 'primary', '2026-07-02', NULL, 1, 'Designation: Conservation Education; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(14, 18, 13, 'primary', '2026-07-02', NULL, 1, 'Designation: Livestock Extension Cooridnator; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(15, 21, 104, 'primary', '2026-07-02', NULL, 1, 'Designation: Gardener; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(16, 22, 105, 'primary', '2026-07-02', NULL, 1, 'Designation: Armed patrol man; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(17, 23, 15, 'primary', '2026-07-02', NULL, 1, 'Designation: Senior Supervisor Fence; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(18, 24, 16, 'primary', '2026-07-02', NULL, 1, 'Designation: Water Supervisor; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(19, 25, 17, 'primary', '2026-07-02', NULL, 1, 'Designation: Armed patrol man; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(20, 26, 18, 'primary', '2026-07-02', NULL, 1, 'Designation: MCA; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(21, 27, 106, 'primary', '2026-07-02', NULL, 1, 'Designation: MCA; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(22, 28, 19, 'primary', '2026-07-02', NULL, 1, 'Designation: Armed Ranger; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(23, 29, 4, 'primary', '2026-07-02', NULL, 1, 'Designation: Animal Health Technician; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(24, 30, 20, 'primary', '2026-07-02', NULL, 1, 'Designation: PatrolMan; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(25, 32, 22, 'primary', '2026-07-02', NULL, 1, 'Designation: Sector Head; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(26, 33, 23, 'primary', '2026-07-02', NULL, 1, 'Designation: Plumber; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(27, 34, 24, 'primary', '2026-07-02', NULL, 1, 'Designation: Agriculture Extension Officer; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(28, 35, 25, 'primary', '2026-07-02', NULL, 1, 'Designation: Agriculture Coordinator; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(29, 36, 26, 'primary', '2026-07-02', NULL, 1, 'Designation: Plumber; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(30, 37, 27, 'primary', '2026-07-02', NULL, 1, 'Designation: TBA; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(31, 38, 107, 'primary', '2026-07-02', NULL, 1, 'Designation: Electrician; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(32, 39, 7, 'primary', '2026-07-02', NULL, 1, 'Designation: Supervisor fence; Allocation-sheet status: Operational; Comment: OK; REVIEW: name matches >1 roster entry, could not disambiguate confidently', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(33, 40, 108, 'primary', '2026-07-02', NULL, 1, 'Designation: Armed patrol man; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(34, 41, 83, 'primary', '2026-07-02', NULL, 1, 'Designation: Armed patrol man; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(35, 42, 29, 'primary', '2026-07-02', NULL, 1, 'Designation: electrician; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(36, 43, 109, 'primary', '2026-07-02', NULL, 1, 'Designation: Livestock Supervisor; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(37, 44, 31, 'primary', '2026-07-02', NULL, 1, 'Designation: Livestock Vet; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(38, 45, 32, 'primary', '2026-07-02', NULL, 1, 'Designation: Plumber; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(39, 46, 33, 'primary', '2026-07-02', NULL, 1, 'Designation: Building Supervisor; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(40, 47, 21, 'primary', '2026-07-02', NULL, 1, 'Designation: TIU Officer; Allocation-sheet status: Operational; Comment: Ok', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(41, 48, 110, 'primary', '2026-07-02', NULL, 1, 'Designation: Sector Head; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(42, 49, 111, 'primary', '2026-07-02', NULL, 1, 'Designation: KPR; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(43, 50, 97, 'primary', '2026-07-02', NULL, 1, 'Designation: Chief Commercial Officer; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(44, 51, 112, 'primary', '2026-07-02', NULL, 1, 'Designation: Technology; Manager; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(45, 52, 35, 'primary', '2026-07-02', NULL, 1, 'Designation: Head of Accounts; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(46, 52, 112, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(47, 53, 36, 'primary', '2026-07-02', NULL, 1, 'Designation: Head of Shared Services; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(48, 54, 113, 'primary', '2026-07-02', NULL, 1, 'Designation: Director Communications & Marketing; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(49, 56, 37, 'primary', '2026-07-02', NULL, 1, 'Designation: Senior Tourism Field Officer; Allocation-sheet status: Operational; Comment: OK; REVIEW: name matches >1 roster entry, could not disambiguate confidently', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(50, 56, 66, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(51, 57, 39, 'primary', '2026-07-02', NULL, 1, 'Designation: Livestock  Driver; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(52, 57, 114, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(53, 58, 40, 'primary', '2026-07-02', NULL, 1, 'Designation: Technical Operations Driver; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(54, 59, 41, 'primary', '2026-07-02', NULL, 1, 'Designation: Wildlife Operations Drivers (Day / Night); Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(55, 60, 43, 'primary', '2026-07-02', NULL, 1, 'Designation: Wildlife Operations Drivers (Day / Night); Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(56, 61, 44, 'primary', '2026-07-02', NULL, 1, 'Designation: Wildlife Operations Drivers (Day / Night); Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(57, 61, 115, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(58, 62, 45, 'primary', '2026-07-02', NULL, 1, 'Designation: Wildlife Operations Drivers (Day / Night); Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(59, 62, 44, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(60, 63, 49, 'primary', '2026-07-02', NULL, 1, 'Designation: Livestock  Driver; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(61, 63, 116, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(62, 64, 16, 'primary', '2026-07-02', NULL, 1, 'Designation: Team leader, Water; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(63, 64, 47, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(64, 65, 51, 'primary', '2026-07-02', NULL, 1, 'Designation: Chimps Driver; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(65, 66, 117, 'primary', '2026-07-02', NULL, 1, 'Designation: Security Driver; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(66, 66, 63, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(67, 67, 118, 'primary', '2026-07-02', NULL, 1, 'Designation: Tourism Driver; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(68, 67, 66, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(69, 68, 119, 'primary', '2026-07-02', NULL, 1, 'Designation: Securiry Driver; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(70, 68, 53, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(71, 69, 120, 'primary', '2026-07-02', NULL, 1, 'Designation: Security Driver; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(72, 69, 121, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(73, 70, 122, 'primary', '2026-07-02', NULL, 1, 'Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(74, 70, 123, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(75, 71, 55, 'primary', '2026-07-02', NULL, 1, 'Designation: CDP Driver; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(76, 71, 124, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(77, 72, 50, 'primary', '2026-07-02', NULL, 1, 'Designation: TechOps Driver; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(78, 72, 40, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(79, 73, 56, 'primary', '2026-07-02', NULL, 1, 'Designation: Tourism Field Officer; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(80, 73, 125, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(81, 74, 37, 'primary', '2026-07-02', NULL, 1, 'Designation: Tourism Field Officer; Allocation-sheet status: Operational; Comment: OK; REVIEW: name matches >1 roster entry, could not disambiguate confidently', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(82, 74, 96, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(83, 75, 126, 'primary', '2026-07-02', NULL, 1, 'Designation: Team Lead Earthworks; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(84, 75, 65, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(85, 76, 96, 'primary', '2026-07-02', NULL, 1, 'Designation: Livestock coordinator; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(86, 76, 127, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(87, 77, 58, 'primary', '2026-07-02', NULL, 1, 'Designation: Chief Programs Officer; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(88, 77, 128, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(89, 78, 42, 'primary', '2026-07-02', NULL, 1, 'Designation: Mason; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(90, 78, 33, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(91, 79, 129, 'primary', '2026-07-02', NULL, 1, 'Designation: Manager, workshop; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(92, 79, 130, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(93, 84, 114, 'primary', '2026-07-02', NULL, 1, 'Designation: Meat Van Driver; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(94, 84, 60, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(95, 85, 60, 'primary', '2026-07-02', NULL, 1, 'Designation: Meat Van Driver; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(96, 85, 114, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(97, 86, 61, 'primary', '2026-07-02', NULL, 1, 'Designation: Truck Driver; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(98, 86, 40, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(99, 87, 62, 'primary', '2026-07-02', NULL, 1, 'Designation: Truck Driver; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(100, 87, 40, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(101, 88, 63, 'primary', '2026-07-02', NULL, 1, 'Designation: Truck Driver; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(102, 88, 131, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(103, 89, 71, 'primary', '2026-07-02', NULL, 1, 'Designation: Truck Driver; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(104, 89, 69, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(105, 90, 65, 'primary', '2026-07-02', NULL, 1, 'Designation: Plant Operator; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(106, 90, 64, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(107, 91, 69, 'primary', '2026-07-02', NULL, 1, 'Designation: Plant Operator; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(108, 91, 64, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(109, 92, 132, 'primary', '2026-07-02', NULL, 1, 'Designation: Plant Operator; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(110, 92, 133, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(111, 93, 64, 'primary', '2026-07-02', NULL, 1, 'Designation: Plant Operator; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(112, 94, 64, 'primary', '2026-07-02', NULL, 1, 'Designation: Plant Operator; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(113, 94, 64, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(114, 95, 133, 'primary', '2026-07-02', NULL, 1, 'Designation: Plant Operator; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(115, 95, 65, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(116, 96, 127, 'primary', '2026-07-02', NULL, 1, 'Designation: Tractor Drivers; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(117, 96, 68, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(118, 97, 68, 'primary', '2026-07-02', NULL, 1, 'Designation: Tractor Drivers; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(119, 97, 116, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(120, 98, 66, 'primary', '2026-07-02', NULL, 1, 'Designation: Tractor Drivers; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(121, 98, 136, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(122, 99, 137, 'primary', '2026-07-02', NULL, 1, 'Designation: Plant/Tractor Drivers; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(123, 99, 133, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(124, 100, 70, 'primary', '2026-07-02', NULL, 1, 'Designation: Tractor Drivers; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(125, 100, 134, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(126, 101, 116, 'primary', '2026-07-02', NULL, 1, 'Designation: Tractor Drivers; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(127, 101, 127, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(128, 102, 133, 'primary', '2026-07-02', NULL, 1, 'Designation: Tractor Drivers; Allocation-sheet status: Operational; Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(129, 102, 137, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(130, 103, 38, 'primary', '2026-07-02', NULL, 1, 'Designation: Bus Driver; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(131, 103, 65, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(132, 104, 71, 'primary', '2026-07-02', NULL, 1, 'Designation: Bus Driver; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(133, 104, 71, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(134, 106, 138, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK; Driver auto-created (name not in roster)', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(135, 107, 74, 'primary', '2026-07-02', NULL, 1, 'Designation: Fencer; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(136, 108, 75, 'primary', '2026-07-02', NULL, 1, 'Designation: Plumber; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(137, 108, 77, 'reliever', '2026-07-02', NULL, 1, 'Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53'),
(138, 109, 76, 'primary', '2026-07-02', NULL, 1, 'Designation: Mason; Allocation-sheet status: Operational; Comment: OK', '2026-07-02 01:07:53', '2026-07-02 01:07:53');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `asset_disposal_logs`
--
ALTER TABLE `asset_disposal_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_asset_action` (`action_type`),
  ADD KEY `idx_asset_vehicle` (`vehicle_id`);

--
-- Indexes for table `battery_change_logs`
--
ALTER TABLE `battery_change_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_battery_vehicle` (`vehicle_id`),
  ADD KEY `idx_battery_date` (`change_date`),
  ADD KEY `fk_battery_service` (`service_record_id`);

--
-- Indexes for table `drivers`
--
ALTER TABLE `drivers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_driver_department` (`department`),
  ADD KEY `idx_driver_active` (`is_active`),
  ADD KEY `dl_number` (`dl_number`);

--
-- Indexes for table `fuel_depot_readings`
--
ALTER TABLE `fuel_depot_readings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_depot_date` (`reading_date`);

--
-- Indexes for table `fuel_logs`
--
ALTER TABLE `fuel_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_fuel_vehicle` (`vehicle_id`),
  ADD KEY `idx_fuel_date` (`log_date`);

--
-- Indexes for table `job_cards`
--
ALTER TABLE `job_cards`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `job_reference` (`job_reference`),
  ADD KEY `fk_job_mechanic` (`mechanic_id`),
  ADD KEY `idx_job_status` (`status`),
  ADD KEY `idx_job_vehicle` (`vehicle_id`);

--
-- Indexes for table `mechanics`
--
ALTER TABLE `mechanics`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `employee_id` (`employee_id`),
  ADD KEY `idx_mechanic_department` (`department`);

--
-- Indexes for table `odometer_logs`
--
ALTER TABLE `odometer_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_odo_vehicle_time` (`vehicle_id`,`logged_at`);

--
-- Indexes for table `service_records`
--
ALTER TABLE `service_records`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_service_vehicle` (`vehicle_id`),
  ADD KEY `fk_service_mechanic` (`mechanic_id`),
  ADD KEY `idx_service_date` (`service_date`);

--
-- Indexes for table `tyre_change_logs`
--
ALTER TABLE `tyre_change_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tyre_vehicle` (`vehicle_id`),
  ADD KEY `idx_tyre_date` (`change_date`),
  ADD KEY `fk_tyre_service` (`service_record_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `registration` (`registration`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_department` (`department`),
  ADD KEY `idx_fleet_number` (`fleet_number`),
  ADD KEY `fleet_number` (`fleet_number`),
  ADD KEY `fleet_number_2` (`fleet_number`);

--
-- Indexes for table `vehicle_change_logs`
--
ALTER TABLE `vehicle_change_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_vcl_vehicle` (`vehicle_id`),
  ADD KEY `idx_vcl_date` (`changed_at`);

--
-- Indexes for table `vehicle_driver_assignments`
--
ALTER TABLE `vehicle_driver_assignments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_assignment_vehicle` (`vehicle_id`,`role`,`is_active`),
  ADD KEY `idx_assignment_driver` (`driver_id`,`is_active`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `asset_disposal_logs`
--
ALTER TABLE `asset_disposal_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `battery_change_logs`
--
ALTER TABLE `battery_change_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `drivers`
--
ALTER TABLE `drivers`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=139;

--
-- AUTO_INCREMENT for table `fuel_depot_readings`
--
ALTER TABLE `fuel_depot_readings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fuel_logs`
--
ALTER TABLE `fuel_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `job_cards`
--
ALTER TABLE `job_cards`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `mechanics`
--
ALTER TABLE `mechanics`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `odometer_logs`
--
ALTER TABLE `odometer_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `service_records`
--
ALTER TABLE `service_records`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tyre_change_logs`
--
ALTER TABLE `tyre_change_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=110;

--
-- AUTO_INCREMENT for table `vehicle_change_logs`
--
ALTER TABLE `vehicle_change_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `vehicle_driver_assignments`
--
ALTER TABLE `vehicle_driver_assignments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=139;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `asset_disposal_logs`
--
ALTER TABLE `asset_disposal_logs`
  ADD CONSTRAINT `fk_asset_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `battery_change_logs`
--
ALTER TABLE `battery_change_logs`
  ADD CONSTRAINT `fk_battery_service` FOREIGN KEY (`service_record_id`) REFERENCES `service_records` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_battery_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `fuel_logs`
--
ALTER TABLE `fuel_logs`
  ADD CONSTRAINT `fk_fuel_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `job_cards`
--
ALTER TABLE `job_cards`
  ADD CONSTRAINT `fk_job_mechanic` FOREIGN KEY (`mechanic_id`) REFERENCES `mechanics` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_job_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `odometer_logs`
--
ALTER TABLE `odometer_logs`
  ADD CONSTRAINT `fk_odo_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `service_records`
--
ALTER TABLE `service_records`
  ADD CONSTRAINT `fk_service_mechanic` FOREIGN KEY (`mechanic_id`) REFERENCES `mechanics` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_service_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `tyre_change_logs`
--
ALTER TABLE `tyre_change_logs`
  ADD CONSTRAINT `fk_tyre_service` FOREIGN KEY (`service_record_id`) REFERENCES `service_records` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tyre_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `vehicle_change_logs`
--
ALTER TABLE `vehicle_change_logs`
  ADD CONSTRAINT `fk_vcl_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `vehicle_driver_assignments`
--
ALTER TABLE `vehicle_driver_assignments`
  ADD CONSTRAINT `fk_assignment_driver` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_assignment_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
