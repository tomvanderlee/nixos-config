## Context

See proposal.md - Why. `add-uv-and-docker-runtime`'s design.md chose rootless specifically to avoid `docker`-group root-equivalent access, accepting rootless's compatibility gaps as the trade-off. That trade-off didn't hold up: the rootless per-user systemd service (`systemd.user.services.docker`, `wantedBy = [ "default.target" ]` at the *user* manager level) doesn't get started in a session that was already active before the switch — NixOS's `nixos-rebuild switch` reloads and restarts *system* units automatically, but does not reach into already-running per-user systemd managers to link and start newly-enabled user units. Combined with `DOCKER_HOST` only being exported into freshly-started shells (via `environment.extraInit` → `/etc/profile`), a user mid-session sees exactly the failure Tom hit: the `docker` CLI falls back to the default rootful socket path, which doesn't exist because no rootful daemon was ever configured.

## Goals / Non-Goals

**Goals:**
- `docker` CLI commands work reliably without session-timing caveats — the daemon should be up as soon as the system has booted, regardless of who's logged in or when.
- No manual per-session environment setup (`DOCKER_HOST`) required.

**Non-Goals:**
- Re-attempting rootless with a fix for the session-timing issue (e.g. instructing users to always log out/in after a switch) — rejected as more operational friction than it's worth for a single-user desktop/dev machine; the security benefit of rootless is being deliberately traded away here.
- Any change to the `docker`/`docker-compose` CLI packages themselves (`modules/home/dev-tools.nix`) — unaffected either way.
- Docker daemon TLS/remote-access configuration — out of scope, same as before.

## Decisions

**Decision: rootful (`virtualisation.docker.enable = true;`) over continuing to debug rootless.**
- Alternatives considered: (a) keep rootless, document "log out and back in after any switch that touches Docker" — rejected, this is a real, easy-to-forget footgun on a machine where the whole point is long-lived desktop sessions; (b) keep rootless but add a `systemd.user.services.docker` restart hook to `nixos-rebuild switch` itself — not a supported NixOS mechanism for reaching into other users' already-running session managers, would require nonstandard tooling; (c) rootful — accepted, standard system-service semantics (starts at boot, `nixos-rebuild switch` restarts system units automatically like every other service in this repo, e.g. GDM/SSH/dconf), well-trodden path, and matches how every other service in `modules/nixos/common.nix` already behaves.

**Decision: use `tom`'s group membership (`extraGroups = [ "wheel" "docker" ]`) rather than requiring `sudo docker ...`.**
- Requiring `sudo` for every Docker command would be significant day-to-day friction for a dev machine and isn't how Docker is conventionally used; group membership is the standard, documented NixOS/Docker pattern. This is the security trade-off being explicitly accepted: `docker` group membership is root-equivalent (a container can bind-mount `/` and modify the host), same risk profile most NixOS Docker users accept by default.

## Risks / Trade-offs

- [`docker` group membership is root-equivalent — any process able to run `docker` commands as `tom` can trivially become root on the host] → Explicitly accepted per the user's request; this is the well-known, standard trade-off of rootful Docker, and the alternative (rootless) already proved less reliable in practice on this machine.
- [Anyone who already had the rootless daemon actually running before this switch loses access to whatever images/containers existed in the rootless-specific storage path] → Not applicable here: the rootless daemon never successfully served a `docker run` in practice (that's the bug being fixed), so there's nothing to migrate.
