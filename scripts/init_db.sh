#!/bin/bash
set -euo pipefail

# renovate: datasource=docker depName=alpine
ALPINE_VERSION="3.23.0"
WAIT_FOR_IT_VERSION="latest"

echo "Waiting for DB container to be ready..."
docker run --rm -it --network opal-${ENVIRONMENT} chainguard/wait-for-it:${WAIT_FOR_IT_VERSION} --host="$DB_HOST" --port="$DB_PORT" --timeout=20

echo "Running container for mysql-client..."
docker run --rm --interactive \
    --env DB_ROOT_USER=${DB_ROOT_USER} \
    --env DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD} \
    --env DB_HOST=${DB_HOST} \
    --env DB_USER=${DB_USER} \
    --env DB_PASSWORD=${DB_PASSWORD} \
    --env DB_NAME=${DB_NAME} \
    --network opal-${ENVIRONMENT} \
    alpine:${ALPINE_VERSION} sh -s << EOF
set -euo pipefail
apk add --no-cache mysql-client
echo "Connecting to DB server on ${DB_HOST}:${DB_PORT}..."
echo "Creating DB user "${DB_USER}"..."
MYSQL_PWD=${DB_ROOT_PASSWORD} mariadb --protocol tcp --skip-ssl --user ${DB_ROOT_USER} --host ${DB_HOST} --port ${DB_PORT} <<'EOIF'
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
-- set password explicitly in case user already exists with different password
ALTER USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
FLUSH PRIVILEGES;
EOIF
echo "Successfully created DB user ${DB_USER}"
echo "Creating DBs..."
MYSQL_PWD=${DB_ROOT_PASSWORD} mariadb --protocol tcp --skip-ssl --user ${DB_ROOT_USER} --host ${DB_HOST} --port ${DB_PORT} <<'EOIF'
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
CREATE DATABASE IF NOT EXISTS \`OpalDB\` /*!40100 DEFAULT CHARACTER SET latin1 */;
CREATE DATABASE IF NOT EXISTS \`QuestionnaireDB\` /*!40100 DEFAULT CHARACTER SET utf8 */;
EOIF
echo "Successfully created DBs"
echo "Granting privileges to DB user..."
MYSQL_PWD=${DB_ROOT_PASSWORD} mariadb --protocol tcp --skip-ssl --user ${DB_ROOT_USER} --host ${DB_HOST} --port ${DB_PORT} <<'EOIF'
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
GRANT ALL PRIVILEGES ON \`OpalDB\`.* TO '$DB_USER'@'%';
GRANT ALL PRIVILEGES ON \`QuestionnaireDB\`.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
EOIF
echo "Successfully granted privileges to DB user"
echo "Done!"
EOF
