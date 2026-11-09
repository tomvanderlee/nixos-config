# Design

## Context

`modules/nixos/common.nix` enables NetworkManager on every host; the `Home` WireGuard profile (peer `192.168.0.0/16`, DNS and keys) lives in `/etc/NetworkManager/system-connections`, created through GNOME Settings, `autoconnect=no`. Opt-in system modules (`zfs.nix`, `dev-postgresql.nix`) are imported unconditionally by `lib/mkNixos.nix` and gated by an option, with the per-host `configuration.nix` turning them on. See proposal.md for motivation.

Observed on the ThinkPad: wired is `enp0s13f0u3u4` (a USB dock, type `802-3-ethernet`), Wi-Fi is `wlp0s20f3`, and container bridges/veths (`docker0`, `br-*`) emit NetworkManager events of type `bridge`/`veth`.

## Goals / Non-Goals

**Goals:** declarative, repeatable policy ("untrusted network → VPN up, trusted → down") that keeps GNOME UI toggling working. **Non-Goals:** see proposal.md.

## Decisions

- **NetworkManager dispatcher script** via `networking.networkmanager.dispatcherScripts` (type `basic`), written with `pkgs.writeShellScript` and a fixed PATH (`networkmanager`, `coreutils`, `gnugrep`). Alternatives: a systemd service polling `nmcli` (extra moving part, needs its own timers); NM's per-profile `connection.secondaries` (imperative state outside the repo, no "trusted" inversion, would have to be set on every untrusted Wi-Fi profile, and it re-attaches on reconnect so it would fight manual overrides).
- **Trigger events: `up` and `down`** only, and only when the event's device type is `wifi` or `ethernet`. Events from `wg0`, `lo`, bridges and veths are ignored, which also prevents the script from reacting to its own `nmcli connection up/down`.
- **Decide from global state, not the single event.** On each trigger the script lists active connections (`nmcli -t -f TYPE,NAME connection show --active`), then:
  1. any `802-3-ethernet` → trusted
  2. else any active `802-11-wireless` whose SSID is in `trustedSsids` → trusted. The SSID is read from the connection profile (`nmcli -g 802-11-wireless.ssid connection show <name>`), so it matches the configured SSID even for hidden or renamed profiles.
  3. else any active `802-11-wireless` → untrusted
  4. else (no physical connection) → do nothing.
  Doing this globally makes dock/undock and roaming order-independent: unplugging while on `ErmeLan` stays trusted, replugging at an untrusted Wi-Fi resolves to trusted until unplugged.
- **Idempotent actions**: only call `nmcli connection up|down` when the current state differs; check whether the profile name appears in the same active-connection list (`nmcli -t -f NAME connection show --active`). Failures are logged with `logger -t vpn-autoconnect` and the script always exits 0.
- **Manual override by absence of persistence.** The script writes nothing to NetworkManager (`autoconnect` untouched) and never runs on VPN events or timers, so a GNOME toggle sticks until the next physical up/down. Deliberate consequence: a Wi-Fi roam or reconnect re-applies policy.
- **Module and scope**: `modules/nixos/vpn-autoconnect.nix`, imported in `lib/mkNixos.nix`, enabled in `hosts/toms-thinkpad/configuration.nix` with `trustedSsids = [ "ErmeLan" ]`. Not in `common.nix` (the `Home` profile only exists on Tom's machines).
- **SSID as a string in the Nix config**: SSIDs are not secret. Shell-escape with `lib.escapeShellArg` and compare exactly (including curly apostrophes).

## Risks / Trade-offs

- [Wired is always trusted, including in untrusted places] → Deliberate (decided with the user); a hotel cable leaves the VPN down, and the user can toggle it manually.
- [Event ordering at boot/resume: profile or secrets not available yet] → The script logs and exits 0; the next network event retries. Manual toggle is always available.
- [Wi-Fi reconnects re-override a manual "off"] → Documented in README and the spec; a persistent pause switch is a non-goal.
- [Dispatcher runs as root with user-influenced SSID text] → The SSID is only compared, never executed; the trusted list is Nix-evaluated and escaped.
- [Manual VPN-up on a trusted network behind the same subnet (the `192.168.10.0/24` overlap)] → Existing behavior, unchanged; not fixed here.
- [`wg0` coming up resets DNS order] → NetworkManager owns `resolv.conf` here (no systemd-resolved); the profile's DNS is the user's responsibility (non-goal).

## Migration Plan

Show the diff, ask, then `nixos-rebuild switch`. Verify with `journalctl -t vpn-autoconnect` while switching networks. Rollback: set the option to `false` or boot the previous generation; the `Home` profile is untouched either way.
