#!/bin/bash
# Description: Refresh data in a non-production environment

set -euo pipefail

echo "Beginning test data reset."

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

echo "Upgrading QuestionnaireDB..."
docker compose run --rm db-management alembic --name questionnairedb upgrade head
echo "Upgrading OpalDB..."
docker compose run --rm db-management alembic --name opaldb upgrade head

echo "Migrating admin..."
docker compose exec admin python manage.py migrate

# Truncate legacy DBs first in order for insert_test_data command to be able to insert legacy records as well
docker compose run --rm db-management python -m db_management.run_sql_scripts OpalDB db_management/opaldb/data/truncate/
docker compose run --rm db-management python -m db_management.run_sql_scripts QuestionnaireDB db_management/questionnairedb/data/truncate/

# TODO: figure out if this is still needed
# docker compose exec admin python manage.py initialize_data --force-delete
docker compose exec admin python manage.py insert_test_data $institution --force-delete

docker compose run --rm db-management python -m db_management.run_sql_scripts QuestionnaireDB db_management/questionnairedb/data/initial/
docker compose run --rm db-management python -m db_management.run_sql_scripts QuestionnaireDB db_management/questionnairedb/data/test/
docker compose run --rm db-management python -m db_management.run_sql_scripts QuestionnaireDB db_management/questionnairedb/data/test/$institution_lower/
docker compose run --rm db-management python -m db_management.run_sql_scripts OpalDB db_management/opaldb/data/initial/
docker compose run --rm db-management python -m db_management.run_sql_scripts OpalDB db_management/opaldb/data/test/
docker compose run --rm db-management python -m db_management.run_sql_scripts OpalDB db_management/opaldb/data/test/$institution_lower/
docker compose run --rm db-management python -m db_management.run_sql_scripts OpalDB db_management/opaldb/data/test/notifications/

docker compose exec admin cat opal/core/management/commands/files/initialize_firebase_users.js | docker compose exec --no-TTY listener node
docker compose exec admin python manage.py find_deviations
docker compose exec admin python manage.py find_questionnaire_respondent_deviations

echo "Test data successfully reset."
