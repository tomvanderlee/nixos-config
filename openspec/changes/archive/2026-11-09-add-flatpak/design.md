# Design

## Context

`modules/nixos/common.nix` already carries system services every host gets (Docker, nix-ld, GNOME stack). NixOS provides `services.flatpak.enable`, which installs Flatpak, enables its D-Bus/polkit services and `xdg.portal`. It does not add any remote, so `flatpak install` fails until one exists. GNOME is enabled in the same file, so portal backends (`xdg-desktop-portal-gnome`) are already pulled in.

## Goals / Non-Goals

**Goals:**
- `flatpak install flathub <app-id>` works after first boot with no manual setup.
- Builds and switches never depend on network access.

**Non-Goals:**
- Declarative app lists, other remotes, standalone home-manager support (see proposal).

## Decisions

- **Put it in `common.nix`, no new option.** Matches how Docker is handled (on for every host). Alternative: opt-in `development`-style option in a new module as with `dev-postgresql`/`zfs`; rejected because Flatpak has no meaningful cost or security exposure when unused and the user wants it as a default capability. The in-flight `add-headless-host-option` change can later move it under the `desktop.enable` gate if wanted; the two touch different lines of `common.nix`.
- **Add Flathub with a one-shot systemd unit** (`wantedBy = multi-user.target`, `after = network-online.target`, `flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo`), the pattern recommended on the NixOS wiki. Alternative: tell the user to run the command once by hand; rejected as not reproducible. The unit does not use `ExecStart` failure as a boot blocker: it is not a dependency of anything, so failure offline only leaves the unit failed and it retries on the next boot/switch.
- **System-level install, not per-user.** The remote is system-wide so `flatpak install` works for any user; users may still use `--user`.

## Risks / Trade-offs

- [Flatpak apps are outside Nix's reproducibility and unfree allowlist] → Accepted; documented in README as the escape hatch for apps nixpkgs lacks.
- [Unit fails when offline at boot] → Harmless, `--if-not-exists` makes the retry idempotent; verified in tasks by inspecting the unit rather than requiring network in checks.
- [Flatpak apps and the fprintd/Bitwarden browser integration may need extra portals or permissions] → Out of scope; handle per app.
