## 1. Enable automatic timezone detection

- [x] 1.1 Add `services.automatic-timezoned.enable = true;` to `modules/nixos/common.nix`, alongside the other unconditional host-level services
- [x] 1.2 Verify `nix eval '.#nixosConfigurations.test-vm.config.services.automatic-timezoned.enable'` (or the appropriate real host output) evaluates to `true`, and that `.config.services.geoclue2.enable` and `.config.time.timeZone` evaluate to `true` and `null` respectively (confirming `automatic-timezoned` took over from the `Etc/UTC` default as expected) — this repo has no host tracked in git today (`hosts/test-vm` is a local-only scratch VM excluded via `.git/info/exclude`, so it's invisible to the flake's git-tree evaluation and `nixosConfigurations` is currently empty); verified instead via a synthetic `nixpkgs.lib.nixosSystem` built directly from `modules/nixos/common.nix`, confirming `services.automatic-timezoned.enable = true`, `services.geoclue2.enable = true`, and `time.timeZone = null`

## 2. Verification

- [x] 2.1 Run `nix flake check` and confirm it passes
- [x] 2.2 Run `nix build '.#nixosConfigurations.test-vm.config.system.build.toplevel'` (or the appropriate real host output) and confirm it succeeds — same test-vm caveat as 1.2; built the synthetic `nixosSystem`'s `config.system.build.toplevel` instead, which succeeded natively (this machine is aarch64-linux) and produced a closure including the `automatic-timezoned`, `automatic-timezoned-geoclue-agent`, `geoclue`, and `systemd-timedated` units
- [x] 2.3 Run `nix fmt` and confirm `modules/nixos/common.nix` is formatted with no diff
