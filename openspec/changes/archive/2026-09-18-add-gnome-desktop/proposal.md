## Why

NixOS hosts built from this flake currently have no desktop environment at all — just a headless system. The user wants GNOME enabled as the default desktop on every NixOS system this flake provisions.

## What Changes

- `modules/nixos/common.nix` gains: `services.xserver.enable`, `services.displayManager.gdm.enable`, `services.desktopManager.gnome.enable` — GNOME with GDM as the login manager, applied unconditionally to every NixOS host (not an opt-in per-host module), confirmed via direct Q&A.
- `networking.networkmanager.enable = true` — required for GNOME's own network settings UI to function.
- `services.pipewire` (`enable`, `pulse.enable`) + `security.rtkit.enable` — the standard NixOS audio stack GNOME expects.
- `services.printing.enable = true` (CUPS) + `services.avahi` (`enable`, `nssmdns4`, `openFirewall`) — printing support with network/AirPrint printer discovery, added per explicit user request; `openFirewall` so the firewall enabled in the prior `add-developer-environment` change doesn't block discovery traffic.
- Update `README.md` to document that NixOS hosts now boot into GNOME by default, with these companions.

## Capabilities

### New Capabilities
- `gnome-desktop`: NixOS hosts built from this flake boot into a working GNOME desktop (login manager, networking, audio, printing) by default.

### Modified Capabilities
(none — this doesn't change any requirement from `nix-flake-bootstrap`, `dotfiles-management`, or `developer-environment`; it's a new, additive system capability)

## Impact

- Affected code: `modules/nixos/common.nix`, `README.md`.
- Applies to every NixOS host built from this flake going forward. There is still no live NixOS host (only `hosts/template/`), so this only takes effect once a real host is scaffolded via `scripts/bootstrap-host.sh` — same situation as every prior NixOS-side change in this repo.
- Nix is still not installed on this development machine, so the exact module option paths (`services.displayManager.*`/`services.desktopManager.*`, which NixOS has been migrating out of the older `services.xserver.displayManager.*`/`services.xserver.desktopManager.*` nesting) can only be verified by manual review here, not by actually building — flagged explicitly as an implementation-time risk, not asserted with full confidence.
- Out of scope: per-user GNOME customization (dconf settings, Shell extensions), and any change to the user's existing `~/dotfiles` `herbstluftwm`/`xorg` packages, which this change doesn't touch.
