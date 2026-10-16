# Design

## Context

`modules/nixos/common.nix` applies the whole GNOME stack unconditionally; `modules/home/desktop-apps.nix` already reads `osConfig ? null` to detect GNOME. `hosts/test-vm` is a graphical VM and must keep working. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- One host-level switch that turns off the desktop and all GUI apps.
- No change for existing hosts.

**Non-Goals:**
- Finer-grained toggles (audio only, printing only).
- Changing standalone defaults.

## Decisions

- **A NixOS option `desktop.enable` in `modules/nixos/desktop.nix`, default `true`**, instead of a separate headless module or host-level `mkForce` overrides: one explicit, discoverable switch, and defaults preserve behaviour. The desktop settings in `common.nix` move into `lib.mkIf config.desktop.enable`. `lib/mkNixos.nix` imports the new module next to `common.nix`.
- **Home option `home.desktop.enable` defaulting to `osConfig.desktop.enable or true`**, defined in `desktop-apps.nix`. The alternative of reading `osConfig` inline in the package list would give standalone Linux machines no opt-out. The existing `osConfig ? null` convention is reused.
- **GNOME-only apps keep their `gnome.enable` check** and are additionally behind the desktop option, so a host that disables the desktop loses them by either path.
- **NetworkManager stays enabled everywhere**: a headless VM needs working networking to be reachable over SSH, and NetworkManager's DHCP default does that without extra config. Moving it would add a replacement networking config for no gain.
- **`--headless` edits a placeholder line in the template**: the template gets a commented `# desktop.enable = false;` line, and the script uncomments it with `sed`, the same mechanism it already uses for the CHANGEME values. Appending text blindly would be fragile if the template changes.

## Risks / Trade-offs

- [Moving settings out of `common.nix` could drop or alter one] → Verify the `test-vm` toplevel derivation path is identical before and after for a desktop host.
- [Headless host still pulls in some desktop-adjacent packages through other options] → Verify with `nix path-info`/`nix-store -q --requisites` that no `gnome-shell` appears in the headless closure.
- [Template placeholder drift] → Cover the flag with a test that scaffolds a host into a temp dir and evaluates it.
