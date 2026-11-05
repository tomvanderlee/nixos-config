# Proposal

## Why

The `ttun-server` project needs a local PostgreSQL for development, and the dev machine (`test-vm`, aarch64-linux, NixOS 26.11) has no PostgreSQL. The system should provide one, only on dev hosts.

## What Changes

- Add `modules/nixos/dev-postgresql.nix` with an opt-in option `development.postgresql.enable` (default `false`). When enabled it runs `services.postgresql` with `postgresql_18` (newest major in this nixpkgs; `pkgs.postgresql` is 18.6), listening on `127.0.0.1` and `::1`, port 5432, and trust authentication for loopback TCP only. No databases or roles are provisioned beyond the default `postgres` database and superuser; databases are created on demand with `createdb`.
- Import the module from `lib/mkNixos.nix` and enable it in `hosts/test-vm/configuration.nix` only.
- Document the option and the `createdb` workflow in `README.md`.
- **BREAKING**: none. Hosts that do not set the option are unchanged.

## Capabilities

### New Capabilities
- `dev-postgresql`: opt-in local development PostgreSQL on loopback with only the default database.

### Modified Capabilities
(none)

## Impact

- **Affected code**: new `modules/nixos/dev-postgresql.nix`, `lib/mkNixos.nix`, `hosts/test-vm/configuration.nix`, `README.md`.
- **Not affected**: `hosts/template` (option stays off), `flake.nix`, `lib/unfree-allowlist.nix` (PostgreSQL is free software), `~/Projects/ttun-server`.
- **Independent of** `fix-python-native-libs`; the two can be applied in either order.

## Non-goals

- Declaratively provisioning databases or roles (`ensureDatabases`, `ensureUsers`); the user runs `createdb` as needed.
- Exposing PostgreSQL beyond loopback, passwords, TLS or production hardening.
- Running `nixos-rebuild switch` without the user's approval.
