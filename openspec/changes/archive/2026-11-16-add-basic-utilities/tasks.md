# Tasks

## 1. Home profile utilities

- [x] 1.1 Create `modules/home/network-tools.nix` with the portable utilities filtered via `lib.meta.availableOn`, import it in `modules/home/default.nix`; verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages' --apply 'map (p: p.name)'` lists them
- [x] 1.2 Add `openspec` to `modules/home/dev-tools.nix`; verify it appears in the `tom@linux` package list and `nix eval` of `tom@darwin` still succeeds
- [x] 1.3 Verify `nix build '.#homeConfigurations."tom@linux".activationPackage'` succeeds and `dig`, `nslookup`, `openspec` exist under its `home-path/bin`

## 2. NixOS system diagnostics

- [x] 2.1 Add the Linux diagnostics to `environment.systemPackages` in `modules/nixos/common.nix`; verify `nix build '.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel'` succeeds and `sw/bin` contains `tcpdump`, `lsof`, `strace`
- [x] 2.2 Verify no new `security.wrappers` entries or services via `nix eval '.#nixosConfigurations.toms-thinkpad.config.security.wrappers' --apply builtins.attrNames` compared with before

## 3. Final checks

- [x] 3.1 Run `nix fmt` and `nix flake check`; verify both pass
- [x] 3.2 Run `openspec validate add-basic-utilities --strict`; verify it passes
