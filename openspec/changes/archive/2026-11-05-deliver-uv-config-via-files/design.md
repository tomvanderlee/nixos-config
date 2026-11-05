# Design

## Context

`modules/home/dev-tools.nix` sets the uv variables via `home.sessionVariables`. Home-manager only applies them if a shell sources `hm-session-vars.sh`, which neither the NixOS environment setup nor the dotfiles-owned `.bashrc` does on this host. The user's `EDITOR`/`VISUAL` have the same exposure but are not part of this change.

## Goals / Non-Goals

**Goals:** uv selects a managed CPython 3.14 in any shell, including one with no home-manager environment. **Non-Goals:** see proposal.md.

## Decisions

- **uv config files via `xdg.configFile`** instead of fixing shell sourcing: uv reads `~/.config/uv/uv.toml` and a user-level `.python-version` itself, so it works in non-login shells, IDEs, cron and systemd units, and on standalone home-manager or macOS (`~/.config/uv` is read there too). Alternatives: `environment.sessionVariables` on NixOS (system-wide, not applied to standalone machines), or sourcing `hm-session-vars.sh` from the dotfiles (touches a repo this one deliberately does not own).
- **`python-preference = "only-managed"` in `uv.toml`** keeps uv off the Nix `python3`; the option name matches the former environment variable's values.
- **`.python-version` with the series `3.14`**, which uv resolves to the latest managed 3.14.x. Project-level pins still win.
- **Remove the two session variables** rather than keep both, so there is one source of truth and no misleading, never-applied setting.

## Risks / Trade-offs

- [Both files are read-only symlinks into the Nix store] → Acceptable; edits go through this repo. `uv python pin --global` will fail to rewrite the file, which is intended.
- [A project needing a newer Python than 3.14 fails to resolve] → It pins its own version.
- [The existing `.venv` in `ttun-server` is Python 3.15] → Recreate it, only with the user's go-ahead.
