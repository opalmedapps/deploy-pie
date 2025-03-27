#!/bin/bash
# Name: initialize.sh
# Date Authored: 29 Oct 2024
# Author: Kelly Agnew
# Description: Ensure database schemas are fully updated and migrated, and have the minimum set of data for functionality

set -euo pipefail

declare -a commands=(
    "docker compose run --rm alembic alembic --name questionnairedb upgrade head"
    "docker compose run --rm alembic alembic --name opaldb upgrade head"

    "docker compose exec backend python manage.py migrate"

    "docker compose run --rm alembic python -m db_management.run_sql_scripts OpalDB db_management/opaldb/data/initial/"
    "docker compose run --rm alembic python -m db_management.run_sql_scripts QuestionnaireDB db_management/questionnairedb/data/initial/"

    "docker compose exec backend python manage.py initialize_data --listener-token=${LISTENER_TOKEN} --listener-registration-token=${LISTENER_REGISTRATION_TOKEN} --interface-engine-token=${INTERFACE_ENGINE_TOKEN} --opaladmin-backend-legacy-token=${OPALADMIN_TOKEN} --admin-password=${ADMIN_PASSWORD}"
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
