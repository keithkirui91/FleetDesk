# Kamok FleetDesk — Next.js edition

A full rewrite of the original PHP/MySQL fleet & garage management app as a
Next.js (App Router) application, backed by the same MySQL database.

## Stack

- **Next.js 14** (App Router, JavaScript)
- **MySQL** via `mysql2` (same schema shape as the original, see `schema.sql`)
- **Auth**: signed session cookies (HMAC, no external auth library) —
  compatible with `bcrypt` password hashes
- No external UI framework; the original app's own CSS (`main.css` /
  `layout.css` / `components.css`) was carried over almost verbatim into
  `app/globals.css`

## What's new in this update

- **Battery/Tyre Change Log buttons** on the Service page, next to Add
  Service Record.
- **Dashboard**: time-range filter (3/6/12 months), department filter
  (applies to the jobs timeline, fuel-drawn chart, downtime breakdown,
  longest-open-jobs, upcoming services, and licence-expiry panels), "View
  all" links on every panel, and an "Add Fuel Log" button.
- **Fuel Delivery Logs** (`/fuel-delivery`) — a new page for logging new
  fuel stock received at the depot. Reachable via a button on the Dip
  Reading Logs page. Each delivery automatically computes the new tank
  balance (`previous balance + quantity delivered`) and records it as a new
  entry in the same depot-balance history used everywhere else (dashboard,
  auto-deduction on fuel fills, etc.) — so the depot balance is always the
  most recent entry regardless of whether it came from a manual dip
  reading, a delivery, or an automatic deduction.
- **Driver name on mileage logs**: both the gate kiosk (`/gate-mileage`) and
  the admin Mileage page now have a "Driver" field next to Vehicle. It
  auto-fills with that vehicle's assigned primary driver when you pick a
  vehicle, but stays fully editable (relievers, one-off drivers, etc.), and
  offers an autocomplete dropdown of driver names used before (via a native
  `<datalist>`, so it still accepts free text that isn't in the list).

### Database change required

Odometer/mileage logs now have a `driver_name` column. `schema.sql` already
includes it for fresh installs, but if you already have a live database
(e.g. your Railway deployment), run the one-off migration on top of it:

```bash
FORCE_MIGRATE=1 npm run migrate -- migrations/002_add_driver_name_to_odometer_logs.sql
```

(`FORCE_MIGRATE` is needed because the default migrate guard skips
everything once it sees the `vehicles` table — that guard is meant for
full schema/data imports, not small targeted migrations like this one.)

## Getting started

```bash
npm install
cp .env.example .env.local   # then fill in your MySQL credentials
```

Create the database and import the schema:

```bash
mysql -u youruser -p -e "CREATE DATABASE fleetdesk"
mysql -u youruser -p fleetdesk < schema.sql
```

If you have an existing data export from the old app (INSERT statements for
`vehicles`, `drivers`, `vehicle_driver_assignments`, etc.), import it the same
way, after the schema:

```bash
mysql -u youruser -p fleetdesk < your_data_export.sql
```

### Automatic migration on deploy

`scripts/migrate.js` runs a `.sql` file against the database and is wired in
as `prestart` in `package.json`, so it runs automatically every time the app
boots (e.g. on every Railway deploy, since Railway runs `npm start`).

It's **safe to run repeatedly**: before doing anything, it checks whether a
`vehicles` table already exists and skips if so, so it won't re-import (and
duplicate) data on every redeploy.

```bash
npm run migrate                    # runs schema.sql (default)
npm run migrate -- FD_DB_Export.sql  # runs a specific file instead
FORCE_MIGRATE=1 npm run migrate    # forces a re-run even if already applied
```

To have your production data import automatically on first deploy: put your
full SQL export (schema + data, like a phpMyAdmin dump) in the repo root and
point `prestart` at it instead of `schema.sql`:

```json
"prestart": "node scripts/migrate.js your_export.sql"
```

Then run the app manually (outside of the automatic hook) with:

