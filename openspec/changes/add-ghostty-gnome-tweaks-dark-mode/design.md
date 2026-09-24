## Context

See proposal.md - Why. This section covers two decisions with real alternatives: how to make GNOME default to dark mode system-wide, as a *default* rather than an enforced policy; and how to scope GNOME Tweaks to only the profile activations where GNOME actually exists.

`modules/nixos/common.nix` already sets `services.desktopManager.gnome.enable = true;` for every NixOS host (see `openspec/specs/gnome-desktop/spec.md`), which transitively enables NixOS's dconf module (`programs.dconf`, defined in `nixos/modules/programs/dconf.nix` in the pinned `nixos-unstable` nixpkgs). That module already ships the primitive needed here: `programs.dconf.profiles.<name>.databases`, a list of dconf keyfile databases merged into the named profile (`user` by default).

Key mechanics confirmed by reading that module's source:
- A profile's databases are searched top-to-bottom, first match wins, *except* the live, user-writable dconf database (`user-db:user`), which is prepended automatically (`enableUserDb = true` by default) and is therefore always searched **before** any `databases` entries.
- This means a value written into `programs.dconf.profiles.user.databases[].settings` acts as a fallback: it only applies where the user hasn't already written their own value via `dconf write` / GNOME Settings. No `locks` entry is needed (and none is added) — adding one would make the value mandatory instead of a default, which is not what was asked for ("enabled by default", not "enforced").

`modules/home/desktop-apps.nix` (and the rest of `modules/home/`) is consumed two ways: by every NixOS host, via `lib/mkNixos.nix`'s home-manager integration; and by the standalone, non-NixOS `homeConfigurations."tom@linux"`/`"tom@darwin"`, via `lib/mkHome.nix` (see README: "any Linux now"). Only the former actually has GNOME enabled — the latter is a generic Linux/macOS home-manager profile with no GNOME involved at all. Confirmed by reading the locked `home-manager` input's `nixos/common.nix` (the module backing `inputs.home-manager.nixosModules.home-manager`): the NixOS integration passes each user's home-manager modules an `osConfig` specialArg set to the full NixOS `config`. That specialArg exists only when home-manager is evaluated as part of a NixOS (or nix-darwin) system; `lib/mkHome.nix`'s standalone `homeManagerConfiguration` never supplies it.

## Goals / Non-Goals

**Goals:**
- Every NixOS host from this flake boots new user sessions into GNOME dark mode without per-host or per-user opt-in.
- The setting remains a normal, user-changeable GNOME Settings toggle.
- GNOME Tweaks is provisioned exactly where GNOME is present, not merely wherever the package happens to build (i.e. not "any Linux").

**Non-Goals:**
- Locking or enforcing dark mode (`lockAll` / `locks` are intentionally not used).
- Managing dark-mode-equivalent settings for individual apps (e.g. Firefox's own theme, GTK app-specific accent colors) — only the GNOME shell/interface-level `color-scheme` key is covered.
- Any home-manager-level (per-user Nix) implementation — this is a NixOS system module change only, matching where `gnome-desktop`'s other requirements already live (`modules/nixos/common.nix`), and it is Linux/GNOME-specific so it does not belong in the cross-platform `modules/home/*` tree.

## Decisions

**Decision: implement via `programs.dconf.profiles.user.databases`, not home-manager's `dconf.settings`.**
- Alternatives considered: home-manager exposes its own `dconf.settings` option per-user. Rejected because (a) `modules/home/*.nix` is shared across both `tom@linux` and `tom@darwin` home-manager configurations, and dconf/GNOME concepts don't apply on Darwin — it would need an `isLinux` guard for no benefit; (b) the `gnome-desktop` capability's other requirements are all expressed as NixOS system module config in `modules/nixos/common.nix`, keyed off "every NixOS host," not per-configured-home-manager-user, so the NixOS-level mechanism is the better fit and requires no per-user wiring at all — it applies to any user account on the host, including ones outside this flake's home-manager scope.

**Decision: set only `org/gnome/desktop/interface color-scheme = "prefer-dark"`, no `gtk-theme`/`icon-theme` overrides.**
- `color-scheme` is the single key GNOME Shell (and GTK4/libadwaita apps) read to decide light vs. dark; setting it is sufficient for "dark mode" as commonly understood and matches exactly what GNOME Settings' Appearance toggle itself writes. Also setting a specific dark GTK theme name was considered and rejected as unnecessary scope — GNOME's stock Adwaita theme already responds to `color-scheme` directly.

**Decision: no lock, so the default only applies until the user changes it themselves.**
- Matches the request's literal phrasing ("dark mode ... enabled by default") rather than "enforced." Also avoids surprising a user who deliberately switches to light mode having it reset.

**Decision: gate GNOME Tweaks on `osConfig.services.desktopManager.gnome.enable`, not on `pkgs.stdenv.hostPlatform.isLinux`.**
- Alternatives considered:
  - `isLinux`, matching the existing `teams-for-linux` pattern — this was the first draft, and is wrong: `modules/home/desktop-apps.nix` is also consumed by the standalone, non-NixOS `homeConfigurations."tom@linux"`, which has no GNOME involved at all. `isLinux` would install GNOME Tweaks there regardless.
  - Checking only `osConfig != null` (i.e. "are we integrated into any NixOS system at all") — rejected as less precise than checking the actual `gnome.enable` value: it would silently keep installing GNOME Tweaks if a future NixOS host in this flake ever disabled GNOME.
  - Chosen: `(osConfig.services.desktopManager.gnome.enable or false)`. Requires adding `osConfig ? null` to `modules/home/desktop-apps.nix`'s function signature so the module still evaluates standalone, where `osConfig` is never supplied.
- Effect: `teams-for-linux` keeps its existing `isLinux`-only gating in `linuxOnlyApps` (it works on any Linux desktop, no GNOME dependency). GNOME Tweaks is not added to that list; it gets its own `lib.optional (osConfig.services.desktopManager.gnome.enable or false) pkgs.gnome-tweaks`, combined into the same filtered package list.

## Risks / Trade-offs

- [A user who already has an existing dconf database with no explicit `color-scheme` value keeps seeing whatever GNOME's own compiled-in default was before this change (light) until dark mode is written by the new default db] → Not applicable in practice: the new default database is searched immediately after the user db on every session; since the user never wrote `color-scheme` explicitly, the fallback applies from the next login onward with no migration step needed.
- [`programs.dconf.enable` might not be implied for every code path that sets `services.desktopManager.gnome.enable`] → Mitigate by explicitly setting `programs.dconf.enable = true;` alongside the new `profiles.user.databases` entry in `modules/nixos/common.nix`, rather than relying on it being pulled in transitively.
- [`osConfig` could in principle be absent for a reason other than "standalone, no GNOME" in some future home-manager version] → Mitigated by using `osConfig ? null` with an explicit `or false` fallback rather than assuming absence means anything specific: the check degrades safely to "excluded" whether `osConfig` is missing entirely or present with GNOME disabled.

## Migration Plan

Purely additive NixOS module config; takes effect on next `nixos-rebuild switch` and next user login (dconf reads happen at session start, not via hot-reload of the system config). No rollback concerns beyond reverting the module change — no data migration, no locked state to undo.
