#!/bin/bash
# Description: Refresh data in a non-production environment

set -euo pipefail

echo "Beginning ORMS test data reset..."

# Check for required arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <institution>"
    echo "Valid institutions: OMI, OHIGPH"
    exit 1
fi

institution=$1
institution_lower=$(echo $1 | tr '[:upper:]' '[:lower:]')

# Validate the institution
if [[ "$institution" != "OMI" && "$institution" != "OHIGPH" ]]; then
    echo "Invalid institution: $institution"
    echo "Valid institutions: OMI, OHIGPH"
    exit 1
fi

set -euxo pipefail

echo "Upgrading OrmsDatabase..."
docker compose run --rm db-management alembic --name ormsdb upgrade head
echo "Upgrading OrmsLog..."
docker compose run --rm db-management alembic --name ormslogdb upgrade head

docker compose run --rm db-management python -m db_management.run_sql_scripts OrmsDatabase db_management/ormsdb/data/truncate/
docker compose run --rm db-management python -m db_management.run_sql_scripts OrmsLog db_management/ormslogdb/data/truncate/

docker compose run --rm db-management python -m db_management.run_sql_scripts OrmsDatabase db_management/ormsdb/data/initial/
docker compose run --rm db-management python -m db_management.run_sql_scripts OrmsDatabase db_management/ormsdb/data/test/
docker compose run --rm db-management python -m db_management.run_sql_scripts OrmsDatabase db_management/ormsdb/data/test/$institution_lower/
docker compose run --rm db-management python -m db_management.run_sql_scripts OrmsLog db_management/ormslogdb/data/initial/
docker compose run --rm db-management python -m db_management.run_sql_scripts OrmsLog db_management/ormslogdb/data/test/
docker compose run --rm db-management python -m db_management.run_sql_scripts OrmsLog db_management/ormslogdb/data/test/$institution_lower/

docker compose exec admin python manage.py update_orms_patients

echo "ORMS test data successfully reset."
