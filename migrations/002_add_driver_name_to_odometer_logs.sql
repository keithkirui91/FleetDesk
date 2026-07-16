-- Adds driver_name to odometer_logs for databases that already existed
-- before this column was introduced (schema.sql already has it for fresh
-- installs).
--
-- Plain ADD COLUMN (no IF NOT EXISTS) — that syntax needs MySQL 8.0.29+,
-- which isn't guaranteed on every host (e.g. Railway's MySQL image
-- rejected it). This is safe as a plain statement anyway: scripts/migrate.js
-- only records a migration as applied after it succeeds, so it will only
-- ever run this once per database.

ALTER TABLE odometer_logs
    ADD COLUMN driver_name VARCHAR(150) NULL AFTER odometer_reading;