```bash
npm run dev      # http://localhost:3000
# or
npm run build && npm start
```

The **first visit** should go to `/auth-setup` to create the first admin
account (username, email, password). After that, everyone signs in at
`/login`. This mirrors the original `auth.php` "first-admin-only" setup flow.

There's also a **gate/data-entry login** for the mileage-logging kiosk, using
the same hard-coded credentials as the original app:
`Data Entry` / `Data Entry`. It only has access to `/gate-mileage`.

## Project layout

- `app/api/*` — one route per resource (`vehicles`, `drivers`, `jobs`,
  `fuel`, `services`, `driver-allocations`, `battery-logs`, `tyre-logs`,
  `fuel-depot`, `odometer`, `asset-logs`, `dashboard`, `reports`, `auth/*`,
  `upload`). Most follow the same simple CRUD shape (`lib/moduleApi.js`
  factors this out), a few (`vehicles`, `jobs`, `fuel`, `driver-allocations`)
  have extra business logic ported straight from the PHP `api/*.php` files
  (auto depot deduction, job reference numbering, primary-driver rotation,
  vehicle status syncing, etc).
- `components/ModulePage.jsx` — one generic list + add + view/edit component
  that powers most of the simple CRUD pages, mirroring `module_page.php`
  from the original app.
- `components/AppShell.jsx` — sidebar + topbar shell, mirrors
  `sidebar.php` / `header.php`.
- `app/dashboard`, `app/jobs`, `app/fleet`, `app/gate-mileage` — the pages
  with genuinely custom behaviour in the original app (kanban-style job
  board, vehicle dispose action, dashboard KPIs/charts, gate kiosk), rebuilt
  as standalone React pages rather than the generic component.
- `middleware.js` — route protection, mirrors `auth_check.php` /
  `gate_auth_check.php`. Note: it does a lightweight, *unverified* read of
  the session cookie (Edge runtime can't use Node's `crypto`) purely to
  decide whether to redirect to `/login`. Every API route still does full
  HMAC verification (`lib/session.js` → `decodeSession`) before trusting the
  session or returning any data, so this doesn't weaken actual data access
  control.

## Known differences from the original PHP app

A few things were simplified or adapted rather than ported 1:1, given the
size of the original app:

- **Licence types** (drivers) and **work-done checklist** (services) were
  multi-select checklists in the original UI; here they're plain text
  fields (comma-separate values yourself). Easy to upgrade to a proper
  multi-select later.
- **Fuel log auto-calculated total cost** (litres × cost/litre) was a small
  inline `<script>` in the original; not yet wired up in the React form —
  the field is editable manually for now.
- **Dashboard** covers the same KPIs, fleet status, downtime-by-department,
  jobs timeline, fuel usage, depot balances, longest-open jobs, upcoming
  services, and expiring documents as the original, but as simple bar/column
  visualisations rather than a JS charting library.
- **`schema.sql` was cross-checked against a real production export** from
  the old app (phpMyAdmin dump) and adjusted to match exactly — e.g. there's
  no `insurance_expiry` column (the original app never had one; only
  `licence_expiry` exists). The production dump also has an extra
  `vehicle_change_logs` table (a field-level audit log) that this app doesn't
  read or write yet — safe to ignore, or ask if you'd like it wired up.
- **Existing uploaded images** from the zip (`assets/uploads/...`) were
  copied into `public/uploads/...` with their original filenames, but if
  your imported `vehicles`/`drivers`/`mechanics` rows store old absolute
  URLs in `primary_image_url` / `photo_url`, you may need to update those to
  `/uploads/vehicles/...` etc.
- The static **fuel price reference** endpoint (`/api/fuel-prices`) just
  carries over the same hard-coded fallback figures that were in the
  original `api/fuel-prices.php` — treat it as a placeholder, not a live
  feed.

## Environment variables

See `.env.example`. `SESSION_SECRET` should be a long random string in any
real deployment — sessions are HMAC-signed with it.
