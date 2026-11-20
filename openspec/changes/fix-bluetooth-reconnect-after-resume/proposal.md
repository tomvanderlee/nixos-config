# Proposal

## Why

On toms-thinkpad the Logitech MX Master 1 (an LE HID mouse) does not reconnect by itself after suspend/resume; the user has to re-pair or restart Bluetooth. After the resume at 2026-11-20 09:33 the Keychron keyboard reconnected on its own, but the mouse did not (GNOME logged `Failed to connect device "MX Master": Timeout was reached`, then `org.bluez.Error.InProgress`). The mouse is Paired, Bonded and Trusted, and `/etc/bluetooth/main.conf` already has `ControllerMode=dual` and `AutoEnable=true`, so this is not a configuration gap. Similar reports exist upstream for BlueZ 5.78 and later (Fedora MX Master 3 slow reconnect, fine on 5.76; Red Hat bug 2467973 on bluez 5.86; bluez/bluez#871 closed without a root cause). The host runs BlueZ 5.87. The working hypothesis is an upstream BlueZ/kernel reconnect regression; restarting `bluetooth.service` after resume is a workaround for it.

## What Changes

- Add a oneshot systemd unit in `modules/nixos/desktop.nix`, ordered after and wanted by `post-resume.target`, that runs `systemctl try-restart bluetooth.service` after every resume from suspend.
- Gate the unit on `config.hardware.bluetooth.enable` (inside the existing `desktop.enable` block), so hosts without Bluetooth get nothing.
- Comment the unit as a stopgap for an upstream bug, with the removal condition.
- **BREAKING**: none.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `gnome-desktop`: Bluetooth input devices recover after resume from suspend without manual intervention.

## Impact

- **Affected code**: `modules/nixos/desktop.nix`.
- **Not affected**: `modules/home/*`, `modules/nixos/common.nix`, `lib/*`, `flake.nix`, `hosts/*`, `lib/unfree-allowlist.nix`, headless hosts (`desktop.enable = false`).
- **Side effect**: restarting `bluetoothd` after each resume briefly drops all connected Bluetooth devices (AirPods, Keychron keyboard, mouse). Devices that are bonded and Trusted reconnect on their own afterwards, but audio in progress is interrupted. Because the unit runs after every resume, this also happens on resumes where the mouse would have reconnected anyway.
- **Assumptions** (recorded here, not needing clarification):
  - `systemctl restart bluetooth` restores the mouse's reconnection after a failed resume. The user will confirm this by hand the next time it fails and will apply this change only if it does. If the restart does not help, this change must not be applied.
  - Only suspend is covered. Reboot-time reconnection is a separate symptom and is not addressed here.
  - The restart runs for all Bluetooth devices, not just the mouse, because BlueZ has no per-device re-arm.

## Non-goals

- `hardware.bluetooth.settings` changes: no `FastConnectable` (BR/EDR only, irrelevant to an LE mouse), no `Privacy=device` (speculative, can worsen reconnects with identity-address peripherals), no `ControllerMode` change (already `dual`).
- Dual-boot link-key handling (no Windows on this machine).
- Changes to librepods or its resume-time BLE scan (suspected interference is untested).
- Pinning or downgrading BlueZ.
- Fixing the upstream bug. The unit should be removed once an upstream BlueZ/kernel fix lands in the pinned nixpkgs and the mouse reconnects after resume without it.
