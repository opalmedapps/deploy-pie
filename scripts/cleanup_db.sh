#!/bin/bash
set -euo pipefail

# renovate: datasource=docker depName=alpine
ALPINE_VERSION="3.23.3"

echo "Running container for mysql-client..."
docker run --rm --interactive \
    --env DB_ROOT_USER=${DB_ROOT_USER} \
    --env DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD} \
    --env DB_HOST=${DB_HOST} \
    --env DB_USER=${DB_USER} \
    --env DB_NAME=${DB_NAME} \
    --network opal-${ENVIRONMENT} \
    --add-host "host.docker.internal:host-gateway" \
    alpine:${ALPINE_VERSION} sh -s << EOF
set -euo pipefail
apk add --no-cache mysql-client
echo "Connecting to DB server on ${DB_HOST}:${DB_PORT}..."
echo "Dropping databases..."
MYSQL_PWD=${DB_ROOT_PASSWORD} mariadb --protocol tcp --skip-ssl --user ${DB_ROOT_USER} --host ${DB_HOST} --port ${DB_PORT} <<'EOIF'
DROP DATABASE IF EXISTS \`$DB_NAME\`;
DROP DATABASE IF EXISTS \`OpalDB\`;
DROP DATABASE IF EXISTS \`QuestionnaireDB\`;
EOIF
echo "Successfully dropped databases"
echo "Dropping DB user ${DB_USER}..."
MYSQL_PWD=${DB_ROOT_PASSWORD} mariadb --protocol tcp --skip-ssl --user ${DB_ROOT_USER} --host ${DB_HOST} --port ${DB_PORT} <<'EOIF'
DROP USER IF EXISTS '$DB_USER'@'%';
FLUSH PRIVILEGES;
EOIF
echo "Successfully dropped DB user ${DB_USER}"
EOF
echo "Done!"
