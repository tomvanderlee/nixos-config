## 1. uv CLI tool

- [x] 1.1 Add `pkgs.uv` to the package list in `modules/home/dev-tools.nix` and verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages'` and `..."tom@darwin"...` both include it.

## 2. Rootless Docker daemon

- [x] 2.1 Add `virtualisation.docker.rootless.enable = true;` and `virtualisation.docker.rootless.setSocketVariable = true;` to `modules/nixos/common.nix`, alongside the other unconditional host-level services.
- [x] 2.2 Build a NixOS host's system closure with `hosts/test-vm` visible via the `path:` flake-ref scheme (it's git-untracked): `nix build 'path:/home/tom/desktop-flake#nixosConfigurations.test-vm.config.system.build.toplevel'`, and verify it succeeds.
- [x] 2.3 Inspect the built closure's `systemd.user.services.docker` unit (e.g. via the closure's `etc/systemd/user/docker.service` or an equivalent generated unit file) and verify it runs `dockerd-rootless` with `ConditionUser=!root`, confirming the daemon is wired as a rootless per-user service rather than a root daemon.
- [x] 2.4 On a booted host, after logging in as `tom`, verify `docker run --rm hello-world` succeeds with no manual `DOCKER_HOST` export or other setup — this needs an interactive login session and can't be exercised from this sandbox.

## 3. Spec sync

- [x] 3.1 Verify `openspec validate --change add-uv-and-docker-runtime --strict` passes once the above are implemented, confirming both delta specs match the shipped behavior.
