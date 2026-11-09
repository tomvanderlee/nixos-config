# Tasks

## 1. Wrapper

- [x] 1.1 In `modules/home/desktop-apps.nix`, replace `pkgs.nextcloud-client` with a `symlinkJoin` + `wrapProgram` wrapper that prefixes `XDG_DATA_DIRS` with the `gtk3` and `gsettings-desktop-schemas` schema directories and keeps `meta`; verify `nix build` of the wrapper does not rebuild the client (only a small derivation builds) and `grep XDG_DATA_DIRS <result>/bin/nextcloud` shows both schema paths
- [x] 1.2 Verify platform filtering still holds: the `tom@linux` package list contains the wrapped `nextcloud-client` and `tom@darwin` returns an empty list (`nix eval ... --apply 'ps: builtins.filter (n: builtins.match "nextcloud-client.*" n != null) (map (p: p.name) ps)'`)
- [x] 1.3 Verify the desktop entry still launches the wrapped binary: the profile's `share/applications` contains the Nextcloud entry and `command -v nextcloud` in the activated profile resolves to the wrapper

## 2. Docs

- [x] 2.1 Add one sentence to the "Nextcloud client" README section noting the launcher is wrapped to expose GTK3 schemas (and why), so it is not removed by mistake; verify the section reads correctly

## 3. Integration

- [x] 3.1 Run `nix fmt -- modules/home/desktop-apps.nix`, `nix flake check --no-build` and `nix build '.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel' --no-link`; verify all succeed and `git status` shows only intended files
- [x] 3.2 After `nixos-rebuild switch`, from a fresh login, start Nextcloud from the app menu, add a folder connection through the folder chooser, and verify the client stays running and `coredumpctl list` shows no new Nextcloud dump

## Workflow follow-up

- Archive the change after review with `/opsx:archive`.
