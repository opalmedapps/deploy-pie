# Deployment of the Opal PIE

This repository contains the setup required to run the [Opal PIE (backend) of the Opal solution](https://docs.opalmedapps.com/development/architecture/#overview-of-the-opal-pie).
This includes all the services except the interface engine which is specific to the institution it is deployed at.

It is a [`copier`](https://copier.readthedocs.io/en/stable/) project template to streamline the process.

## Supported deployment options

The *Opal PIE* components are always deployed as containers on the same host
via a [Docker compose](https://docs.docker.com/compose/) file.

The following options are supported:

### Certificate

1. Use *Let's Encrypt* for issuing a certificate
1. Use an already issued certificate

### Database

1. Run the *MariaDB* database server in a container
1. Run the *MariaDB* on the same server
1. Run the *MariaDB* on a different server
    1. Let clients connect via an unencrypted connection
    1. Enforce clients to use TLS

### Private certificate authorities (CA)

If the server certificate was issued by a private CA, it is required to provide the CA's public certificate(s) in
order for clients to be able to verify the certificate chain successfully.

To update the required `ca-certificates.crt` file or create the `db-certs.crt` file,
that contains the private CA's public certificate(s),
you can use the [`init-certificates`](https://gitlab.com/opalmedapps/infrastructure/init-certificates)
helper container to generate them.

### Job scheduling

[`Ofelia`](https://github.com/mcuadros/ofelia) can be run as a sidecar container in order to periodically run jobs.
Otherwise, a cron schedule needs to be set up manually to execute required tasks.

## Requirements

The remaining instructions assume that you have already
[created a Firebase project](https://docs.opalmedapps.com/development/local-dev-setup/#create-a-new-firebase-project)
for communication between the mobile app and the Opal PIE.

It is also assumed that you have the certificate for the Apple Push Notification service
to send push notifications to your iOS app.

If the database should not be run in a container, a *MariaDB* server has to be setup and configured.
You will be required to enter the credentials of a root user for the database setup.
**Important:** When the database is running on a separate server,
ensure that it is configured to require encrypted connections (using TLS).

The required software is:

- [Git](https://git-scm.com/)
- [`uv`](https://docs.astral.sh/uv/): Used to install and execute `copier`,
    and will take care of downloading Python if it is not installed
- [Docker Engine](https://docs.docker.com/engine/)
- [Docker Compose](https://docs.docker.com/compose/)

## Prerequisites

At the end of setting up a new project using `copier` certain files, such as certificate files,
are copied to the project directory.
Whether a file is required depends on the chosen deployment options.

Prepare a directory for these files with the following contents:

- `firebase-admin-key.json`: The private key of the service account used by the [Firebase Admin SDK](https://firebase.google.com/docs/database/admin/start#admin-sdk-authentication)
- `apn.crt` and `apn.key`: The public and private certificates for the Apple Push Notification service.
    The private key cannot be password-protected

### When using an already issued certificate

- `<domain>.crt`: The public certificate for the domain (hostname) where the Opal PIE is being deployed on
- `<domain>.key`: The private certificate for the domain (hostname) where the Opal PIE is being deployed on

#### When using certificates issued by a private CA

- `ca-certificates.crt`: An updated `ca-certificates.crt` file including the public certificate(s) of the CA
    that issued the server certificate
- `db-certs.crt`: The public certificate(s) of the CA that issued the server certificate of the DB server
    (only required when the DB server is running on a separate server and enforces TLS connections)

## Generating the project

Run the following command:

```shell
uvx --python ">=3.12" --with copier-templates-extensions --with bcrypt \
    copier copy --trust git+https://github.com/opalmedapps/deploy-pie.git <target-directory>
```

Answer the questions that you are asked.
Once all questions are answered, the project template will be copied to the `target-directory` according to your answers.
Then, setup tasks will be executed.

At the end, you will have a running Opal PIE.

### Project Generation Options

The following list describes all questions that are prompted by `copier` when generating your project.
Some questions are conditional based on your answer to a previous question.

1. **What is your project name?**

    The name of your project is only used in the generated README file.

1. **Where are the extra files located (absolute path)?**

    The absolute path to the extra files [described in the prerequisites](#prerequisites).
    Files located in this directory are copied to their required location during the generation.

1. **The name of the environment you are deploying**

    The environment name (such as *production* or *prod*) is shown in the footer of the OpalAdmin UI.

1. **Which timezone is this running in?**

    The timezone the server is located in.
    A valid TZ identifier must be used.
    See the column *TZ identifier* in the [List of tz database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List).

1. **Which domain is this going to be available at?**

    The domain the Opal PIE is going to be available at.
    Provide the fully qualified domain name (FQDN).
    When using *Let's Encrypt* for the certificate, this is the domain that a certificate will be requested for.

1. **How do you want to deal with the server certificate?**

    The available choices are:

    - Use [Let's Encrypt via `traefik`](https://doc.traefik.io/traefik/https/acme/) as the certificate resolver
    - Use an already issued certificate for which you have the public and private certificates (`.crt` and `.key` files)

1. **Email address to provide to Let's Encrypt (only shown when Let's Encrypt is used)**

    The email address to provide *Let's Encrypt* to notify about an expiring certificate.

1. **HTTP port the reverse proxy is listening at**

    Requests received via HTTP are redirected to HTTPS.

1. **HTTPS port the reverse proxy is listening at**

    The use of HTTPS is mandatory.

    **Important:** `traefik` is currently set up to use the [TLS Challenge](https://doc.traefik.io/traefik/https/acme/#tlschallenge) which requires port `443` to be reachable.

1. **Where do you want to run the DB server?**

    The available choices are:

    - In a container on the same server
    - Directly on the host on the same server
    - Directly on the host on a different server

    For both non-container options it is required that you have a *MariaDB* server already set up with a root user.

1. **What's the hostname of the DB server? (only shown when the DB is on a separate server)**

    The hostname of the database server.

1. **Port the DB server is listening at (only shown when the DB is on a separate server)**

    The port the database server is listening at.

1. **Username of the database user**

    The database user's name that will be created.
    This user is used by the components to connect to the database.
    The password will be generated automatically.

1. **Username of a database root user (only shown when the DB is not running in a container)**

    This user is used to create the database user and the required databases.
    The user `root` is used when running the DB in a container.

1. **Password of the database root user (only shown when the DB is not running in a container)**

    The password is automatically generated when running the DB in a container.
    The password is treated as a [secret](https://copier.readthedocs.io/en/stable/configuring/#:~:text=secret),
    i.e., it will not be saved in the answers file.

1. **Connect to the DB server via TLS? (only shown when the DB is on a separate server)**

    **IMPORTANT:** Always require encrypted connections to the database in production.

    Ensure that the database server only accepts encrypted connections.

1. **Include an [adminer](https://www.adminer.org/en/) container to manage the databases?**

    **IMPORTANT:** Do not use this in a production environment.

1. **Do you need to use a custom CA file to verify HTTPS and DB connections?
    (only shown when an already issued certificate is used or the DB requires a TLS connection)**

    When certificates are issued by a private certificate authority (CA)
    it is likely the case that the CA's certificate is not trusted yet.
    In order for clients to be able to verify the full chain, the CA's public certificate(s) are required.

    For HTTPS connections the `ca-certificates.crt` file is used.
    For DB connections, the `db-certs.crt` file is used.

1. **Do you want to use Ofelia as a job scheduler to run period jobs?**

    *Ofelia* can be run in a sidecar container to run required jobs periodically.
    It is an alternative to using the cron daemon on the host.
    *Ofelia* sends emails for any failing job.

1. **The Firebase project name**

    The name of the Firebase project that is used for communication with the mobile app.

1. **The 2 character unique institution code**

    Only necessary when using the same mobile app with several institutions.
    In this case, each institution has its own *Opal PIE* and requires a unique 2 character code.

    The institution code is used as a prefix for registration codes that users receive to create their user account.

    You can leave the proposed default if only one institution is supported.

1. **The app ID of the iOS app**

    The unique app bundle identifier of the iOS app.

1. **Path to the directory containing clinical notes**

    The path to the directory where clinical notes are or should be stored.

1. **What domain is the registration website deployed at?**

    The fully qualified domain name of the registration website.
    The website must be accessible via HTTPS.

## Updating the project

Run the following command from within the project directory:

```shell
uvx --python ">=3.12" --with copier-templates-extensions --with bcrypt \
    copier update --trust --skip-tasks --skip-answered
```

## Testing

```shell
uvx --python ">=3.12" --with copier-templates-extensions --with bcrypt copier copy --trust --vcs-ref=update-readme --no-cleanup git+https://github.com/opalmedapps/deploy-pie.git
```

During generation:

- test changes on a branch with `--vcs-ref=...`
- can use pre-determined answers file: move it out of the project directory and add `--answers-file .copier-answers.yml`
- avoid cleanup to look at the structure with `--no-cleanup`
- if it happens after containers have been `up`ed: `docker compose down && docker volume prune -a` (caution: note that that applies to all local volumes not used by at least one container)
