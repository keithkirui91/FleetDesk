# FleetDesk

FleetDesk is a lightweight PHP/MySQL garage management app for vehicles, job cards, services, fuel logs, mileage, mechanics, and reports.

## Setup

1. Create/import the database using `schema.sql`.
2. Update database credentials in `config.php` or set these environment variables:
   - `FLEETDESK_DB_HOST`
   - `FLEETDESK_DB_NAME`
   - `FLEETDESK_DB_USER`
   - `FLEETDESK_DB_PASS`
   - `FLEETDESK_DB_PORT`
3. Open `index.php` in the deployed folder.
4. If no admin exists, FleetDesk redirects to `auth.php` to create the first admin.
5. After an admin exists, `auth.php` shows an admin-already-set message.

## Main Files

- `schema.sql` creates the database structure and seed demo data.
- `db.php` owns the MySQL connection.
- `api/` contains JSON endpoints for saving and loading records.
- `module_page.php` renders the shared list/create screens.
- `auth.php` handles first-admin setup and logout.
- `index.php` handles login.
