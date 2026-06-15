ALTER TABLE job_cards
    ADD COLUMN part_availability ENUM('available','not_available') NOT NULL DEFAULT 'available' AFTER priority;

ALTER TABLE fuel_logs
    MODIFY fuel_type ENUM('petrol','diesel','hybrid','lpg','kerosene','other') NOT NULL DEFAULT 'diesel';
