# Design

## Context

Hosts under `hosts/` layer on top of `modules/nixos/common.nix`; `lib/mkNixos.nix` assembles the modules. `hosts/test-vm` is the only real host. The repo already favours option-gated shared modules (see `add-headless-host-option`'s `desktop.enable`).

## Goals / Non-Goals

**Goals:** loopback-only PostgreSQL 18 with just the default database on dev hosts; nothing on other hosts. **Non-Goals:** see proposal.md.

## Decisions

- **Opt-in option `development.postgresql.enable`** in a shared module imported by `lib/mkNixos.nix`, enabled in `hosts/test-vm` only. Alternatives: a per-host `services.postgresql` block (duplicated for further dev hosts) or `common.nix` (violates "not on non-dev hosts"). `hosts/template` is untouched.
- **Package `pkgs.postgresql_18`**, pinned explicitly so a nixpkgs bump cannot cause a major-version data-directory mismatch.
- **Settings**: `enableTCPIP = true`, `settings.listen_addresses = "127.0.0.1,::1"`, `settings.port = 5432`. No `ensureDatabases` or `ensureUsers`: the user creates databases with `createdb` (for example `createdb -h localhost -U postgres <name>`, or `sudo -u postgres createdb <name>` over the peer socket). Firewall not opened.
- **Authentication** replaces the default pg_hba, so it lists `local all all peer` (keeps `sudo -u postgres psql` and the ensure-scripts working), `host all all 127.0.0.1/32 trust` and `host all all ::1/128 trust`. No other host rules.
- **`postgresql_18` added to `environment.systemPackages`** so `psql` is available for the verification command; the app itself uses psycopg's bundled libpq.

## Risks / Trade-offs

- [Trust auth lets any local user act as any role] → Accepted for a dev machine; not reachable externally.
- [Pinned major version ages] → Bumping is a deliberate edit; data-directory upgrade is out of scope.
- [Replacing pg_hba could drop the default local rule] → The explicit `local ... peer` line and a service-start check cover it.
