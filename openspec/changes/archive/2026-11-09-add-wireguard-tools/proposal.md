# Proposal

## Why

Tom needs to debug WireGuard connections (inspect handshakes, transfer counters and peer endpoints, generate keys, bring tunnels up and down by hand). The `wg` and `wg-quick` commands come from `wireguard-tools`, which is not in the shared profile, so each debugging session starts with `nix shell nixpkgs#wireguard-tools`.

## What Changes

- Add `wireguard-tools` (provides `wg`, `wg-quick`) to the CLI packages in `modules/home/dev-tools.nix`, so it is on `PATH` wherever the shared home profile is activated.
- Add one requirement to the `developer-environment` capability stating that these commands are provisioned.
- **BREAKING**: none.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `developer-environment`: adds a requirement that the WireGuard command-line tools are provisioned by the shared home profile.

## Impact

- **Affected code**: `modules/home/dev-tools.nix`.
- **Not affected**: `modules/nixos/common.nix` (no WireGuard interfaces, kernel settings or firewall rules), `lib/unfree-allowlist.nix` (wireguard-tools is GPL-2.0, free), `flake.nix`, `hosts/*`.
- **Assumptions**: Placed next to the other client CLIs in `dev-tools.nix` rather than `cli-tools.nix` (which holds general shell utilities). Most `wg` subcommands (`show`, `set`) and `wg-quick` need root; the user runs them with `sudo`. WireGuard itself is in the Linux kernel, so no NixOS module is needed for inspection.

## Non-goals

- Configuring tunnels or peers declaratively (`networking.wireguard`, `wg-quick` interfaces, `networking.firewall` ports, secrets).
- Other network debugging tools (tcpdump, mtr, etc.); can be a separate change if wanted.
- Making `wg` runnable without `sudo`.
