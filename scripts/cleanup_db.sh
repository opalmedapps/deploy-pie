#!/bin/bash
set -euo pipefail

echo "Connecting to DB server on ${DB_HOST}:${DB_PORT}..."
echo "Dropping databases..."
MYSQL_PWD=${DB_ROOT_PASSWORD} mysql --protocol tcp --skip-ssl --user ${DB_ROOT_USER} --host ${DB_HOST} --port ${DB_PORT} <<'EOIF'
DROP DATABASE IF EXISTS \`$DB_NAME\`;
DROP DATABASE IF EXISTS \`OpalDB\`;
DROP DATABASE IF EXISTS \`QuestionnaireDB\`;
EOIF
echo "Successfully dropped databases"
echo "Dropping DB user "${DB_USER}"..."
MYSQL_PWD=${DB_ROOT_PASSWORD} mysql --protocol tcp --skip-ssl --user ${DB_ROOT_USER} --host ${DB_HOST} --port ${DB_PORT} <<'EOIF'
DROP USER IF EXISTS '$DB_USER'@'%';
FLUSH PRIVILEGES;
EOIF
echo "Successfully dropped DB user ${DB_USER}"
echo "Done!"
