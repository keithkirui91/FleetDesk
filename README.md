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

Then run the app:

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
- **`schema.sql` is inferred**, not copied — the original repo didn't
  include a schema file, only PHP code that referenced tables/columns and a
  partial data export (vehicles, drivers, vehicle_driver_assignments). The
  rest of the schema (jobs, services, fuel, depot, odometer, disposals,
  battery/tyre logs, users) was reconstructed from the API code. Double
  check it against your real data before going to production.
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
