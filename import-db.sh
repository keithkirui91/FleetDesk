#!/bin/bash
set -e

# Import FleetDesk database into Railway MySQL
# This script is run as a pre-deploy command

echo "Importing FleetDesk database..."

# Wait for MySQL to be ready
for i in {1..30}; do
  if mysql -h "$MYSQLHOST" -P "$MYSQLPORT" -u "$MYSQLUSER" -p"$MYSQLPASSWORD" -e "SELECT 1" &>/dev/null; then
    echo "MySQL is ready"
    break
  fi
  echo "Waiting for MySQL... ($i/30)"
  sleep 1
done

# Create database if it doesn't exist
mysql -h "$MYSQLHOST" -P "$MYSQLPORT" -u "$MYSQLUSER" -p"$MYSQLPASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`if0_38642919_fleetdeskb\`;"

# Import the SQL file
mysql -h "$MYSQLHOST" -P "$MYSQLPORT" -u "$MYSQLUSER" -p"$MYSQLPASSWORD" if0_38642919_fleetdeskb < "if0_38642919_fleetdeskb (4).sql"

echo "Database imported successfully!"

