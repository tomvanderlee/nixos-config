# dev-postgresql Specification

## Purpose

Provides an opt-in, loopback-only PostgreSQL server for local development on NixOS hosts built from this flake, without pre-created databases.

## Requirements

### Requirement: Opt-in development PostgreSQL service
The shared system module SHALL provide the option `development.postgresql.enable`, default `false`. When enabled, the host SHALL run `services.postgresql` using `postgresql_18`. Hosts that do not enable it, including anything scaffolded from `hosts/template`, SHALL run no PostgreSQL service.

#### Scenario: Default hosts run no PostgreSQL
- **WHEN** a host that does not set `development.postgresql.enable` is evaluated
- **THEN** `services.postgresql.enable` is false

#### Scenario: The dev host runs PostgreSQL 18
- **WHEN** `hosts/test-vm` is evaluated
- **THEN** `services.postgresql.enable` is true and `services.postgresql.package` is `postgresql_18`

### Requirement: PostgreSQL listens on loopback only
When enabled, PostgreSQL SHALL listen only on `127.0.0.1` and `::1` on port 5432, and the firewall SHALL NOT be opened for it.

#### Scenario: No external listener
- **WHEN** the service is running
- **THEN** `ss -ltn` shows port 5432 bound only to `127.0.0.1` and `::1`

### Requirement: No databases or roles are provisioned declaratively
The module SHALL NOT set `services.postgresql.ensureDatabases` or `services.postgresql.ensureUsers`, so only PostgreSQL's default databases and the `postgres` superuser exist. Databases are created by the user on demand.

#### Scenario: Only default databases exist
- **WHEN** the service first starts on the dev host and `psql -h localhost -U postgres -l` is run
- **THEN** only `postgres`, `template0` and `template1` are listed

#### Scenario: A user creates a database on demand
- **WHEN** `createdb -h localhost -U postgres scratch` is run
- **THEN** it succeeds without prompting for a password and `scratch` appears in the database list

### Requirement: Trust authentication on loopback only
When enabled, pg_hba SHALL trust connections from `127.0.0.1/32` and `::1/128`, keep peer authentication for local socket connections, and contain no rule for other address ranges.

#### Scenario: No remote rules
- **WHEN** the generated `pg_hba.conf` is inspected
- **THEN** its only `host` rules are for `127.0.0.1/32` and `::1/128`
