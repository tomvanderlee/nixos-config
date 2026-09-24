## Context

See proposal.md - Why. This covers the Docker daemon decisions; `uv` is a plain CLI-package addition with nothing else to decide.

Confirmed by reading the pinned `nixos-unstable` nixpkgs' `nixos/modules/virtualisation/docker-rootless.nix`:
- `virtualisation.docker.rootless.enable = true;` runs `dockerd-rootless` as a **user** systemd service (`systemd.user.services.docker`, `wantedBy = [ "default.target" ]`), gated by `ConditionUser = "!root"` — it does not run as a system-level root daemon and does not use the `docker` group at all (that's a rootful-mode concept only).
- `virtualisation.docker.rootless.setSocketVariable = true;` exports `DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock` for the user automatically, so the already-installed `docker` CLI (from `modules/home/dev-tools.nix`) finds the daemon with no per-user shell config.
- Rootless mode needs `newuidmap`/`newgidmap` (from `pkgs.shadow`, via `/run/wrappers`) and subuid/subgid ranges for the user; confirmed in `nixos/modules/config/users-groups.nix` that any `isNormalUser` account (which `tom` already is, in `modules/nixos/common.nix`) gets `autoSubUidGidRange = mkDefault true` for free — no extra config needed for `tom` specifically.

## Goals / Non-Goals

**Goals:**
- `docker`/`docker-compose` (already provisioned via `modules/home/dev-tools.nix`) work out of the box on any NixOS host from this flake, with no manual daemon setup or `DOCKER_HOST` export.
- No root-owned daemon process, and no `docker`-group privilege-escalation path (the well-known rootful-Docker security concern, since group membership in `docker` is root-equivalent).

**Non-Goals:**
- Rootful Docker, or a `docker` group — explicitly not used, per rootless choice.
- Managing Docker on the standalone (non-NixOS) `tom@linux`/`tom@darwin` home-manager profiles — those keep relying on an externally-managed runtime (Docker Desktop/OrbStack), unchanged from today.
- Any Kubernetes/cloud runtime — `kubectl`/`awscli2` remain explicitly client-only, per the narrowed `developer-environment` requirement.
- TLS/remote Docker API exposure, custom daemon settings (registries, storage drivers, etc.) — only the daemon itself is turned on, with defaults.

## Decisions

**Decision: rootless over rootful Docker.**
- User's explicit choice. Alternatives considered: rootful (`virtualisation.docker.enable = true;` + `users.users.tom.extraGroups = [ "docker" ]`) is the more common/simpler setup and has slightly broader compatibility (e.g. binding privileged ports below 1024, some volume-permission edge cases behave more predictably), but membership in the `docker` group is a well-documented root-equivalent privilege escalation (a container can bind-mount `/` and modify the host as root). Rootless avoids that entirely at the cost of those edge-case compatibility gaps.

**Decision: unconditional on every NixOS host, added inline to `modules/nixos/common.nix`.**
- User's explicit choice, matching the existing pattern for GNOME/SSH/printing/avahi in that same file — no per-host opt-in mechanism exists elsewhere in this repo for system services, so introducing one just for Docker would be an inconsistent one-off. Added inline rather than as a new `modules/nixos/docker.nix` file, consistent with how every other unconditional system-level concern in this repo (GNOME, SSH, dconf, pipewire, printing) already lives directly in `common.nix` rather than being split out.

**Decision: rely on nixpkgs' default `autoSubUidGidRange` rather than setting explicit `subUidRanges`/`subGidRanges` on `tom`.**
- Simpler, and confirmed correct by reading the actual default-assignment logic in `users-groups.nix` (`isNormalUser` + no explicit ranges set → `autoSubUidGidRange` defaults to `true`). Setting an explicit range would only add a pin to maintain for no behavioral benefit.

**Decision: narrow the existing `developer-environment` "client-only" requirement rather than leaving it as-is and letting the new `container-runtime` capability silently contradict it.**
- Alternatives considered: leaving the old requirement's blanket wording untouched and only adding `container-runtime` was rejected — a future reader of "Container and cloud tools are client-only" would have no indication Docker is now an exception, and `openspec validate`'s spec/behavior contract would be misleading. Explicitly naming Docker as the carved-out exception keeps the two capabilities' specs mutually consistent.

## Risks / Trade-offs

- [Rootless Docker has real compatibility gaps vs. rootful: binding ports <1024 needs extra config, some third-party images assume a rootful daemon, performance can be slightly lower due to the userspace network stack (slirp4netns/VPNKit-style)] → Accepted trade-off per the user's explicit security-over-compatibility choice; not mitigated further in this change.
- [The user systemd service only starts on user login (`wantedBy = [ "default.target" ]` at the *user* manager level), not at boot before any login] → Expected and consistent with rootless Docker's design (it's inherently tied to a logged-in user's session); not a regression from "no daemon at all" today.
- [`docker` package is already installed twice in concept — once via `modules/home/dev-tools.nix`'s `pkgs.docker` and again via `virtualisation.docker.rootless.package` which nixpkgs adds to `environment.systemPackages`] → Harmless: both resolve to the same nixpkgs `docker` derivation and Nix store paths dedupe; no functional conflict, just two provisioning paths converging on the same package (home-manager for cross-platform coverage, NixOS module as an inherent side effect of enabling the service).
