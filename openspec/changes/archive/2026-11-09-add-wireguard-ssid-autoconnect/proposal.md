# Proposal

## Why

Tom's WireGuard tunnel to the home network (NetworkManager profile `Home`, created in GNOME Settings) is pointless and harmful when already on the home LAN: it overlaps the local subnet and contributed to a DNS timeout problem when tested from inside it. Away from home it should be up without remembering to switch it on. Today it is toggled by hand and `autoconnect` is off.

## What Changes

- Add `modules/nixos/vpn-autoconnect.nix` with an opt-in option set `vpn.autoConnect` (`enable`, default `false`; `connectionName`, default `"Home"`; `trustedSsids`, default `[ ]`).
- When enabled, install a NetworkManager dispatcher script (declarative, via `networking.networkmanager.dispatcherScripts`) that reacts to a physical network coming up or going down and then decides once for the whole system:
  - **Trusted** if any wired (ethernet) connection is active, or any active Wi-Fi connection has an SSID listed in `trustedSsids`. The VPN is brought **down** if it is up.
  - **Untrusted** if there is at least one active Wi-Fi connection and none of the above holds. The VPN is brought **up** if it is down.
  - No physical connection: nothing is changed.
- Manual control stays intact: the script only runs on network up/down events, never on a timer or on VPN events, and never sets `autoconnect` on the profile. Turning the VPN on or off in the GNOME network menu persists until the next network up/down event, which re-evaluates.
- Enable it only on `toms-thinkpad` with `trustedSsids = [ "ErmeLan" ]`.
- Document the option and the manual-override behavior in `README.md`.
- **BREAKING**: none. Hosts that do not set the option are unchanged.

## Capabilities

### New Capabilities
- `wireguard-auto-connect`: opt-in, network-aware automatic connect/disconnect of an existing NetworkManager WireGuard profile, preserving manual control.

### Modified Capabilities
(none)

## Impact

- **Affected code**: new `modules/nixos/vpn-autoconnect.nix`, `lib/mkNixos.nix` (import it), `hosts/toms-thinkpad/configuration.nix`, `README.md`.
- **Not affected**: `modules/nixos/common.nix`, `hosts/template`, `flake.nix`, `lib/unfree-allowlist.nix`, home-manager modules (`wireguard-tools` already ships via the shared profile). The tunnel profile itself (keys, endpoint, DNS) stays in NetworkManager state created through GNOME Settings, not in Nix.
- **Overlap with in-flight work**: `add-headless-host-option` also edits `lib/mkNixos.nix`; the import lines may need a trivial merge.
- **Assumptions**: NetworkManager is the network manager on every host (true via `common.nix`); the profile named in `connectionName` already exists. If it does not, the script logs and does nothing.

## Non-goals

- Creating or managing the WireGuard profile, its keys, endpoint or DNS in Nix (secrets would need sops/agenix, out of scope).
- Per-network allowed-ips or routing changes, or fixing DNS server `192.168.10.43` on the profile.
- A persistent "pause auto-connect" switch; a manual toggle lasts until the next network event.
- Treating wired connections in untrusted places (hotels, offices) as untrusted; wired is always trusted by decision.
- Running `nixos-rebuild switch` without the user's approval.
