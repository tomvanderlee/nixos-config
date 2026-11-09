# Tasks

Never run `nixos-rebuild switch` without asking the user first. Show the full diff before asking.

## 1. Module

- [x] 1.1 Create `modules/nixos/vpn-autoconnect.nix` with `vpn.autoConnect.{enable,connectionName,trustedSsids}` (defaults `false`, `"Home"`, `[ ]`). When enabled, add a `basic` dispatcher script via `networking.networkmanager.dispatcherScripts` implementing the spec: act only on `up`/`down` for wifi/ethernet devices; trusted if any `802-3-ethernet` or an active `802-11-wireless` SSID in `trustedSsids`; untrusted if only other Wi-Fi; no-op when offline; idempotent `nmcli connection up|down`; log via `logger -t vpn-autoconnect`; never touch `autoconnect`; always exit 0; missing profile logs and exits. Verify: file evaluates and `nix fmt` leaves it clean.
- [x] 1.2 Import the module in `lib/mkNixos.nix`. Verify: `nix eval --raw .#nixosConfigurations.toms-thinkpad.config.vpn.autoConnect.enable` prints `false` before the host change.

## 2. Host

- [x] 2.1 In `hosts/toms-thinkpad/configuration.nix` set `vpn.autoConnect = { enable = true; trustedSsids = [ "ErmeLan" ]; };`. Verify: evaluating the host gives `enable = true`, `connectionName = "Home"`, `trustedSsids = [ "ErmeLan" ]`, and a non-ThinkPad host (or `hosts/template` logic) still has the option `false`.

## 3. Script behavior checks (no switch)

- [x] 3.1 Build the dispatcher script and run it with stubbed `nmcli` (a fake on PATH printing canned active-connection lists) for each scenario: wired only, wired + untrusted Wi-Fi, trusted SSID, untrusted SSID, nothing active, event from `wg0`/`docker0`, profile missing. Verify each scenario calls `nmcli connection up`, `down` or nothing exactly as the spec's scenarios state, and the script exits 0 every time.

## 4. Docs and checks

- [x] 4.1 Document `vpn.autoConnect`, the trust rules (wired always trusted), and the manual-override behavior (a GNOME toggle lasts until the next network up/down) in `README.md`. Verify: README section exists and matches the spec.
- [x] 4.2 Run `nix fmt` and `nix flake check`; build `.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel` (no switch). Verify: all succeed and `git status` shows only intended files (the unrelated `development.postgresql` hunk in `hosts/toms-thinkpad/configuration.nix` is pre-existing and uncommitted; do not stage it unasked).

## 5. Switch and verify (requires user approval)

- [x] 5.1 Show the full `git diff` with rationale, then ask before switching.
- [x] 5.2 After the approved switch, with the `Home` profile present: connect to a non-trusted Wi-Fi (or phone hotspot) and verify `nmcli -g GENERAL.STATE connection show Home` reports activated and `journalctl -t vpn-autoconnect` logs the decision; plug in the dock cable and verify the profile deactivates; with the VPN on at a trusted network, toggle it in the GNOME network menu and verify it stays as set until the next network event.

## Workflow follow-up

- Archive the change after review with `/opsx:archive`.
