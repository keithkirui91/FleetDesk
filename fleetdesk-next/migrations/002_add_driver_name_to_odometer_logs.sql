-- Adds driver_name to odometer_logs for databases that already existed
-- before this column was introduced (schema.sql already has it for fresh
-- installs). Safe to run once against an existing production database.
--
-- Run with:
--   FORCE_MIGRATE=1 npm run migrate -- migrations/002_add_driver_name_to_odometer_logs.sql
--
-- (FORCE_MIGRATE is required because the default migrate.js guard skips
-- everything once the `vehicles` table exists — that guard is meant for
-- schema.sql/full-dump runs, not small targeted migrations like this one.)

ALTER TABLE odometer_logs
    ADD COLUMN IF NOT EXISTS driver_name VARCHAR(150) NULL AFTER odometer_reading;
