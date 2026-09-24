## Why

The rootless Docker setup from `add-uv-and-docker-runtime` broke in practice: `docker run` failed with `failed to connect to the docker API at unix:///var/run/docker.sock ... no such file or directory` after a `nixos-rebuild switch`, because a newly-enabled `systemd.user.services.docker` unit doesn't start in an already-logged-in session, and `$DOCKER_HOST` (exported via `environment.extraInit`) only reaches freshly-started shells — both are real, recurring friction for a desktop dev machine where sessions stay open for days. Tom asked to switch to standard rootful Docker instead.

## What Changes

- Replace `virtualisation.docker.rootless.enable`/`setSocketVariable` in `modules/nixos/common.nix` with `virtualisation.docker.enable = true;` (the standard rootful daemon, a system-level service rather than a per-user systemd unit).
- Add `"docker"` to `tom`'s `extraGroups` in `modules/nixos/common.nix` (alongside the existing `"wheel"`), so `tom` can use the Docker socket without `sudo`. This is the rootful equivalent of the rootless setup's `DOCKER_HOST` auto-export — standard mechanism, well-documented NixOS pattern.
- **This reverses the explicit rootless decision** made in `design.md` for `add-uv-and-docker-runtime` (chosen specifically to avoid `docker`-group root-equivalent privilege escalation). Trade-off is now accepted deliberately: `docker` group membership is root-equivalent (a container can bind-mount `/` and modify the host as root), but the daemon runs as a system service that starts at boot (not tied to a logged-in session) and needs no `DOCKER_HOST` env-var propagation, avoiding the exact class of bug just hit.
- **BREAKING**: for anyone who already has a rootless daemon running (e.g. before switching, if a session picked it up), those containers/images live in a different rootless-specific storage location and won't carry over to the rootful daemon's storage — acceptable here since the rootless setup never successfully ran a container in practice.

## Capabilities

### Modified Capabilities
- `container-runtime`: switch from a per-user rootless Docker daemon to a system-level rootful Docker daemon, on every NixOS host.

## Impact

- **Affected code**: `modules/nixos/common.nix` (swap `virtualisation.docker.rootless.*` for `virtualisation.docker.enable` and `tom`'s group membership).
- **Not affected**: `modules/home/dev-tools.nix` (the `docker`/`docker-compose` CLI packages are unchanged — same client either way), `lib/unfree-allowlist.nix` (Docker is free-licensed regardless of mode).
- **Dependencies**: none new — `virtualisation.docker.enable` is the same nixpkgs module family as the rootless option already in use.
- **Platforms**: NixOS hosts only, same scope as before.
