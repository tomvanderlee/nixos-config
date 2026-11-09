# Design

## Context

`modules/home/desktop-apps.nix` keeps a candidate list of GUI packages and filters it through `lib.meta.availableOn pkgs.stdenv.hostPlatform`. `pkgs.nextcloud-client` has `meta.platforms` limited to Linux architectures and a free license, so it needs neither a platform conditional nor an unfree allowlist entry. See proposal.md for motivation and assumptions.

## Goals / Non-Goals

**Goals:**
- Same provisioning path as the other GUI apps, with no new mechanism.

**Non-Goals:**
- Declarative accounts or autostart (see proposal).

## Decisions

- **Add to `crossPlatformApps`.** `availableOn` already removes it on darwin via `meta.platforms`. Alternative: `linuxOnlyApps` for explicitness; equivalent but redundant.
- **Package only, no `services.nextcloud-client`.** The home-manager service would add a systemd user unit that starts the client in the background. Alternative rejected because the client's own startup toggle does the same without Nix-managed state, the unit would need gating by the pending `add-headless-host-option` (`desktop.enable`) change, and stock GNOME has no tray for the client's icon anyway.
- **No secrets in the repo.** First run uses the client's login flow (browser-based app password grant); credentials land in the GNOME keyring.

## Risks / Trade-offs

- [Manual per-machine sign-in] → Accepted; documented in README.
- [Tray icon invisible on stock GNOME] → The client works without it; `gnome-extension-manager` is already provisioned if an AppIndicator extension is wanted.
- [Closure is large (Qt/KDE frameworks)] → Accepted; binary-cached.
