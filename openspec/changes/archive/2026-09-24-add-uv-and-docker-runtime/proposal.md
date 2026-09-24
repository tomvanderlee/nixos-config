## Why

Tom wants `uv` (the Python package/project manager) available as a CLI tool, and — after clarifying the request — wants NixOS hosts to actually run a Docker daemon rather than just the client CLI that's already provisioned, so `docker run`/`docker build` work without a separately-managed runtime.

## What Changes

- Add `pkgs.uv` to `modules/home/dev-tools.nix`'s CLI package list. Verified against the flake's pinned `nixos-unstable` nixpkgs: dual Apache-2.0/MIT licensed (free), broad platform support including `aarch64-darwin`/`x86_64-linux`/`aarch64-linux`. No spec change needed — `developer-environment`'s existing "Developer CLI tools are provisioned via the shared home profile" requirement already covers adding another evidenced CLI tool to the list, the same reasoning previously used for `bitwarden-cli` and `claude-code`.
- Enable a **rootless** Docker daemon (`virtualisation.docker.rootless.enable = true;` plus `virtualisation.docker.rootless.setSocketVariable = true;`) unconditionally on every NixOS host, in `modules/nixos/common.nix`, alongside the other unconditional host-level services (GNOME, SSH, printing). Rootless runs the daemon as a per-user systemd user service under `tom`'s own UID rather than as root — no `docker`-group privilege-escalation path, unlike the standard rootful setup. `setSocketVariable` makes the already-installed `docker` CLI (from `dev-tools.nix`) find the rootless socket automatically via `$DOCKER_HOST`, with no extra per-user config.
- **This reverses part of the existing "Container and cloud tools are client-only" policy** for Docker specifically: `developer-environment`'s spec currently states container/cloud tools SHALL NOT manage the underlying runtime. Docker becomes an explicit, called-out exception; `kubectl` and `awscli2` remain client-only as before (no Kubernetes cluster or cloud account is being provisioned).
- **BREAKING**: none — additive only. Existing `docker`/`docker-compose` CLI usage against an externally-managed runtime (e.g. Docker Desktop/OrbStack on macOS) is unaffected; this only changes NixOS hosts, where no runtime was being managed before.

## Capabilities

### New Capabilities
- `container-runtime`: provides a working, unprivileged (rootless) Docker container runtime on every NixOS host built from this flake, so the already-provisioned `docker`/`docker-compose` CLI tools have something to talk to without a separately-managed daemon.

### Modified Capabilities
- `developer-environment`: narrow the "Container and cloud tools are client-only" requirement to explicitly exclude Docker, which is now backed by the `container-runtime` capability on NixOS hosts; `kubectl` and `awscli2` remain covered by the original client-only rule.

## Impact

- **Affected code**: `modules/home/dev-tools.nix` (add `pkgs.uv`), `modules/nixos/common.nix` (add `virtualisation.docker.rootless.enable`/`setSocketVariable`).
- **Not affected**: `lib/unfree-allowlist.nix` (uv is free-licensed; Docker's daemon package in nixpkgs is Apache-2.0), `modules/home/desktop-apps.nix`.
- **Dependencies**: nixpkgs' `uv` and `docker` (already used) packages, both already present in the pinned `nixos-unstable` input; no new flake inputs.
- **Platforms**: `uv` is provisioned cross-platform like the rest of `dev-tools.nix`. The Docker daemon change only applies to NixOS hosts (`modules/nixos/common.nix`); it has no effect on the standalone `tom@linux`/`tom@darwin` home-manager profiles, which continue to rely on whatever runtime is already present on that machine (e.g. Docker Desktop/OrbStack on macOS), exactly as documented today.
- **Known limitation, out of scope**: no Docker daemon TLS/remote-access configuration, no Docker Compose v1-vs-v2 plugin wiring changes, and no `nix-ld`/extra container-toolchain packages beyond what's already provisioned — this only turns on the daemon itself.
