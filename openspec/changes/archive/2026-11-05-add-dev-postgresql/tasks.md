# Tasks

Never run `nixos-rebuild switch` without asking the user first. Show the full diff before asking.

## 1. Module and host

- [x] 1.1 Create `modules/nixos/dev-postgresql.nix` with `development.postgresql.enable` (default `false`) implementing the spec (`postgresql_18`, loopback `listen_addresses`, port 5432, no `ensureDatabases`/`ensureUsers`, pg_hba with `local all all peer` plus the two trust rules, `postgresql_18` in `environment.systemPackages`); import it in `lib/mkNixos.nix`
- [x] 1.2 Set `development.postgresql.enable = true;` in `hosts/test-vm/configuration.nix` only; verify with `path:` flake refs that `test-vm` has `services.postgresql.enable = true` and package `postgresql_18`, and that evaluating with the option unset gives `false`
  - Note: `hosts/test-vm/` is excluded via `.git/info/exclude` (local-only host), so the `development.postgresql.enable = true;` line lives in the working tree but cannot be committed.
- [x] 1.3 Verify the evaluated `services.postgresql.authentication`, `settings.listen_addresses` and `settings.port` match the spec

## 2. Docs and checks

- [x] 2.1 Document `development.postgresql.enable` and the `createdb` workflow in `README.md`
- [x] 2.2 Run `nix fmt` and `nix flake check`; verify both pass and `git status` shows only intended files
- [x] 2.3 Build `path:/home/tom/desktop-flake#nixosConfigurations.test-vm.config.system.build.toplevel` (no switch)

## 3. Switch and verify (requires user approval)

- [x] 3.1 Show the full `git diff` with rationale, then ask before switching
- [x] 3.2 After the approved switch run `psql -h localhost -U postgres -c 'select 1'`, `createdb -h localhost -U postgres scratch` followed by `dropdb -h localhost -U postgres scratch`, and `ss -ltn | grep 5432`; verify the query returns a row, `\l` lists only the default databases before the test, and the port binds loopback only

## Workflow follow-up

- Archive the change after review with `/opsx:archive`.
