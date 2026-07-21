-- Battery and tyre change log import generated from Tyres&batteries.xlsx
-- Generated: 2026-07-20
-- Vehicle linking rule: match cleaned registration first, then fleet number.
-- Cleaned registration means uppercase with spaces removed, so KBT232U matches KBT 232U.
-- Tyre rows with blank change dates use 2026-07-20 because tyre_change_logs.change_date is required.
-- Battery workbook lifespan is labelled HRS; the app schema now stores expected_lifespan_hours
-- directly, extracted from the "Excel expected lifespan hrs: N." text embedded in notes.
-- That extracted text is stripped from notes after the value is pulled out.

SET FOREIGN_KEY_CHECKS = 0;

-- If battery_change_logs already exists from a previous run of the old script,
-- rename/widen its column before the CREATE TABLE IF NOT EXISTS below (which is a
-- no-op on an existing table and would otherwise leave the old column in place).
SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'battery_change_logs'
      AND COLUMN_NAME = 'expected_lifespan_months'
);
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE battery_change_logs CHANGE COLUMN expected_lifespan_months expected_lifespan_hours INT NULL',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE TABLE IF NOT EXISTS battery_change_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    service_record_id INT NULL,
    change_date DATE NOT NULL,
    odometer INT NULL,
    quantity INT NOT NULL DEFAULT 1,
    battery_size VARCHAR(50) NULL,
    battery_type VARCHAR(50) NULL,
    expected_lifespan_hours INT NULL,
    reason_for_removal TEXT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (service_record_id) REFERENCES service_records(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tyre_change_logs (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT UNSIGNED NOT NULL,
    service_record_id INT UNSIGNED NULL,
    change_date DATE NOT NULL,
    odometer INT UNSIGNED NULL,
    quantity TINYINT UNSIGNED NOT NULL DEFAULT 1,
    tyre_name VARCHAR(100) NULL,
    tyre_size VARCHAR(60) NULL,
    tyre_type ENUM('Nylon','Radial','Superlug') NOT NULL DEFAULT 'Radial',
    expected_lifespan_km INT UNSIGNED NULL,
    quality_comment TEXT NULL,
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tyre_vehicle_date (vehicle_id, change_date),
    CONSTRAINT tyre_change_logs_vehicle_fk FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    CONSTRAINT tyre_change_logs_service_fk FOREIGN KEY (service_record_id) REFERENCES service_records(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TEMPORARY TABLE IF EXISTS import_tyre_change_logs;
CREATE TEMPORARY TABLE import_tyre_change_logs (
    row_no INT NOT NULL,
    fleet_no VARCHAR(50) NULL,
    reg_no VARCHAR(80) NULL,
    change_date DATE NOT NULL,
    odometer INT UNSIGNED NULL,
    quantity TINYINT UNSIGNED NOT NULL DEFAULT 1,
    tyre_name VARCHAR(100) NULL,
    tyre_size VARCHAR(60) NULL,
    tyre_type ENUM('Nylon','Radial','Superlug') NOT NULL DEFAULT 'Radial',
    expected_lifespan_km INT UNSIGNED NULL,
    quality_comment TEXT NULL,
    notes TEXT NULL
);
INSERT INTO import_tyre_change_logs (row_no,fleet_no,reg_no,change_date,odometer,quantity,tyre_name,tyre_size,tyre_type,expected_lifespan_km,quality_comment,notes) VALUES
(2,'Z16','TRAILER','2026-07-20',0,4,'ROADSHINE','11.00 R20','Radial',0,NULL,'Imported from Tyres&batteries.xlsx tyres row 2. Original change date blank; 2026-07-20 used for required change_date.'),
(3,'D22','KBT232U','2026-07-20',379424,4,'MICHELING',NULL,'Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 3. Original change date blank; 2026-07-20 used for required change_date.'),
(4,'G03','KBR088Y','2026-07-20',579151,7,'XCEED','9.5 R17.5','Radial',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 4. Original change date blank; 2026-07-20 used for required change_date.'),
(5,'W13','KTWB395B','2026-07-20',0,2,'WINDFORCE','155 R12','Radial',3,NULL,'Imported from Tyres&batteries.xlsx tyres row 5. Original change date blank; 2026-07-20 used for required change_date.'),
(6,'W14','KTWB9145D','2026-07-20',10651,2,'WINDFORCE','155 R12','Radial',15000,NULL,'Imported from Tyres&batteries.xlsx tyres row 6. Original change date blank; 2026-07-20 used for required change_date.'),
(7,'FE20','BAILER','2026-07-20',0,1,'BKT','11.5/80 R15.3','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 7. Original change date blank; 2026-07-20 used for required change_date.'),
(8,'D39','KDE450C','2026-07-20',14780,5,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 8. Original change date blank; 2026-07-20 used for required change_date.'),
(9,'Z26','TRAILER','2026-07-20',NULL,2,NULL,'385 R225','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 9. Original change date blank; 2026-07-20 used for required change_date.'),
(10,'K03','KAU426V','2026-07-20',213645,7,'ROADSHINE','900 R20','Radial',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 10. Original change date blank; 2026-07-20 used for required change_date.'),
(11,'D24','KCE659V','2026-07-20',440770,4,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 11. Original change date blank; 2026-07-20 used for required change_date.'),
(12,'P01','KAP742W','2026-07-20',1390,2,'BKT',NULL,'Nylon',2000,NULL,'Imported from Tyres&batteries.xlsx tyres row 12. Original change date blank; 2026-07-20 used for required change_date.'),
(13,'W2','WORKHORSE 2','2026-07-20',NULL,2,'KUMHO','155 - 12','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 13. Original change date blank; 2026-07-20 used for required change_date.'),
(14,'B05','KCH718T','2026-07-20',105110,4,'COMFORSER','195 R15','Radial',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 14. Original change date blank; 2026-07-20 used for required change_date.'),
(15,'D34','KCR730T','2026-07-20',92811,5,'TRAK TUF','7.50*16','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 15. Original change date blank; 2026-07-20 used for required change_date.'),
(16,'D34','KCR730T','2026-07-20',135113,4,'TRAK TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 16. Original change date blank; 2026-07-20 used for required change_date.'),
(17,'Z04','TRAILER-TT8-ZA 4462','2026-07-20',NULL,4,'RETREAD','7.50*16','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 17. Original change date blank; 2026-07-20 used for required change_date.'),
(18,'P08','KTCC360A','2026-07-20',5215,4,'SPEED WAYS','12.4 - 24','Nylon',2000,NULL,'Imported from Tyres&batteries.xlsx tyres row 18. Original change date blank; 2026-07-20 used for required change_date.'),
(19,'P04','KAT392L','2026-07-20',2503,2,'RETREAD','7.50*16','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 19. Original change date blank; 2026-07-20 used for required change_date.'),
(20,'Z03','TRAILER-TT2-ZA 1962','2026-07-20',NULL,2,'RETREAD','7.50*16','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 20. Original change date blank; 2026-07-20 used for required change_date.'),
(21,'D37','KDB096U','2026-07-20',44418,5,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 21. Original change date blank; 2026-07-20 used for required change_date.'),
(22,'K08','KAU460S','2026-07-20',229487,7,'TRAKMAX','900 R 20','Radial',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 22. Original change date blank; 2026-07-20 used for required change_date.'),
(23,'D09','KAT198Q','2026-07-20',562566,4,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 23. Original change date blank; 2026-07-20 used for required change_date.'),
(24,'D09','KAT198Q','2026-07-20',575090,4,'TRAK TUF','7.50*16','Nylon',30000,'New odometer was replaced','Imported from Tyres&batteries.xlsx tyres row 24. Original change date blank; 2026-07-20 used for required change_date.'),
(25,'T01','KAN336V','2026-07-20',655342,1,'TRAK TUF','7.50*16','Nylon',20000,NULL,'Imported from Tyres&batteries.xlsx tyres row 25. Original change date blank; 2026-07-20 used for required change_date.'),
(26,'T01','KAN336V','2026-07-20',664586,1,'TRAK TUF','7.50*16','Nylon',20000,NULL,'Imported from Tyres&batteries.xlsx tyres row 26. Original change date blank; 2026-07-20 used for required change_date.'),
(27,'T01','KAN336V','2026-07-20',667190,4,'TRAK TUF','7.50*16','Nylon',20000,NULL,'Imported from Tyres&batteries.xlsx tyres row 27. Original change date blank; 2026-07-20 used for required change_date.'),
(28,'T01','KAN336V','2026-07-20',674082,2,'TRAK TUF','7.50*16','Nylon',20000,NULL,'Imported from Tyres&batteries.xlsx tyres row 28. Original change date blank; 2026-07-20 used for required change_date.'),
(29,'D26','KCN464N','2026-07-20',183096,4,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 29. Original change date blank; 2026-07-20 used for required change_date.'),
(30,'D26','KCN464N','2026-07-20',216507,5,'TRAK TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 30. Original change date blank; 2026-07-20 used for required change_date.'),
(31,'D27','KCN470N','2026-07-20',247629,5,'TRAK TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 31. Original change date blank; 2026-07-20 used for required change_date.'),
(32,'D27','KCN470N','2026-07-20',279209,4,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 32. Original change date blank; 2026-07-20 used for required change_date.'),
(33,'D27','KCN470N','2026-07-20',301297,5,'TRAK TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 33. Original change date blank; 2026-07-20 used for required change_date.'),
(34,'D11','KAT201Q','2026-07-20',506843,5,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 34. Original change date blank; 2026-07-20 used for required change_date.'),
(35,'D11','KAT201Q','2026-07-20',542364,4,'TRAK TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 35. Original change date blank; 2026-07-20 used for required change_date.'),
(36,'D30','KCN211N','2026-07-20',90918,4,'COMFORSER','195*15','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 36. Original change date blank; 2026-07-20 used for required change_date.'),
(37,'D38','KDB201Y','2026-07-20',40222,5,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 37. Original change date blank; 2026-07-20 used for required change_date.'),
(38,'D38','KDB201Y','2026-07-20',63620,4,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 38. Original change date blank; 2026-07-20 used for required change_date.'),
(39,'D38','KDB201Y','2026-07-20',93219,5,'TRAK TUF','7.50*16','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 39. Original change date blank; 2026-07-20 used for required change_date.'),
(40,'D33','KCR585W','2026-07-20',222374,4,'TRAK TUF','7.50*16','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 40. Original change date blank; 2026-07-20 used for required change_date.'),
(41,'D33','KCR585W','2026-07-20',229815,4,'RETREAD','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 41. Original change date blank; 2026-07-20 used for required change_date.'),
(42,'D12','KAT202Q','2026-07-20',484170,5,'TRAK TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 42. Original change date blank; 2026-07-20 used for required change_date.'),
(43,'W11','KBM838V','2026-07-20',NULL,2,'AUSTON','155 R12','Radial',NULL,'faulty odometer','Imported from Tyres&batteries.xlsx tyres row 43. Original change date blank; 2026-07-20 used for required change_date.'),
(44,'W12','KTWB235B','2026-07-20',NULL,2,'MILE MAX','155 R12','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 44. Original change date blank; 2026-07-20 used for required change_date.'),
(45,'Z16','TRAILER','2026-07-20',NULL,1,'ROADSHINE','11.00 R20','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 45. Original change date blank; 2026-07-20 used for required change_date.'),
(46,'D33','KCR585W','2026-07-20',277233,5,'TRAK TUF','7.50*16','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 46. Original change date blank; 2026-07-20 used for required change_date.'),
(47,'B06','KCL697W','2026-07-20',224895,4,'PORTRAN','215 R16','Radial',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 47. Original change date blank; 2026-07-20 used for required change_date.'),
(48,'D15','KAU056G','2026-07-20',622115,4,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 48. Original change date blank; 2026-07-20 used for required change_date.'),
(49,'D33','KCR585W','2026-07-20',299962,5,'TRAK TUF','7.50*16','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 49. Original change date blank; 2026-07-20 used for required change_date.'),
(50,'D33','KCR585W','2026-07-20',318666,4,'MRF-RETREAD','7.50*16','Nylon',30000,'RETHREAD','Imported from Tyres&batteries.xlsx tyres row 50. Original change date blank; 2026-07-20 used for required change_date.'),
(51,'D33','KCR585W','2026-07-20',329815,1,'MRF-RETREAD','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 51. Original change date blank; 2026-07-20 used for required change_date.'),
(52,'D33','KCR585W','2026-07-20',337702,5,'TRAK TUF','7.50*16','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 52. Original change date blank; 2026-07-20 used for required change_date.'),
(53,'A29','KMDQ709D','2026-07-20',NULL,1,'VEE RUBBER','275 - 21','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 53. Original change date blank; 2026-07-20 used for required change_date.'),
(54,'A33','KMDY 729N','2026-07-20',NULL,1,'VEE RUBBER','410 - 18','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 54. Original change date blank; 2026-07-20 used for required change_date.'),
(55,'A12','KMCB724M','2026-07-20',2580,1,'VEE RUBBER','275 - 21','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 55. Original change date blank; 2026-07-20 used for required change_date.'),
(56,'A37','KMCA406R','2026-07-20',8736,2,'VEE RUBBER','410 - 18','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 56. Original change date blank; 2026-07-20 used for required change_date.'),
(57,'K09','KAS979Y','2026-07-20',NULL,1,'ROADSHINE','1200 - 24','Radial',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 57. Original change date blank; 2026-07-20 used for required change_date.'),
(58,'K09','KAS979Y','2026-07-20',NULL,3,'SKYFIRE','1200 - 24','Nylon',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 58. Original change date blank; 2026-07-20 used for required change_date.'),
(59,'Z16','TRAILER','2026-07-20',NULL,1,NULL,'1100 - 20','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 59. Original change date blank; 2026-07-20 used for required change_date.'),
(60,'P02','KAT390L','2026-07-20',NULL,2,'RETREAD','7.50*16','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 60. Original change date blank; 2026-07-20 used for required change_date.'),
(61,'M01','KHMA869B','2026-07-20',21759,2,'AEOLUS','1400-24','Nylon',1000,NULL,'Imported from Tyres&batteries.xlsx tyres row 61. Original change date blank; 2026-07-20 used for required change_date.'),
(62,'M01','KHMA869B','2026-07-20',22363,2,'AEOLUS','275 - 21','Nylon',1000,NULL,'Imported from Tyres&batteries.xlsx tyres row 62. Original change date blank; 2026-07-20 used for required change_date.'),
(63,'B04','KCH672H','2026-07-20',121847,5,'ARMSTRONG','225 - 17','Nylon',60000,NULL,'Imported from Tyres&batteries.xlsx tyres row 63. Original change date blank; 2026-07-20 used for required change_date.'),
(64,'D36','KBU548Q','2026-07-20',245353,5,'TRAK TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 64. Original change date blank; 2026-07-20 used for required change_date.'),
(65,'T03','KCJ464L','2026-07-20',110671,2,'LINGLONG','265/70*19.5','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 65. Original change date blank; 2026-07-20 used for required change_date.'),
(66,'T03','KCJ464L','2026-07-20',148429,7,'LINGLONG','265/70*19.5','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 66. Original change date blank; 2026-07-20 used for required change_date.'),
(67,'T03','KCJ464L','2026-07-20',158249,4,'LING LONG','265/70 R19.5','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 67. Original change date blank; 2026-07-20 used for required change_date.'),
(68,'P07','KTCB249U','2026-07-20',7403,2,'KIRITI','14.9 - 24','Nylon',2000,NULL,'Imported from Tyres&batteries.xlsx tyres row 68. Original change date blank; 2026-07-20 used for required change_date.'),
(69,'K09','KAS979Y','2026-07-20',NULL,2,'TAITONG','1200 - 24','Radial',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 69. Original change date blank; 2026-07-20 used for required change_date.'),
(70,'Z09','TRAILER','2026-07-20',NULL,2,'KUMHO','185/70 R14','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 70. Original change date blank; 2026-07-20 used for required change_date.'),
(71,'P08','KTCC360A','2026-07-20',3809,2,'OTANI','24 R24','Radial',2000,NULL,'Imported from Tyres&batteries.xlsx tyres row 71. Original change date blank; 2026-07-20 used for required change_date.'),
(72,'D38','KDB201Y','2026-07-20',115130,3,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 72. Original change date blank; 2026-07-20 used for required change_date.'),
(73,'D28','KCN142N','2026-07-20',80000,5,'MAXXIS','195 - 15','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 73. Original change date blank; 2026-07-20 used for required change_date.'),
(74,'K01','KAU648A','2026-07-20',NULL,4,NULL,'11.00 - 20','Radial',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 74. Original change date blank; 2026-07-20 used for required change_date.'),
(75,'B07','KCR056L','2026-07-20',181737,5,'GOOD YEAR','225 R17','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 75. Original change date blank; 2026-07-20 used for required change_date.'),
(76,'Z16','TRAILER','2026-07-20',NULL,1,'ROADSHINE','11.00 R20','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 76. Original change date blank; 2026-07-20 used for required change_date.'),
(77,'K07','KAU459S','2026-07-20',193919,7,'TRAK TUF',NULL,'Radial',40000,'New odometer was replaced','Imported from Tyres&batteries.xlsx tyres row 77. Original change date blank; 2026-07-20 used for required change_date.'),
(78,'D32','KCR584W','2026-07-20',200286,5,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 78. Original change date blank; 2026-07-20 used for required change_date.'),
(79,'D32','KCR584W','2026-07-20',238853,4,'TRAIL TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 79. Original change date blank; 2026-07-20 used for required change_date.'),
(80,'G02','KAV964Q','2026-07-20',236572,7,'FR ROADSHINE',NULL,'Superlug',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 80. Original change date blank; 2026-07-20 used for required change_date.'),
(81,'G02','KAV964Q','2026-07-20',266539,6,'FR ROADSHINE',NULL,'Superlug',40000,'New odometer was replaced','Imported from Tyres&batteries.xlsx tyres row 81. Original change date blank; 2026-07-20 used for required change_date.'),
(82,'G02','KAV964Q','2026-07-20',NULL,6,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 82. Original change date blank; 2026-07-20 used for required change_date.'),
(83,'B06','KCL 697W','2026-07-20',246535,4,'KUMHO','215/65 R16','Radial',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 83. Original change date blank; 2026-07-20 used for required change_date.'),
(84,'G03','KBR088Y','2026-07-20',137330,7,'LING LONG','265/70 R19.5','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 84. Original change date blank; 2026-07-20 used for required change_date.'),
(85,'PRIVATE','KBN794N','2026-07-20',0,5,'STAMINA','7.50*16','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 85. Original change date blank; 2026-07-20 used for required change_date.'),
(86,'B07','KCR 056L','2026-07-20',201953,4,'KUMHO','225/65 R17','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 86. Original change date blank; 2026-07-20 used for required change_date.'),
(87,'D14','KAT204Q','2026-07-20',443529,4,'TRAIL TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 87. Original change date blank; 2026-07-20 used for required change_date.'),
(88,'D14','KAT204Q','2026-07-20',474890,5,'TRAIL TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 88. Original change date blank; 2026-07-20 used for required change_date.'),
(89,'G03','KBR088Y','2026-07-20',607466,6,'LING LONG','9.5 - 17.5','Radial',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 89. Original change date blank; 2026-07-20 used for required change_date.'),
(90,'D29','KCN143N','2026-07-20',79216,5,'GOOD YEAR','195 R15','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 90. Original change date blank; 2026-07-20 used for required change_date.'),
(91,'D35','KCR738T','2026-07-20',199564,5,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 91. Original change date blank; 2026-07-20 used for required change_date.'),
(92,'D35','KCR738T','2026-07-20',230269,4,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 92. Original change date blank; 2026-07-20 used for required change_date.'),
(93,'D35','KCR738T','2026-07-20',261524,5,'TRAK TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 93. Original change date blank; 2026-07-20 used for required change_date.'),
(94,'D37','KDB096U','2026-07-20',74449,4,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 94. Original change date blank; 2026-07-20 used for required change_date.'),
(95,'D37','KDB096U','2026-07-20',112113,5,'TRAK TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 95. Original change date blank; 2026-07-20 used for required change_date.'),
(96,'D14','KAT204Q','2026-07-20',502140,1,'MRF','7.50*16','Nylon',30000,'RETHREAD','Imported from Tyres&batteries.xlsx tyres row 96. Original change date blank; 2026-07-20 used for required change_date.'),
(97,'D37','KDB096U','2026-07-20',144901,1,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 97. Original change date blank; 2026-07-20 used for required change_date.'),
(98,'D37','KDB096U','2026-07-20',153176,5,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 98. Original change date blank; 2026-07-20 used for required change_date.'),
(99,'D35','KCR738T','2026-07-20',287916,5,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 99. Original change date blank; 2026-07-20 used for required change_date.'),
(100,'D11','KAT201Y','2026-07-20',575527,5,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 100. Original change date blank; 2026-07-20 used for required change_date.'),
(101,'T01','KAN336V','2026-07-20',694357,7,'MRF','7.50*16','Nylon',20000,NULL,'Imported from Tyres&batteries.xlsx tyres row 101. Original change date blank; 2026-07-20 used for required change_date.'),
(102,'D26','KCN464N','2026-07-20',256762,5,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 102. Original change date blank; 2026-07-20 used for required change_date.'),
(103,'D38','KDB201Y','2026-07-20',138562,5,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 103. Original change date blank; 2026-07-20 used for required change_date.'),
(104,'D36','KBU548Q','2026-07-20',272794,2,'TRAK TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 104. Original change date blank; 2026-07-20 used for required change_date.'),
(105,'D32','KCR84W','2026-07-20',265088,5,'TRAIL TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 105. Original change date blank; 2026-07-20 used for required change_date.'),
(106,'D34','KCR730T','2026-07-20',165472,5,'TRAK TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 106. Original change date blank; 2026-07-20 used for required change_date.'),
(107,'D14','KAT204Q','2026-07-20',507972,5,'TRAK TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 107. Original change date blank; 2026-07-20 used for required change_date.'),
(108,'D31','KCR040M','2026-07-20',29472,5,'LIMAM','145 - 15','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 108. Original change date blank; 2026-07-20 used for required change_date.'),
(109,'D31','KCR040M','2026-07-20',47377,5,'APOLLO','145 - 15','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 109. Original change date blank; 2026-07-20 used for required change_date.'),
(110,'D27','KCN470N','2026-07-20',330011,5,'TRAK TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 110. Original change date blank; 2026-07-20 used for required change_date.'),
(111,'D36','KBU548Q','2026-07-20',273374,3,'TRAK TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 111. Original change date blank; 2026-07-20 used for required change_date.'),
(112,'D28','KCN142M','2026-07-20',19514,5,'APOLLO','145 - 15','Radial',30000,'New odometer was replaced','Imported from Tyres&batteries.xlsx tyres row 112. Original change date blank; 2026-07-20 used for required change_date.'),
(113,'T03','KCJ464L','2026-07-20',169012,2,'LINGLONG','265/70 -19.5','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 113. Original change date blank; 2026-07-20 used for required change_date.'),
(114,'D40','KDN019H','2026-07-20',18368,4,'GOOD RICH','255/19 - 16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 114. Original change date blank; 2026-07-20 used for required change_date.'),
(115,'D33','KCR585W','2026-07-20',361708,4,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 115. Original change date blank; 2026-07-20 used for required change_date.'),
(116,'D39','KDE450C','2026-07-20',48844,5,'TRAK TUF','7.50*16','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 116. Original change date blank; 2026-07-20 used for required change_date.'),
(117,'D12','KAT202Q','2026-07-20',506136,5,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 117. Original change date blank; 2026-07-20 used for required change_date.'),
(118,'D37','KDB096U','2026-07-20',181601,4,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 118. Original change date blank; 2026-07-20 used for required change_date.'),
(119,'D25','KCJ580M','2026-07-20',94212,5,NULL,NULL,'Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 119. Original change date blank; 2026-07-20 used for required change_date.'),
(120,'D34','KCR730T','2026-07-20',188222,5,'TRAK TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 120. Original change date blank; 2026-07-20 used for required change_date.'),
(121,'D15','KAU056G','2026-07-20',648855,4,'TRAK TUF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 121. Original change date blank; 2026-07-20 used for required change_date.'),
(122,'T03','KCJ464L','2026-07-20',173979,4,'LINGLONG','265/70 -19.5','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 122. Original change date blank; 2026-07-20 used for required change_date.'),
(123,'D42','KDN279K','2026-07-20',9620,6,'COMFOSER','235/85*16','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 123. Original change date blank; 2026-07-20 used for required change_date.'),
(124,'D40','KDN019H','2026-07-20',44587,4,NULL,NULL,'Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 124. Original change date blank; 2026-07-20 used for required change_date.'),
(125,'D38','KDB201Y','2026-07-20',167593,5,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 125. Original change date blank; 2026-07-20 used for required change_date.'),
(126,'D09','KAT198Q','2026-07-20',591263,4,NULL,NULL,'Radial',30000,'FOLLOWING ON JOB CARD','Imported from Tyres&batteries.xlsx tyres row 126. Original change date blank; 2026-07-20 used for required change_date.'),
(127,'D09','KAT198Q','2026-07-20',NULL,5,NULL,'750X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 127. Original change date blank; 2026-07-20 used for required change_date.'),
(128,'D09','KAT198Q','2026-07-20',NULL,5,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 128. Original change date blank; 2026-07-20 used for required change_date.'),
(129,'Z19',NULL,'2026-07-20',NULL,4,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 129. Original change date blank; 2026-07-20 used for required change_date.'),
(130,'T03','KCJ464L','2026-07-20',177463,2,'LINGLONG','265/70 -19.5','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 130. Original change date blank; 2026-07-20 used for required change_date.'),
(131,'T03','KCJ464L','2026-07-20',177631,1,'LINGLONG','265/70*19.5','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 131. Original change date blank; 2026-07-20 used for required change_date.'),
(132,'D35','KCR738T','2026-07-20',319705,5,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 132. Original change date blank; 2026-07-20 used for required change_date.'),
(133,'D44','KDQ249C','2026-07-20',23505,5,NULL,'7.50*16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 133. Original change date blank; 2026-07-20 used for required change_date.'),
(134,'B08','KDR 091M','2026-07-20',85090,4,'BRIDGESTONE','225/55-R18','Radial',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 134. Original change date blank; 2026-07-20 used for required change_date.'),
(135,'T03','KCJ464L','2026-07-20',180366,2,'BRIDGESTONE','225/55-R18','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 135. Original change date blank; 2026-07-20 used for required change_date.'),
(136,'D41','KDN120J','2026-07-20',35648,4,NULL,NULL,'Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 136. Original change date blank; 2026-07-20 used for required change_date.'),
(137,'G04','KDP814E','2026-07-20',48430,7,'SAILUN','9.5R*17.5','Radial',50000,NULL,'Imported from Tyres&batteries.xlsx tyres row 137. Original change date blank; 2026-07-20 used for required change_date.'),
(138,'G04','KDP814E','2026-07-20',109819,6,NULL,'95X17.5','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 138. Original change date blank; 2026-07-20 used for required change_date.'),
(139,'D24','KCE659V','2026-07-20',479132,4,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 139. Original change date blank; 2026-07-20 used for required change_date.'),
(140,'D15','KAU056G','2026-07-20',671991,5,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 140. Original change date blank; 2026-07-20 used for required change_date.'),
(141,'D15','KAU056G','2026-07-20',NULL,4,'7.50X16',NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 141. Original change date blank; 2026-07-20 used for required change_date.'),
(142,'D30','KCN211N','2026-07-20',92469,1,'GOOD YEAR','195*15','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 142. Original change date blank; 2026-07-20 used for required change_date.'),
(143,'D30','KCN211N','2026-07-20',104822,5,'MRF','195*15','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 143. Original change date blank; 2026-07-20 used for required change_date.'),
(144,'B06','KCL697W','2026-07-20',271513,5,NULL,NULL,'Radial',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 144. Original change date blank; 2026-07-20 used for required change_date.'),
(145,'B06','KCL697W','2026-07-20',NULL,1,NULL,'215X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 145. Original change date blank; 2026-07-20 used for required change_date.'),
(146,'D32','KCR584W','2026-07-20',290877,5,'APOLLO','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 146. Original change date blank; 2026-07-20 used for required change_date.'),
(147,'B09','KDR097M','2026-07-20',6730,4,'BRIDGESTONE','225/55-R18','Radial',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 147. Original change date blank; 2026-07-20 used for required change_date.'),
(148,'T03','KCJ464L','2026-07-20',185990,1,'LINGLONG','265/70*19.5','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 148. Original change date blank; 2026-07-20 used for required change_date.'),
(149,'D42','KDN279K','2026-07-20',38352,4,NULL,NULL,'Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 149. Original change date blank; 2026-07-20 used for required change_date.'),
(150,'D42','KDN279K','2026-07-20',59415,4,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 150. Original change date blank; 2026-07-20 used for required change_date.'),
(151,'D43','KDP403Y','2026-07-20',27608,5,'CEAT','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 151. Original change date blank; 2026-07-20 used for required change_date.'),
(152,'D37','KDB096U','2026-07-20',187114,5,'CEAT','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 152. Original change date blank; 2026-07-20 used for required change_date.'),
(153,'D26','KCN464N','2026-07-20',292080,5,'CEAT','7.50*16','Nylon',30000,'GOOD RESULTS','Imported from Tyres&batteries.xlsx tyres row 153. Original change date blank; 2026-07-20 used for required change_date.'),
(154,'D26','KCN464N','2026-07-20',292080,5,'CEAT','7.50*16','Nylon',30000,'GOOD RESULTS','Imported from Tyres&batteries.xlsx tyres row 154. Original change date blank; 2026-07-20 used for required change_date.'),
(155,'P07','KTCB249U','2026-07-20',9343,2,'BKT','184*34','Nylon',2000,NULL,'Imported from Tyres&batteries.xlsx tyres row 155. Original change date blank; 2026-07-20 used for required change_date.'),
(156,'P07','KTCB249U','2026-07-20',NULL,2,'KIRITI','149X24','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 156. Original change date blank; 2026-07-20 used for required change_date.'),
(157,'D38','KDB201Y','2026-07-20',193138,4,'CEAT','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 157. Original change date blank; 2026-07-20 used for required change_date.'),
(158,'D38','KDB201Y','2026-07-20',NULL,4,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 158. Original change date blank; 2026-07-20 used for required change_date.'),
(159,'T03','KCJ464L','2026-07-20',189035,2,'WESTLAKE','265/70*19.5','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 159. Original change date blank; 2026-07-20 used for required change_date.'),
(160,'D36','KBU548Q','2026-07-20',296204,4,'CEAT','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 160. Original change date blank; 2026-07-20 used for required change_date.'),
(161,'D27','KCN470N','2026-07-20',358265,4,'CEAT','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 161. Original change date blank; 2026-07-20 used for required change_date.'),
(162,'D44','KDQ249C','2026-07-20',27508,5,'CEAT','7.50*16- Tube, 7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 162. Original change date blank; 2026-07-20 used for required change_date.'),
(163,'D44','KDQ249C','2026-07-20',NULL,4,NULL,'750X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 163. Original change date blank; 2026-07-20 used for required change_date.'),
(164,'D45','KAU580J','2026-07-20',235865,5,'CEAT','7.50*16- Tube, 7.50*16','Nylon',30000,'FIRST CHANGE IN OPC','Imported from Tyres&batteries.xlsx tyres row 164. Original change date blank; 2026-07-20 used for required change_date.'),
(165,'D12','KAT202Q','2026-07-20',529566,5,'CEAT','7.50*16- Tube, 7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 165. Original change date blank; 2026-07-20 used for required change_date.'),
(166,'D12','KAT202Q','2026-07-20',NULL,5,NULL,'7.50X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 166. Original change date blank; 2026-07-20 used for required change_date.'),
(167,'Z27','HARRINTON TRAILER','2026-07-20',NULL,1,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 167. Original change date blank; 2026-07-20 used for required change_date.'),
(168,'D46','KDR810E','2026-07-20',21991,5,'BLACK HAWK','232/85*16','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 168. Original change date blank; 2026-07-20 used for required change_date.'),
(169,'D46','KDR810E','2026-07-20',NULL,1,'RAODCRUZA RADIAL',NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 169. Original change date blank; 2026-07-20 used for required change_date.'),
(170,'D46','KDR810E','2026-07-20',NULL,1,NULL,'235X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 170. Original change date blank; 2026-07-20 used for required change_date.'),
(171,'D46','KDR810E','2026-07-20',NULL,5,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 171. Original change date blank; 2026-07-20 used for required change_date.'),
(172,'Z26','TRAILER','2026-07-20',NULL,2,'SAILUN','385*22.5','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 172. Original change date blank; 2026-07-20 used for required change_date.'),
(173,'M07','CAT 533E','2026-07-20',NULL,2,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 173. Original change date blank; 2026-07-20 used for required change_date.'),
(174,'D24','KCE659V','2026-07-20',504548,1,NULL,NULL,'Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 174. Original change date blank; 2026-07-20 used for required change_date.'),
(175,'T03','KCJ464','2026-07-20',192181,4,'WESTLAKE','265/70*19.5','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 175. Original change date blank; 2026-07-20 used for required change_date.'),
(176,'B09','KDR097M','2026-07-20',7120,1,'BRIDGESTONE','225/55-R18','Radial',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 176. Original change date blank; 2026-07-20 used for required change_date.'),
(177,'B07','KCR 056L','2026-07-20',218519,1,'KUMHO','225/65 R17','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 177. Original change date blank; 2026-07-20 used for required change_date.'),
(178,'B07','KCR 056L','2026-07-20',NULL,1,NULL,'225/65 R17','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 178. Original change date blank; 2026-07-20 used for required change_date.'),
(179,'K08','KAU460S','2026-07-20',247750,3,'ROADSHINE','900 R 20','Radial',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 179. Original change date blank; 2026-07-20 used for required change_date.'),
(180,'D35','KCR738T','2026-07-20',346128,4,'CEAT','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 180. Original change date blank; 2026-07-20 used for required change_date.'),
(181,'D35','KCR738T','2026-07-20',NULL,4,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 181. Original change date blank; 2026-07-20 used for required change_date.'),
(182,'D35','KCR738T','2026-07-20',NULL,4,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 182. Original change date blank; 2026-07-20 used for required change_date.'),
(183,'K03','KAU426V','2026-07-20',251972,4,'ROADSHINE','900 R 20','Radial',40000,NULL,'Imported from Tyres&batteries.xlsx tyres row 183. Original change date blank; 2026-07-20 used for required change_date.'),
(184,'D14','KAT204Q','2026-07-20',528254,4,'CEAT','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 184. Original change date blank; 2026-07-20 used for required change_date.'),
(185,'D39','KDE450C','2026-07-20',83822,4,'CEAT','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 185. Original change date blank; 2026-07-20 used for required change_date.'),
(186,'D40','KDN019H','2026-07-20',72400,4,'SAILUN','235/85*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 186. Original change date blank; 2026-07-20 used for required change_date.'),
(187,'D40','KDN019H','2026-07-20',NULL,4,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 187. Original change date blank; 2026-07-20 used for required change_date.'),
(188,'D40','KDN019H','2026-07-20',NULL,5,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 188. Original change date blank; 2026-07-20 used for required change_date.'),
(189,'D34','KCR730T','2026-07-20',217225,4,'CEAT','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 189. Original change date blank; 2026-07-20 used for required change_date.'),
(190,'D34','KCR730T','2026-07-20',NULL,5,NULL,'750X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 190. Original change date blank; 2026-07-20 used for required change_date.'),
(191,'T01','KAN336V','2026-07-20',723813,7,'APOLLO','7.50*16','Nylon',20000,NULL,'Imported from Tyres&batteries.xlsx tyres row 191. Original change date blank; 2026-07-20 used for required change_date.'),
(192,'B04','KCH672H','2026-07-20',147781,2,'KUMHO','225/20*16','Radial',60000,NULL,'Imported from Tyres&batteries.xlsx tyres row 192. Original change date blank; 2026-07-20 used for required change_date.'),
(193,'W16',NULL,'2026-07-20',0,2,'DURUN','155*12','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 193. Original change date blank; 2026-07-20 used for required change_date.'),
(194,'W16',NULL,'2026-07-20',NULL,4,'DURUN','155X12','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 194. Original change date blank; 2026-07-20 used for required change_date.'),
(195,'W16',NULL,'2026-07-20',NULL,4,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 195. Original change date blank; 2026-07-20 used for required change_date.'),
(196,'T03','KCJ464','2026-07-20',202062,4,'LING LONG','265/70*19.5','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 196. Original change date blank; 2026-07-20 used for required change_date.'),
(197,'T03','KCJ464','2026-07-20',NULL,2,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 197. Original change date blank; 2026-07-20 used for required change_date.'),
(198,'T03','KCJ464','2026-07-20',NULL,4,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 198. Original change date blank; 2026-07-20 used for required change_date.'),
(199,'T03','KCJ464','2026-07-20',NULL,2,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 199. Original change date blank; 2026-07-20 used for required change_date.'),
(200,'T03','KCJ464','2026-07-20',NULL,4,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 200. Original change date blank; 2026-07-20 used for required change_date.'),
(201,'D37','KDB096U','2026-07-20',240800,4,'CEAT','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 201. Original change date blank; 2026-07-20 used for required change_date.'),
(202,'W17',NULL,'2026-07-20',0,6,'DURUN','155*12','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 202. Original change date blank; 2026-07-20 used for required change_date.'),
(203,'D33','KCR585W','2026-07-20',392528,4,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 203. Original change date blank; 2026-07-20 used for required change_date.'),
(204,'D29','KCN143N','2026-07-20',101958,4,'KUMHO','195*15','Radial',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 204. Original change date blank; 2026-07-20 used for required change_date.'),
(205,'D32','KCR584W','2026-07-20',319923,4,'MRF','7.50*16','Nylon',30000,NULL,'Imported from Tyres&batteries.xlsx tyres row 205. Original change date blank; 2026-07-20 used for required change_date.'),
(206,'D26','KCN464N','2026-07-20',NULL,4,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 206. Original change date blank; 2026-07-20 used for required change_date.'),
(207,'D26','KCN464N','2026-07-20',NULL,4,NULL,NULL,'Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 207. Original change date blank; 2026-07-20 used for required change_date.'),
(208,'K12','KDP124C','2026-07-20',NULL,10,'RADIAL',NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 208. Original change date blank; 2026-07-20 used for required change_date.'),
(209,'D45','KAU580J','2026-07-20',NULL,4,NULL,'7.50X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 209. Original change date blank; 2026-07-20 used for required change_date.'),
(210,'D43','KDP403Y','2026-07-20',NULL,5,NULL,'235x16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 210. Original change date blank; 2026-07-20 used for required change_date.'),
(211,'D32','KCR584W','2026-07-20',NULL,5,NULL,'750x16','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 211. Original change date blank; 2026-07-20 used for required change_date.'),
(212,'D37','KDB096U','2026-07-20',NULL,4,NULL,'750x16','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 212. Original change date blank; 2026-07-20 used for required change_date.'),
(213,'D38',NULL,'2026-07-20',NULL,5,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 213. Original change date blank; 2026-07-20 used for required change_date.'),
(214,'D48',NULL,'2026-03-26',NULL,4,NULL,'250X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 214.'),
(215,'D37',NULL,'2026-03-28',NULL,4,NULL,'250X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 215.'),
(216,'D27',NULL,'2026-04-25',NULL,5,NULL,'250X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 216.'),
(217,'D34',NULL,'2026-05-14',NULL,5,NULL,'250X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 217.'),
(218,'D43',NULL,'2026-07-20',NULL,1,NULL,'235X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 218. Original change date blank; 2026-07-20 used for required change_date.'),
(219,'D38',NULL,'2026-05-21',NULL,4,NULL,'750X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 219.'),
(220,'D42',NULL,'2026-05-29',NULL,4,NULL,'235X16','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 220.'),
(221,'D44',NULL,'2026-05-29',NULL,4,NULL,'235X16','Nylon',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 221.'),
(222,'D12',NULL,'2026-4-4',NULL,4,NULL,'750x18','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 222.'),
(223,'D32',NULL,'2026-07-20',NULL,4,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 223. Original change date blank; 2026-07-20 used for required change_date.'),
(224,'D41',NULL,'2026-06-16',NULL,5,NULL,'235/85X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 224.'),
(225,'B10',NULL,'2026-06-18',NULL,4,NULL,'195/80X15','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 225.'),
(226,'D43',NULL,'2026-06-26',NULL,4,NULL,'235/85X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 226.'),
(227,'G04',NULL,'2026-06-25',NULL,6,NULL,'9.5X17.5','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 227.'),
(228,'D35',NULL,'2026-07-25',NULL,4,NULL,'7.50X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 228.'),
(229,'D51',NULL,'2026-06-15',NULL,4,NULL,'28.5X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 229.'),
(230,'D38',NULL,'2026-01-07',NULL,1,NULL,'750X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 230.'),
(231,'D36',NULL,'2026-01-08',NULL,1,NULL,'750X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 231.'),
(232,'T01',NULL,'2026-01-20',NULL,1,NULL,'750X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 232.'),
(233,'D41',NULL,'2026-01-21',NULL,1,NULL,'235X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 233.'),
(234,'D14',NULL,'2026-01-26',553733,1,NULL,'7.50X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 234.'),
(235,'D15',NULL,'2026-01-27',717011,1,NULL,'7.50X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 235.'),
(236,'B08',NULL,'2026-02-03',NULL,1,NULL,'225X18','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 236.'),
(237,'D33',NULL,'2026-01-29',NULL,1,NULL,'7.50X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 237.'),
(238,'D47',NULL,'2026-01-26',NULL,1,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 238.'),
(239,'Z26',NULL,'2026-02-11',NULL,1,NULL,'385X22.5','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 239.'),
(240,'T03',NULL,'2026-02-18',NULL,1,NULL,'265/70X19.5','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 240.'),
(241,'P06',NULL,'2026-02-10',NULL,1,NULL,NULL,'Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 241.'),
(242,'D10',NULL,'2026-02-19',NULL,1,NULL,'195/80X15','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 242.'),
(243,'D35',NULL,'2026-03-09',NULL,1,NULL,'750X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 243.'),
(244,'D26',NULL,'2026-03-05',35194,1,NULL,'750X16','Radial',NULL,NULL,'Imported from Tyres&batteries.xlsx tyres row 244.');

DROP TEMPORARY TABLE IF EXISTS import_battery_change_logs;
CREATE TEMPORARY TABLE import_battery_change_logs (
    row_no INT NOT NULL,
    fleet_no VARCHAR(50) NULL,
    reg_no VARCHAR(80) NULL,
    change_date DATE NOT NULL,
    odometer INT UNSIGNED NULL,
    quantity TINYINT UNSIGNED NOT NULL DEFAULT 1,
    battery_size VARCHAR(60) NULL,
    battery_type VARCHAR(80) NULL,
    expected_lifespan_months SMALLINT UNSIGNED NULL,
    reason_for_removal TEXT NULL,
    notes TEXT NULL
);
INSERT INTO import_battery_change_logs (row_no,fleet_no,reg_no,change_date,odometer,quantity,battery_size,battery_type,expected_lifespan_months,reason_for_removal,notes) VALUES
(2,'G04','KDP 814E','2026-03-23',131849,1,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 2.'),
(3,'G03','KBR088Y','2022-10-13',584470,2,'12V/70Ah',NULL,NULL,'NOT HOLDING CHARGE- vehicle handed over to Lewa conservancy','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 3.'),
(4,'D31','KCR040M','2022-10-13',30963,1,'12V/45Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 4.'),
(5,'D30','KCN211N','2022-10-13',87313,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 5.'),
(6,'P02','KAT390L','2022-11-03',4763,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 5000. | Imported from Tyres&batteries.xlsx batteries row 6.'),
(7,'D27','KCN470N','2022-11-05',282587,1,'12V/90Ah','MF',NULL,'SENT FOR CLAIM- WAS IT RETURNED degrees  degrees  degrees  degrees ','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 7.'),
(8,'D34','KCR730T','2023-01-30',118098,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 8.'),
(9,'D38','KDB201Y','2023-01-30',86491,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 9.'),
(10,'D37','KDB096V','2023-01-31',101866,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 10.'),
(11,'B05','KCH718T','2023-01-31',1012242,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 11.'),
(12,'D12','KAT202Q','2023-01-31',484499,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 12.'),
(13,'D25','KCJ580M','2023-02-02',89726,1,'12V/45Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 13.'),
(14,'D33','KCR585W','2023-03-24',289463,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 14.'),
(15,'D14','KAT204Q','2023-03-24',462203,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 15.'),
(16,'D35','KCR738T','2023-03-24',254776,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 16.'),
(17,'D32','KCR584W','2023-03-25',227332,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 17.'),
(18,'G02','KAV964Q','2023-03-29',253534,1,'12V/70Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 18.'),
(19,'G02','KAV964Q','2023-04-23',302379,2,'12V/70Ah','MF',NULL,NULL,'Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 19.'),
(20,'G02','KAV964Q','2026-04-23',302379,2,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 20.'),
(21,'M10','KAY448MF','2023-04-03',494,2,'12V/120Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 5000. | Imported from Tyres&batteries.xlsx batteries row 21.'),
(22,'D15','KAU056G','2023-04-04',631936,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 22.'),
(23,'K03','KAU426V','2023-04-27',215502,1,'12V/150Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 23.'),
(24,'D26','KCN464N','2023-05-11',216507,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 24.'),
(25,'D36','KBU548Q','2023-05-12',245246,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 25.'),
(26,'D36','KBU548Q','2026-03-06',32484,1,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 26.'),
(27,'P08','KTCC360A','2023-05-28',5001,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 5000. | Imported from Tyres&batteries.xlsx batteries row 27.'),
(28,'D11','KAT201Q','2023-06-07',558799,1,'12V/90Ah','MF',NULL,'SENT FOR CLAIM- WAS IT RETURNED degrees  degrees  degrees  degrees ','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 28.'),
(29,'P07','KTCB249Y','2023-07-11',7682,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 5000. | Imported from Tyres&batteries.xlsx batteries row 29.'),
(30,'P07','KTCB249Y','2026-06-18',10557,1,NULL,NULL,NULL,NULL,'Excel expected lifespan hrs: 90. | Imported from Tyres&batteries.xlsx batteries row 30.'),
(31,'D27','KCN470N','2023-07-11',307866,1,'amoron','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 31.'),
(32,'M07','CAT953','2023-07-11',3705,2,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 5000. | Imported from Tyres&batteries.xlsx batteries row 32.'),
(33,'D09','KAT198Q','2023-07-12',576090,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 33.'),
(34,'D09','KAT198Q','2026-07-09',NULL,1,'amoron',NULL,NULL,'NOT WORKING','Imported from Tyres&batteries.xlsx batteries row 34.'),
(35,'K08','KAU460S','2023-07-15',231359,1,'12V/150Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 35.'),
(36,'D32','KCR584W','2023-08-06',244048,1,'12V/90AH','MF',NULL,'FITTED FROM CLAIM','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 36.'),
(37,'D39','KDE450C','2023-08-07',33570,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 37.'),
(38,'M05','KHMA888A','2023-08-09',10750,2,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 5000. | Imported from Tyres&batteries.xlsx batteries row 38.'),
(39,'D37','KDB096U','2023-08-18',131913,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 39.'),
(40,'D37','KDB096U','2026-06-05',407066,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 40.'),
(41,'D12','KAT202Q','2026-06-08',407066,1,'12V/90Ah','MF',NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 41.'),
(42,'D12','KAT202Q','2023-08-29',494215,1,'12V/90Ah','MF',NULL,'FITTED FROM CLAIM','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 42.'),
(43,'D38','KDB201Y','2023-09-04',116721,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 43.'),
(44,'D24','KCE659V','2023-09-05',461319,1,'12V/90Ah','MF',NULL,'FITTED FROM CLAIM','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 44.'),
(45,'D15','KAU056G','2023-10-06',639608,1,'12V/90Ah','MF',NULL,'FITTED FROM CLAIM','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 45.'),
(46,'D22','KBT232U','2024-09-09',399947,1,'12V/90Ah','MF',NULL,NULL,'Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 46.'),
(47,'D36','KBU548Q','2023-10-06',NULL,1,'12V/90Ah','MF',NULL,'FITTED FROM CLAIM','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 47.'),
(48,'PRIVATE','KBN794N','2023-10-08',261693,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Imported from Tyres&batteries.xlsx batteries row 48.'),
(49,'D33','KCR585W','2023-10-09',328751,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 49.'),
(50,'D34','KCR730T','2023-10-11',148716,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 50.'),
(51,'D26','KCN464N','2023-10-11',242641,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 51.'),
(52,'M04','KHMA886B','2023-10-21',173471,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 5000. | Imported from Tyres&batteries.xlsx batteries row 52.'),
(53,'M04','KHMA886B','2025-10-31',17656,1,NULL,'HELDEN SILVES',NULL,'BATTERY RETURN FOR CLAIM','Imported from Tyres&batteries.xlsx batteries row 53.'),
(54,'GN24','W/SHOP GEN','2023-11-14',56061,1,'12V/120Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 5000. | Imported from Tyres&batteries.xlsx batteries row 54.'),
(55,'D29','KCN143M','2023-11-29',86588,1,'12V/45Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 55.'),
(56,'D14','KAT204Q','2023-12-06',495000,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 56.'),
(57,'D35','KCR738T','2023-12-06',281114,1,'12V/90AH','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 57.'),
(58,'T01','KAN336V','2023-12-08',690674,2,'12V/90AH','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 58.'),
(59,'D39','KDE450C','2023-12-08',39631,1,'12V/90Ah','MF',NULL,'FAULTY AFTER ACCIDENT','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 59.'),
(60,'M05','KHMA886B','2024-02-08',10891,2,'12V/90Ah','MF',NULL,'OLD BATTERIES STOLEN','Excel expected lifespan hrs: 5000. | Imported from Tyres&batteries.xlsx batteries row 60.'),
(61,'D32','KCR584W','2023-08-06',264205,1,'12V/90Ah','MF',NULL,'SENT FOR CLAIM- WAS IT RETURNED degrees  degrees  degrees  degrees ','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 61.'),
(62,'D37','KDB096U','2024-02-16',161869,1,'12V/90Ah','MF',NULL,'SENT FOR CLAIM- WAS IT RETURNED degrees  degrees  degrees  degrees ','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 62.'),
(63,'D24','KCE659V','2024-02-28',473480,1,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 63.'),
(64,'D24','KCE659V','2026-04-20',NULL,1,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 64.'),
(65,'D38','KDB201Y','2024-03-06',144242,1,'12V/90Ah','MF',NULL,'FITTED AT NANYUKI','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 65.'),
(66,'D27','KCN470N','2024-03-06',331016,1,'12V/90Ah','MF',NULL,'FITTED FROM CLAIM','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 66.'),
(67,'T03','KCJ464L','2024-03-06',167796,2,'12V/90Ah','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 67.'),
(68,'D32','KCR584W','2024-03-11',266388,1,'12V/90Ah','MF',NULL,'FITTED ATLAS BATTERY FOR TRIAL','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 68.'),
(69,'D32','KCR584W','2026-05-08',357006,1,'12V/90Ah','MF',NULL,'FITTED ATLAS BATTERY FOR TRIAL','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 69.'),
(70,'P08','KTCC360A','2024-02-12',5781,1,'12V/90Ah','MF',NULL,'SENT FOR CLAIM','Excel expected lifespan hrs: 5000. | Imported from Tyres&batteries.xlsx batteries row 70.'),
(71,'D36','KBU548Q','2024-03-14',275737,1,'12V/90AH','MF',NULL,'FITTED FROM CLAIM','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 71.'),
(72,'D36','KBU548Q','2026-03-23',131849,1,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 72.'),
(73,'D09','KAT198Q','2024-03-23',589121,1,'12V/90AH','MF',NULL,'FITTED FROM CLAIM','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 73.'),
(74,'D33','KCR585W','2024-03-27',335722,1,'12V/90AH','MF',NULL,'FITTED FROM CLAIM','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 74.'),
(75,'P01','KAP742W','2024-03-28',1390,1,'12V/90AH','MF',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 5000. | Imported from Tyres&batteries.xlsx batteries row 75.'),
(76,'D34','KCR730T','2024-05-07',175642,1,'12V/90AH','ATLAS',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 76.'),
(77,'D11','KAT201Y','2024-05-17',585282,1,'12V/90AH','ATLAS',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 77.'),
(78,'D28','KCN142M','2024-06-05',23908,1,'12V/90AH','ATLAS',NULL,'NOT HOLDING CHARGE','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 78.'),
(79,'M02','KHMA887B','2024-06-22',3017,1,'12V/90AM','MF',NULL,NULL,'Excel expected lifespan hrs: 5000. | Imported from Tyres&batteries.xlsx batteries row 79.'),
(80,'M02','KHMA887B','2025-09-11',NULL,1,NULL,'Power Zone',NULL,NULL,'Excel expected lifespan hrs: 5000. | Imported from Tyres&batteries.xlsx batteries row 80.'),
(81,'D35','KCR738T','2024-07-15',307752,1,'12V/90AH','ATLAS',NULL,'REPLACED WITH KCR 585W BATTERY','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 81.'),
(82,'D35','KCR738T','2025-09-11',365066,1,'12V/90AH',NULL,NULL,NULL,'Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 82.'),
(83,'D37','KDB096U','2024-07-27',187994,1,'12V/90Ah','ATLAS',NULL,NULL,'Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 83.'),
(84,'D37','KDB096U','2026-06-05',407066,1,'amaron',NULL,NULL,NULL,'Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 84.'),
(85,'D33','KCR585W','2024-07-18',345904,1,'12V/90Ah','ATLAS',NULL,'FROM D32 TO D33 BUT COVERED ABOUT 200 KM','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 85.'),
(86,'D27','KCN470N','2024-07-30',348089,1,'12V/90Ah','ATLAS',NULL,'SENT FOR CLAIM- WAS IT RETURNED degrees  degrees  degrees  degrees ','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 86.'),
(87,'P04','KAT392L','2024-07-31',9625,1,'12V/90Ah','ATLAS',NULL,NULL,'Excel expected lifespan hrs: 5000. | Imported from Tyres&batteries.xlsx batteries row 87.'),
(88,'D38','KDB201Y','2024-08-21',170777,1,'12V/90Ah','ATLAS',NULL,NULL,'Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 88.'),
(89,'P06','KTCB545','2024-08-15',5305,1,'12V/90Ah',NULL,NULL,NULL,'Excel expected lifespan hrs: 5000. | Imported from Tyres&batteries.xlsx batteries row 89.'),
(90,'P06','KTCB545','2025-09-15',NULL,1,NULL,NULL,NULL,NULL,'Excel expected lifespan hrs: 5000. | Imported from Tyres&batteries.xlsx batteries row 90.'),
(91,'P08',NULL,'2026-05-30',7054,1,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 91.'),
(92,'D24','KCE659V','2024-08-28',479304,1,'12V/70Ah','AMARON',NULL,NULL,'Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 92.'),
(93,'B07','KCR056L','2024-09-08',213782,1,'12V/90Ah',NULL,NULL,NULL,'Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 93.'),
(94,'D12','KAT202Q','2024-10-02',516244,1,'12V/90Ah','ATLAS',NULL,'OK','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 94.'),
(95,'D25','KCJ580M','2024-11-29',10938,1,'12V/90Ah','MF',NULL,'HAS BEEN USING KCN211M BATTERY','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 95.'),
(96,'D41','KDN120J','2024-12-20',NULL,1,'12V/90Ah','MF',NULL,NULL,'Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 96.'),
(97,'D41','KDN120J','2026-05-08',101087,1,NULL,NULL,NULL,NULL,'Excel expected lifespan hrs: 96442. | Imported from Tyres&batteries.xlsx batteries row 97.'),
(98,'D09','KAT198Q','2024-12-20',NULL,1,'12V/90Ah','MF',NULL,NULL,'Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 98.'),
(99,'D33','KCR585W','2024-12-20',366186,1,'12V/90AH','MF',NULL,NULL,'Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 99.'),
(100,'B05','KCH718T','2025-01-23',109468,1,'12V/90AH','MF',NULL,NULL,'Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 100.'),
(101,'D26','KCN464N','2024-12-23',294636,1,'12V/90AH','MF',NULL,NULL,'Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 101.'),
(102,'D41','KDN120J','2025-02-19',46452,1,'12V/90AH','MF',NULL,NULL,'Excel expected lifespan hrs: 3000. | Imported from Tyres&batteries.xlsx batteries row 102.'),
(103,'D38','KDB201Y','2025-02-20',196120,1,'12V/90AH','Chroride Oxide',NULL,NULL,'Excel expected lifespan hrs: 3000. | Imported from Tyres&batteries.xlsx batteries row 103.'),
(104,'D42','KDN279K','2025-03-06',43923,1,'12V/90AH',NULL,NULL,NULL,'Excel expected lifespan hrs: 3000. | Imported from Tyres&batteries.xlsx batteries row 104.'),
(105,'D37','KDB096U','2025-06-03',222787,1,'12V/90AH',NULL,NULL,NULL,'Excel expected lifespan hrs: 3000. | Imported from Tyres&batteries.xlsx batteries row 105.'),
(106,'D26','KCN464N','2025-09-26',328226,1,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 106.'),
(107,'D38','KDB201Y','2025-09-29',NULL,1,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 107.'),
(108,'D27','KCN470N','2025-10-09',363026,1,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 108.'),
(109,'D34','KCR738T','2025-03-22',218682,1,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 109.'),
(110,'P07','KTCB249V','2025-03-22',9423,1,'NS9012V',NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 110.'),
(111,'D36','KBU548Q','2025-04-10',302958,1,'NS9012V',NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 111.'),
(112,'T03','KCL 464L','2025-11-13',215365,1,'NS9012V',NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 112.'),
(113,'M07','CAT953','2023-07-11',4865,1,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 113.'),
(114,'D15','KCN464N','2023-10-06',712399,1,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 114.'),
(115,'D42','KDN279K','2024-07-27',17927,1,'12V/90Ah','ATLAS',NULL,'OVERHEATING','Excel expected lifespan hrs: 30000. | Imported from Tyres&batteries.xlsx batteries row 115.'),
(116,'M01','KHMA869B','2025-12-15',NULL,2,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 116.'),
(117,'D46','KDR810E','2025-10-30',51847,1,'NS9012V',NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 117.'),
(118,'B08','KDR091M','2025-10-07',NULL,1,'12V/90AH','MF',NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 118.'),
(119,'D44',NULL,'2026-05-09',NULL,1,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 119.'),
(120,'D43','KDP403Y','2026-05-08',91646,1,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 120.'),
(121,'D45','KAU580J','2025-03-23',241849,1,'NS9012V',NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 121.'),
(122,'D45','KAU580J','2026-01-21',283201,1,'NS9012V',NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 122.'),
(123,'D46','KDR 810E','2026-06-22',NULL,1,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 123.'),
(124,'D09','KAT198Q','2026-07-09',NULL,1,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 124.'),
(125,'GN24',NULL,'2026-03-03',NULL,1,NULL,NULL,NULL,NULL,'Imported from Tyres&batteries.xlsx batteries row 125.');

INSERT INTO tyre_change_logs (vehicle_id, service_record_id, change_date, odometer, quantity, tyre_name, tyre_size, tyre_type, expected_lifespan_km, quality_comment, notes)
SELECT v.id, NULL, s.change_date, s.odometer, s.quantity, s.tyre_name, s.tyre_size, s.tyre_type, s.expected_lifespan_km, s.quality_comment, s.notes
FROM import_tyre_change_logs s
JOIN vehicles v ON v.id = (
    SELECT v2.id
    FROM vehicles v2
    WHERE (s.reg_no IS NOT NULL AND REPLACE(UPPER(v2.registration), ' ', '') = REPLACE(UPPER(s.reg_no), ' ', ''))
       OR (s.fleet_no IS NOT NULL AND UPPER(TRIM(v2.fleet_number)) = UPPER(TRIM(s.fleet_no)))
    ORDER BY CASE WHEN s.reg_no IS NOT NULL AND REPLACE(UPPER(v2.registration), ' ', '') = REPLACE(UPPER(s.reg_no), ' ', '') THEN 0 ELSE 1 END, v2.id
    LIMIT 1
)
WHERE NOT EXISTS (
    SELECT 1 FROM tyre_change_logs existing
    WHERE existing.vehicle_id = v.id
      AND existing.change_date = s.change_date
      AND COALESCE(existing.odometer, 0) = COALESCE(s.odometer, 0)
      AND COALESCE(existing.tyre_name, '') = COALESCE(s.tyre_name, '')
      AND COALESCE(existing.tyre_size, '') = COALESCE(s.tyre_size, '')
      AND existing.quantity = s.quantity
);

-- Backfill any rows that were already imported by a previous run of the old script
-- (the dedup check in the INSERT below would otherwise skip fixing them).
UPDATE battery_change_logs
SET expected_lifespan_hours = CAST(
        SUBSTRING_INDEX(
            SUBSTRING(notes, LOCATE('Excel expected lifespan hrs: ', notes) + LENGTH('Excel expected lifespan hrs: ')),
            '.', 1
        ) AS UNSIGNED
    ),
    notes = SUBSTRING(notes, LOCATE('Imported from', notes))
WHERE notes LIKE 'Excel expected lifespan hrs:%';

INSERT INTO battery_change_logs (vehicle_id, service_record_id, change_date, odometer, quantity, battery_size, battery_type, expected_lifespan_hours, reason_for_removal, notes)
SELECT v.id, NULL, s.change_date, s.odometer, s.quantity, s.battery_size, s.battery_type,
    CASE WHEN s.notes LIKE 'Excel expected lifespan hrs:%'
         THEN CAST(
             SUBSTRING_INDEX(
                 SUBSTRING(s.notes, LOCATE('Excel expected lifespan hrs: ', s.notes) + LENGTH('Excel expected lifespan hrs: ')),
                 '.', 1
             ) AS UNSIGNED
         )
         ELSE NULL
    END AS expected_lifespan_hours,
    s.reason_for_removal,
    CASE WHEN s.notes LIKE 'Excel expected lifespan hrs:%'
         THEN SUBSTRING(s.notes, LOCATE('Imported from', s.notes))
         ELSE s.notes
    END AS notes
FROM import_battery_change_logs s
JOIN vehicles v ON v.id = (
    SELECT v2.id
    FROM vehicles v2
    WHERE (s.reg_no IS NOT NULL AND REPLACE(UPPER(v2.registration), ' ', '') = REPLACE(UPPER(s.reg_no), ' ', ''))
       OR (s.fleet_no IS NOT NULL AND UPPER(TRIM(v2.fleet_number)) = UPPER(TRIM(s.fleet_no)))
    ORDER BY CASE WHEN s.reg_no IS NOT NULL AND REPLACE(UPPER(v2.registration), ' ', '') = REPLACE(UPPER(s.reg_no), ' ', '') THEN 0 ELSE 1 END, v2.id
    LIMIT 1
)
WHERE NOT EXISTS (
    SELECT 1 FROM battery_change_logs existing
    WHERE existing.vehicle_id = v.id
      AND existing.change_date = s.change_date
      AND COALESCE(existing.odometer, 0) = COALESCE(s.odometer, 0)
      AND COALESCE(existing.battery_size, '') = COALESCE(s.battery_size, '')
      AND existing.quantity = s.quantity
);

-- Review these result sets after upload. They list workbook rows that did not match any vehicle.
SELECT 'unmatched tyre row' AS issue, s.row_no, s.fleet_no, s.reg_no
FROM import_tyre_change_logs s
WHERE NOT EXISTS (
    SELECT 1 FROM vehicles v
    WHERE (s.reg_no IS NOT NULL AND REPLACE(UPPER(v.registration), ' ', '') = REPLACE(UPPER(s.reg_no), ' ', ''))
       OR (s.fleet_no IS NOT NULL AND UPPER(TRIM(v.fleet_number)) = UPPER(TRIM(s.fleet_no)))
)
ORDER BY s.row_no;

SELECT 'unmatched battery row' AS issue, s.row_no, s.fleet_no, s.reg_no
FROM import_battery_change_logs s
WHERE NOT EXISTS (
    SELECT 1 FROM vehicles v
    WHERE (s.reg_no IS NOT NULL AND REPLACE(UPPER(v.registration), ' ', '') = REPLACE(UPPER(s.reg_no), ' ', ''))
       OR (s.fleet_no IS NOT NULL AND UPPER(TRIM(v.fleet_number)) = UPPER(TRIM(s.fleet_no)))
)
ORDER BY s.row_no;

SET FOREIGN_KEY_CHECKS = 1;
