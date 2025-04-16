#!/bin/bash
# Name: initialize.sh
# Date Authored: 29 Oct 2024
# Author: Kelly Agnew
# Description: Refresh data in a non-production environment

set -euox pipefail

echo "Beginning test data reset."

# Check for required arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <institution>"
    echo "Valid institutions: OMI, OHIGPH"
    exit 1
fi

institution=$1

# Validate the institution
if [[ "$institution" != "OMI" && "$institution" != "OHIGPH" ]]; then
    echo "Invalid institution: $institution"
    echo "Valid institutions: OMI, OHIGPH"
    exit 1
fi

declare -a commands=(
    "docker compose run --rm alembic ./alembic-upgrade.sh"

    "docker compose exec admin python manage.py migrate"

    "docker compose run --rm alembic db_management/reset_data.sh $institution"

    "docker compose exec admin python manage.py initialize_data --force-delete"
    "docker compose exec -u root admin chown -R 1003:1003 /app/opal/media/uploads"
    "docker compose exec -u root admin chmod -R 0777 /app/opal/media/uploads"
    "docker compose exec admin python manage.py insert_test_data $institution --force-delete"

    "docker compose exec admin python manage.py migrate_users"

    "docker compose exec listener node src/firebase/initialize_users.js"

    "docker compose exec admin python manage.py find_deviations"
)

# Execute each command
for cmd in "${commands[@]}"; do
    echo "Executing: $cmd"
    if eval "$cmd"; then
        echo "Command executed successfully."
    else
        echo "Error executing command. Exiting."
        exit 1
    fi
    echo "------------------------------------------------------------"
done

echo "Test data successfully reset."
