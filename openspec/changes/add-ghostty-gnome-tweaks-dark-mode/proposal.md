## Why

Tom wants Ghostty as an available terminal emulator (with its config stowed from the personal dotfiles repo, same as any other dotfiles package), GNOME Tweaks available for customizing desktop settings, and GNOME to boot into dark mode by default instead of the current light default.

## What Changes

- Add `pkgs.ghostty` to `modules/home/desktop-apps.nix`'s cross-platform app list, following the existing `lib.meta.availableOn` filtering pattern. Verified against the flake's pinned `nixos-unstable` nixpkgs: `ghostty` is MIT-licensed and currently builds only on Linux platforms there (no `darwin` entries in `meta.platforms` yet) — the existing availableOn filter already excludes it on `tom@darwin` without any code change, per the desktop-applications capability's existing "unsupported packages are skipped" requirement.
- No dotfiles-module change for stowing Ghostty's config: `modules/home/dotfiles.nix` already stows every top-level package directory in the cloned dotfiles repo except platform-default or explicitly excluded ones, and `ghostty` is not in either exclude list — so once a `ghostty/` package directory exists in the dotfiles repo, it is symlinked automatically by the existing behavior. Nothing to change here; noted for clarity since the request called it out explicitly.
- Add `pkgs.gnome-tweaks` to `modules/home/desktop-apps.nix`, gated on GNOME actually being enabled rather than merely on Linux: `lib.optional (osConfig.services.desktopManager.gnome.enable or false) pkgs.gnome-tweaks`, requiring `osConfig ? null` to be added to the module's function signature (see design.md). `modules/home/desktop-apps.nix` is shared by both every NixOS host (where GNOME is force-enabled) and the standalone, non-NixOS `homeConfigurations."tom@linux"` — a plain `isLinux` gate (the `teams-for-linux` pattern) would wrongly install GNOME Tweaks on the latter, which has no GNOME. Verified GPL-3.0-or-later license — no unfree-allowlist change needed.
- Add a system-wide GNOME dark-mode default to `modules/nixos/common.nix`, alongside the existing `services.desktopManager.gnome.enable = true;`, via NixOS's dconf default-database mechanism (`org/gnome/desktop/interface color-scheme = "prefer-dark"`). This sets the *default* only — it does not lock the setting, so a user can still switch back to light mode from GNOME Settings. Design in `design.md` covers the exact NixOS option used.
- **BREAKING**: none — additive only. Existing users who already manually switched to dark or light mode are unaffected by a default (dconf defaults only apply where no user value is already set).

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `desktop-applications`: add a requirement that Ghostty is provisioned via the shared home profile like Firefox/Bitwarden (cross-platform, filtered by package availability), plus a separate requirement that GNOME Tweaks is provisioned only where GNOME is enabled (NixOS hosts), not merely wherever the package builds (any Linux).
- `gnome-desktop`: add a requirement that every NixOS host built from this flake's shared system module defaults its GNOME session to dark mode, while leaving the setting user-changeable.

(`dotfiles-management` is unaffected at the requirement level: Ghostty's dotfiles package is stowed automatically under the existing "non-excluded package is still stowed" requirement — no new or changed requirement needed.)

## Impact

- **Affected code**: `modules/home/desktop-apps.nix` (add `ghostty` to `crossPlatformApps`; add `osConfig ? null` to the module's arguments and a new `osConfig`-gated `gnome-tweaks` entry, kept separate from `linuxOnlyApps`), `modules/nixos/common.nix` (add dconf default-database config for dark mode).
- **Not affected**: `lib/unfree-allowlist.nix` (both new packages are free-licensed), `modules/home/dotfiles.nix` (Ghostty's dotfiles package needs no exclude-list or code change to be stowed).
- **Dependencies**: nixpkgs' `ghostty` and `gnome-tweaks` packages (already present in the pinned `nixos-unstable` input; no new flake inputs). The personal dotfiles repo (`https://git.tomvanderlee.com/dotfiles`, cloned via `home.dotfiles.repoUrl` in `users/tom.nix`) is expected to already contain, or will need, a top-level `ghostty/` package directory for its config to actually be stowed — that repo lives outside this flake and is out of scope for this change to edit.
- **Platforms**: Ghostty is Linux-only in nixpkgs today, so it doesn't appear on `tom@darwin`. GNOME Tweaks is gated on GNOME being enabled rather than on platform: it appears in a NixOS host's home-manager activation (e.g. `nixosConfigurations.test-vm`'s `home-manager.users.tom`) but not in the standalone `homeConfigurations."tom@linux"` or `"tom@darwin"`, even though `tom@linux` is technically Linux. The dark-mode default likewise only applies to NixOS hosts.
- **Known limitation, out of scope**: this change does not modify the external dotfiles repository itself (creating a `ghostty/` package there is a separate, out-of-flake step); it also does not lock the dark-mode dconf key, so it is a default rather than an enforced policy, per the request wording ("enabled by default").
