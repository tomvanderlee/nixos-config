## 1. Switch to rootful Docker

- [x] 1.1 In `modules/nixos/common.nix`, replace `virtualisation.docker.rootless.enable`/`setSocketVariable` with `virtualisation.docker.enable = true;`.
- [x] 1.2 Add `"docker"` to `users.users.tom.extraGroups` in `modules/nixos/common.nix` (alongside `"wheel"`).
- [x] 1.3 Build a NixOS host's system closure with `hosts/test-vm` visible via the `path:` flake-ref scheme: `nix build 'path:/home/tom/desktop-flake#nixosConfigurations.test-vm.config.system.build.toplevel'`, and verify it succeeds.
- [x] 1.4 Inspect the built closure's Docker systemd unit (system-level `docker.service`, not a user unit this time) and verify it's a root-run system service, and verify `tom`'s configured groups include `docker`.

## 2. Spec sync

- [x] 2.1 Verify `openspec validate --change switch-docker-rootful --strict` passes, confirming the delta spec matches the shipped behavior.
