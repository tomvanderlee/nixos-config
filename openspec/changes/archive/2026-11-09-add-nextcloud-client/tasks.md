# Tasks

## 1. Package and docs

- [x] 1.1 Add `pkgs.nextcloud-client` to `crossPlatformApps` in `modules/home/desktop-apps.nix`; verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages' --apply 'ps: builtins.filter (n: builtins.match "nextcloud-client.*" n != null) (map (p: p.name) ps)'` lists it and the same eval for `"tom@darwin"` returns an empty list
- [x] 1.2 Add a short "Nextcloud client" section to `README.md` covering first-run sign-in (keyring, no secrets in the repo) and enabling "Launch on system startup" in the client settings; verify the section renders and mentions no server URL or credentials

## 2. Integration

- [x] 2.1 Run `nix fmt -- modules/home/desktop-apps.nix`, `nix flake check --no-build` and `nix build '.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel' --no-link`; verify all succeed and `git status` shows only intended files
- [x] 2.2 After `nixos-rebuild switch`, verify the client launches from the GNOME menu and signs in to the Nextcloud server

## Workflow follow-up

- Archive the change after review with `/opsx:archive`.
