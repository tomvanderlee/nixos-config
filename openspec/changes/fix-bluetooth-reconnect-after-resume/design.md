# Design

## Context

See proposal.md - Why. The Bluetooth stack on toms-thinkpad is stock NixOS: `hardware.bluetooth.enable` is true, `bluetoothd` 5.87 runs with default `main.conf`, and `modules/nixos/desktop.nix` already holds the Bluetooth-related WirePlumber AVRCP setting. NixOS wires `systemd-suspend.service` so that `post-resume.target` is reached after every resume (the log shows `Controller resume with wake event 0x0` from bluetoothd at resume).

## Goals / Non-Goals

**Goals:**
- Make a bonded LE mouse reconnect after resume with no user action beyond using it.
- Keep the workaround small, local to `desktop.nix`, and obviously removable.

**Non-Goals:**
- Anything in the proposal's Non-goals list.
- Detecting whether the mouse failed to reconnect (see Decision 3).

## Decisions

1. **Hook: a oneshot service wanted by `post-resume.target`.** `systemd.services.bluetooth-resume-restart = { wantedBy = [ "post-resume.target" ]; after = [ "post-resume.target" ]; serviceConfig.Type = "oneshot"; script = "systemctl try-restart bluetooth.service"; }`. Alternatives: a `powerManagement.resumeCommands` snippet (works, but is inline shell with no unit status or journal identity, which makes it harder to inspect and remove); a `systemd-sleep` hook script in `/usr/lib/systemd/system-sleep` (runs while sleep is still being finalized, and is also unit-less); a udev/D-Bus trigger on the failed connect (far more complex, and unproven).
2. **`try-restart`, not `restart`.** Avoids starting `bluetooth.service` on a host where it is stopped or disabled, which matches the "only when it was running" scenario.
3. **Unconditional restart on every resume.** Detecting "mouse did not reconnect" would need a timer and a polling loop for a bug whose cause is unknown. The cost of an unconditional restart is a brief drop of connected devices after resume, which the user accepts for now.
4. **Gate on `config.hardware.bluetooth.enable`.** Inside the existing `lib.mkIf config.desktop.enable` block, wrap the unit in `lib.mkIf config.hardware.bluetooth.enable`. This matches the spec's "Bluetooth enabled" condition and keeps headless/Bluetooth-less hosts clean. Placed in `desktop.nix` next to the other Bluetooth settings instead of `common.nix`, since the symptom concerns the desktop input devices and `common.nix` is unconditional.
5. **No ordering against `bluetooth.service`.** `try-restart` is idempotent, so a `Requires=`/`After=bluetooth.service` would only add a dependency that could pull the daemon in.

## Risks / Trade-offs

- [Restart drops AirPods audio and the keyboard for a few seconds after every resume] → Accepted; bonded Trusted devices reconnect on their own. Revisit with a conditional trigger if it proves annoying.
- [The workaround may not fix the mouse (hypothesis unconfirmed)] → The user confirms by running `sudo systemctl restart bluetooth` after a failed resume before applying this change. If that does not restore the mouse, do not apply it.
- [Race: restart runs before the controller has finished resuming] → `post-resume.target` is reached after `systemd-suspend.service` returns, so the controller has already resumed; a failure here would only leave the previous behavior.
- [Stale workaround stays in the repo forever] → The comment above the unit states the removal condition (upstream fix in the pinned nixpkgs and mouse reconnects without it).

## Migration Plan

Apply with `nixos-rebuild switch`. Rollback: remove the unit and switch again; nothing else is changed or persisted.
